module threev.angine.graphics.primitive;

import std.string;
import glad.gl.loader;
import glad.gl.funcs;
import glad.gl.enums;
import glad.gl.types;
import core.stdc.stdlib : malloc, free;

enum DrawPrimitive {
    TriangleStrip = GL_TRIANGLE_STRIP,
    LineStrip = GL_LINE_STRIP,
    Lines = GL_LINES,
    Triangles = GL_TRIANGLES
}

private bool alpha_blending_enabled = false;

void setViewport(int x, int y, int w, int h) {
    glViewport(x, y, w, h);
}

void setViewport(int w, int h) {
    setViewport(0, 0, w, h);
}

void clearScreen() {
    glClear(GL_COLOR_BUFFER_BIT);
}

void setClearColor(float r, float g, float b, float a) {
    glClearColor(r, g, b, a);
}

void draw(DrawPrimitive primitive, int nbVertices) {
    glDrawArrays(primitive, 0, nbVertices);
}

void drawIndexed(DrawPrimitive primitive, int nbIndices) {
    glDrawElements(primitive, nbIndices, GL_UNSIGNED_INT, null);
}

void enableAlphaBlending() {
    if (!alpha_blending_enabled) {
        alpha_blending_enabled = true;
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    }
}

void disableAlphaBlending() {
    if (alpha_blending_enabled) {
        alpha_blending_enabled = false;
        glDisable(GL_BLEND);
    }
}

void loadGl() {
    gladLoadGL();
}

void loadGlFromLoader(void* delegate(const char* name) loader) {
    gladLoadGL(loader);
}

string glVersion() {
    return fromStringz(cast(const char*) glGetString(GL_VERSION)).idup;
}

enum BufferUsage {
    Dynamic = GL_DYNAMIC_DRAW,
    Static = GL_STATIC_DRAW
}

abstract class GpuBuffer {
    immutable uint handle;

    this(const void* data, ulong byteSize, BufferUsage usage) {
        uint h;
        glCreateBuffers(1, &h);
        handle = h;
        glNamedBufferData(handle, byteSize, data, usage);
    }

    ~this() {
        glDeleteBuffers(1, &handle);
    }

    void uploadData(void* data, int size, long offset) {
        glNamedBufferSubData(handle, offset, size, data);
    }

    void bind();
}

class IndexBuffer : GpuBuffer {
    private static uint bound = 0;
    this(const uint* data, ulong byteSize, BufferUsage usage) {
        super(data, byteSize, usage);
    }

    override void bind() {
        if (handle != bound) {
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, handle);
            bound = handle;
        }
    }
}

class ArrayBuffer : GpuBuffer {
    private static uint bound = 0;

    this(const float* data, ulong byteSize, BufferUsage usage) {
        super(data, byteSize, usage);
    }

    override void bind() {
        if (handle != bound) {
            glBindBuffer(GL_ARRAY_BUFFER, handle);
            bound = handle;
        }
    }
}

class Vao {
    private static uint bound = 0;
    immutable uint handle;
    this(int n, const int* strides, const long* offsets, const int* sizes, ArrayBuffer vbo) {
        uint h;
        glCreateVertexArrays(1, &h);
        handle = h;
        for (int i = 0; i < n; i++) {
            glEnableVertexArrayAttrib(handle, i);
            glVertexArrayVertexBuffer(handle, i, vbo.handle, offsets[i], strides[i]);
            glVertexArrayAttribFormat(handle, i, sizes[i], GL_FLOAT, GL_FALSE, 0);
            glVertexArrayAttribBinding(handle, i, i);
        }
    }

    ~this() {
        glDeleteVertexArrays(1, &handle);
    }

    void bind() {
        if (handle != bound) {
            bound = handle;
            glBindVertexArray(handle);
        }
    }
}

enum TextureFilter {
    Nearest = GL_NEAREST,
    Linear = GL_LINEAR
}

class Texture {
    immutable uint handle;
    immutable int width;
    immutable int height;
    this(TextureFilter filter, int width, int height, int nb_channel, const void* data) {
        uint h;
        glPixelStorei(GL_UNPACK_ALIGNMENT, alignmentFromNbChannel(nb_channel));
        glCreateTextures(GL_TEXTURE_2D, 1, &h);
        handle = h;
        glTextureParameteri(handle, GL_TEXTURE_MIN_FILTER, filter);
        glTextureParameteri(handle, GL_TEXTURE_MAG_FILTER, filter);
        glTextureStorage2D(handle, 1, internalStorageFromNbChannel(nb_channel), width, height);
        glTextureSubImage2D(handle, 0, 0, 0, width, height,
                externalStorageFromNbChannel(nb_channel), GL_UNSIGNED_BYTE, data);
        this.width = width;
        this.height = height;
    }

