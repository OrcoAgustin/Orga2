//Realizar un programa que compare si los 3 bits m´as altos de una palabra de 32 bits son
//iguales a los 3 bits m´as bajos de otra palabra de 32 bits. Si son iguales, informarlo por
//pantalla.

#include <stdio.h>

int main(){
    unsigned int a = 0x80000000;
    unsigned int b = 0x00000008;

    printf("a shifteado: %d\n" , a >> 29 );
    printf("b enmascarado: %d\n", b & 0x07);

    if ((a >> 29) == (b & 0x07)) {
        printf("a: %d\n", a);
        printf("b: %d\n", b);
        
        printf("Los 3 bits mas altos de a son iguales a los 3 bits mas bajos de b\n");
    }

    return 0;
}