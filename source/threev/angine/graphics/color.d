module threev.angine.graphics.color;

struct Color {
    float r, g, b, a;
    this(ubyte r, ubyte g, ubyte b, ubyte a) {
        this.r = r / 255f;
        this.g = g / 255f;
        this.b = b / 255f;
        this.a = a / 255f;
    }

    ref auto opIndex(size_t index) {
        switch (index) {
        case 0:
            return r;
        case 1:
            return g;
        case 2:
            return b;
        case 3:
            return a;
        default:
            assert(0);
        }
    }

    static immutable Color black = Color(0, 0, 0, 255);
    static immutable Color red = Color(255, 0, 0, 255);
    static immutable Color green = Color(0, 255, 0, 255);
    static immutable Color blue = Color(0, 0, 255, 255);
    static immutable Color white = Color(255, 255, 255, 255);
    static immutable Color transparent = Color(0, 0, 0, 0);
    static immutable Color grey = Color(150, 150, 150, 255);
}
