import std.stdio;

import threev.angine;

class MyScene : AngineScene {

	this() {

	}

	override public void update(FrameInfo info) {
		writeln(info);
	}

	override public void draw(FrameInfo info) {
	}

	override public void onKeyDown(Key k, Modifiers mods) {
		
	}

	override public void onKeyUp(Key k, Modifiers mods) {
		
	}

	override public void keyDown(Key k, Modifiers mods) {
		
	}

	override public void mouseDown(MouseButton b, Modifiers mods) {
		
	}

	override public void onMouseDown(MouseButton b, Modifiers mods) {
		
	}

	override public void onMouseUp(MouseButton b, Modifiers mods) {
		
	}

	override public void onMouseMove(Vec pos, Modifiers mods) {
		
	}

	override public void onMouseScroll(Vec scroll, Modifiers mods) {
		
	}
}

void main() {
	auto config = AngineConfig();
	config.windowConfig.vsync = false;
	Angine a = new Angine(config);
	a.launch!MyScene;
}
