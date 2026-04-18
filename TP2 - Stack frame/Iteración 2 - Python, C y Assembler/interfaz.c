#include <stdio.h>

extern long sumar_uno(long n);

long procesar_valor(double valor_gini) {
    // convertir el float de la API a entero 
    long valor_entero = (long)valor_gini;
    

    return sumar_uno(valor_entero);
}