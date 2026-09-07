#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "../test-utils.h"
#include "Memoria.h"

int main() {
 /* Pruebas para strPrint */
    printf("Prueba con texto: ");
    strPrint("Hola Orga 2!\n", stdout);
    printf("Prueba con vacio: ");
    strPrint("", stdout);
    printf("\n");
    printf("Prueba con NULL: ");
    strPrint(NULL, stdout);
    printf("\n");
    return 0;
}
