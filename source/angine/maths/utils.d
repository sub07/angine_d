module angine.maths.utils;

import std.math;

float toRad(float deg) {
    return deg * PI / 180;
}

float toDeg(float rad) {
    return rad * 180 / PI;
}
