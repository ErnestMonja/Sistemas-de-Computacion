# TO DO LIST:
1) ¿Cuál es el rendimiento de estos procesadores para compilar el kernel?
 - Intel Core i5-13600K (base)
 - AMD Ryzen 9 5900X 12-Core
 - Intel Core Ultra 9 185H
   
¿Cuál es la aceleración cuando usamos un AMD Ryzen 9 7950X 16-Core, cual de ellos hace un uso más eficiente de la cantidad de núcleos que tiene? y ¿Cuál es más eficiente en términos de costo (dinero y energía)?

### Análisis de Benchmarks 

2) Armar una lista de benchmarks, ¿Cuáles les serían más útiles a cada uno? ¿Cuáles podrían llegar a medir mejor las tareas que ustedes realizan a diario? Pensar en las tareas que cada uno realiza a diario y escribir en una tabla de dos entradas las tareas y que benchmark la representa mejor.

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






