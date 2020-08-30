module threev.angine.core.scene;

import threev.angine.maths.vec;
import threev.angine.core.event;
import std.container;
import threev.angine.core.angine;

struct FrameInfo {
    float dt = 0;
    float fps = 0;
    ulong frameIndex = 0;
    bool focused = true;
}

abstract class Scene {
    SceneManager manager;
    public bool backgroundActivity = false;

    this(SceneManager manager) {
        this.manager = manager;
    }

    // Behavior
    public void update(FrameInfo info);
    public void draw(FrameInfo info);
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
    protected @property float windowHeight();
    protected @property void windowHeight(float newHeight);
    protected @property float windowWidth();
    protected @property void windowWidth(float newWidth);
    protected @property Vec windowSize();
    protected @property void windowSize(Vec newSize);
    protected void pushScene(Scene s) {
        manager.push(s);
    }

    protected void setScene(Scene s) {
        manager.set(s);
    }

    protected void popScene() {
        manager.pop();
    }
}

class SceneManager {
    private SList!Scene sceneStack;

    void push(Scene s) {
        sceneStack.insertFront(s);
    }

    void pop() {
        sceneStack.removeFront();
    }

    void clear() {
        sceneStack.clear();
    }

    void set(Scene s) {
        clear();
        sceneStack.insertFront(s);
    }

    void update(FrameInfo f) {
        auto i = 0;
        foreach (scene; sceneStack) {
            if (i == 0)
                f.focused = true;
            else {
                if (!scene.backgroundActivity)
                    continue;
                f.focused = false;
            }
            scene.update(f);
            i++;
        }
    }

    void draw(FrameInfo f) {
        auto i = 0;
        foreach (scene; sceneStack) {
            if (i == 0)
                f.focused = true;
            else {
                if (!scene.backgroundActivity)
                    continue;
                f.focused = false;
            }
            scene.draw(f);
            i++;
        }
    }

    public void dispatchOnKeyDown(Key k, Modifiers mods) {
        Scene topScene = sceneStack.front();
        topScene.onKeyDown(k, mods);
    }

    public void dispatchKeyDown(Key k, Modifiers mods) {
        Scene topScene = sceneStack.front();
        topScene.keyDown(k, mods);
    }

    public void dispatchOnKeyUp(Key k, Modifiers mods) {
        Scene topScene = sceneStack.front();
        topScene.onKeyUp(k, mods);
    }

    public void dispatchOnMouseMove(Vec pos, Modifiers mods) {
        Scene topScene = sceneStack.front();
        topScene.onMouseMove(pos, mods);
    }

    public void dispatchOnMouseScroll(Vec pos, Modifiers mods) {
        Scene topScene = sceneStack.front();
        topScene.onMouseScroll(pos, mods);
    }

    public void dispatchMouseDown(MouseButton b, Modifiers mods) {
        Scene topScene = sceneStack.front();
        topScene.mouseDown(b, mods);
    }

    public void dispatchOnMouseDown(MouseButton b, Modifiers mods) {
        Scene topScene = sceneStack.front();
        topScene.onMouseDown(b, mods);
    }

    public void dispatchOnMouseUp(MouseButton b, Modifiers mods) {
        Scene topScene = sceneStack.front();
        topScene.onMouseUp(b, mods);
    }
}
