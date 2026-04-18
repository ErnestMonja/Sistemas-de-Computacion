#include <stdio.h>

/**
 * Capa Intermedia en C
 * Recibe el GINI como double (64 bits), lo castea a long y suma 1.
 */
long calcular_gini(double valor)
{
    // Conversión: el casteo a long elimina la parte decimal
    long parte_entera = (long)valor;
    
    // Incremento solicitado por la consigna
    long resultado = parte_entera + 1;
    
    // Opcional: imprimir desde C para ver la comunicación
    // printf("[C] Procesando %f -> Resultado: %ld\n", valor, resultado);
    
    return resultado;
}