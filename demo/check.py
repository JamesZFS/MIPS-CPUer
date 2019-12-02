import math

W = 2**16

def org_code(x):
    # assert x >= 0x10000000 and x <= 0xFFFFFFFF
    return hex(-((1<<32)-x) if x & 0x80000000 else x)

def to_float(x):
    # assert x >= 0x10000000 and x <= 0xFFFFFFFF
    return -((1<<32)-x)/W if x & 0x80000000 else x/W

def from_float(x):
    return hex(int(x * W) & 0xFFFFFFFF)

# print(org_code(0xfffff000))
# print(to_float(0xfffff000))
# print(to_float(int(from_float(-4720.9946746), 16)))

# a = 200.454; b = -0.0254; c = a * b
# print("[a] = %s \n[b] = %s" %(from_float(a), from_float(b)))
# print("c =", c, "\n[c] =", from_float(c))
# print("out =", to_float(0x001fffed))

a = 12348.02161
print("[a] = %s " % from_float(a))
b = math.sqrt(a)
print("b =", b, "\n[b] =", from_float(b))
print("out =", to_float(0x00250000))
