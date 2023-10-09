/*
2023 computer architecture Q1.C
*/
#include <stdio.h>
#include <stdint.h>

// from Q1.A
// find the place of high 1 bit
// ex . 11010011 -> 11111111 
// preserve the high 1 bit and set all the bits after it to 1
uint64_t mask_lowest_one(uint64_t x){
    uint64_t mask = x;
    x |= (x >> 1);
    x |= (x >> 2);
    x |= (x >> 4);
    x |= (x >> 8);
    x |= (x >> 16);
    x |= (x >> 32);
    return mask;
}

// find the place of lowest zero bit
// ex . 11010011 -> 00000011 
// preserve the lowest zero bit and set all the bits after it to 1
uint64_t mask_lowest_zero(uint64_t x)
{
    uint64_t mask = x;
    mask &= (mask << 1) | 0x1;
    mask &= (mask << 2) | 0x3;
    mask &= (mask << 4) | 0xF;
    mask &= (mask << 8) | 0xFF;
    mask &= (mask << 16) | 0xFFFF;
    mask &= (mask << 32) | 0xFFFFFFFF;
    return mask;
}

// add x by 1
int64_t inc(int64_t x)
{
    // x = all one bits will overflow to 0
    if (~x == 0)
        return 0;
    // set carry flag
    int64_t mask = mask_lowest_zero(x);
    // 0011 -> 0100
    int64_t z1 = mask ^ ((mask << 1) | 1);
    return (x & ~mask) | z1;
}

// get precision bit value
static inline int64_t getbit(int64_t value, int n)
{
    return (value >> n) & 1;
}

/* int32 multiply */
int64_t imul32(int32_t a, int32_t b)
{
    int64_t r = 0, a64 = (int64_t) a, b64 = (int64_t) b;
    for (int i = 0; i < 32; i++) {
        if (getbit(b64, i))
            r += a64 << i;
    }
    return r;
}
// improve int32 multiply
int64_t imul32_improve(int32_t a, int32_t b)
{
    int64_t r = (int64_t)b;
    int64_t a64 = (int64_t)a;
    for (int i = 0; i < 32; i++){
        if(r & 1){
            r = r + (a64 << 32);
        }
        r = r >> 1;
    }
    return r;
}

/* float32 multiply */
float fmul32(float a, float b)
{
    /* TODO: Special values like NaN and INF */
    int32_t ia = *(int32_t *) &a, ib = *(int32_t *) &b;

    /* sign */
    int sa = ia >> 31;
    int sb = ib >> 31;

    /* mantissa */
    int32_t ma = (ia & 0x7FFFFF) | 0x800000;
    int32_t mb = (ib & 0x7FFFFF) | 0x800000;

    /* exponent */
    int32_t ea = ((ia >> 23) & 0xFF);
    int32_t eb = ((ib >> 23) & 0xFF);

    /* 'r' = result */
    int64_t mrtmp = imul32(ma, mb) >> 23;
    int mshift = getbit(mrtmp, 24);

    int64_t mr = mrtmp >> mshift;
    //sub overlap exponent
    int32_t ertmp = ea + eb - 127;
    int32_t er = mshift ? inc(ertmp) : ertmp;
    /* TODO: Overflow ^ */
    int sr = sa ^ sb;
    int32_t r = (sr << 31) | ((er & 0xFF) << 23) | (mr & 0x7FFFFF);
    return *(float *) &r;
}

int main(){
    float a = 2.5;
    float b = 2.5;
    float c = fmul32(a, b);
    printf("%f\n", c);
    return 0;
}

