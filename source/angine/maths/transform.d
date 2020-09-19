module angine.maths.transform;

import angine.maths;

struct Transform {
    public Vec translate = Vec();
    public Vec scale = Vec(1);
    public float rotate = 0;
    public Vec origin = Vec();

    public void translateBy(Vec translate) {
        this.translate += translate;
    }

    public void rotateBy(float rotate) {
        this.rotate += rotate;
    }

    public void scaleBy(Vec scale) {
        this.scale *= scale;
    }

    public void translateOriginBy(Vec origin) {
        this.origin += origin;
    }

    public Vec apply(Vec pos) {
        pos -= origin;
        pos *= scale;
        pos.rotate(rotate);
        pos += translate;
        return pos;
    }
}