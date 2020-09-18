module angine.physics.hitbox;

import angine.physics;
import angine.maths;
import std;

interface HitBox {
    bool hit(Vec pos);
}

class RectHitBox : HitBox {
    Rect boundingBox;

    this(Rect boundingBox) {
        this.boundingBox = boundingBox;
    }

    this(float x, float y, float w, float h) {
        this.boundingBox = new Rect(x, y, w, h);
    }

    override bool hit(Vec pos) {
        return boundingBox.contains(pos);
    }
}

class CircleHitBox : HitBox {
    Circle boundingCircle;

    this(Circle boundingCircle) {
        this.boundingCircle = boundingCircle;
    }

    this(Vec center, float radius) {
        this.boundingCircle = new Circle(center, radius);
    }

    override bool hit(Vec pos) {
        return boundingCircle.contains(pos);
    }
}