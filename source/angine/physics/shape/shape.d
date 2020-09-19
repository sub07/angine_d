module angine.physics.shape.shape;

import angine.maths;

abstract class Shape {
    Transform transform;

    public bool contains(Vec pos);

    protected Vec transformed(Vec pos) {
        return transform.apply(pos);
    }
}
