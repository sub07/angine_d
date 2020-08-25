module angine.graphics.batch;

import angine.graphics.primitive;
import angine.graphics.color;
import angine.graphics.mesh;
import angine.maths.vec;
import angine.maths.rect;
import std.stdio;
import angine.graphics.subtexture;
import angine.graphics.font;

class TextureBatch {
    private bool transparency_enabled = false;
    private Mesh mesh;
    IndexBuffer ibo;
    Vao vao;
    bool drawing = false;
    Texture last = null;
    Shader textureShader;
    Shader textShader;
    Color color = Color.white;
    int counter = 0;
    BatchMode mode = BatchMode.Texture;

    private enum BatchMode {
        Texture,
        Text
    }

    private enum nbComponentVao = 3;
    private enum vertexSize = 2;
    private enum textureCoordSize = 2;
    private enum colorSize = 4;
    private enum nbFloatPerPoint = vertexSize + textureCoordSize + colorSize;

    this(int nbTextureMax, Shader textureShader, Shader textShader) {

        long[nbComponentVao] offsets = [
            0, vertexSize * float.sizeof, (vertexSize + textureCoordSize) * float.sizeof
        ];
        int[nbComponentVao] strides = [
            nbFloatPerPoint * cast(int) float.sizeof,
            nbFloatPerPoint * cast(int) float.sizeof,
            nbFloatPerPoint * cast(int) float.sizeof
        ];
        int[nbComponentVao] sizes = [vertexSize, textureCoordSize, colorSize];

        this.textureShader = textureShader;
        this.textShader = textShader;
        mesh = new Mesh(nbTextureMax * nbFloatPerPoint * 4);
        vao = new Vao(nbComponentVao, strides.ptr, offsets.ptr, sizes.ptr, mesh.vbo);
        uint[] indices;
        indices.length = nbTextureMax * 6;
        int index = 0;
        for (int i = 0; i < nbTextureMax * 4; i += 4) {
            indices[index++] = i;
            indices[index++] = i + 1;
            indices[index++] = i + 2;
            indices[index++] = i + 2;
            indices[index++] = i + 1;
            indices[index++] = i + 3;
        }
        ibo = new IndexBuffer(indices.ptr,
                indices.length * cast(int) float.sizeof, BufferUsage.Static);
    }

    private void flush() {
        if (counter == 0 || last is null)
            return;
        last.bindTextureUnit(0);
        if (mode == BatchMode.Texture) {
            textureShader.use();
        } else {
            textShader.use();
        }
        vao.bind();
        ibo.bind();
        mesh.submitToGpu();
        if (transparency_enabled) {
            Gl.context.enableAlphaBlending();
        } else {
            Gl.context.disableAlphaBlending();
        }
        Gl.context.drawIndexed(DrawPrimitive.Triangles, counter * 6);
        counter = 0;
        mesh.clear();
    }

    void begin() {
        drawing = true;
    }

    void end() {
        flush();
        drawing = false;
    }

    @property void transparency(bool t) {
        if (drawing && transparency_enabled != t) {
            flush();
        }
        transparency_enabled = t;
    }

    @property bool transparency() {
        return transparency_enabled;
    }

    private void tex(Texture t, Vec translate = Vec(), Vec scale = Vec(1),
            Vec origin = Vec(), float rotate = 0) {
        tex(t, translate.x, translate.y, scale.x, scale.y, origin.x, origin.y,
                rotate, 0, 0, t.width, t.height);
    }

    private void tex(Texture t, Vec translate = Vec(), Vec scale = Vec(1),
            Vec origin = Vec(), float rotate = 0, Rect subTexture = Rect()) {
        tex(t, translate.x, translate.y, scale.x, scale.y, origin.x, origin.y,
                rotate, subTexture.x, subTexture.y, subTexture.w, subTexture.h);
    }

    void drawTexture(SubTexture t, Vec translate = Vec(), Vec scale = Vec(1),
            Vec origin = Vec(), float rotate = 0) {
        if (!drawing)
            return;
        if (mode != BatchMode.Texture) {
            flush();
            mode = BatchMode.Texture;
        }
        tex(t.associatedTexture, translate, scale, origin, rotate, t.region);
    }