    ~this() {
        glDeleteTextures(1, &handle);
    }

    void bindTextureUnit(uint textureUnit) {
        glBindTextureUnit(textureUnit, handle);
    }

    override bool opEquals(Object other) const {
        return toHash() == other.toHash();
    }

    override size_t toHash() const {
        return handle;
    }

    private static GLenum internalStorageFromNbChannel(int nbChannel) {
        switch (nbChannel) {
        case 1:
            return GL_R8;
        case 2:
            return GL_RG8;
        case 3:
            return GL_RGB8;
        default:
            return GL_RGBA8;
        }
    }

    private static GLenum externalStorageFromNbChannel(int nbChannel) {
        switch (nbChannel) {
        case 1:
            return GL_RED;
        case 2:
            return GL_RG;
        case 3:
            return GL_RGB;
        default:
            return GL_RGBA;
        }
    }

    private static int alignmentFromNbChannel(int nbChannel) {
        switch (nbChannel) {
        case 1:
            return 1;
        case 2:
            return 2;
        case 3:
            return 1;
        case 4:
            return 4;
        default:
            return GL_RGBA;
        }
    }
}

class Shader {
    private static used = 0;

    immutable uint handle;
    string vertexLog = "";
    string fragmentLog = "";
    bool vertexOk = true;
    bool fragmentOk = true;
    bool ok;

    this(string vertexSources, string fragmentSources) {
        immutable vs = glCreateShader(GL_VERTEX_SHADER);
        immutable vSources = toStringz(vertexSources);
        glShaderSource(vs, 1, &vSources, null);
        glCompileShader(vs);
        check(ShaderType.Vertex, vs);

        immutable fs = glCreateShader(GL_FRAGMENT_SHADER);
        immutable fSources = toStringz(fragmentSources);
        glShaderSource(fs, 1, &fSources, null);
        glCompileShader(fs);
        check(ShaderType.Fragment, fs);

        ok = vertexOk && fragmentOk;

        handle = glCreateProgram();
        glAttachShader(handle, vs);
        glAttachShader(handle, fs);
        glLinkProgram(handle);
        glDeleteShader(vs);
        glDeleteShader(fs);

        import std.stdio : writeln;

        if (!ok) {
            if (!vertexOk) {
                writeln("Vertex shader compilation failed: \n", vertexLog);
            }
            if (!fragmentOk) {
                writeln("Fragment shader compilation failed: \n", fragmentLog);
            }
        }
    }

    ~this() {
        glDeleteProgram(handle);
    }

    void use() {
        if (handle != used) {
            used = handle;
            glUseProgram(handle);
        }
    }

    void sendInt(const char* name, int value) {
        use();
        immutable location = glGetUniformLocation(handle, name);
        glUniform1i(location, value);
    }

    void sendFloat(const char* name, float value) {
        use();
        immutable location = glGetUniformLocation(handle, name);
        glUniform1f(location, value);
    }

    void sendMat3(const char* name, const float* mat) {
        use();
        immutable location = glGetUniformLocation(handle, name);
        glUniformMatrix3fv(location, 1, GL_FALSE, mat);
    }

    void sendVec2(const char* name, float x, float y) {
        use();
        immutable location = glGetUniformLocation(handle, name);
        glUniform2f(location, x, y);
    }

    void sendVec4(const char* name, float x, float y, float z, float w) {
        use();
        immutable location = glGetUniformLocation(handle, name);
        glUniform4f(location, x, y, z, w);
    }

    private enum ShaderType {
        Vertex,
        Fragment
    }

    private bool check(ShaderType type, uint shader) {
        int compileStatus;
        glGetShaderiv(shader, GL_COMPILE_STATUS, &compileStatus);
        if (compileStatus == GL_FALSE) {
            int len;
            glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &len);
            char* buffer = cast(char*) malloc(len + 1);
            glGetShaderInfoLog(shader, len + 1, null, buffer);
            const char[] charArray = fromStringz(buffer);
            if (type == ShaderType.Vertex) {
                vertexOk = false;
                vertexLog = cast(string) charArray;
            } else {
                fragmentOk = false;
                fragmentLog = cast(string) charArray;
            }
            free(buffer);
            return false;
        }
        return true;
    }
}
