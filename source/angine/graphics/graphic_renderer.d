module angine.graphics.graphic_renderer;

import angine.graphics;
import angine.maths;

class GraphicsRenderer {
    TextureBatch tBatch;

    this(Shader texture, Shader text) {
        tBatch = new TextureBatch(5000, texture, text);
        tBatch.transparency = true;
    }

    void drawTexture(SubTexture t, Vec translate = Vec(), Vec scale = Vec(1),
            Vec origin = Vec(), float rotate = 0) {
        tBatch.drawTexture(t, translate, scale, origin, rotate);
    }

    void drawTexture(Texture t, Vec translate = Vec(), Vec scale = Vec(1),
            Vec origin = Vec(), float rotate = 0) {
        tBatch.drawTexture(t, translate, scale, origin, rotate);
    }

    void drawString(Font font, string str, Color c, Vec translate = Vec(),
            Vec scale = Vec(1), Vec origin = Vec(), float rotate = 0) {
        tBatch.drawString(font, str, c, translate, scale, origin, rotate);
    }

    void drawString(Font font, Object obj, Color c, Vec translate = Vec(),
            Vec scale = Vec(1), Vec origin = Vec(), float rotate = 0) {
        tBatch.drawString(font, obj, c, translate, scale, origin, rotate);
    }
}