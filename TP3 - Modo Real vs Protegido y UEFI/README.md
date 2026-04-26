# TP#3: Modo Real vs Modo Protegido

## 1- Imagen Booteable
### 1.1- Creación de una Imagen Booteable
Una imagen booteable (o de arranque) es un tipo de imagen de disco que, al estar en un dispositivo de arranque, permite que la computadora asociada arranque sin necesidad de un sistema operativo previo. En la arquitectura x86, lo más simple es crear un sector de arranque MBR y colocarlo en un disco. Para ello, se puede crear un sector de arranque con una sola línea de printf:

```bash
printf '\364%509s\125\252' > main.img
```

Se propone analizar en detalle lo que realiza cada parte de este comando:
* `\364` es un número en octal, el cual traducido a hexadecimal es igual a: `0x4F` la cual hace referencia a la instrucción `HLT` (Halt) la cual detiene a la unidad central de procesamiento `(CPU)` hasta que se active la siguiente interrupción externa.
* `%509s` produce 509 espacios. Necesarios para completar la imagen hasta el byte 510.
* `\125\252` son números en octal, los cuales pasados a hexadecimal son iguales a: `0x55` y `0xAA` respectivamente. Estos números son requisito para que la imagen sea interpretada como una `MBR`.
* `> main.img` guarda toda la operación realizada en el archivo `main.img`.


Se propone entonces obtener la codificacion hexadecimal de una instruccion, en este caso se trata de la instrucción `HLT` mediante la escritura, ensamblaje y desamblaje de una instrucción en Assembler, con las siguientes líneas de código:
```bash
echo hlt > a.S
as -o a.o a.S
objdump -S a.o
```

El resultado de compilación de estas líneas es el siguiente:
![]()






























## 2- UEFI y Coreboot:
### 2.1- UEFI: Definición, uso y funciones
La UEFI (Unified Extensible Firmware Interface) consiste en una especificación de firmware de computadora, la cual se presenta como un estándar moderno que reemplaza a la BIOS (Basic Input/Output System), siendo este último el firmware fundamental preinstalado en un chip de la placa base que inicia, prueba (POST) y configura el hardware (CPU, RAM, discos) al encender el PC. Se tiene que a diferencia de la BIOS, que está limitada al modo real de 16 bits, la UEFI puede ejecutarse en modos de mayor capacidad (32 o 64 bits) y permite un arranque más flexible y seguro.

Se utiliza como una interfaz entre el SO y el firmware de la plataforma. A diferencia de las interrupciones de BIOS, UEFI utiliza servicios de arranque (Boot Services) y servicios de tiempo de ejecución (Runtime Services) a los que se accede mediante tablas de punteros a funciones en C.

Una función común que se puede llamar es GetVariable, que permite leer variables de configuración almacenadas en la memoria no volátil (NVRAM) del firmware.



### 2.2- Bugs de UEFI explotables 
Nótese que dada la definición presentada de la UEFI, se tiene que esta se ejecuta antes del sistema operativo, y por lo tanto puede ser un objetivo crítico para el malware que busque capitalizarse de los bugs y errores de seguridad presentados en la misma. Algunos de los casos conocidos son:

* LoJax: Se trata de el primer malware de tipo Rootkit diseñado para infectar computadoras desde la UEFI detectado en condiciones reales. Este malware se infiltraba en la memoria Flash SPI de tal modo que es imposible su limpieza con métodos convencionales como la reinstalación del sistema operativo o el cambio del disco rígido. Es el primero descubierto que usa este modo de infección que hasta el momento se consideraba teórica. El malware fue descubierto por la compañía de seguridad ESET.
  
* BlackLotus: Es un Bookit de UEFI diseñado específicamente para Windows que incorpora un Bypass integrado del Secure Boot y protección Ring0-Kernel para protegerse de cualquier intento de eliminación. Este permite explotar vulnerabilidades, tales como CVE-2022-21894, para ejecutar código no firmado durante el arranque.

* Vulnerabilidades del Buffer Overflow: Ocurre cuando un programa escribe más datos en un área de memoria (búfer) de los que puede albergar, sobrescribiendo memoria adyacente. Esto permite a atacantes corromper datos, provocar fallos del sistema o ejecutar código malicioso arbitrario, tomando el control del sistema.



### 2.3- CSME e Intel MEBx
El CSME (Converged Security and Management Engine) consiste de un subsistema embebido y un dispositivo PCIe (Peripheral Component Interconnect Express) integrado en los chipsets de Intel que esta diseñado para actuar como un controlador de seguridad y manejabilidad en el PCH (Plataform Controller Hub). Este funciona con su propio procesador, microkernel y memoria, permitiendo tareas de gestión remota y seguridad independientemente del estado del procesador principal o del sistema operativo.

Para configurar el CSME, Intel provee el Intel MEBx (Management Engine BIOS Extension) el cual es una interfaz de configuración a nivel de plataforma para el subsistema Intel Management Engine (ME) en sistemas Intel vPro. Permite activar/desactivar funciones como Intel AMT (Active Management Technology), generalmente presionando Ctrl+P, y configurar parámetros de red y seguridad antes de iniciar el sistema operativo.


### 2.4- Coreboot
Se tiene que el Coreboot (antes llamado LinuxBIOS) es un proyecto dirigido a reemplazar el firmware no libre de los BIOS propietarios, encontrados en la mayoría de los computadores, por un BIOS libre y ligero diseñado para realizar solamente el mínimo de tareas necesarias para cargar y correr un sistema operativo moderno de 32 bits o de 64 bits. coreboot es respaldado por la Free Software Foundation (FSF). Entre ellos se encuentran SeaBIOS, Grub o incluso el kernel de Linux. Algunas de sus ventajas principales pueden ser:
 * Velocidad: El tiempo de arranque es significativamente menor al eliminar procesos innecesarios del firmware comercial.
 * Seguridad: Al ser código abierto, puede ser auditado por la comunidad para detectar puertas traseras.
 * Personalización: Permite un control total sobre el proceso de arranque del hardware.
Dadas estas ventajas, se tiene que la implementación del Coreboot es muy común en las Chromebooks de Google. También es utilizado por fabricantes enfocados en la privacidad y el hardware abierto como System76, Purism y Framework.



## 3-
































## Bibliografía
* [Imagen Booteable](https://en.wikipedia.org/wiki/Boot_image)
* [LoJaX](https://es.wikipedia.org/wiki/LoJax)
* [BlackLotus](https://github.com/ldpreload/BlackLotus)
* [Buffer Overflow](https://www.cloudflare.com/es-es/learning/security/threats/buffer-overflow/)
* [Intel CSME](https://www.intel.com/content/dam/www/public/us/en/security-advisory/documents/intel-csme-security-white-paper.pdf)
* [Intel MEBx](https://en.wikipedia.org/wiki/Intel_Management_Engine)
* [Coreboot](https://es.wikipedia.org/wiki/Coreboot)
