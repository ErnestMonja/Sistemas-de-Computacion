### Análisis de Benchmarks 

1) Armar una lista de benchmarks, ¿Cuáles les serían más útiles a cada uno? ¿Cuáles podrían llegar a medir mejor las tareas que ustedes realizan a diario? Pensar en las tareas que cada uno realiza a diario y escribir en una tabla de dos entradas las tareas y que benchmark la representa mejor.

Un Benchmarks es una prueba estandarizada diseñada para medir el rendimiento de un sistema informático (procesador, memoria, dico o red) bajo una carga de trabajo específica. A diferencia de una simple medición de tiempo, un benchmarks permite comparar de manera objetiva y cientidica el desempeño entre diferentes arquitecturas de hardware o configuraciones de software, utilizando métricas reproducibles como operaciones por sgundo,ancho de banda o tiempo de respuesta 

Para los procesadores del punto 1, los benchmarks más útiles son: 

- **Intel Core i5-13600K**: `PCMARK 10`. Es ideal para medir la agilidad en tareas de oficina, navegación web y edición ligera, donde este procesador destaca por su relación costo-beneficio.
- **AMD Ryzen 9 5900X 12-Core**: `Cinebench R23` y `V-Ray`. Estos procesadores brillan en renderizado y cálculo bruto, donde todos los núcleos se mantienen al 100% durante mucho tiempo
- **Intel Core Ultra 9 185H**: `Geekbench 6` y `Phoronix Test Suite`. Al ser una arquitectura híbrida (núcleos P y E), necesita herramientas que midan tanto el rendimiento de ráfaga en un solo núcleo como la eficiencia multihilo en tareas reales
  Núcleos P y E: son dos tipo de núcleos. Los núclos de Rendimiento (P) son los núcleo más grandes, potentes y rápidos de la CPU y los núcleos de Eficiencia (E) son núcleos mas pequeños que consumen muchisima menos energía, son los encargados de las tareas que corren de fondo.
  

#### Tabla

|Tarea Diaria | Benchmark Representivo | Justificación | 
| :---:| :---: |:---:| 
|Compilación de Código| Timed Linux Kernel Compilation | Mide la velocidad del procesador y la RAM para transformar miles de líneas de código en binarios, tal como lo usamos | 
|Progamación de Micros | CoreMark | Es el estándar de la industria para microcntroladores.Mide que tan eficiente es el procesador manejando bucles, lecturas de memoria y cálculos lógicos |
|Gestión de Versiones (Git)| FS-Mark (File System Mark)| Git realiza miles de peque;as operaciones de escritura y lectura en disco.Este benchmark mide que tn rápido es la SSD NVMe para este tipo de tareas | 
|Simulación de Circuitos| PSPICE/SPECwpc | Mide la capacidad de cálculo matemático en un solo núcleo, crucial para resolver matrices de circuitos| 
|Multitarea de Desarrollo (Terminal + IDE + web )| Sysbench(CPU/Memory) | Evalúa como se comporta el sistema cuadno hay muchos procesos pidiendo memoria y ciclos de CPU al mismo tiempo, evitando cuellos de botella| 


#### Conclusión 

Después de analizar las tareas que realizamos a diario, un benchmark que solo mida la potencia bruta de renderizado (es la capacidad máxima que tiene un procesador para trabajar manteniendo a todos sus núcleos trabajando al 100% de su capacidad), no es la mejor opción para medir el rendimiento real. 
Para el tipo de tareas que hacemos como programación o simulación de circuitos, los benchmarks que mejor representan la activadad de nuestros procesadores son aquellos que evalúan la agilidad monohilo y la velocidad de compilación, como `CoreMark` o `Timed Linux Kernel`. Estas pruebas validan de manera más fiel como las arquitecturas más modernas (híbridas o de alto conteo de núcleos con gran caché) gestionan las ráfagas de procesamiento intenso y la multitarea compleja sin afectar la estabilidad del sistema 


---

### Análisis de Rendimiento

2) ¿Cuál es el rendimiento de estos procesadores para compilar el kernel?
 - Intel Core i5-13600K (base)
 - AMD Ryzen 9 5900X 12-Core
¿Cuál es la aceleración cuando usamos un AMD Ryzen 9 7950X 16-Core, cual de ellos hace un uso más eficiente de la cantidad de núcleos que tiene? y ¿Cuál es más eficiente en términos de costo (dinero y energía)?

Para evaluar el rendimiento de los procesadores se utilizó el benchmark **build-linux-kernel** de Phoronix Test Suite, disponible en el siguiente enlace:

https://openbenchmarking.org/test/pts/build-linux-kernel&eval=9cdcd82c9c47af9df17263e4312f634338dbf476#metrics

