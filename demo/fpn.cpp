#include <cstdio>
#include <cassert>
#include <random>
#include <ctime>

constexpr uint32_t W = 1 << 16;

// signed fixed point number, integer part 15 bits + sign, decimal part unsigned 16 bits
struct Fixed // real value := d * 2^-16 === (d >> 16) + (d & 0x0000FFFF) * [2^-16] === (d >> 16).(d & 0x0000FFFF)
{
    uint32_t d;
};

void disp(Fixed a);

Fixed add(Fixed a, Fixed b)
{
    return Fixed{a.d + b.d};
}

Fixed sub(Fixed a, Fixed b)
{
    return Fixed{a.d - b.d};
}

Fixed mul(Fixed a, Fixed b)
{
    uint64_t c = uint64_t(a.d) * uint64_t(b.d);
    bool sign = c < 0;
//    printf("%.8x * %.8x = %.16llx * %.16llx = %.16llx  ", a.d, b.d, int64_t(a.d), int64_t(b.d), c);
    return Fixed{uint32_t(sign ? (c >> 16) | 0x80000000 : (c >> 16) & 0x7FFFFFFF)};
}

Fixed div(Fixed a, Fixed b)
{
    uint32_t q = a.d / b.d, r = a.d % b.d;
//    printf("%.8x / %.8x, q = %.8x, r = %.8x   ", a.d, b.d, q, r);
    uint32_t c = 0;
    for (int i = 1; i <= 16; ++i) {
        r <<= 1;
        c <<= 1;
        c += r / b.d;
        r = r % b.d;
    }
    return Fixed{(q << 16) + c};
}

struct Pos
{
    Fixed x, y;
};

Fixed sqrt(Fixed a)
{
    Fixed x = Fixed{a.d >> 1};
    for (int i = 0; i < 10; ++i) {
        x = add(x, div(a, x));
        x.d >>= 1;
    }
    return x;
}

Fixed dist(Pos a, Pos b)
{
    Fixed dx = sub(a.x, b.x);
    Fixed dy = sub(a.y, b.y);
    disp(add(mul(dx, dx), mul(dy, dy)));
    return sqrt(add(mul(dx, dx), mul(dy, dy)));
}


// *** below are just for tests
Fixed fromFloat(float f)
{
    return Fixed{uint32_t(f * W)};
}

float toFloat(Fixed a)
{
    return uint32_t(a.d) * 1.0 / W;
}

void disp(Fixed a)
{
    printf("%f [0x%.8x]\n", toFloat(a), a.d);
}


int main()
{
    std::default_random_engine engine;
    std::uniform_real_distribution<float> gen(1, 100);
    float diff = 0;
    for (int i = 0; i < 1000; ++i) {
        float a = gen(engine), b = gen(engine), c = a + b;
        Fixed fa = fromFloat(a), fb = fromFloat(b), fc = add(fa, fb);
        diff = std::max(std::abs(toFloat(fc) - c), diff);
    }
    printf("add: max diff = %f\n", diff);
    diff = 0;
    for (int i = 0; i < 1000; ++i) {
        float a = gen(engine), b = gen(engine), c = a - b;
        Fixed fa = fromFloat(a), fb = fromFloat(b), fc = sub(fa, fb);
        diff = std::max(std::abs(toFloat(fc) - c), diff);
    }
    printf("sub: max diff = %f\n", diff);
    diff = 0;
    for (int i = 0; i < 100000; ++i) {
        float a = gen(engine), b = gen(engine), c = a * b;
        Fixed fa = fromFloat(a), fb = fromFloat(b), fc = mul(fa, fb);
        diff = std::max(std::abs(toFloat(fc) - c), diff);
//        printf("%f * %f == %f,  fixed: %f\n", a, b, c, toFloat(fc));
    }
    printf("mul: max diff = %f\n", diff);
    diff = 0;
    for (int i = 0; i < 10000; ++i) {
        float a = gen(engine), b = gen(engine), c = a / b;
        Fixed fa = fromFloat(a), fb = fromFloat(b), fc = div(fa, fb);
        diff = std::max(std::abs(toFloat(fc) - c), diff);
//        printf("%f / %f == %f,  fixed: %f\n", a, b, c, toFloat(fc));
    }
    printf("div: max diff = %f\n", diff);
    diff = 0;
    for (int i = 0; i < 1000; ++i) {
        float a = gen(engine), b = std::sqrt(a);
        Fixed fa = fromFloat(a), fb = sqrt(fa);
        diff = std::max(std::abs(toFloat(fb) - b), diff);
    }
    printf("sqrt: max diff = %f\n", diff);
    diff = 0;
    for (int i = 0; i < 1; ++i) {
//        float a = gen(engine), b = gen(engine), c = gen(engine), d = gen(engine);
//        printf("(%f, %f), (%f, %f)\n",a ,b,c,d);
        float a = 3, b = 0, c = 0, d = 4.1;
        disp(mul(sub(fromFloat(b), fromFloat(d)), sub(fromFloat(b), fromFloat(d))));
        float temp = (a - c) * (a - c) + (b - d) * (b - d);
        printf("%f  ", temp);
        float ref = std::sqrt(temp);
        Pos s = {fromFloat(a), fromFloat(b)}, t = {fromFloat(c), fromFloat(d)};
        Fixed res = dist(s, t);
        diff = std::max(std::abs(toFloat(res) - ref), diff);
    }
    printf("dist: max diff = %f\n", diff);
    return 0;
}