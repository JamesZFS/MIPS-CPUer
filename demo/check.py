W = 2**16

def to_float(x):
    assert x >= 0x10000000 and x <= 0xFFFFFFFF
    return -((1<<32)-x)/W if x & 0x80000000 else x/W

def from_float(x):
    return hex(int(x * W) & 0xFFFFFFFF)

print(to_float(0xed8f015d))

print(to_float(int(from_float(-4720.9946746), 16)))
