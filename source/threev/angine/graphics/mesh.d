module threev.angine.graphics.mesh;


import threev.angine.graphics.primitive;
import core.stdc.string;
import std.format;
import std.stdio;

unittest {
    import bindbc.glfw : loadGLFW, glfwInit, glfwCreateWindow,
        glfwMakeContextCurrent, glfwTerminate;

    loadGLFW();
    glfwInit();
    auto w = glfwCreateWindow(800, 600, "t", null, null);
    glfwMakeContextCurrent(w);
    loadGl();
    auto m = new Mesh(500);
    import std.stdio : writeln;

    assert(m.size == 0);
    assert(m.data.length == 500);
    float[50] v = 5;
    m.add(v);
    assert(m.size == 50);
    assert(m.data.length == 500);
    glfwTerminate();
}

class Mesh {
    ArrayBuffer vbo;
    float[] data;
    int size;
    this(int capacity) {
        data.length = capacity;
        size = 0;
        vbo = new ArrayBuffer(null, capacity * float.sizeof, BufferUsage.Dynamic);
    }

    void submitToGpu() {
        vbo.uploadData(data.ptr, size * cast(int) float.sizeof, 0);
    }

    void clear() {
        size = 0;
    }

    void add(float[] data) {
        if (size + data.length > this.data.length)
            throw new Exception(format("mesh overflow %d(mesh current size) + %d(input size) >= %d(mesh capacity)",
                    size, data.length, this.data.length));
        memcpy(this.data.ptr + size, data.ptr, data.length * float.sizeof);
        size += data.length;
    }
}
