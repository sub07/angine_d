import std.stdio;

import threev.angine;

class MyScene : AngineScene {
	Font courier;

	this(Angine a) {
		super(a);
		courier = new Font("assets/courier.ttf", 40);
	}

	override public void update(FrameInfo info) {
		// writeln(info);
	}

	override public void draw(FrameInfo info) {
		drawString(courier, "Score", Color.white, windowSize / 2);
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
	config.windowConfig.width = 799;
	config.windowConfig.vsync = false;
	Angine a = new Angine(config);
	a.launch!MyScene;
}
