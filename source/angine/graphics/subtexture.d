module angine.graphics.subtexture;

import angine.graphics;
import angine.physics.shape;
import angine.maths;

SubTexture subTextureOf(Texture t, Rect r) {
    return SubTexture(t, r);
}

SubTexture subTextureOf(Texture t, float x, float y, float w, float h) {
    return SubTexture(t, new Rect(x, y, w, h));
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
