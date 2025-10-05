#include "fileUtils.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION

void FileHandler::writePNG(uint8_t* buf, int width, int height, const char* fn)
{
    if (!buf) { fprintf(stderr, "Null buffer\n"); return; }
    // buf already contains width*height*3 bytes: R,G,B,R,G,B,...
    if (stbi_write_png(fn, width, height, 3, buf, width * 3) == 0) {
        fprintf(stderr, "Failed to write PNG file %s\n", fn);
        exit(1);
    }
    printf("Wrote image file %s\n", fn);
}