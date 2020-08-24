import std.stdio;

import angine.core.scene;
import core.thread;

class Scene1 : DumbScene {
	this(SceneManager m) {
		super(m);
		backgroundActivity = false;
	}

	override void update(FrameInfo info) {
		writeln("Scene 1 update, focused : ", info.focused);
		if (info.frameIndex == 5)
			pushScene(new Scene2(manager));
	}

	override void draw(FrameInfo info) {
		writeln("Scene 1 draw, focused : ", info.focused);
	}

	override void event(FrameInfo info, Event event) {

	}
}

class Scene2 : DumbScene {
	this(SceneManager m) {
		super(m);
	}

	override void update(FrameInfo info) {
		writeln("Scene 2 update, focused : ", info.focused);
	}

	override void draw(FrameInfo info) {
		writeln("Scene 2 draw, focused : ", info.focused);
		windowHeight = 5;
	}

	override void event(FrameInfo info, Event event) {

	}
}

void _main() {
	auto manager = new SceneManager();
	manager.push(new Scene1(manager));
	FrameInfo info;
	while (true) {
		info.frameIndex++;
		manager.update(info);
		manager.draw(info);
		Thread.sleep(seconds(1));
	}
}
