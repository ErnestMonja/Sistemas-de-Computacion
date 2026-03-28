# Estudio sobre el Tiempo de Ejecución en la ESP32 con variaciones en la Frecuencia del CPU

## 1- Introducción al Rendimiento
De acuerdo a la bibliografia presentada en esta asignatura, se define al rendimiento de un sistema como la capacidad que tiene dicho sistema para realizar un trabajo en un determinado tiempo. Es inversamente proporcional al tiempo, es decir, cuanto mayor sea el tiempo que necesite, menor será el rendimiento. Se tiene entonces que en base a esta definición, es de esperarse que al aumentar la frecuencia de trabajo de nuestro CPU, se pueden entonces ejecutar una mayor cantidad de instrucciones por unidad de tiempo, es decir y en términos más simplistas: los programas se ejecutarán más rápidos.

En esta sección del Trabajo Práctico 1, se busco estudiar de forma empírica esta relación, utilizando como base la placa ESP32 la cual tiene la ventaja de que esta permite ajustar su frecuencia de trabajo de su CPU. Para ello, se ejecutó un código el cual compara la velocidad de ejecución de un código a medida que se modifica la frecuencia de trabajo del CPU.

## 2- Análisis Empírico
Dado que no se tuvo poseción de una ESP32, se optó por usar un simulador online llamado [Wokwi](https://wokwi.com/projects/new/esp32-s2), el cual permite introducir un código en $C/C++$ y lo compiló en una instancia virtual de este microcontrolador, la cual a fines prácticos de nuestro análisis de rendimiento será suficiente.

Para realizar tal medición y análisis, se diseño un código en $C$
