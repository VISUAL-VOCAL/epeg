#include "Epeg.h"
#include "epeg_private.h"

#if defined(_WINDOWS) && defined(_DEBUG)
void __declspec(dllimport) OutputDebugStringA(const char *s);

#include <stdarg.h>
void DebugPrintfA(const char *format, ...)
{
    va_list args;
    va_start(args, format);
    int nBuf;
    char szBuffer[512]; /* get rid of this hard-coded buffer */
    nBuf = _vsnprintf(szBuffer, 511, format, args);
    OutputDebugStringA(szBuffer);
    va_end(args);
}
#define DebugPrintf(format, ...) DebugPrintfA(format, __VA_ARGS__)
#else
#define DebugPrintf(format, ...)
#endif

/**
* Read the standard XMP packet, if any, in the file.
* @param im A handle to an opened Epeg image.
* @param size Returns the size of the packet in bytes.
*
* Returns pointer to packet or NULL if no standard XMP packet was found.
* Note: XMP specification: http://www.adobe.com/devnet/xmp.html 
*/
EAPI const void *
epeg_xmp_packet_get(Epeg_Image *im, int *size)
{
    struct jpeg_marker_struct *m;
    for (m = im->in.jinfo.marker_list; m; m = m->next)
    {
        if (m->marker == (JPEG_APP0 + 1))
        {
            /* Look for the XMP tag */
            const char xmpTag[] = "http://ns.adobe.com/xap/1.0/";

            if (0 == strncmp((const char*)m->data, xmpTag, MIN(m->data_length, sizeof(xmpTag))))
            {
                /* this is an XMP packet */
                if (size != NULL)
                {
                    *size = m->data_length - sizeof(xmpTag);
                }

                return (const void*)((const char*)m->data + sizeof(xmpTag));
            }
        }
    }

    if (size != NULL)
    {
        *size = 0;
    }
    return NULL;
}

/**
* Read the chunks of the extended XMP packet, if any, in the file. Call repeatedly to return the sequence of chunks.
* @param im A handle to an opened Epeg image.
* @param guid A 32 character GUID string identifying the extended packet to read.
* @param chunkSize Returns the size of the current chunk in bytes.
* @param chunkOffset Returns the offset in bytes of the current chunk within the packet.
* @param fullPacketSize Return the size of the full packet in bytes.
* @param marker The next marker to read or NULL to start from the beginning. Returns the next marker.
*
* Returns pointer to chunk or NULL if no more matching chunks were found.
* Note: XMP specification: http://www.adobe.com/devnet/xmp.html
*/
EAPI const void *
epeg_xmp_ext_packet_chunk_get(
    Epeg_Image *im,
    const char *guid,
    unsigned int *chunkSize,
    unsigned int *chunkOffset,
    unsigned int *fullPacketSize,
    void **marker)
{
    struct jpeg_marker_struct *m = (marker != NULL && *marker != NULL) ? (jpeg_saved_marker_ptr)*marker : im->in.jinfo.marker_list;
    DebugPrintf("epeg_xmp_ext_packet_chunk_get: im=%p, guid=%s, marker=%p, m=%p\n", im, guid, marker, m);
    for (; m; m = m->next)
    {
        DebugPrintf("epeg_xmp_ext_packet_chunk_get: marker\n");

        if (m->marker == (JPEG_APP0 + 1))
        {
            DebugPrintf("epeg_xmp_ext_packet_chunk_get: JPEG_APP1\n");
            /* Look for the extended XMP tag */
            const char xmpTag[] = "http://ns.adobe.com/xmp/extension/";

            const unsigned char* data = m->data;
            unsigned int dataLengthRemaining = m->data_length;
            if (dataLengthRemaining >= sizeof(xmpTag) &&
                0 == strncmp((const char*)data, xmpTag, sizeof(xmpTag)))
            {
                DebugPrintf("epeg_xmp_ext_packet_chunk_get: found ext XMP tag\n");
                /* this is an extended XMP packet */
                data += sizeof(xmpTag);
                dataLengthRemaining -= sizeof(xmpTag);

                /* look for a matching GUID string */
                unsigned int guidLen = 32;
                if (dataLengthRemaining >= guidLen &&
                    0 == _strnicmp((const char*)data, guid, guidLen))
                {
                    DebugPrintf("epeg_xmp_ext_packet_chunk_get: found guid\n");

                    /* guid matches */
                    data += guidLen;
                    dataLengthRemaining -= guidLen;

                    if (dataLengthRemaining >= 8)
                    {
                        /* read the big-endian fullPacketSize */
                        if (fullPacketSize != NULL)
                        {
                            *fullPacketSize =
                                (*(data + 0) << 24) |
                                (*(data + 1) << 16) |
                                (*(data + 2) <<  8) |
                                (*(data + 3) <<  0);
                        }
                        data += 4;
                        dataLengthRemaining -= 4;

                        /* read the big-endian chunkOffset */
                        if (chunkOffset != NULL)
                        {
                            *chunkOffset = 
                                (*(data + 0) << 24) |
                                (*(data + 1) << 16) |
                                (*(data + 2) <<  8) |
                                (*(data + 3) <<  0);
                        }
                        data += 4;
                        dataLengthRemaining -= 4;

                        /* set the chunk size */
                        if (chunkSize != NULL)
                        {
                            *chunkSize = dataLengthRemaining;
                        }

                        /* return the next marker for the next call */
                        if (marker != NULL)
                        {
                            *marker = m->next;
                        }

                        return (dataLengthRemaining > 0) ? data : NULL;
                    }
                }
            }
        }
    }

    /* no more chunks found */
    if (fullPacketSize != NULL)
    {
        *fullPacketSize = 0;
    }
    if (chunkOffset != NULL)
    {
        *chunkOffset = 0;
    }
    if (chunkSize != NULL)
    {
        *chunkSize = 0;
    }
    if (marker != NULL)
    {
        *marker = NULL;
    }
    return NULL;
}

