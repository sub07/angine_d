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

private struct ShaderCollection {
    Shader textureBatch;
    Shader textBatch;
}

class Angine {
    SceneManager sceneManager;
    Window window;
    ShaderCollection shaders;
    bool shouldClose = false;
    EventState eventState;
    EventState previousState;
    TextureBatch batch;

    this(AngineConfig config) {
        window = new GLFWWindow(config.windowConfig, WindowEventCallbacks(&keyCallback,
                &mouseCallback, &mouseMoveCallback, &mouseScrollCallback));
        sceneManager = new SceneManager();
        loadGl(window.loader);

        shaders.textureBatch = new Shader(vTex, fTex);
        shaders.textBatch = new Shader(vTex, fText);

        shaders.textureBatch.sendVec2("viewportSize", window.width, window.height);
        shaders.textBatch.sendVec2("viewportSize", window.width, window.height);

        batch = new TextureBatch(5000, shaders.textureBatch, shaders.textBatch);
        batch.transparency = true;
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
        AngineScene initialScene = new S(this);
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
            batch.begin();
            sceneManager.draw(info);
            batch.end();
            window.swapBuffers();
            info.frameIndex++;
        }
    }
}

abstract class AngineScene : Scene {
    Angine engine = null;
    this(Angine a) {
        super(a.sceneManager);
        engine = a;
    }

    override protected void exit() {
        engine.shouldClose = true;
    }

    override protected @property Vec windowSize() {
        return Vec(engine.window.width, engine.window.height);
    }

    override protected @property void windowSize(Vec newSize) {
        engine.window.width = cast(int) newSize.w;
        engine.window.height = cast(int) newSize.h;
    }

    void drawTexture(SubTexture t, Vec translate = Vec(), Vec scale = Vec(1),
            Vec origin = Vec(), float rotate = 0) {
        engine.batch.drawTexture(t, translate, scale, origin, rotate);
    }

    void drawTexture(Texture t, Vec translate = Vec(), Vec scale = Vec(1),
            Vec origin = Vec(), float rotate = 0) {
        engine.batch.drawTexture(t, translate, scale, origin, rotate);
    }

    void drawString(Font font, string str, Color c, Vec translate = Vec(),
            Vec scale = Vec(1), Vec origin = Vec(), float rotate = 0) {
        engine.batch.drawString(font, str, c, translate, scale, origin, rotate);
    }

    void drawString(Font font, Object obj, Color c, Vec translate = Vec(),
            Vec scale = Vec(1), Vec origin = Vec(), float rotate = 0) {
        engine.batch.drawString(font, obj, c, translate, scale, origin, rotate);
    }
}
