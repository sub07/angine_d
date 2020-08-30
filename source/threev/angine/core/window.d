module threev.angine.core.window;

import bindbc.glfw;
import std.string;
import threev.angine.core.event;

struct WindowConfig {
    int width = 800;
    int height = 600;
    string appName = "Title";
    bool resizable = true;
    bool vsync = true;
    bool fullscreen = false;
    int monitorIndex = 0;
}

alias KeyCallback = void delegate(Key, ActionState, Modifiers);
alias MouseCallback = void delegate(MouseButton, ActionState, Modifiers);
alias MouseMoveCallback = void delegate(int, int);
alias MouseScrollCallback = void delegate(int, int);

struct WindowEventCallbacks {
    KeyCallback keyCallback;
    MouseCallback mouseCallback;
    MouseMoveCallback mouseMoveCallback;
    MouseScrollCallback mouseScrollCallback;
}

interface Window {
    string title();
    void title(string newTitle);
    int width();
    void width(int newWidth);
    int height();
    void height(int newHeight);
    void pumpEvent();
    void swapBuffers();
    bool shouldClose();
    void* delegate(const char* name) loader();
}

class GLFWWindow : Window {
    private GLFWwindow* handle;
    private string mTitle;
    private WindowEventCallbacks callbacks;

    this(WindowConfig config, WindowEventCallbacks callbacks) {
        if (loadGLFW() == GLFWSupport.noLibrary)
            throw new Exception("can't load glfw");

        this.callbacks = callbacks;
        glfwInit();

        glfwWindowHint(GLFW_RESIZABLE, config.resizable ? GLFW_TRUE : GLFW_FALSE);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 6);

        if (config.fullscreen) {
            GLFWmonitor* monitor = getMonitorFromIndex(config.monitorIndex);
            if (config.width == 0 && config.height == 0) {
                int width, height;
                glfwGetMonitorWorkarea(monitor, null, null, &width, &height);
                handle = glfwCreateWindow(width, height, toStringz(config.appName), monitor, null);
            } else {
                handle = glfwCreateWindow(config.width, config.height,
                        toStringz(config.appName), monitor, null);
            }
        } else {
            handle = glfwCreateWindow(config.width, config.height,
                    toStringz(config.appName), null, null);
        }

        glfwSwapInterval(config.vsync ? 1 : 0);

