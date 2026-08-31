#include <stdio.h>

int main(){
    int a=5;
    int b=5;

    printf("a=%d, b=%d", a, b);

    int i=a;
    int j=a;

    printf("i=%d , j=%d ", i, j);

    printf("i++=%d , ++j=%d ", i++, ++j);

    printf("i=%d, j=%d ", i, j);
    return 0;
}