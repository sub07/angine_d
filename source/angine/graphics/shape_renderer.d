module angine.graphics.shape_renderer;

import angine.graphics;
import angine.maths;

import std.algorithm;

private const static nbComponent = 2;
private const static vertexSize = 2;
private const static colorSize = 4;
private const static floatPerVertex = vertexSize + colorSize;
private const static long[2] offsets = [0, vertexSize * cast(int) float.sizeof];
private const static strides = [
    floatPerVertex * cast(int) float.sizeof, floatPerVertex * cast(int) float.sizeof
];
private const static sizes = [vertexSize, colorSize];

class ShapeRenderer {
    Color color = Color.white;
    Vec[] vertices;
    Transform transform;
    Shader shapeShader;
    bool closed = true;

    this(Shader shapeShader) {
        this.shapeShader = shapeShader;
    }

    void addVertex(Vec v) {
        vertices ~= v;
    }

    void flush() {
        float[] data;
        data.length = vertices.length * floatPerVertex;

        foreach (i, ref Vec v; vertices) {
            const tVec = transform.apply(v);
            data[i * floatPerVertex] = tVec.x;
            data[i * floatPerVertex + 1] = tVec.y;

            data[i * floatPerVertex + 2] = color.r;
            data[i * floatPerVertex + 3] = color.g;
            data[i * floatPerVertex + 4] = color.b;
            data[i * floatPerVertex + 5] = color.a;
        }

        ArrayBuffer vbo = new ArrayBuffer(data.ptr, data.length * float.sizeof, BufferUsage.Static);
        Vao vao = new Vao(nbComponent, strides.ptr, offsets.ptr, sizes.ptr, vbo);

        shapeShader.use();
        vao.bind();

        draw(closed ? DrawPrimitive.LineLoop : DrawPrimitive.LineStrip, cast(int) data.length / 6);

        vertices.length = 0;

        destroy(vbo);
        destroy(vao);
        destroy(data);
    }
}
