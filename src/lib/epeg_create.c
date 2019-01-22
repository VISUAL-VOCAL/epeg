#include "Epeg.h"
#include "epeg_private.h"


/**
 * Create an Epeg_Image from raw pixel data.
 * @param w The width of the image in pixels.
 * @param h The height of the image in pixels.
 * @param stride The distance between each scanline in bytes. May be negative for bottom-up images.
 * @param colorspace The colorspace of the source pixels (must be EPEG_RGBA8 for now).
 * @param rawPixels Pointer to the raw pixel data to read.
 *
 * @return A handle to the new image or NULL on failure.
 */

EAPI Epeg_Image *
epeg_create(int w, int h, int stride, Epeg_Colorspace colorspace, const void* rawPixels)
{
    Epeg_Image *im = NULL;
    boolean success = FALSE;
    unsigned int y;
    const unsigned char* rawLine = rawPixels;

    if (colorspace != EPEG_RGB8)
    {
        goto done;
    }

    im = calloc(1, sizeof(Epeg_Image));
    if (!im)
    {
        goto done;
    }

    im->color_space = colorspace;
    im->in.w = im->out.w = w;
    im->in.h = im->out.h = h;

    im->in.jinfo.output_components = im->in.jinfo.out_color_components = 3;
    im->in.jinfo.out_color_space = JCS_RGB;

    im->in.jinfo.dct_method = JDCT_IFAST;

    im->pixels = malloc(im->in.w * im->in.h * im->in.jinfo.output_components);
    if (!im->pixels)
    {
        goto done;
    }

    im->lines = malloc(im->in.h * sizeof(char *));
    if (!im->lines)
    {
        goto done;
    }

    {
        unsigned int bytesToCopyPerLine = im->in.jinfo.output_components * im->in.w;
        for (y = 0; y < im->in.h; y++, rawLine += stride)
        {
            im->lines[y] = im->pixels + (y * bytesToCopyPerLine);
            memcpy(im->lines[y], rawLine, bytesToCopyPerLine);
        }
    }

    im->isRawImage = TRUE;

    success = TRUE;

done:
    if (!success)
    {
        if (im)
        {
            if (im->pixels)
            {
                free(im->pixels);
            }
            free(im);
            im = NULL;
        }
    }

    return im;
}
