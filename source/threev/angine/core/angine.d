module threev.angine.core.angine;

import threev.angine.core;
import threev.angine.graphics;
import threev.angine.maths;

struct AngineConfig {
    WindowConfig windowConfig;
}

private struct EventState {
    bool[Key.Last] keysDown = false;
    bool[MouseButton.Last] buttonsDown = false;
    Modifiers mods;
}

class Angine {
    SceneManager sceneManager;
    Window window;
    bool shouldClose = false;
    EventState eventState;
    EventState previousState;
    this(AngineConfig config) {
        window = new GLFWWindow(config.windowConfig, WindowEventCallbacks(&keyCallback,
                &mouseCallback, &mouseMoveCallback, &mouseScrollCallback));
        sceneManager = new SceneManager();
        loadGl(window.loader);
        setClearColor(0, 0, 0, 1);
    }

    void keyCallback(Key k, ActionState action, Modifiers mods) {
        eventState.mods = mods;
        final switch (action) with (ActionState) {
        case Pressed:
            eventState.keysDown[k] = true;
            sceneManager.dispatchOnKeyDown(k, mods);
            break;
        case Released:
            eventState.keysDown[k] = false;
            sceneManager.dispatchOnKeyUp(k, mods);
            break;
        case Repeated:
            break;
        }
    }

    void mouseCallback(MouseButton b, ActionState action, Modifiers mods) {
        eventState.mods = mods;
        final switch (action) with (ActionState) {
        case Pressed:
            eventState.buttonsDown[b] = true;
            sceneManager.dispatchOnMouseDown(b, mods);
            break;
        case Released:
            eventState.buttonsDown[b] = false;
            sceneManager.dispatchOnMouseUp(b, mods);
            break;
        case Repeated:
            break;
        }
    }

    void mouseMoveCallback(int x, int y) {
        sceneManager.dispatchOnMouseMove(Vec(x, y), eventState.mods);
    }

    void mouseScrollCallback(int x, int y) {
        sceneManager.dispatchOnMouseScroll(Vec(x, y), eventState.mods);
    }

    private void handleEvents() {
        shouldClose = window.shouldClose();
        foreach (key, pressed; eventState.keysDown) {
            if (pressed)
                sceneManager.dispatchKeyDown(cast(Key) key, eventState.mods);
        }

        foreach (button, pressed; eventState.buttonsDown) {
            if (pressed)
                sceneManager.dispatchMouseDown(cast(MouseButton) button, eventState.mods);
        }
    }

    void launch(S : AngineScene)() {
        AngineScene initialScene = new S(sceneManager, this);
        sceneManager.set(initialScene);
        FrameInfo info;
        double last = now();
        double dtAcc = 0.0;
        int dtAccCount = 0;
        while (!shouldClose) {
            info.dt = now() - last;
            last = now();
            dtAcc += info.dt;
            dtAccCount++;
            if (dtAccCount == 50) {
                info.fps = 1 / (dtAcc / dtAccCount);
                dtAcc = 0.0;
                dtAccCount = 0;
            }
            window.pumpEvent();
            handleEvents();
            sceneManager.update(info);
            clearScreen();
            sceneManager.draw(info);
            window.swapBuffers();
            info.frameIndex++;
        }
    }
}

abstract class AngineScene : Scene {
    Angine engine = null;
    this(SceneManager m, Angine a) {
        super(m);
        engine = a;
    }

    override protected void exit() {
        engine.shouldClose = true;
    }

    override protected @property float windowHeight() {
        return cast(float) engine.window.height;
    }

    override protected @property void windowHeight(float newHeight) {
        engine.window.height = cast(int) newHeight;
    }

    override protected @property float windowWidth() {
        return cast(float) engine.window.width;
    }

    override protected @property void windowWidth(float newWidth) {
        engine.window.width = cast(int) newWidth;
    }

    override protected @property Vec windowSize() {
        return Vec(windowWidth, windowHeight);
    }

    override protected @property void windowSize(Vec newSize) {
        windowWidth = newSize.w;
        windowHeight = newSize.h;
    }
}
