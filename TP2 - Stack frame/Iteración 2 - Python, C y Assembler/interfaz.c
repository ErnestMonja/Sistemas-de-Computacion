#include <stdio.h>

// Declaramos la función que está en el archivo .s
extern long sumar_uno(long n);

// Esta es la función que llamará Python
long procesar_valor(double valor_gini) {
    // Conversión de float (double) a entero (long) [cite: 25, 652]
    long valor_entero = (long)valor_gini;
    
    // Llamada a la capa inferior (Assembler) [cite: 24]
    return sumar_uno(valor_entero);
}