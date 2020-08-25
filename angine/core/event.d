module angine.core.event;

import angine.maths.vec;

enum Key {
    Unknown,
    Escape,
    F1,
    F2,
    F3,
    F4,
    F5,
    F6,
    F7,
    F8,
    F9,
    F10,
    F11,
    F12,
    PrintScreen,
    ScrollLock,
    Pause,
    Insert,
    Home,
    PageUp,
    PageDown,
    End,
    Delete,
    Up,
    Down,
    Left,
    Right,
    NumLock,
    NpDivide,
    NpMultiply,
    NpMinus,
    NpPlus,
    NpEnter,
    NpDot,
    Grave,
    Np0,
    Np1,
    Np2,
    Np3,
    Np4,
    Np5,
    Np6,
    Np7,
    Np8,
    Np9,
    Kb0,
    Kb1,
    Kb2,
    Kb3,
    Kb4,
    Kb5,
    Kb6,
    Kb7,
    Kb8,
    Kb9,
    Minus,
    Equals,
    RightBracket,
    LeftBracket,
    A,
    B,
    C,
    D,
    E,
    F,
    G,
    H,
    I,
    J,
    K,
    L,
    M,
    N,
    O,
    P,
    Q,
    R,
    S,
    T,
    U,
    V,
    W,
    X,
    Y,
    Z,
    Comma,
    Dot,
    Semicolon,
    Slash,
    Backslash,
    Apostrophe,
    Tab,
    CapsLock,
    LeftShift,
    LeftControl,
    Super,
    LeftAlt,
    Space,
    RightAlt,
    RightControl,
    RightShift,
    Enter,
    Backspace
}

enum MouseButton {
    LeftButton,
    MiddleButton,
    RightButton
}

enum ActionState {
    Pressed,
    Released
}

struct EventState {
    bool[Key] kPressed;
    bool[MouseButton] bPressed;
    Modifiers mods;
}

struct Modifiers {
    bool ctrl;
    bool alt;
    bool shift;
    bool windows;
    bool num_lock;
    bool caps_lock;
}

enum EventType {
    KeyDown,
    OnKeyDown,
    OnKeyUp,
    OnMouseMove,
    OnMouseDown,
    OnMouseUp,
    MouseDown,
    OnMouseScroll,
    OnWindowResize
}

struct Event {
    EventType type;
    Modifiers mods;
    Key key;
    MouseButton button;
    Vec mouseScroll;
    Vec mousePosition;
    Vec windowSize;
}