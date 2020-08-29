module snake;

import std.stdio;
import std.string;
import threev.angine;
import std.math;
import std.random;
import std.container;
import std.exception;
import std.conv;
import std.format;
import std.functional;

immutable vTex = `
#version 460

layout(location = 0) in vec2 vertexPosition;
layout(location = 1) in vec2 texturePosition;
layout(location = 2) in vec4 color;

out vec2 texPos;
out vec4 tint;
uniform vec2 viewportSize;

void main() {
	vec2 workingVec = vertexPosition;
	workingVec.x = workingVec.x * (2 / viewportSize.x) - 1;
	workingVec.y = workingVec.y * -(2 / viewportSize.y) + 1;
	gl_Position = vec4(workingVec, 0.0, 1.0);
	texPos = texturePosition;
	tint = color;
}
`;

immutable fTex = `
#version 460

in vec2 texPos;
in vec4 tint;
uniform sampler2D textureUnit;
out vec4 finalPixelColor;

void main() {
    finalPixelColor = texture(textureUnit, texPos) * tint;
}
`;

immutable fText = `
#version 460

in vec2 texPos;
in vec4 tint;
uniform sampler2D textureUnit;
out vec4 finalPixelColor;

void main() {
    finalPixelColor = vec4(1, 1, 1, texture(textureUnit, texPos).r) * tint;
}
`;

enum {
	cellSize = Vec(32, 32),
	gridSize = Vec(10, 10),
	screenSize = Vec(800, 600)
}

Vec randomPos() {
	return Vec(uniform(2, cast(int) gridSize.w - 2), uniform(2, cast(int) gridSize.h - 2));
}

Vec randomApplePos() {
	return Vec(uniform(0, cast(int) gridSize.w), uniform(0, cast(int) gridSize.h));
}

float rotateFromOrientation(Orientation o) {
	final switch (o) {
	case Orientation.North:
		return PI_2;
	case Orientation.South:
		return -PI_2;
	case Orientation.West:
		return 0;
	case Orientation.East:
		return PI;
	}
}

enum Orientation {
	North,
	South,
	West,
	East
}

Orientation randomOrientation() {
	immutable r = uniform(0, 4);
	final switch (r) {
	case 0:
		return Orientation.North;
	case 1:
		return Orientation.South;
	case 2:
		return Orientation.West;
	case 3:
		return Orientation.East;
	}
}

Vec vecFromOrientation(Orientation o) {
	final switch (o) {
	case Orientation.North:
		return Vec(0, -1);
	case Orientation.South:
		return Vec(0, 1);
	case Orientation.West:
		return Vec(-1, 0);
	case Orientation.East:
		return Vec(1, 0);
	}
}

Orientation oppositeOrientation(Orientation o) {
	final switch (o) {
	case Orientation.North:
		return Orientation.South;
	case Orientation.South:
		return Orientation.North;
	case Orientation.East:
		return Orientation.West;
	case Orientation.West:
		return Orientation.East;
	}
}

struct SnakePart {
	bool tail;
	Vec pos;
	Orientation o;

	string toString() const {
		return pos.toString() ~ ", " ~ to!string(o);
	}
}

final class Snake {
	Image snakeImg;

	Shader textureShader;
	Shader textShader;

	TextureBatch batch;

	Texture snakeTex;

	SubTexture snakeHead;
	SubTexture snakeBody;
	SubTexture snakeTail;
	SubTexture appleTex;
	SubTexture cellTex;
	SubTexture gameOverRect;

	Font courier;

	Vec centeringOffset;
	auto snake = Array!SnakePart();

	SnakePart head;
	SnakePart tail;

	Vec apple;

	int score = 0;

	bool gameOver = false;
	bool pause = false;

	Window window;

