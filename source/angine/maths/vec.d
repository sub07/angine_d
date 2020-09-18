module angine.maths.vec;

import std.math;
import std.format;

unittest {
    import std.stdio : writeln;

    immutable v = Vec(5);
    assert(v.x == 5 && v.y == 5);
    Vec v1 = Vec(4, 5);
    assert(v1.w == 4);
    assert(v1.h == 5);

    v1.w = 9;

    assert(v1.w == 9);
    assert(v1.x == 9);

    assert(v != v1);

    immutable v2 = Vec(5, 2);
    immutable v3 = Vec(5, 2);

    assert(v2 == v3);

    assert(v2 - v3 == Vec());
}

struct Vec {
    float x = 0;
    float y = 0;

    this(float x, float y) {
        this.x = x;
        this.y = y;
    }

    this(Vec v) {
        x = v.x;
        y = v.y;
    }

    this(float xy) {
        x = xy;
        y = xy;
    }

    @property int i() {
        return cast(int) x;
    }

    @property int j() {
        return cast(int) y;
    }

    @property float w() inout {
        return x;
    }

    @property float h() inout {
        return y;
    }

    @property void w(float w) {
        x = w;
    }

    @property void h(float h) {
        y = h;
    }

    public Vec opBinary(string op)(Vec rhs) inout {
        return mixin("Vec(x" ~ op ~ "rhs.x, y" ~ op ~ "rhs.y)");
    }

    public Vec opBinary(string op)(float rhs) {
        return mixin("Vec(x" ~ op ~ "rhs, y" ~ op ~ "rhs)");
    }

    string toString() const {
        return format("(%f, %f)", x, y);
    }

    Vec opOpAssign(string op)(Vec value) {
        mixin("x" ~ op ~ "= value.x;");
        mixin("y" ~ op ~ "= value.y;");
        return this;
    }

    bool opEquals(const Vec other) const {
        return x == other.x && y == other.y;
    }

    size_t toHash() const @safe pure nothrow {
        return cast(size_t)(13 * x + 11 * y);
    }

    float norm() {
        return sqrt(x * x + y * y);
    }

    Vec middle(Vec v) {
        return Vec((x + v.x) / 2, (y + v.y) / 2);
    }

    Vec normalize() {
        immutable n = norm();
        return Vec(x / n, y / n);
    }

    Vec normal() {
        return Vec(y, -x);
    }

    float dist(Vec v) {
        auto sub = this - v;
        return sub.norm();
    }

    float dist2(Vec v) {
        immutable sub = this - v;
        return sub.x * sub.x + sub.y * sub.y;
    }

    float det(Vec v) {
        return x * v.y - y * v.x;
    }

    float dot(Vec v) {
        return x * v.x + y * v.y;
    }

    Vec rotated(float val) {
        auto new_x = cos(val) * x - sin(val) * y;
        auto new_y = sin(val) * x + cos(val) * y;
        return Vec(new_x, new_y);
    }

    void rotate(float val) {
        if (val == 0)
            return;
        immutable new_x = cos(val) * x - sin(val) * y;
        immutable new_y = sin(val) * x + cos(val) * y;
        x = new_x;
        y = new_y;
    }
}
