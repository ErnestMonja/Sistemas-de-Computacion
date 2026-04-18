#include <stdio.h>

/**
 * Capa Intermedia en C: Recibe el GINI como double (64 bits), lo castea a long y suma 1.
 */
long calcular_gini(double valor)
{
    // Conversión: el casteo a long elimina la parte decimal
    long parte_entera = (long) valor;
    
    // se realiza el incremento deseado
    long resultado = parte_entera + 1;
    
    return resultado;
}