    void drawTexture(Texture t, Vec translate = Vec(), Vec scale = Vec(1),
            Vec origin = Vec(), float rotate = 0) {
        if (!drawing)
            return;
        if (mode != BatchMode.Texture) {
            flush();
            mode = BatchMode.Texture;
        }
        tex(t, translate, scale, origin, rotate);
    }

    Vec drawString(Font font, string str, Color c, Vec translate = Vec(),
            Vec scale = Vec(1), Vec origin = Vec(), float rotate = 0) {
        immutable old = color;
        color = c;
        immutable s = drawString(font, str, translate, scale, origin, rotate);
        color = old;
        return s;
    }

    Vec drawString(Font font, Object obj, Color c, Vec translate = Vec(),
            Vec scale = Vec(1), Vec origin = Vec(), float rotate = 0) {
        immutable old = color;
        color = c;
        immutable s = drawString(font, obj.toString(), translate, scale, origin, rotate);
        color = old;
        return s;
    }

    Vec drawString(Font font, Object obj, Vec translate = Vec(), Vec scale = Vec(1),
            Vec origin = Vec(), float rotate = 0) {
        return drawString(font, obj.toString(), translate, scale, origin, rotate);
    }

    Vec drawString(Font font, string str, Vec translate = Vec(), Vec scale = Vec(1),
            Vec origin = Vec(), float rotate = 0) {
        if (!drawing)
            return Vec();

        if (mode != BatchMode.Text) {
            flush();
            mode = BatchMode.Text;
        }

        immutable entry = font.stringSizeBottom(str);
        float bottom = entry.bottom;
        immutable size = entry.size; 
        for (int i = 0; i < str.length; i++) {
            Glyph g = font.glyphs[str[i]];
            immutable o = origin - Vec(g.offset.x, size.h - g.offset.y + bottom);
            tex(font.texture, translate, scale, o, rotate, g.subTexture);
            origin -= g.advance;
        }

        return size;
    }

    private void tex(Texture t, float translateX, float translateY, float scaleX, float scaleY,
            float originX, float originY, float rotate, float subTexX,
            float subTexY, float subTexW, float subTexH) {
        if (t is null)
            return;
        if (t != last) {
            flush();
            last = t;
        }

        auto p1 = Vec(0, 0);
        auto p2 = Vec(subTexW, 0);
        auto p3 = Vec(0, subTexH);
        auto p4 = Vec(subTexW, subTexH);

        immutable pos = Vec(translateX, translateY);
        immutable origin = Vec(originX, originY);
        immutable scale = Vec(scaleX, scaleY);

        p1 -= origin;
        p2 -= origin;
        p3 -= origin;
        p4 -= origin;

        p1 *= scale;
        p2 *= scale;
        p3 *= scale;
        p4 *= scale;

        p1.rotate(rotate);
        p2.rotate(rotate);
        p3.rotate(rotate);
        p4.rotate(rotate);

        p1 += pos;
        p2 += pos;
        p3 += pos;
        p4 += pos;

        float[4 * nbFloatPerPoint] v;

        immutable startU = subTexX / t.width;
        immutable endU = (subTexX + subTexW) / t.width;
        immutable startV = subTexY / t.height;
        immutable endV = (subTexY + subTexH) / t.height;

        v[0] = p1.x;
        v[1] = p1.y;
        v[2] = startU;
        v[3] = startV;
        v[4] = color.r;
        v[5] = color.g;
        v[6] = color.b;
        v[7] = color.a;

        v[8] = p2.x;
        v[9] = p2.y;
        v[10] = endU;
        v[11] = startV;
        v[12] = color.r;
        v[13] = color.g;
        v[14] = color.b;
        v[15] = color.a;

        v[16] = p3.x;
        v[17] = p3.y;
        v[18] = startU;
        v[19] = endV;
        v[20] = color.r;
        v[21] = color.g;
        v[22] = color.b;
        v[23] = color.a;

        v[24] = p4.x;
        v[25] = p4.y;
        v[26] = endU;
        v[27] = endV;
        v[28] = color.r;
        v[29] = color.g;
        v[30] = color.b;
        v[31] = color.a;

        mesh.add(v);
        counter++;
    }
}
