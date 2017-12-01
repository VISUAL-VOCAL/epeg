#include "Epeg.h"
#include "epeg_private.h"

// Added by Visual Vocal to read the XMP packet, if any, in the file.
// Returns NULL if no XMP packet was found.
// XMP specification: http://www.adobe.com/devnet/xmp.html 
EAPI const void *
epeg_xmp_packet_get(Epeg_Image *im, int *size)
{
    struct jpeg_marker_struct *m;
    for (m = im->in.jinfo.marker_list; m; m = m->next)
    {
        if (m->marker == (JPEG_APP0 + 1))
        {
            // Look for the XMP tag
            const char xmpTag[] = "http://ns.adobe.com/xap/1.0/";
            const int xmpPacketOffset = 33; // as per the XMP spec

            if (0 == strncmp((const char*)m->data, xmpTag, MIN(m->data_length, sizeof(xmpTag))))
            {
                // this is an XMP packet
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
