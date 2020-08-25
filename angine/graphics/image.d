module angine.graphics.image;

import imaged;
import angine.graphics.color;

enum PixelFormat {
    R8 = 1,
    RG8 = 2,
    RGB8 = 3,
    RGBA8 = 4
}

class Image {
    ubyte[] data;
    int width;
    int height;
    PixelFormat format;
    this(string path) {
        IMGError e;
        imaged.Image i = load(path, e);
        data = i.pixels.dup;
        width = i.width;
        height = i.height;
        switch (i.pixelFormat) {
        case Px.R8G8B8:
            format = PixelFormat.RGB8;
            break;
        case Px.R8G8B8A8:
            format = PixelFormat.RGBA8;
            break;
        default:
            throw new Exception("Unsupported image format" ~ i.pixelFormat.stringof ~ " " ~ path);
        }
        destroy(i);
    }

    this(int width, int height, PixelFormat format) {
        data.length = width * height * format;
        this.width = width;
        this.height = height;
        this.format = format;
    }

    void clear(Color color) {
        for (int i = 0; i < width * height * format; i += format) {
            for (int c = 0; c < format; c++) {
                data[i + c] = cast(ubyte)(color[c] * 255);
            }
        }
    }

    void drawImage(Image src, int startX, int startY) {
        assert(format == src.format);
        immutable sw = src.width;
        immutable sh = src.height;

        for (int x = startX; x < startX + sw; x++) {
            for (int y = startY; y < startY + sh; y++) {
                if (x < 0 || x >= width || y < 0 || y >= height)
                    continue;
                int destI = (y * width + x) * format;
                int srcI = ((y - startY) * sw + (x - startX)) * src.format;
                for (int c = 0; c < format; c++) {
                    data[destI + c] = src.data[srcI + c];
                }
            }
        }
    }
}
