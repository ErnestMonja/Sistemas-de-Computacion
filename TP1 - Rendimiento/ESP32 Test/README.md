# Informe de Análisis de Rendimiento variando la Frecuencia de CPU en una ESP32 utilizando Simulación en Wokwi.

---

## 1- Introducción al Rendimiento
De acuerdo a la bibliografía presentada en esta asignatura, se define al rendimiento de un sistema como la capacidad que tiene dicho sistema para realizar un trabajo en un determinado tiempo. Es inversamente proporcional al tiempo, es decir, cuanto mayor sea el tiempo que necesite, menor será el rendimiento. Se tiene entonces que en base a esta definición, es de esperarse que al aumentar la frecuencia de trabajo de nuestro `CPU`, se pueden entonces ejecutar una mayor cantidad de instrucciones por unidad de tiempo, es decir y en términos más simplistas: los programas se ejecutarán más rápidos.

En esta sección del Trabajo Práctico 1, se buscó estudiar de forma empírica esta relación, utilizando como base la placa `ESP32` la cual tiene la ventaja de que permite ajustar la frecuencia de trabajo de su `CPU`. Para ello, se ejecutó un código el cual compara la velocidad de ejecución de un código a medida que se modifica la frecuencia de trabajo del `CPU`.

---

## 2- Análisis Empírico
### 2.1 - Realización de la Prueba
Dado que no se tuvo posesión de una `ESP32` en forma física, se optó por usar un simulador online llamado [Wokwi](https://wokwi.com/projects/new/esp32-s3), el cual permite introducir un código en `C/C++` y lo compila en una instancia virtual de este microcontrolador, la cual a fines prácticos de nuestro análisis de rendimiento, resulta suficiente.

Para realizar tal medición y análisis, se diseñó un código en `C` el cual realizó una serie de sumas tanto para números enteros como flotantes y midió el tiempo de ejecución mediante el comando `millis()`, para tales tareas a medida que se varió la frecuencia de la `CPU` de la placa. Para esto, se utilizó el código que se encuentra en este directorio y se llama `ESP32 Test.c`.

En este código se llama a la función `ejecutarPrueba()` la cual toma como parámetro la frecuencia de la `CPU` a la cual se debe realizar el test. Internamente esta función llama a otras dos funciones llamadas `testEnteros()` y `testFloats()` las cuales ejecutan un ciclo `for()` con sumas de `500000` iteraciones.

---

### 2.2- Obtención de los Resultados
Una vez explicado el funcionamiento de este código, se procedió a la ejecución del mismo donde se obtuvieron los siguientes valores: 

| Frecuencia `[MHz]` | Tiempo enteros `[ms]` | Tiempo float `[ms]` | Tiempo total `[ms]` |
|--------------------|-----------------------|---------------------|---------------------|
| 2                  | 2828                  | 31891               | 34719               |
| 4                  | 1435                  | 16034               | 17469               |
| 8                  | 1076                  | 11996               | 13072               |

![Resultados del test](https://github.com/ErnestMonja/Sistemas-de-Computacion/blob/main/TP1%20-%20Rendimiento/ESP32%20Test/ESP32%20-%20Test%20Results.png)
---

> Nótese que las frecuencias de trabajo del `CPU` utilizadas, son comparativamente bajas a las que suele trabajar la `CPU` normalmente, esto se debió a que [Wokwi](https://wokwi.com/projects/new/esp32-s3) internamente limita la frecuencia de trabajo del `CPU` a `8 [MHz]` por defecto, de modo que si las frecuencias se aumentan (por ejemplo en 1 orden de magnitud), tales cambios no se reflejan en la simulación y los tiempos de ejecución serán todos iguales. Esto se puede confirmar consultando la documentación del simulador en: [ESP32 CPU frequency limit](https://docs.wokwi.com/guides/esp32#cpu-frequency-limit)

---

### 2.3- Análisis del Tiempo total
Se propone analizar primeramente, cómo varía el tiempo de ejecución en función de la frecuencia de la `CPU` de la `ESP32` al ejecutar tanto las operaciones de números enteros como de números flotantes, ya que nos permitirá realizar una conclusión interesante. Veamos entonces, cómo podemos relacionar las frecuencias de trabajo de la `CPU` de acuerdo a los tiempos totales de ejecución del código, tomando como referencia la frecuencia de trabajo más alta.

| Comparación | Relación Teórica de Frecuencias | Relación Medida de Tiempos|
|-------------|---------------------------------|---------------------------|
| 8 → 4 MHz   | 8/4 = **2,00×**                 | 17469/13072 ≈ **1,33×**   |
| 8 → 2 MHz   | 8/2 = **4,00×**                 | 34719/13072 ≈ **2,65×**   |

Se observa de acuerdo a esta tabla, que por ejemplo en la primera fila, si bien se ha reducido la frecuencia de trabajo en un `50 [%]`, se tiene que los tiempos de ejecución solo han aumentado un `~33 [%]` (cuando debieron aumentar un `100 [%]`) y para la segunda fila se observa un resultado aún más alejado: para una reducción de la frecuencia de trabajo de un `25 [%]`, los tiempos de ejecución aumentan un `~165 [%]` (cuando debieron aumentar un `200 [%]`). Esto nos conlleva a pensar que no hay una relación causal directa entre la frecuencia de trabajo y los tiempos de medición, es decir:

$$
T_{prog} \neq \frac{1}{f_{CPU}}
$$

Se tiene que esta inecuación surge debido a que no se consideraron en nuestro análisis, variables tales como los Ciclos por Instrucción (`CPI`) o el Número de Instrucciones (`N`). Se deduce de observar la primera tabla, que si bien se realizan la misma cantidad de instrucciones `N` tanto para números flotantes como para números enteros, la cantidad de `CPI` difiere enormemente entre cada tipo de suma debido a que no es lo mismo computacionalmente hablando sumar unos u otros; conllevando así a una relación entre frecuencia de trabajo y tiempo de ejecución, dada por:

$$
T_{prog} = N(CPI)\left(\frac{1}{f_{CPU}}\right)
$$

Esto nos quiere decir que para un mismo número de iteraciones y a la misma frecuencia de trabajo del `CPU`, influye seriamente el `CPI` que debe realizarse dentro de cada bucle de repetición como lo es en este caso. 

---

### 2.4- Análisis del Tiempo de ejecución por operación
En el análisis precedente, se realizaron las relaciones tomando el tiempo total de operaciones, es decir el que considera los tiempos tanto de las operaciones con números enteros como con números con punto flotante. Sin embargo, se observa que si comparamos estrictamente los tiempos de ejecución de operaciones del mismo tipo, se pueden observar relaciones tales como:

* Si se duplica la frecuencia del `CPU` (de `2 [MHz]` a `4 [MHz]`), el tiempo de ejecución para enteros se debería reducir a la mitad:

$$
R_{2-4}^{(int)} = \frac{1435}{2828} = 0,5074 \approx 0,5
$$

* Si se cuadriplica la frecuencia del `CPU` (de `2 [MHz]` a `8 [MHz]`), el tiempo de ejecución para enteros se debería reducir a un cuarto:

$$
R_{2-8}^{(int)} = \frac{1076}{2828} = 0,3804 \approx 0,38 \neq 0,25 
$$

* Si se duplica la frecuencia del `CPU` (de `2 [MHz]` a `4 [MHz]`), el tiempo de ejecución para flotantes se debería reducir a la mitad:

$$
R_{2-4}^{(float)} = \frac{16034}{31891} = 0,5027 \approx 0,5
$$

* Si se cuadriplica la frecuencia del `CPU` (de `2 [MHz]` a `8 [MHz]`), el tiempo de ejecución para flotantes se debería reducir a un cuarto:

$$
R_{2-8}^{(float)} = \frac{11996}{31891} = 0,3761 \approx 0,37 \neq 0,25
$$

Nótese aquí que han ocurrido dos cosas fundamentales:
* Al compararse el mismo tipo de operación, se tiene entonces que el número de instrucciones y los ciclos por instrucciones se vuelven irrelevantes, ya que al utilizar la ecuación de $T_{prog}$ descripta en la subsección anterior, ambos valores se cancelan, y por lo tanto, la relación de tiempos dependerá exclusivamente de la frecuencia de trabajo de la `CPU`.
* Si bien lo anterior es cierto, se observa que al cuadruplicar la frecuencia de trabajo del `CPU`, no se llega a una reducción del `25 [%]` sino más bien a una reducción del `~37/38 [%]` del tiempo de ejecución. Esto se debe al límite interno con el que cuenta [Wokwi](https://wokwi.com/projects/new/esp32-s3) con las frecuencias del `CPU` y considerando también que se trata de un simulador online, se tiene que los resultados obtenidos de un benchmark de este estilo, han sido afectados significativamente.

Se observa entonces que la inecuación alcanzada en el apartado anterior, es una consecuencia directa de comparar tiempos de ejecución de 2 operaciones con distinta cantidad de Ciclos por Instrucción, ya que al analizar por partes los resultados, se llega a una relación más directa donde $T_{prog} \ \propto \frac{1}{f_{CPU}}$ la cual es únicamente válida para comparación entre el mismo tipo de instrucciones.

---

## 3- Conclusión
Se concluye entonces que a lo largo de esta sección del Trabajo Práctico N°1, se han podido simular los tiempos de ejecución de un simple código compuesto por sumas de enteros y flotantes y se demostró que los tiempos de ejecución no solamente dependen de la frecuencia de trabajo del `CPU`, sino que también son afectados tanto por el número de instrucciones como de la cantidad de ciclos necesarios que demora una instrucción, y esta última a su vez depende del tipo de operación que se esté realizando.

Vimos también que si se trata de una operación del mismo tipo, se vuelve irrelevante el número de instrucciones o los ciclos por instrucción, ya que estos dependerán del tipo de operación a realizar.
