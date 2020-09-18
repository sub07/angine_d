module angine.physics.shape.rect;

import angine.physics.shape.shape : Shape;
import angine.maths;

unittest {
    Shape rect = new Rect(50, 60, 10, 20);
    assert(!rect.contains(Vec()));
    assert(rect.contains(Vec(53, 68)));
    assert(!rect.contains(Vec(62, 53)));
    assert(!rect.contains(Vec(-50, 53)));
    assert(!rect.contains(Vec(50, -53)));
    assert(!rect.contains(Vec(53, 82)));
    assert(!rect.contains(Vec(60, 60)));
}

class Rect : Shape {
    float x = 0;
    float y = 0;
    float w = 0;
    float h = 0;

    this() {
        
    }

    this(float x, float y, float w, float h) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }

    override public bool contains(Vec pos) {
        Vec topLeft = transformed(Vec(x, y));
        Vec bottomRight = transformed(Vec(x + w, y + h));

        return pos.x >= topLeft.x && pos.y >= topLeft.y && pos.x < bottomRight.x
            && pos.y < bottomRight.y;
    }
}
