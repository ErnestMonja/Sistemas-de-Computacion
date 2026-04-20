


# TP#2: Calculadora de índices GINI

## Iteración 1 - Interoperabilidad Python y C

El objetivo es implementar un sistema que consulte el índice GINI desde la API del Banco Mundial y procese dicha información utilizando una arquitectura de capas, comunicando Python con una librería escrita en C.

### Arquitectura del Proyecto

El sistema está diseñado para ser modular y escalable, utilizando convenciones de llamada (ABI) para la comunicación entre capas:

1.  **Capa Superior (Python):** `main.py`. Se encarga de la interfaz con el usuario, el consumo de la API REST mediante `requests` y el manejo de los datos (filtrado y ordenamiento).
2.  **Capa Intermedia (C):** `libgini.c`. Recibe un valor `double` desde Python, realiza el casting a `long` y aplica el incremento (+1).

### Flujo de Proceso

1. **Python** solicita los datos a la API Rest.
2. **Python** filtra y limpia los datos.
3. **Python** invoca la función `calcular_gini` de la librería `libgini.so` mediante `ctypes`.
4. **C** procesa el valor y devuelve el resultado a **Python**.

### Resultado

Aquí se muestra la tabla final con los índices calculados:

![](Iteración%201%20-%20Python%20y%20C/Resultado.jpg)

## Iteración 2: Implementación en Ensamblador (x86-64)

Se profundizó en la arquitectura del sistema reemplazando la lógica aritmética implementada en C por una rutina escrita directamente en **Ensamblador (x86-64)**. El objetivo principal fue manipular registros y entender la convención de llamadas (ABI) de bajo nivel.

### Nueva Arquitectura
Ahora el flujo de control se optimizó para separar la gestión de tipos de la lógica de cómputo:

1.  **Capa Superior (Python):** Orquesta el proceso y consume la API.
2.  **Capa Intermedia (C):** Recibe el `double` de Python, realiza el casting a `long` (eliminando decimales) y delega el cálculo a la capa inferior.
3.  **Capa Inferior (Ensamblador):** Realiza la operación aritmética elemental (`n + 1`) utilizando registros directamente.

### Flujo de Proceso

1. **Python** solicita los datos a la API Rest.
2. **Python** filtra y limpia los datos.
3. **Python** invoca la función `procesar_valor` de la librería `libcalculo.so`.
4. **C** recibe el valor, lo convierte a long y llama a la rutina de **Assembler**.
5. **Assembler** crea el Stack Frame, suma 1 y devuelve el resultado en el registro `%rax`

A continuación se muestra una imagen de la creación del Stack Frame en el código de Assembler `Calculo.s`

![](Iteración%202%20-%20Python,%20C%20y%20Assembler/Capturas-GDB/Creacion_stackframe.png)

### Verificación con GDB

Para validar que el stack frame y el paso de parámetros funcionan correctamente, realizamos el seguimiento con `gdb`.

- Breakpoints: Se establecieron puntos de parada en sumar_uno para inspeccionar los registros.

- Análisis de Stack: Para verificar cómo se guardaba el rbp del llamador y la dirección de retorno antes de ejecutar el prólogo de la función.


![](Iteración%202%20-%20Python,%20C%20y%20Assembler/Capturas-GDB/Resultado.png)

### Resultado

El sistema ahora procesa la lógica aritmética en el nivel más bajo posible, garantizando una mayor eficiencia y demostrando la capacidad de integrar distintos lenguajes mediante el uso correcto de interfaces ABI.

![](Iteración%202%20-%20Python,%20C%20y%20Assembler/Tabla_Resultado_Final.png)