	this(Window w) {
		window = w;
		centeringOffset = Vec(w.width, w.height) / 2 - (cellSize * gridSize) / 2;
		apple = randomApplePos();
		snakeImg = new Image("assets/snake.png");
		textureShader = new Shader(vTex, fTex);
		textShader = new Shader(vTex, fText);
		courier = new Font("assets/courier.ttf", 40);
		textureShader.sendVec2("viewportSize", w.width, w.height);
		textShader.sendVec2("viewportSize", w.width, w.height);
		batch = new TextureBatch(1000, textureShader, textShader);
		batch.transparency = true;
		snakeTex = new Texture(TextureFilter.Nearest, snakeImg.width,
				snakeImg.height, snakeImg.format, snakeImg.data.ptr);

		snakeHead = snakeTex.subTextureOf(Rect(0, 0, 32, 32));
		snakeBody = snakeTex.subTextureOf(Rect(32, 0, 32, 32));
		snakeTail = snakeTex.subTextureOf(Rect(64, 0, 32, 32));
		appleTex = snakeTex.subTextureOf(Rect(96, 0, 32, 32));
		cellTex = snakeTex.subTextureOf(Rect(128, 0, 32, 32));
		gameOverRect = snakeTex.subTextureOf(Rect(160, 0, 1, 1));
		snake.reserve(cast(int)(gridSize.w * gridSize.h) / 3);

		head = SnakePart(true, randomPos(), randomOrientation());
		tail = SnakePart(true, head.pos - vecFromOrientation(head.o), head.o);

		growSnake();
	}

	void growSnake() {
		snake ~= SnakePart(false, tail.pos, tail.o);
		tail.pos -= vecFromOrientation(tail.o);
	}

	private void adjustOrientation() {
		immutable beforeLast = snakeBeforeLast();
		tail.o = beforeLast.o;

		for (int i = 0; i < snake.length() - 1; i++) {
			snake[$ - 1 - i].o = snake[$ - 2 - i].o;
		}

		auto secondBody = snakeSecond();
		secondBody.o = head.o;

		snakeSecond() = secondBody;
	}

	private void step() {
		head.pos += vecFromOrientation(head.o);
		tail.pos += vecFromOrientation(tail.o);
		foreach (ref part; snake) {
			part.pos += vecFromOrientation(part.o);
		}
	}

	private void checkOutOfGrid() {
		if (head.pos.x < 0)
			head.pos.x = gridSize.w - 1;
		if (head.pos.x >= gridSize.w)
			head.pos.x = 0;
		if (head.pos.y < 0)
			head.pos.y = gridSize.h - 1;
		if (head.pos.y >= gridSize.h)
			head.pos.y = 0;

		if (tail.pos.x < 0)
			tail.pos.x = gridSize.w - 1;
		if (tail.pos.x >= gridSize.w)
			tail.pos.x = 0;
		if (tail.pos.h < 0)
			tail.pos.h = gridSize.h - 1;
		if (tail.pos.h >= gridSize.h)
			tail.pos.h = 0;

		foreach (ref part; snake) {
			if (part.pos.x < 0)
				part.pos.x = gridSize.w - 1;
			if (part.pos.x >= gridSize.w)
				part.pos.x = 0;
			if (part.pos.y < 0)
				part.pos.y = gridSize.h - 1;
			if (part.pos.y >= gridSize.h)
				part.pos.y = 0;
		}
	}

	private bool onSnakeBody(Vec v) {
		foreach (part; snake ~ tail) {
			if (part.pos == v)
				return true;
		}
		return false;
	}

	private void checkOnApple() {
		if (head.pos == apple) {
			growSnake();
			score++;
			do {
				apple = randomApplePos();
			}
			while (onSnakeBody(apple) || apple == head.pos);
		}
	}

	private void checkCollision() {
		if (onSnakeBody(head.pos))
			gameOver = true;
	}

	void tick() {
		step();
		adjustOrientation();
		checkOutOfGrid();
		checkCollision();
		checkOnApple();
		checkOutOfGrid();
	}

	double timeAcc = 0;
	double tickInterval = 0.4;

	ref SnakePart snakeSecond() {
		return snake.empty ? tail : snake.front();
	}

	SnakePart snakeBeforeLast() {
		return snake.empty ? head : snake.back();
	}

