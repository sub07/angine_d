module angine.graphics.graphic_renderer;

import angine.graphics;
import angine.maths;

class GraphicsRenderer {
    TextureBatch tBatch;
    ShapeRenderer shapeRenderer;

    this(Shader texture, Shader text, Shader shape) {
        tBatch = new TextureBatch(5000, texture, text);
        shapeRenderer = new ShapeRenderer(shape);
        tBatch.transparency = true;
    }

    void rect(float x, float y, float w, float h) {
        shapeRenderer.addVertex(Vec(x, y));
        shapeRenderer.addVertex(Vec(x + w, y));
        shapeRenderer.addVertex(Vec(x + w, y + h));
        shapeRenderer.addVertex(Vec(x, y + h));

        shapeRenderer.flush();
    }

    void setShapeColor(Color c) {
        shapeRenderer.color = c;
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
