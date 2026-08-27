#include <stdio.h>

int ej5 (){
    float a = 0.1f;
    double b = 0.1;
    printf("float: %.20f\n", a);
    printf("double: %.20f\n", b);

    printf("cast de float a int: %i\n",(int)a);
    printf("cast de double a int: %i\n",(int)b);

    return 0;
}

int mensajeSecreto (){
    int mensaje_secreto[] = {116, 104, 101, 32, 103, 105, 102, 116, 32, 111,
    102, 32, 119, 111, 114, 100, 115, 32, 105, 115, 32, 116, 104, 101, 32,
    103, 105, 102, 116, 32, 111, 102, 32, 100, 101, 99, 101, 112, 116, 105,
    111, 110, 32, 97, 110, 100, 32, 105, 108, 108, 117, 115, 105, 111, 110};
    
    size_t length = sizeof(mensaje_secreto) / sizeof(int);
    printf("size_t: %zu\n", length);

    char decoded[length];
    for (int i = 0; i < length; i++) {
        decoded[i] = (char) (mensaje_secreto[i]);
        printf("decoded en %i : %c\n", i, decoded[i]);
    }
    for (int i = 0; i < length; i++) {
        printf("%c", decoded[i]);
    }
    return 0;
}

int main (){
    mensajeSecreto();
    return 0;
}

