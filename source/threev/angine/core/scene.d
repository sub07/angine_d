module threev.angine.core.scene;

import threev.angine.maths.vec;
import threev.angine.core.event;
import std.container;

struct FrameInfo {
    float dt = 0;
    float fps = 0;
    ulong frameIndex = 0;
    bool focused = true;
}

abstract class Scene {
    protected SceneManager manager;
    public bool backgroundActivity = false;

    this(SceneManager manager) {
        this.manager = manager;
    }

    // Behaviour
    public void update(FrameInfo info);
    public void draw(FrameInfo info);
    public void event(FrameInfo info, Event event);

    // User capabilities
    protected void exit();
    protected @property float windowHeight();
    protected @property void windowHeight(float newHeight);
    protected @property float windowWidth();
    protected @property void windowWidth(float newWidth);
    protected @property Vec windowSize();
    protected @property void windowSize(Vec newSize);
    protected void pushScene(Scene s);
    protected void setScene(Scene s);
    protected void popScene();
}

abstract class DumbScene : Scene {

    this(SceneManager m) {
        super(m);
    }

    override protected void exit() {
    }

    override protected @property float windowHeight() {
        return 0;
    }

    override protected @property void windowHeight(float newHeight) {
    }

    override protected @property float windowWidth() {
        return 0;
    }

    override protected @property void windowWidth(float newWidth) {
    }

    override protected @property Vec windowSize() {
        return Vec();
    }

    override protected @property void windowSize(Vec newSize) {
    }

    override protected void pushScene(Scene s) {
        manager.push(s);
    }

    override protected void setScene(Scene s) {
        manager.set(s);
    }

    override protected void popScene() {
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
}
