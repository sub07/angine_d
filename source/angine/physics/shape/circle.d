module angine.physics.shape.circle;

import angine.physics.shape.shape : Shape;
import angine.maths;
import std;

unittest {
    Shape circle = new Circle(Vec(50, 50), 10);
    assert(!circle.contains(Vec()));
    assert(circle.contains(Vec(50, 50)));
    assert(circle.contains(Vec(51, 58)));
    assert(!circle.contains(Vec(61, 61)));
    assert(!circle.contains(Vec(61, 60)));
}

class Circle : Shape {
    Vec center = Vec();
    float radius = 0;

    this(Vec center, float radius) {
        this.center = center;
        this.radius = radius;
    }

    override public bool contains(Vec pos) {
        return transformed(center).dist2(pos) <= radius * radius * max(transform.scale.x,
                transform.scale.y);
    }
}
