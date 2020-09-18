module angine.core_info.window;

import angine.core_info;

alias KeyCallback = void delegate(Key, ActionState, Modifiers);
alias MouseCallback = void delegate(MouseButton, ActionState, Modifiers);
alias MouseMoveCallback = void delegate(int, int);
alias MouseScrollCallback = void delegate(int, int);
alias WindowResizeCallback = void delegate(int, int);
alias FramebufferResizeCallback = void delegate(int, int);

struct WindowEventCallbacks {
    KeyCallback keyCallback;
    MouseCallback mouseCallback;
    MouseMoveCallback mouseMoveCallback;
    MouseScrollCallback mouseScrollCallback;
    WindowResizeCallback windowResizeCallback;
    FramebufferResizeCallback framebufferResizeCallback;
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