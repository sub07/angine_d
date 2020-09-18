module angine.core.scene.scene_manager;

import angine.core.scene;
import angine.core_info;
import angine.graphics.graphic_renderer;
import angine.maths;
import std.container.slist;

interface SceneManager {
    void push(Scene s);
    void pop();
    void clear();
    void set(Scene s);
    void update(FrameInfo f);
    void draw(FrameInfo f, GraphicsRenderer renderer);
    public void dispatchOnKeyDown(Key k, Modifiers mods);
    public void dispatchKeyDown(Key k, Modifiers mods);
    public void dispatchOnKeyUp(Key k, Modifiers mods);
    public void dispatchOnMouseMove(Vec pos, Modifiers mods);
    public void dispatchOnMouseScroll(Vec pos, Modifiers mods);
    public void dispatchMouseDown(MouseButton b, Modifiers mods);
    public void dispatchOnMouseDown(MouseButton b, Modifiers mods);
    public void dispatchOnMouseUp(MouseButton b, Modifiers mods);

    public static SceneManager make() {
        return new SceneManagerImpl();
    }
}

class SceneManagerImpl : SceneManager {
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

    void draw(FrameInfo f, GraphicsRenderer renderer) {
        auto i = 0;
        foreach (scene; sceneStack) {
            if (i == 0)
                f.focused = true;
            else {
                if (!scene.backgroundActivity)
                    continue;
                f.focused = false;
            }
            scene.draw(f, renderer);
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
