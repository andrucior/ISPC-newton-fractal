#pragma once

#include <iostream>
#include "stb_image_write.h"

static class FileHandler
{
public:
	static void writePNG(uint8_t* buf, int width, int height, const char* fn);
};