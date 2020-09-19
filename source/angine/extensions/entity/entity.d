module angine.extensions.entity.entity;

import angine.maths;
import angine.graphics.graphic_renderer;
import angine.core_info;

import std.string;

unittest {
    Entity e1 = new DumbEntity();
    Entity e2 = new DumbEntity();
    Entity e3 = new DumbEntity();

    const e2Cpy = e2;

    assert(e1 != e2);
    assert(e1.toHash() == 0);
    assert(e2.toHash() == 1);
    assert(e2Cpy == e2);
}

abstract class Entity {
    private static ulong idCounter = 0;

    public Transform transform;
    private ulong id;

    this() {
        this.id = idCounter++;
    }

    void update(FrameInfo info);
    void draw(FrameInfo info, GraphicsRenderer renderer);

    override size_t toHash() const @safe pure nothrow {
        return id;
    }

    override public string toString() const {
        return format("%s (%ul)", this.classinfo.name, id);
    }

    bool opEquals(R)(const R other) const {
        return toHash() == other.toHash();
    }
}

class DumbEntity : Entity {
    override void update(FrameInfo info) {

    }

    override void draw(FrameInfo info, GraphicsRenderer renderer) {

    }
}