	void retry() {
		gameOver = false;
		score = 0;
		snake.clear();
		tail = SnakePart(true, head.pos - vecFromOrientation(head.o), head.o);
		growSnake();
	}

	void loop(double dt) {
		if (!pause)
			timeAcc += dt;
		if (timeAcc > tickInterval) {
			timeAcc = 0.0;
			if (!gameOver) {
				tick();
			}
		}

		batch.begin();
		for (float x = 0; x < gridSize.w; x++) {
			for (float y = 0; y < gridSize.h; y++) {
				batch.drawTexture(cellTex, Vec(x, y) * cellSize + centeringOffset);
			}
		}

		batch.drawTexture(snakeHead, head.pos * cellSize + Vec(16,
				16) + centeringOffset, Vec(1), Vec(16, 16), rotateFromOrientation(head.o));
		batch.drawTexture(snakeTail, tail.pos * cellSize + Vec(16,
				16) + centeringOffset, Vec(1), Vec(16, 16), rotateFromOrientation(tail.o));

		foreach (part; snake) {
			batch.drawTexture(part.tail ? snakeTail : snakeBody,
					part.pos * cellSize + Vec(16, 16) + centeringOffset, Vec(1),
					Vec(16, 16), rotateFromOrientation(part.o));
		}

		batch.drawTexture(appleTex, apple * cellSize + centeringOffset);

		if (gameOver) {
			batch.drawTexture(gameOverRect, Vec(), Vec(window.width, window.height));
			Vec gameOverStringSize = courier.stringSize("GAME OVER ! (Press R to retry)");
			batch.drawString(courier, "GAME OVER ! (Press R to retry)", Color.white,
					Vec(window.width, window.height) / 2, Vec(1), gameOverStringSize / 2, 0);
		}

		if (pause && !gameOver) {
			batch.drawTexture(gameOverRect, Vec(), Vec(window.width, window.height));
			Vec pauseStringSize = courier.stringSize("PAUSE");
			batch.drawString(courier, "PAUSE", Color.white, Vec(window.width,
					window.height) / 2 - pauseStringSize / 2);
		}

		Vec scoreStringSize = courier.stringSize(format("Score: %s", score));
		batch.drawString(courier, format("Score: %s", score),
				Vec(window.width / 2 - scoreStringSize.x / 2, 10));
		batch.end();
	}
}

class EventManager {
	Snake s;
	void keyCallback(Key key, ActionState action, Modifiers m) {
		if (action == ActionState.Pressed) {
			if (key == Key.Space) {
				s.pause = !s.pause;
			}
			if (key == Key.Up) {
				immutable second = s.snakeSecond();
				if (second.o != Orientation.South) {
					s.head.o = Orientation.North;
				}
			}
			if (key == Key.Down) {
				immutable second = s.snakeSecond();
				if (second.o != Orientation.North) {
					s.head.o = Orientation.South;
				}
			}
			if (key == Key.Left) {
				immutable second = s.snakeSecond();
				if (second.o != Orientation.East) {
					s.head.o = Orientation.West;
				}
			}
			if (key == Key.Right) {
				immutable second = s.snakeSecond();
				if (second.o != Orientation.West) {
					s.head.o = Orientation.East;
				}
			}
			if (key == Key.R && s.gameOver) {
				s.retry();
			}
		}
	}
}

void main() {
	immutable conf = WindowConfig(800, 600, "Snake", false, true, false, 0);
	auto eventManager = new EventManager();
	immutable callbacks = WindowEventCallbacks(&eventManager.keyCallback);
	Window w = new GLFWWindow(conf, callbacks);

	loadGlFromLoader(w.loader());
	writeln(glVersion());
	setClearColor(0, 0, 0, 1.0);

	Snake game = new Snake(w);

	eventManager.s = game;

	double last = now();

	while (!w.shouldClose()) {
		w.pumpEvent();
		immutable dt = now() - last;
		last = now();

		clearScreen();
		game.loop(dt);

		w.swapBuffers();
	}
	destroy(w);
}