/**
* Read the entire extended XMP packet, if any, in the file. Must call epeg_xmp_ext_packet_free to release memory!
* @param im A handle to an opened Epeg image.
* @param guid A 32 character GUID string identifying the extended packet to read.
* @param maxSize The maximum allowable size of the packet to read.
* @param size Returns the size of the packet in bytes.
*
* Returns pointer to packet or NULL if no matching packet was found or if packet size exceeds maxSize.
* Must call epeg_xmp_ext_packet_free to release memory!
* Note: XMP specification: http://www.adobe.com/devnet/xmp.html
*/
EAPI const void *
epeg_xmp_ext_packet_get(
    Epeg_Image *im,
    const char *guid,
    unsigned int maxSize,
    unsigned int *size)
{
    boolean fail = FALSE;
    unsigned int packetSize = 0;
    unsigned char *packet = NULL;
    void *marker = NULL;
    do
    {
        unsigned int chunkSize;
        unsigned int chunkOffset;
        unsigned int fullPacketSize;
        const void *chunk = epeg_xmp_ext_packet_chunk_get(
            im,
            guid,
            &chunkSize,
            &chunkOffset,
            &fullPacketSize,
            &marker);

        if (chunk == NULL)
        {
            DebugPrintf("chunk is NULL\n");
            fail = TRUE;
            break;
        }

        if (packet == NULL)
        {
            packetSize = fullPacketSize;
            if (packetSize > maxSize)
            {
                DebugPrintf("packetSize is too big\n");
                fail = TRUE;
                break;
            }

            packet = (unsigned char *)malloc(packetSize);
            if (packet == NULL)
            {
                DebugPrintf("malloc failed\n");
                fail = TRUE;
                break;
            }
        }

        if (packetSize != fullPacketSize)
        {
            DebugPrintf("packet size changed from chunk-to-chunk\n");
            fail = TRUE;
            break;
        }

        if (chunkOffset + chunkSize > packetSize)
        {
            DebugPrintf("chunk offset out of bounds\n");
            fail = TRUE;
            break;
        }

        memcpy(packet + chunkOffset, chunk, chunkSize);

    } while (marker != NULL);

    if (size != NULL)
    {
        *size = packetSize;
    }

    if (fail)
    {
        if (packet != NULL)
        {
            free(packet);
            packet = NULL;
        }
    }

    return packet;
}

EAPI void
epeg_xmp_ext_packet_free(
    const void *packet)
{
    free((void*)packet);
}