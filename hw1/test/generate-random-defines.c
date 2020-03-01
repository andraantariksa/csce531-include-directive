/* Generates #define directives corresponding to a random function */
#include <stdlib.h>
#include <stdio.h>

#define MOD 1000
#define MAX 10000

int main()
{
    int i;
    long r1, r2;
    
    srandom(2019);
    printf("/* This file is the output of running generate-random-defines.c. */\n");
    for (i=0; i<MAX; i++) {
        r1 = random();
        r2 = random();
        printf("#define x%ld x%ld\n", r1%MOD, r2%MOD);
        if (i%20 == 0)
            printf("int x = x%ld\n", r1%MOD);
    }
    return 0;
}
