#include <cstdio>
#include <cassert>
#include <cmath>

struct Vec2f {
    float x, y;
};

float dist(Vec2f a, Vec2f b) {
    float dx2 = a.x - b.x, dy2 = a.y - b.y;
    dx2 = dx2 * dx2;
    dy2 = dy2 * dy2;
    float res = dx2 + dy2;
    res = std::sqrt(res);
    return res;
}

Vec2f gravity(Vec2f r, Vec2f rs) { // from r to rs
    float ax, ay;

    float d = dist(r, rs);
    float denom = d * d;
    denom = denom * d; // dist^(3/2)
    
    ax = rs.x - r.x;
    ax = ax / denom;

    ay = rs.y - r.y;
    ay = ay / denom;
    
    return {ax, ay};
}

const float m1 = 1.0, m2 = 1.0, m3 = 1.0;
Vec2f r1 = {0, 1}, r2 = {0.866025, -0.5}, r3 = {-0.866025, -0.5};
Vec2f v1 = {0.759836, 0}, v2 = {-0.379918, -0.658037}, v3 = {-0.379918, 0.658037};
Vec2f a1, a2, a3;

void step(float dt) {
    // compute accelarations:
    Vec2f f = gravity(r1, r2); // 1 -> 2
    a1.x = f.x * m2;
    a1.y = f.y * m2;

    a2.x = -f.x * m1;
    a2.y = -f.y * m1;

    f = gravity(r2, r3); // 2 -> 3
    a2.x += f.x * m3;
    a2.y += f.y * m3;

    a3.x = -f.x * m2;
    a3.y = -f.y * m2;

    f = gravity(r3, r1); // 3 -> 1
    a3.x += f.x * m1;
    a3.y += f.y * m1;

    a1.x -= f.x * m3;
    a1.y -= f.y * m3;

    // update velocities:
    v1.x += a1.x * dt;
    v1.y += a1.y * dt;
    
    v2.x += a2.x * dt;
    v2.y += a2.y * dt;

    v3.x += a3.x * dt;
    v3.y += a3.y * dt;

    // update positions:
    r1.x += v1.x * dt;
    r1.y += v1.y * dt;
    
    r2.x += v2.x * dt;
    r2.y += v2.y * dt;

    r3.x += v3.x * dt;
    r3.y += v3.y * dt;
}

int main()
{
    float t;
    const float dt = 0.01;
    for (int i = 0; i < 1000; ++i) {
        t = i * dt;
        if (i % 50 == 0 || (8.2 < t && t < 8.4)) {
            printf("at time %f, r1 = (%f, %f), \t|r1| = %f\n", t, r1.x, r1.y, std::sqrt(r1.x*r1.x + r1.y*r1.y));
            printf("at time %f, r2 = (%f, %f), \t|r2| = %f\n", t, r2.x, r2.y, std::sqrt(r2.x*r2.x + r2.y*r2.y));
            printf("at time %f, r3 = (%f, %f), \t|r3| = %f\n", t, r3.x, r3.y, std::sqrt(r3.x*r3.x + r3.y*r3.y));
        }
        step(dt);
    }
    return 0;
}