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

    this(float x, float y) nothrow {
        this.x = x;
        this.y = y;
    }

    this(Vec v) nothrow {
        x = v.x;
        y = v.y;
    }

    this(float xy) nothrow {
        x = xy;
        y = xy;
    }

    @property float w() inout nothrow {
        return x;
    }

    @property float h() inout nothrow {
        return y;
    }

    @property void w(float w) nothrow {
        x = w;
    }

    @property void h(float h) nothrow {
        y = h;
    }

    public inout(Vec) opBinary(string op)(inout(Vec) rhs) inout {
        return mixin("Vec(x" ~ op ~ "rhs.x, y" ~ op ~ "rhs.y)");
    }

    public inout(Vec) opBinary(string op)(inout(float) rhs) inout {
        return mixin("Vec(x" ~ op ~ "rhs, y" ~ op ~ "rhs)");
    }

    string toString() inout {
        return format("(%f, %f)", x, y);
    }

    Vec opOpAssign(string op)(Vec value) {
        mixin("x" ~ op ~ "= value.x;");
        mixin("y" ~ op ~ "= value.y;");
        return this;
    }

    bool opEquals(const Vec other) const nothrow {
        return x == other.x && y == other.y;
    }

    size_t toHash() const @safe pure nothrow {
        return cast(size_t)(13 * x + 11 * y);
    }

    float norm() immutable {
        return sqrt(x * x + y * y);
    }

    Vec middle(Vec v) immutable {
        return Vec((x + v.x) / 2, (y + v.y) / 2);
    }

    Vec normalize() immutable {
        immutable n = norm();
        return Vec(x / n, y / n);
    }

    Vec normal() immutable {
        return Vec(y, -x);
    }

    float dist(Vec v) immutable {
        immutable sub = this - v;
        return sub.norm();
    }

    float dist2(Vec v) immutable {
        immutable sub = this - v;
        return sub.x * sub.x + sub.y * sub.y;
    }

    float det(Vec v) immutable {
        return x * v.y - y * v.x;
    }

    float dot(Vec v) immutable {
        return x * v.x + y * v.y;
    }

    Vec rotated(float val) immutable {
        immutable new_x = cos(val) * x - sin(val) * y;
        immutable new_y = sin(val) * x + cos(val) * y;
        return Vec(new_x, new_y);
    }

    void rotate(float val) {
        immutable new_x = cos(val) * x - sin(val) * y;
        immutable new_y = sin(val) * x + cos(val) * y;
        x = new_x;
        y = new_y;
    }
}
