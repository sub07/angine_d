module threev.angine.core.time;
import core.time;

MonoTime startTime;

static this() {
    resetTimer();
}

double now() {
    Duration d = MonoTime.currTime - startTime;
    return d.total!"nsecs" / 1_000_000_000.0;
}

void resetTimer() {
    startTime = MonoTime.currTime;
}
