module angine.graphics.subtexture;

public import angine.graphics.primitive;
import angine.maths.rect;

SubTexture subTextureOf(Texture t, Rect r) {
    return SubTexture(t, r);
}

SubTexture subTextureOf(Texture t, float x, float y, float w, float h) {
    return SubTexture(t, Rect(x, y, w, h));
}

struct SubTexture {
    Texture associatedTexture;
    Rect region;

    this(Texture tex, Rect region) {
        associatedTexture = tex;
        this.region = region;
    }

    @property float width() {
        return region.w;
    }

    @property float height() {
        return region.h;
    }
}
