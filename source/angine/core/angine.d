module angine.core.angine;

import angine.core.window;
import angine.core.scene;
import angine.core_info;

import angine.core.time;

import angine.graphics.primitive;
import angine.graphics.batch_shaders;
import angine.graphics.shape_shaders;
import angine.graphics.graphic_renderer;

import angine.maths;

private struct EventState {
    bool[Key.Last] keysDown = false;
    bool[MouseButton.Last] buttonsDown = false;
    Modifiers mods;
}

private struct ShaderCollection {
    Shader textureBatch;
    Shader textBatch;
    Shader shape;
}

final class Angine {
    SceneManager sceneManager;
    Window window;
    ShaderCollection shaders;
    bool shouldClose = false;
    EventState eventState;
    EventState previousState;
    GraphicsRenderer renderer;

    this(AngineConfig config) {
        window = new GLFWWindow(config, WindowEventCallbacks(&keyCallback, &mouseCallback, &mouseMoveCallback,
                &mouseScrollCallback, &windowResizeCallback, &framebufferResizeCallback));
        sceneManager = SceneManager.make();
        loadGl(window.loader);

        shaders.textureBatch = new Shader(vTex, fTex);
        shaders.textBatch = new Shader(vTex, fText);
        shaders.shape = new Shader(shapeVertexShader, shapeFragmentShader);

        framebufferResizeCallback(window.width, window.height);

        renderer = new GraphicsRenderer(shaders.textureBatch, shaders.textBatch, shaders.shape);
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

    void windowResizeCallback(int w, int h) {
    }

    void framebufferResizeCallback(int w, int h) {

        setViewport(w, h);
        shaders.textureBatch.sendVec2("viewportSize", cast(float) w, cast(float) h);
        shaders.textBatch.sendVec2("viewportSize", cast(float) w, cast(float) h);
        shaders.shape.sendVec2("viewportSize", cast(float) w, cast(float) h);
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

    static void launch(S : AngineScene)(AngineConfig config) {
        Angine instance = new Angine(config);
        AngineScene initialScene = new S(instance);
        instance.sceneManager.set(initialScene);
        FrameInfo info;
        double last = now();
        double dtAcc = 0.0;
        int dtAccCount = 0;
        while (!instance.shouldClose) {
            info.dt = now() - last;
            last = now();
            dtAcc += info.dt;
            dtAccCount++;
            if (dtAccCount == 50) {
                info.fps = 1 / (dtAcc / dtAccCount);
                dtAcc = 0.0;
                dtAccCount = 0;
            }
            instance.window.pumpEvent();
            instance.handleEvents();
            instance.sceneManager.update(info);
            clearScreen();
            instance.renderer.tBatch.begin();
            instance.sceneManager.draw(info, instance.renderer);
            instance.renderer.tBatch.end();
            instance.window.swapBuffers();
            info.frameIndex++;
        }
    }
}

abstract class AngineScene : Scene {
    private Angine instance;
    this(Angine a) {
        super(a.sceneManager);
        instance = a;
    }

    override protected void exit() {
        instance.shouldClose = true;
    }

    override protected Vec windowSize() {
        return Vec(instance.window.width, instance.window.height);
    }

    override protected void windowSize(Vec newSize) {
        instance.window.width = cast(int) newSize.w;
        instance.window.height = cast(int) newSize.h;
    }
}
