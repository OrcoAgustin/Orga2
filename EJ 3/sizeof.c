#include <stdio.h>

int main() {
    char c = 100;
    unsigned char uc = 254;  
    short s = 23000;
    unsigned short us = 64000;
    int i =  2147483000;
    unsigned int ui = 3147483000;
    long long l = 5294967295;
    unsigned long long ul = 184000000000000;

    printf("char(%llu): %c \n", sizeof(c),c);
    printf("unsigned char(%llu): %u \n", sizeof(uc),uc);
    printf("short(%llu): %d \n", sizeof(s),s);
    printf("unsigned short(%llu): %u \n", sizeof(us),us);
    printf("int(%llu): %d \n", sizeof(i),i);
    printf("unsigned int(%llu): %u \n", sizeof(ui),ui);
    printf("long(%llu): %lld \n", sizeof(l),l);
    printf("unsigned long(%llu): %llu \n", sizeof(ul),ul);

    return 0;
}