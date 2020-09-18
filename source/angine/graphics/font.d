module angine.graphics.font;

import angine.graphics;
import angine.maths;
import angine.physics.shape;
import std;
import bindbc.freetype;

private enum nbCharToLoad = 590;

struct Glyph {
    Rect subTexture;
    Vec advance;
    Vec offset;
}

class Font {
    Texture texture;
    Glyph[nbCharToLoad] glyphs;
    Tuple!(Vec, "size", float, "bottom")[string] stringSizeCache;

    this(string path, int fontSize) {
        if (loadFreeType() == FTSupport.noLibrary)
            throw new Exception("Cannot load freetype (check dll)");
        FT_Library lib;
        if (FT_Init_FreeType(&lib))
            throw new Exception("Cannot init freetype");
        FT_Face face;
        if (FT_New_Face(lib, toStringz(path), 0, &face))
            throw new Exception("Cannot load font from " ~ path);
        FT_Set_Pixel_Sizes(face, 0, fontSize);

        uint totalWidth = 0;
        uint maxHeight = 0;

        for (int c = 0; c < nbCharToLoad; c++) {
            FT_Load_Char(face, c, FT_LOAD_RENDER);
            immutable h = face.glyph.bitmap.rows;
            totalWidth += face.glyph.bitmap.width;
            if (maxHeight < h)
                maxHeight = h;
        }

        auto fontAtlas = new Image(totalWidth, maxHeight, PixelFormat.R8);

        int x = 0;
        for (int c = 0; c < nbCharToLoad; c++) {
            FT_Load_Char(face, c, FT_LOAD_RENDER);
            immutable w = face.glyph.bitmap.width;
            immutable h = face.glyph.bitmap.rows;
            const buffer = face.glyph.bitmap.buffer;
            glyphs[c] = Glyph(new Rect(x, 0.0f, w, h), Vec(face.glyph.advance.x / 64,
                    face.glyph.advance.y / 64), Vec(face.glyph.bitmap_left,
                    face.glyph.bitmap_top));
            if (buffer !is null) {
                auto i = new Image(w, h, PixelFormat.R8);
                i.data = buffer[0 .. (w * h)].dup;
                fontAtlas.drawImage(i, x, 0);
                destroy(i);
            }
            x += w;
            stringSizeCache[""] = tuple(Vec(), 0);
        }

        FT_Done_Face(face);
        FT_Done_Library(lib);

        texture = new Texture(TextureFilter.Linear, fontAtlas.width,
                fontAtlas.height, fontAtlas.format, fontAtlas.data.ptr);

        destroy(fontAtlas);
        unloadFreeType();
    }

    public Vec stringSize(string s) {
        return stringSizeBottom(s).size;
    }

    public Tuple!(Vec, "size", float, "bottom") stringSizeBottom(string s) {
        auto cached = s in stringSizeCache;
        if (cached !is null) {
            return *cached;
        }

        float bottom = 0;
        float top = 0;
        float w = 0;
        for (int i = 0; i < s.length; i++) {
            auto g = glyphs[s[i]];
            w += g.advance.x;
            if (g.offset.y > top)
                top = g.offset.y;
            if (g.offset.y - texture.height < bottom)
                bottom = g.offset.y - texture.height;
        }
        auto res = Vec(w, top - bottom);
        stringSizeCache[s] = tuple(res, bottom);
        return stringSizeCache[s];
    }
}
