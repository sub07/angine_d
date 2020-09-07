module snake;

import threev.angine;
import std;

final class Snake : AngineScene {
    Vec cellSize = Vec(32, 32);
    Vec gridSize = Vec(10, 10);

    Texture snakeTex;

    SubTexture snakeHead;
    SubTexture snakeBody;
    SubTexture snakeTail;
    SubTexture appleTex;
    SubTexture cellTex;
    SubTexture gameOverRect;

    Font courier;

    auto snake = Array!SnakePart();

    SnakePart head;
    SnakePart tail;

    Vec apple;

    int score = 0;

    bool gameOver = false;
    bool pause = false;

    float timeAcc = 0;
    float tickInterval = 0.4;

    Entity e;

    this(Angine a) {
        super(a);
        apple = randomApplePos();
        Image snakeImg = new Image("assets/snake.png");
        courier = new Font("assets/courier.ttf", 40);
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
        e = new Entity();
        growSnake();
    }

    override void update(FrameInfo i) {
        if (!pause)
            timeAcc += i.dt;
        if (timeAcc > tickInterval) {
            timeAcc = 0.0;
            if (!gameOver) {
                tick();
            }
        }
    }

    override void draw(FrameInfo i) {
        for (float x = 0; x < gridSize.w; x++) {
            for (float y = 0; y < gridSize.h; y++) {
                drawTexture(cellTex, Vec(x, y) * cellSize + centeringOffset);
            }
        }

        drawTexture(snakeHead, head.pos * cellSize + Vec(16,
                16) + centeringOffset, Vec(1), Vec(16, 16), rotateFromOrientation(head.o));
        drawTexture(snakeTail, tail.pos * cellSize + Vec(16,
                16) + centeringOffset, Vec(1), Vec(16, 16), rotateFromOrientation(tail.o));

        foreach (part; snake) {
            drawTexture(part.tail ? snakeTail : snakeBody,
                    part.pos * cellSize + Vec(16, 16) + centeringOffset, Vec(1),
                    Vec(16, 16), rotateFromOrientation(part.o));
        }

        drawTexture(appleTex, apple * cellSize + centeringOffset);

        if (gameOver) {
            drawTexture(gameOverRect, Vec(), Vec(windowSize.w, windowSize.h));
            Vec gameOverStringSize = courier.stringSize("GAME OVER ! (Press R to retry)");
            drawString(courier, "GAME OVER ! (Press R to retry)", Color.white,
                    Vec(windowSize.w, windowSize.h) / 2, Vec(1), gameOverStringSize / 2, 0);
        }

        if (pause && !gameOver) {
            drawTexture(gameOverRect, Vec(), Vec(windowSize.w, windowSize.h));
            Vec pauseStringSize = courier.stringSize("PAUSE");
            drawString(courier, "PAUSE", Color.white, Vec(windowSize.w,
                    windowSize.h) / 2 - pauseStringSize / 2);
        }

        Vec scoreStringSize = courier.stringSize(format("Score: %s", score));
        drawString(courier, format("Score: %s", score), Color.white,
                Vec(windowSize.w / 2 - scoreStringSize.x / 2, 10));
    }

    override void onKeyDown(Key key, Modifiers mods) {
        if (key == Key.Space) {
            pause = !pause;
        }
        if (key == Key.Up) {
            immutable second = snakeSecond();
            if (second.o != Orientation.South) {
                head.o = Orientation.North;
            }
        }
        if (key == Key.Down) {
            immutable second = snakeSecond();
            if (second.o != Orientation.North) {
                head.o = Orientation.South;
            }
        }
        if (key == Key.Left) {
            immutable second = snakeSecond();
            if (second.o != Orientation.East) {
                head.o = Orientation.West;
            }
        }
        if (key == Key.Right) {
            immutable second = snakeSecond();
            if (second.o != Orientation.West) {
                head.o = Orientation.East;
            }
        }
        if (key == Key.R && gameOver) {
            retry();
        }
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

    @property Vec centeringOffset() {
        return windowSize / 2 - (cellSize * gridSize) / 2;
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

    void growSnake() {
        snake ~= SnakePart(false, tail.pos, tail.o);
        tail.pos -= vecFromOrientation(tail.o);
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
    }

}

void main() {
    AngineConfig config = AngineConfig();
    Angine a = new Angine(config);
    a.launch!Snake;
}
