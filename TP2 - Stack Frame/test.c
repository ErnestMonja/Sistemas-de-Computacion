#include <stdio.h>

extern long sumar_uno(long n);

int main() {
    long a = 10;
    long resultado = sumar_uno(a);
    printf("Resultado: %ld\n", resultado);
    return 0;
}