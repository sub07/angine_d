module threev.angine.entity.entity;

import threev.angine;
import std;

class Transform {
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
}

class Entity : Transform {
    private static ulong idCounter = 0;

    private ulong id;
    Entity[] children;

    this() {
        id = idCounter++;
    }

    void addChild(Entity e) {
        children ~= e;
    }

    override public string toString() const {
        return to!string(id);
    }
}
