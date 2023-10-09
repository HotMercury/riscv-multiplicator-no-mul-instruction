#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

void print_binary(uint32_t x){
    printf("ob");
    for(int i = 31; i >= 0; i--){
        printf("%d", (x >> i) & 1);
        if(i % 4 == 0 && i != 0)
            printf(",");
    }
    printf("\n");
}

typedef union express{
    int IEEE_integer;
    float floating;
}express_t;

int main(int argc, char *argv[]){
    express_t num;
    num.floating = atof(argv[1]);

    printf("%f\n", num.floating);
    printf("0d%d\n", num.IEEE_integer);
    printf("0x%x\n", num.IEEE_integer);
    print_binary(num.IEEE_integer);
    return 0;
}