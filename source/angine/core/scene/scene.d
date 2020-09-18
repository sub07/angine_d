module angine.core.scene.scene;

import angine.maths;
import angine.graphics.graphic_renderer;
import angine.core_info;
import angine.core.scene;

abstract class Scene {
    SceneManager manager;
    public bool backgroundActivity = false;

    this(SceneManager manager) {
        this.manager = manager;
    }

    public void update(FrameInfo info) {
    }

    public void draw(FrameInfo info, GraphicsRenderer renderer) {
    }

    public void keyDown(Key k, Modifiers mods) {
    }

    public void onKeyDown(Key k, Modifiers mods) {
    }

    public void onKeyUp(Key k, Modifiers mods) {
    }

    public void onMouseMove(Vec pos, Modifiers mods) {
    }

    public void onMouseScroll(Vec pos, Modifiers mods) {
    }

    public void mouseDown(MouseButton b, Modifiers m) {
    }

    public void onMouseDown(MouseButton b, Modifiers m) {
    }

    public void onMouseUp(MouseButton b, Modifiers m) {
    }

    // User capabilities
    protected void exit();
    protected Vec windowSize();
    protected void windowSize(Vec newSize);
}
