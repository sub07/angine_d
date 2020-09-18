module angine.core_info.angine;

struct AngineConfig {
    int width = 800;
    int height = 600;
    string appName = "Title";
    bool resizable = true;
    bool vsync = true;
    bool fullscreen = false;
    int monitorIndex = 0;
}