typedef int fpn32_t;

fpn32_t div(fpn32_t a, fpn32_t b) {
    return 0;
}

fpn32_t sqrt(fpn32_t a)
{
    register fpn32_t x = a >> 1;
    for (register int i = 0; i < 10; ++i) {
        x = x + div(a, x);
        x >>= 1;
    }
    return x;
}