Con la configuración: "*pts/build-linux-kernel-1.15.x - Build: deconfig*"

Este benchmark mide el **tiempo de compilación del kernel de Linux**.

---

## Resultados obtenidos

Se analizaron los siguientes procesadores:

- Intel Core i5-13600K  
- AMD Ryzen 9 5900X 12-Core  
- AMD Ryzen 9 7950X 16-Core  

| Procesador | Posición | Tiempo promedio | Configuración |
|-----------|--------|----------------|--------------|
| Intel Core i5-13600K | 58th | 72 ± 5 s | 14 cores / 20 threads @ 5.1 GHz |
| AMD Ryzen 9 5900X | 56th | 76 ± 8 s | 12 cores / 24 threads @ 3.7 GHz |
| AMD Ryzen 9 7950X | 74th | 50 ± 6 s | 16 cores / 32 threads @ 4.5 GHz |

---

## Análisis de resultados

Se observa que el **Intel Core i5-13600K** presenta un tiempo de compilación ligeramente menor que el **AMD Ryzen 9 5900X**, a pesar de que este último posee más hilos. Esto puede explicarse por:

- Mejor rendimiento por núcleo (cuánto trabajo hace un núcleo en cada “tick” del reloj)
- Mayor frecuencia de operación 
- Arquitectura más moderna (Raptor Lake 2022 vs Zen 3 2020)

Por otro lado, el **AMD Ryzen 9 7950X** muestra una mejora significativa en el tiempo de compilación, lo cual se debe a:

- Mayor cantidad de núcleos e hilos
- Arquitectura más reciente (Zen 4 2022)

---

## Cálculo de Speedup

Se define como:

$$
Speedup = \frac{Rendimiento_{mejorado}}{Rendimiento_{original}}
$$

Tomando los datos del tiempo de compilación del kernel de linux, y sabiendo que el rendimiento es inversamente proporcional al timepo, calculamos:

### Respecto al Intel Core i5-13600K

$$
Speedup ≈ \frac{72}{50} ≈ 1.44
$$

→ El Ryzen 9 7950X es aproximadamente **1.44 veces más rápido** que el i5-13600K.

---

### Respecto al AMD Ryzen 9 5900X

$$
Speedup ≈ \frac{76}{50} ≈ 1.52
$$

→ El Ryzen 9 7950X es aproximadamente **1.52 veces más rápido** que el Ryzen 9 5900X.

---

## Uso eficiente de los núcleos

No solo importa cuántos núcleos tiene un procesador, sino qué tan bien logra aprovecharlos.

  | Procesador | Núcleos | Speedup respecto al i5 | Eficiencia por núcleo |
|-----------|--------|----------------|--------------|
| Intel Core i5-13600K | 14 | 1.00 | $\frac{1}{14} = 0.0714$ |
| AMD Ryzen 9 5900X | 12 | 0.95 | $\frac{0.95}{12} = 0.0792$ |
| AMD Ryzen 9 7950X | 16 | 1.44 | $\frac{1.44}{16} = 0.09$ |

---

## Eficiencia en costo (dinero)

  | Procesador | Rendimiento | Costo | Resultado |
|-----------|--------|----------------|--------------|
| Intel Core i5-13600K | $\frac{1}{72} = 0.0139$ | $320 | $\frac{0.0139}{320} = 4.34x10^(-5)$ |
| AMD Ryzen 9 5900X | $\frac{1}{76} = 0.01316$ | $350 | $\frac{0.01316}{350} = 3.76x10^(-5)$ |
| AMD Ryzen 9 7950X | $\frac{1}{50} = 0.02$ | $512 | $\frac{0.02}{512} = 3.9x10^(-5)$ |

Mientras más alto sea el resultado, mejor es el procesador en relación calidad-precio. En este caso, el procesador Intel Core i5-13600K es quien tiene mejor relación, sin embargo, si se busca más poder de procesamiento total, se debe optar por el AMD Ryzen 9 7950X.

---

## Eficiencia energética

  | Procesador | Rendimiento | Potencia consumida [W] | Resultado |
|-----------|--------|----------------|--------------|
| Intel Core i5-13600K | $0.0139$ | 125 | $\frac{0.0139}{125} = 1.112x10^(-4)$ |
| AMD Ryzen 9 5900X | $0.01316$ | 105 | $\frac{0.01316}{105} = 1.253x10^(-4)$ |
| AMD Ryzen 9 7950X | $0.02$ | 170 | $\frac{0.02}{170} = 1.176x10^(-4)$ |

Debido a su baja potencia de consumo, el procesador AMD es quien tiene mejor relación, sin embargo, si se busca más poder de procesamiento total, se debe optar por el AMD Ryzen 9 7950X.
