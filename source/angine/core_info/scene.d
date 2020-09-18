module angine.core_info.scene;

struct FrameInfo {
    float dt = 0;
    float fps = 0;
    ulong frameIndex = 0;
    bool focused = true;
}