#include <stdio.h>
#include "ximage.h"

int LoadImage(CxImage& image, const char* img_file)
{
  DWORD format = CXIMAGE_FORMAT_UNKNOWN;
  int len = strlen(img_file);
  if (len<5)
    return 0;
  const char* suffix = img_file + len - 4;

  if (strcmp(suffix, ".jpg") == 0)
    format = CXIMAGE_FORMAT_JPG;
  else if (strcmp(suffix, ".png") == 0)
    format = CXIMAGE_FORMAT_PNG;

  if (format != CXIMAGE_FORMAT_UNKNOWN)
    image.Load(img_file, format);

  return len - 4;
}

int main(int argc, char** argv)
{
  int i;
  for (i = 1; i < argc; i++)
  {
    CxImage  image;

    // Load image.
    int base_len = LoadImage(image, argv[i]);
    if (!image.IsValid())
    {
      printf("Can't open image file %s.\n", argv[i]);
      continue;
    }

    if (image.GetBpp() < 24)
      image.IncreaseBpp(24);

    CxImage image2(image);

    // Encode to jpg
    image.SetJpegQuality(99);
    BYTE*  buffer = 0;
    long size = 0;
    image.Encode(buffer, size, CXIMAGE_FORMAT_JPG);
    image.Destroy();

    image2.RotateRight();

    // Decode jpg
    image.Decode(buffer, size, CXIMAGE_FORMAT_JPG);
    free(buffer);
    buffer = 0;
    size = 0;

    image.Mirror();

    // Encode png
    image.Encode(buffer, size, CXIMAGE_FORMAT_PNG);
    image.Destroy();

    int width2 = image2.GetWidth() / 2;
    int height2 = image2.GetHeight() / 2;
    image2.Resample(width2, height2, 0);

    // Decode png
    image.Decode(buffer, size, CXIMAGE_FORMAT_PNG);
    free(buffer);
    buffer = 0;
    size = 0;

    image2.GrayScale();

    // Encode bmp
    image.Encode(buffer, size, CXIMAGE_FORMAT_BMP);
    image.Destroy();

    // Decode bmp
    image.Decode(buffer, size, CXIMAGE_FORMAT_BMP);
    free(buffer);
    buffer = 0;
    size = 0;

    // Encode tif
    image.Encode(buffer, size, CXIMAGE_FORMAT_TIF);
    image.Destroy();

    // Decode tif
    image.Decode(buffer, size, CXIMAGE_FORMAT_TIF);
    free(buffer);
    buffer = 0;
    size = 0;

    int width = image.GetWidth();
    int height = image.GetHeight();
    width2 = image2.GetWidth();
    height2 = image2.GetHeight();
    image.MixFrom(image2, 127, (width - width2)/2, (height - height2)/2);
    image2.Destroy();

    // Encode gif
    image.DecreaseBpp(8, false);
    image.Encode(buffer, size, CXIMAGE_FORMAT_GIF);
    image.Destroy();

    // Decode gif
    image.Decode(buffer, size, CXIMAGE_FORMAT_GIF);
    free(buffer);
    buffer = 0;
    size = 0;

    height = height * 400 / width;
    width = 400;
    image.Resample(width, height, 0);

    // Output
    char output_file[100];
    strncpy(output_file, argv[i], base_len);
    strcpy(output_file + base_len, ".gif");
    image.Save(output_file, CXIMAGE_FORMAT_GIF);
  }
  return 0;
}