        glfwMakeContextCurrent(handle);
        glfwSetWindowUserPointer(handle, cast(void*) this);
        glfwSetKeyCallback(handle, &keyCallback);
        glfwSetMouseButtonCallback(handle, &mouseCallback);
        glfwSetCursorPosCallback(handle, &mouseMoveCallback);
        glfwSetScrollCallback(handle, &mouseScrollCallback);
    }

    ~this() {
        glfwTerminate();
        unloadGLFW();
    }

    string title() {
        return mTitle;
    }

    void title(string newTitle) {
        mTitle = newTitle;
        glfwSetWindowTitle(handle, toStringz(newTitle));
    }

    int width() {
        int w;
        glfwGetWindowSize(handle, &w, null);
        return w;
    }

    void width(int newWidth) {
        glfwSetWindowSize(handle, newWidth, this.height);
    }

    int height() {
        int h;
        glfwGetWindowSize(handle, null, &h);
        return h;
    }

    void height(int newHeight) {
        glfwSetWindowSize(handle, this.width, newHeight);
    }

    void pumpEvent() {
        glfwPollEvents();
        if (callbackThrowing !is null) {
            throw callbackThrowing;
        }
    }

    void swapBuffers() {
        glfwSwapBuffers(handle);
    }

    bool shouldClose() {
        return glfwWindowShouldClose(handle) == GLFW_TRUE;
    }

    void* delegate(const char* name) loader() {
        return x => glfwGetProcAddress(x);
    }

    private static Throwable callbackThrowing = null;

    private static extern (C) void keyCallback(GLFWwindow* w, int key,
            int scancode, int action, int mods) nothrow {
        GLFWWindow win = cast(GLFWWindow) glfwGetWindowUserPointer(w);
        try {
            win.callbacks.keyCallback(glfwToEngineKey(key),
                    glfwToEngineAction(action), glfwToEngineModifiers(mods));
        } catch (Exception e) {
            callbackThrowing = e;
        }
    }

    private static extern (C) void mouseCallback(GLFWwindow* w, int button, int action, int mods) nothrow {
        GLFWWindow win = cast(GLFWWindow) glfwGetWindowUserPointer(w);
        try {
            win.callbacks.mouseCallback(glfwToEngineMouseButton(button),
                    glfwToEngineAction(action), glfwToEngineModifiers(mods));
        } catch (Exception e) {
            callbackThrowing = e;
        }
    }

    private static extern (C) void mouseMoveCallback(GLFWwindow* w, double x, double y) nothrow {
        GLFWWindow win = cast(GLFWWindow) glfwGetWindowUserPointer(w);
        try {
            win.callbacks.mouseMoveCallback(cast(int) x, cast(int) y);
        } catch (Exception e) {
            callbackThrowing = e;
        }
    }

    private static extern (C) void mouseScrollCallback(GLFWwindow* w, double x, double y) nothrow {
        GLFWWindow win = cast(GLFWWindow) glfwGetWindowUserPointer(w);
        try {
            win.callbacks.mouseScrollCallback(cast(int) x, cast(int) y);
        } catch (Exception e) {
            callbackThrowing = e;
        }
    }

    private static MouseButton glfwToEngineMouseButton(int glfwMouseButton) {
        final switch (glfwMouseButton) with (MouseButton) {
        case GLFW_MOUSE_BUTTON_RIGHT:
            return RightButton;
        case GLFW_MOUSE_BUTTON_MIDDLE:
            return MiddleButton;
        case GLFW_MOUSE_BUTTON_LEFT:
            return LeftButton;
        }
    }

    private static Modifiers glfwToEngineModifiers(int mods) {
        return Modifiers(cast(bool)(mods & GLFW_MOD_CONTROL),
                cast(bool)(mods & GLFW_MOD_ALT), cast(bool)(mods & GLFW_MOD_SHIFT),
                cast(bool)(mods & GLFW_MOD_SUPER), cast(bool)(mods & GLFW_MOD_NUM_LOCK),
                cast(bool)(mods & GLFW_MOD_CAPS_LOCK));
    }

    private static ActionState glfwToEngineAction(int glfwAction) {
        final switch (glfwAction) {
        case GLFW_PRESS:
            return ActionState.Pressed;
        case GLFW_RELEASE:
            return ActionState.Released;
        case GLFW_REPEAT:
            return ActionState.Repeated;
        }
    }

    private static Key glfwToEngineKey(int glfwKey) {
        switch (glfwKey) {
        case GLFW_KEY_A:
            return Key.A;
        case GLFW_KEY_B:
            return Key.B;
        case GLFW_KEY_C:
            return Key.C;
        case GLFW_KEY_D:
            return Key.D;
        case GLFW_KEY_E:
            return Key.E;
        case GLFW_KEY_F:
            return Key.F;
        case GLFW_KEY_G:
            return Key.G;
        case GLFW_KEY_H:
            return Key.H;
        case GLFW_KEY_I:
            return Key.I;
        case GLFW_KEY_J:
            return Key.J;
        case GLFW_KEY_K:
            return Key.K;
        case GLFW_KEY_L:
            return Key.L;
        case GLFW_KEY_M:
            return Key.M;
        case GLFW_KEY_N:
            return Key.N;
        case GLFW_KEY_O:
            return Key.O;
        case GLFW_KEY_P:
            return Key.P;
        case GLFW_KEY_Q:
            return Key.Q;
        case GLFW_KEY_R:
            return Key.R;
        case GLFW_KEY_S:
            return Key.S;
        case GLFW_KEY_T:
            return Key.T;
        case GLFW_KEY_U:
            return Key.U;
        case GLFW_KEY_V:
            return Key.V;
        case GLFW_KEY_W:
            return Key.W;
        case GLFW_KEY_X:
            return Key.X;
        case GLFW_KEY_Y:
            return Key.Y;
        case GLFW_KEY_Z:
            return Key.Z;
        case GLFW_KEY_1:
            return Key.Kb1;
        case GLFW_KEY_2:
            return Key.Kb2;
        case GLFW_KEY_3:
            return Key.Kb3;
        case GLFW_KEY_4:
            return Key.Kb4;
        case GLFW_KEY_5:
            return Key.Kb5;
        case GLFW_KEY_6:
            return Key.Kb6;
        case GLFW_KEY_7:
            return Key.Kb7;
        case GLFW_KEY_8:
            return Key.Kb8;
        case GLFW_KEY_9:
            return Key.Kb9;
        case GLFW_KEY_0:
            return Key.Kb0;
        case GLFW_KEY_ENTER:
            return Key.Enter;
        case GLFW_KEY_ESCAPE:
            return Key.Escape;
        case GLFW_KEY_BACKSPACE:
            return Key.Backspace;
        case GLFW_KEY_TAB:
            return Key.Tab;
        case GLFW_KEY_SPACE:
            return Key.Space;
        case GLFW_KEY_MINUS:
            return Key.Minus;
        case GLFW_KEY_EQUAL:
            return Key.Equals;
        case GLFW_KEY_LEFT_BRACKET:
            return Key.LeftBracket;
        case GLFW_KEY_RIGHT_BRACKET:
            return Key.RightBracket;
        case GLFW_KEY_BACKSLASH:
            return Key.Backslash;
        case GLFW_KEY_SEMICOLON:
            return Key.Semicolon;
        case GLFW_KEY_APOSTROPHE:
            return Key.Apostrophe;
        case GLFW_KEY_GRAVE_ACCENT:
            return Key.Grave;
        case GLFW_KEY_COMMA:
            return Key.Comma;
        case GLFW_KEY_PERIOD:
            return Key.Dot;
        case GLFW_KEY_SLASH:
            return Key.Slash;
        case GLFW_KEY_CAPS_LOCK:
            return Key.CapsLock;
        case GLFW_KEY_F1:
            return Key.F1;
        case GLFW_KEY_F2:
            return Key.F2;
        case GLFW_KEY_F3:
            return Key.F3;
        case GLFW_KEY_F4:
            return Key.F4;
        case GLFW_KEY_F5:
            return Key.F5;
        case GLFW_KEY_F6:
            return Key.F6;
        case GLFW_KEY_F7:
            return Key.F7;
        case GLFW_KEY_F8:
            return Key.F8;
        case GLFW_KEY_F9:
            return Key.F9;
        case GLFW_KEY_F10:
            return Key.F10;
        case GLFW_KEY_F11:
            return Key.F11;
        case GLFW_KEY_F12:
            return Key.F12;
        case GLFW_KEY_PRINT_SCREEN:
            return Key.PrintScreen;
        case GLFW_KEY_SCROLL_LOCK:
            return Key.ScrollLock;
        case GLFW_KEY_PAUSE:
            return Key.Pause;
        case GLFW_KEY_INSERT:
            return Key.Insert;
        case GLFW_KEY_HOME:
            return Key.Home;
        case GLFW_KEY_PAGE_UP:
            return Key.PageUp;
        case GLFW_KEY_DELETE:
            return Key.Delete;
        case GLFW_KEY_END:
            return Key.End;
        case GLFW_KEY_PAGE_DOWN:
            return Key.PageDown;
        case GLFW_KEY_RIGHT:
            return Key.Right;
        case GLFW_KEY_LEFT:
            return Key.Left;
        case GLFW_KEY_DOWN:
            return Key.Down;
        case GLFW_KEY_UP:
            return Key.Up;
        case GLFW_KEY_NUM_LOCK:
            return Key.NumLock;
        case GLFW_KEY_KP_DIVIDE:
            return Key.NpDivide;
        case GLFW_KEY_KP_MULTIPLY:
            return Key.NpMultiply;
        case GLFW_KEY_KP_SUBTRACT:
            return Key.NpMinus;
        case GLFW_KEY_KP_ADD:
            return Key.NpPlus;
        case GLFW_KEY_KP_ENTER:
            return Key.NpEnter;
        case GLFW_KEY_KP_1:
            return Key.Np1;
        case GLFW_KEY_KP_2:
            return Key.Np2;
        case GLFW_KEY_KP_3:
            return Key.Np3;
        case GLFW_KEY_KP_4:
            return Key.Np4;
        case GLFW_KEY_KP_5:
            return Key.Np5;
        case GLFW_KEY_KP_6:
            return Key.Np6;
        case GLFW_KEY_KP_7:
            return Key.Np7;
        case GLFW_KEY_KP_8:
            return Key.Np8;
        case GLFW_KEY_KP_9:
            return Key.Np9;
        case GLFW_KEY_KP_0:
            return Key.Np0;
        case GLFW_KEY_KP_DECIMAL:
            return Key.NpDot;
        case GLFW_KEY_LEFT_SUPER:
        case GLFW_KEY_RIGHT_SUPER:
            return Key.Super;
        case GLFW_KEY_LEFT_SHIFT:
            return Key.LeftShift;
        case GLFW_KEY_LEFT_CONTROL:
            return Key.LeftControl;
        case GLFW_KEY_LEFT_ALT:
            return Key.LeftAlt;
        case GLFW_KEY_RIGHT_ALT:
            return Key.RightAlt;
        case GLFW_KEY_RIGHT_CONTROL:
            return Key.RightControl;
        case GLFW_KEY_RIGHT_SHIFT:
            return Key.RightShift;
        default:
            return Key.Unknown;
        }
    }

    private static GLFWmonitor* getMonitorFromIndex(int index) {
        int count;
        GLFWmonitor** monitors = glfwGetMonitors(&count);
        if (index < 0 || index >= count)
            return glfwGetPrimaryMonitor();
        return monitors[index];
    }
}
