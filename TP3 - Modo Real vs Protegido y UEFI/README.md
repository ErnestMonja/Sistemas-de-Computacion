# TP#3: Modo Real vs Modo Protegido

## 1- Imagen Booteable
Una imagen booteable (o de arranque) es un tipo de imagen de disco que, al estar en un dispositivo de arranque, permite que la computadora asociada arranque sin necesidad de un sistema operativo previo. En la arquitectura x86, lo más simple es crear un sector de arranque MBR y colocarlo en un disco. Para ello, se puede crear un sector de arranque con una sola línea de printf:

```bash
printf '\364%509s\125\252' > main.img
```

Se propone analizar en detalle lo que realiza cada parte de este comando:
* `\364` es un número en octal, el cual traducido a hexadecimal es igual a: `0x4F` la cual hace referencia a la instrucción `HLT` (Halt) la cual detiene a la unidad central de procesamiento `(CPU)` hasta que se active la siguiente interrupción externa.
* `%509s` produce 509 espacios. Necesarios para completar la imagen hasta el byte 510.
* `\125\252` son números en octal, los cuales pasados a hexadecimal son iguales a: `0x55` y `0xAA` respectivamente. Estos números son requisito para que la imagen sea interpretada como una `MBR`.
* `> main.img` guarda toda la operación realizada en el archivo `main.img`.

Se propone entonces obtener la codificacion hexadecimal de una instrucción, en este caso se trata de la instrucción `HLT` mediante la escritura, ensamblaje y desensamblaje de una instrucción en Assembler, con las siguientes líneas de código:
```bash
echo hlt > a.S
as -o a.o a.S
objdump -S a.o
```

El resultado de compilación de estas líneas, es el que se muestra en la siguiente figura:

![Creación de la Imagen Booteable](https://github.com/ErnestMonja/Sistemas-de-Computacion/blob/main/TP3%20-%20Modo%20Real%20vs%20Protegido%20y%20UEFI/Imagen%20Booteable/1-%20Creaci%C3%B3n%20de%20la%20Imagen%20Booteable.png)

Se observa aquí que la instrucción `HLT` se corresponde efectivamente con el número hexadecimal `0X4F`.

Continuando este análisis de la imagen booteable, se tiene que para ejecutar la imagen se propuso instalar QEMU, siendo este un emulador de procesadores basado en la traducción dinámica de binarios (conversión del código binario de la arquitectura fuente en código entendible por la arquitectura huésped). Para ello se ejecutaron las siguientes lineas de código:

```bash
sudo apt install qemu-system-x86
qemu-system-x86_64 --drive file=main.img,format=raw,index=0,media=disk
```

Estos comandos efectivamente instalan QEMU y lo inicializan con la imagen booteable creada, tal como muestra la siguiente figura:

![Instalación de QEMU](https://github.com/ErnestMonja/Sistemas-de-Computacion/blob/main/TP3%20-%20Modo%20Real%20vs%20Protegido%20y%20UEFI/Imagen%20Booteable/2-%20Instalaci%C3%B3n%20de%20QEMU.png)

Se propone entonces grabar tal imagen dentro de un pendrive y bootear el hardware de acuerdo a la siguiente línea:

```bash
sudo dd if=main.img of=/dev/sdb
```

El comando `dd` o Data Duplicator copia datos a bajo nivel, bit por bit, ignorando sistemas de archivos (como FAT32 o NTFS) desde la imagen creada hasta un pendrive. Nótese que de utilizar `sda` (que suele ser el disco principal) en lugar de `sdb`, se podría borrar accidentalmente el sistema operativo. Por lo tanto, se debe verificar con el comando `lsblk`, qué letra tiene el pendrive utilizado.

Nótese que si se esta usando una máquina virtual de Linux (como es el caso), utilizar un pendrive puede resultar bastante complicado debido a que al conectarlo a la computadora de forma física, ocurre un conflicto entre Windows (nuestro sistema operativo anfitrión) y Ubuntu-Linux (sistema operativo emulado) por el control del HW y como es de esperarse, el sistema operativo anfitrión no cede, ocasionando así un error de `PNP_DETECTED_FATAL_ERROR` (véase: [Errores de Drivers](https://learn.microsoft.com/es-es/windows-hardware/drivers/debugger/bug-check-0xca--pnp-detected-fatal-error)) que indica que el administrador `Plug and Play (PnP)` ha fallado debido a controladores (drivers) dañados, incompatibles o hardware defectuoso. 

![PNP_DETECTED_FATAL_ERROR](https://github.com/ErnestMonja/Sistemas-de-Computacion/blob/main/TP3%20-%20Modo%20Real%20vs%20Protegido%20y%20UEFI/Imagen%20Booteable/3-%20PNP_DETECTED_FATAL_ERROR.jpeg)

Para solventar este problema, se decidio emular el comportamiento del pendrive generando un archivo vacío de `100 [MB]` en el disco con el siguiente comando:

```bash
dd if=/dev/zero of=pendrive_virtual.img bs=1M count=100
```

Tras una simple configuración dentro del entorno de la máquina virtual, de modo que se conecta este "pendrive" a la VM como si fuera un disco extra, se tiene que al ejecutar el comando `lsblk`, se observa la siguiente salida:

![lsbkl](https://github.com/ErnestMonja/Sistemas-de-Computacion/blob/main/TP3%20-%20Modo%20Real%20vs%20Protegido%20y%20UEFI/Imagen%20Booteable/4-%20LSBLK.png)

Se observa que efectivamente se toma este archivo vacio de `100 [MB]` como un disco extra y por lo tanto puede ser tratado como un pendrive para duplicar los datos de la imagen creada. Ejecutando el comando `sudo dd if=main.img of=/dev/sdb`, se obtiene la siguiente salida en consola:

![imagen generada](https://github.com/ErnestMonja/Sistemas-de-Computacion/blob/main/TP3%20-%20Modo%20Real%20vs%20Protegido%20y%20UEFI/Imagen%20Booteable/5-%20Imagen%20copiada.png)

Se verifica la exitosa copia de valores con los siguientes comandos:

```bash
sudo cmp -n 512 main.img /dev/sdb
sudo dd if=/dev/sdb bs=1 skip=510 count=2 | xxd
```

El primer comando compara los primeros `512` bytes del archivo main.img con los primeros `512` bytes del pendrive virtual ubicado en: `/dev/sdb`, de modo que si los bytes son iguales, entonces el comando no retornará nada. El ultimo comando lee los ultimos 2 bytes del pendrive virtual y verifica que sean iguales al `boot signature`, es decir que sean iguales a: `0x55` y `0xAA` en hexadecimal. Se observa entonces la siguiente salida de consola:

![Verificación](https://github.com/ErnestMonja/Sistemas-de-Computacion/blob/main/TP3%20-%20Modo%20Real%20vs%20Protegido%20y%20UEFI/Imagen%20Booteable/6-%20Verificaci%C3%B3n.png)

Se observa que efectivamente los archivos terminan efectivamente con tal signatura de números hexadecimales de modo que efectivamente se ha copiado la imagen de arranque en nuestro pendrive virtual. Se tiene entonces que al arrancar la máquina virtual desde este disco, se cargan los `512` bytes del archivo `main.img` en la memoria ram y al leer los números hexadecimales conseguidos, el sistema de arranque detecta que el pendrive es efectivamente un disco de arranque y por lo tanto se le transfiere el control al procesador para que empiece a ejecutar la primera instrucción en esa dirección. Sin embargo, como el resto del archivo son solo ceros (que el procesador interpreta como la instrucción ADD), el procesador empezará a ejecutar instrucciones nulas y sin sentido hasta que colapse o se reinicie. En este caso, al utilizar QEMU como emulador de arranque, se observa que la pantalla se queda tildada en "Booting from Hard Disk..." y no pasa nada más.

![](https://github.com/ErnestMonja/Sistemas-de-Computacion/blob/main/TP3%20-%20Modo%20Real%20vs%20Protegido%20y%20UEFI/Imagen%20Booteable/7-%20Ejecuci%C3%B3n.png)



## 2- UEFI y Coreboot:
### 2.1- UEFI: Definición, uso y funciones
La `UEFI` (Unified Extensible Firmware Interface) consiste en una especificación de firmware de computadora, la cual se presenta como un estándar moderno que reemplaza a la `BIOS` (Basic Input/Output System), siendo este último el firmware fundamental preinstalado en un chip de la placa base que inicia, prueba (`POST`) y configura el hardware (`CPU`, `RAM`, discos) al encender el `PC`. Se tiene que a diferencia de la `BIOS`, que está limitada al modo real de `16` bits, la `UEFI` puede ejecutarse en modos de mayor capacidad (`32` o `64` bits) y permite un arranque más flexible y seguro.

Se utiliza como una interfaz entre el SO y el firmware de la plataforma. A diferencia de las interrupciones de `BIOS`, `UEFI` utiliza servicios de arranque (Boot Services) y servicios de tiempo de ejecución (Runtime Services) a los que se accede mediante tablas de punteros a funciones en `C`.

Una función común que se puede llamar es GetVariable, que permite leer variables de configuración almacenadas en la memoria no volátil (`NVRAM`) del firmware.



### 2.2- Bugs de UEFI explotables 
Nótese que dada la definición presentada de la `UEFI`, se tiene que esta se ejecuta antes del sistema operativo, y por lo tanto puede ser un objetivo crítico para el malware que busque capitalizarse de los bugs y errores de seguridad presentados en la misma. Algunos de los casos conocidos son:

* `LoJax`: Se trata de el primer malware de tipo `Rootkit` diseñado para infectar computadoras desde la `UEFI` detectado en condiciones reales. Este malware se infiltraba en la memoria Flash `SPI` de tal modo que es imposible su limpieza con métodos convencionales como la reinstalación del sistema operativo o el cambio del disco rígido. Es el primero descubierto que usa este modo de infección que hasta el momento se consideraba teórica. El malware fue descubierto por la compañía de seguridad `ESET`.
  
* `BlackLotus`: Es un Bookit de UEFI diseñado específicamente para Windows que incorpora un Bypass integrado del Secure Boot y protección Ring0-Kernel para protegerse de cualquier intento de eliminación. Este permite explotar vulnerabilidades, tales como `CVE-2022-21894`, para ejecutar código no firmado durante el arranque.

* `Vulnerabilidades del Buffer Overflow`: Ocurre cuando un programa escribe más datos en un área de memoria (búfer) de los que puede albergar, sobrescribiendo memoria adyacente. Esto permite a atacantes corromper datos, provocar fallos del sistema o ejecutar código malicioso arbitrario, tomando el control del sistema.



### 2.3- CSME e Intel MEBx
El `CSME` (Converged Security and Management Engine) consiste de un subsistema embebido y un dispositivo `PCIe` (Peripheral Component Interconnect Express) integrado en los chipsets de Intel que esta diseñado para actuar como un controlador de seguridad y manejabilidad en el `PCH` (Plataform Controller Hub). Este funciona con su propio procesador, microkernel y memoria, permitiendo tareas de gestión remota y seguridad independientemente del estado del procesador principal o del sistema operativo.

Para configurar el `CSME`, `Intel` provee el `Intel MEBx` (Management Engine `BIOS` Extension) el cual es una interfaz de configuración a nivel de plataforma para el subsistema Intel Management Engine (`ME`) en sistemas `Intel vPro`. Permite activar/desactivar funciones como `Intel AMT` (Active Management Technology), generalmente presionando `Ctrl+P`, y configurar parámetros de red y seguridad antes de iniciar el sistema operativo.


### 2.4- Coreboot
Se tiene que el `Coreboot` (antes llamado `LinuxBIOS`) es un proyecto dirigido a reemplazar el firmware no libre de los `BIOS` propietarios, encontrados en la mayoría de los computadores, por un `BIOS` libre y ligero diseñado para realizar solamente el mínimo de tareas necesarias para cargar y correr un sistema operativo moderno de `32` o de `64` bits. coreboot es respaldado por la Free Software Foundation (`FSF`). Entre ellos se encuentran `SeaBIOS`, `Grub` o incluso el kernel de `Linux`. Algunas de sus ventajas principales pueden ser:
 * Velocidad: El tiempo de arranque es significativamente menor al eliminar procesos innecesarios del firmware comercial.
 * Seguridad: Al ser código abierto, puede ser auditado por la comunidad para detectar puertas traseras.
 * Personalización: Permite un control total sobre el proceso de arranque del hardware.
Dadas estas ventajas, se tiene que la implementación del Coreboot es muy común en las Chromebooks de Google. También es utilizado por fabricantes enfocados en la privacidad y el hardware abierto como `System76`, `Purism` y `Framework.`



## 3- Linker y Hello World en Modo Real
Un Linker (enlazador) o editor de enlaces es un programa informático que combina archivos intermedios de compilación de software, como archivos objeto y de biblioteca , en un único archivo ejecutable , como un programa o una biblioteca. Sus funciones principales son:
* Resolución de símbolos: Si en un archivo se usa una función que está definida en otro, el linker busca dónde está y conecta el llamado con la definición.
* Asignación de memoria: Decide en qué dirección de memoria se ubicará cada sección del código (código, datos, variables globales).
* Relocalización: Ajusta las direcciones de memoria dentro del código para que coincidan con el lugar donde finalmente se cargará el programa.

Para entender una mejor aplicación del Linker, se propone continuar con el escenario planteado por un usuario en [StackOverflow](https://stackoverflow.com/questions/59881880/what-memory-is-impacted-using-the-location-counter-in-linker-script) el cual se plantea tambien como parte de la consigna de este trabajo práctico. La idea que planteo este usuario, fue de imprimir un simple "hello world" en `Assembler` mediante el uso del modo real de una computadora. Para ello utilizo el siguiente código en `Assembler`:

```asm
.code16
    mov $msg, %si
    mov $0x0e, %ah
loop:
    lodsb
    or %al, %al
    jz halt
    int $0x10
    jmp loop
halt:
    hlt
msg:
    .asciz "hello world"
```

Luego, se propuso el siguiente código en Linker para unirlo en un ejecutable y pasarselo al disco de arranque:

```ld
SECTIONS
{
    /* The BIOS loads the code from the disk to this location.
     * We must tell that to the linker so that it can properly
     * calculate the addresses of symbols we might jump to.
     */
    . = 0x7c00;
    .text :
    {
        __start = .;
        *(.text)
        /* Place the magic boot bytes at the end of the first 512 sector. */
        . = 0x1FE;
        SHORT(0xAA55)
    }
}
```

La dirección que vemos en el script de Linker, es la dirección de carga (`VMA` - Virtual Memory Address) la cual es igual a `0x7C00` siendo esta es la ubicación estándar en la memoria `RAM` donde la `BIOS` de un `PC` basado en `x86` carga el primer sector de arranque (`MBR` - Master Boot Record) de `512` bytes. Al encenderse, la `CPU` en modo real de `16` bits transfiere el control a esta dirección para iniciar el sistema operativo. es decir, le indica al linker que el código "cree" que está viviendo en esa dirección específica de la memoria RAM. El valor de `0x7C00` tiene origen del `IBM PC DOS` (The IBM Personal Computer Disk Operating System), siendo este un sistema operativo de disco (DOS) que dominó el mercado de los computadores personales entre 1985 y 1995, donde dado que la computadora base tenía solo `32` [KB] de memoria `RAM`, `IBM` tomo la decisión de que el sector de booteo debía cargarse cerca del final de esos primeros `32` [KB] de `RAM`, pero dejando espacio suficiente para que el propio sector de booteo pudiera trabajar y tener su propio "stack" (pila).

Estas líneas en el Linker son fundamentales debido a que en los códigos en `Assembler`, las referencias a datos (como `mov $msg, %si`) se convierten en direcciones absolutas durante la edición de memoria (linking). Es decir, que de no incluir la línea `. = 0x7c00` en el archivo `link.ld` asume que el programa empieza en la posición `0x0000`de la memoria `RAM`. Se tiene entonces que cuando el código busque el mensaje, dado que la `BIOS` carga el código en `0x7C00`, el programa buscaría en el lugar equivocado y no funcionaria el código.

Se tiene que para ensamblar este código, se deben ejecutar las siguientes lineas de comando 

```bash
as -g -o main.o main.asm
ld --oformat binary -o main.img -T link.ld main.o
qemu-system-x86_64 -hda main.img
```

En estas líneas, se utiliza `--oformat binary` para generar un binario plano, eliminando las cabeceras del formato ELF que la BIOS no puede interpretar, garantizando así que el archivo contenga solo instrucciones ejecutables que el procesador procesará secuencialmente desde el momento del booteo. A continuación se presenta la salida en `QEMU` del código:

![Linkeado](https://github.com/ErnestMonja/Sistemas-de-Computacion/blob/main/TP3%20-%20Modo%20Real%20vs%20Protegido%20y%20UEFI/Linker/1-%20Linkeado%20y%20compilaci%C3%B3n.png)

Como se observa, el código es linkeado y mandado al emulador de `QEMU` el cual imprime correctamente la salida esperada de "hello world". Se propone descomponer este código en `Assembler` primero mediante el comando `objdump` para el cual se provee la siguiente línea de código:

```bash
objdump -D -b binary -m i8086 -M addr16,data16 main.img
```

![](https://github.com/ErnestMonja/Sistemas-de-Computacion/blob/main/TP3%20-%20Modo%20Real%20vs%20Protegido%20y%20UEFI/Linker/2-%20objdump.png)

Y luego mediante el comando `hd main.img` para el cual se muestra la siguiente salida en consola:

![](https://github.com/ErnestMonja/Sistemas-de-Computacion/blob/main/TP3%20-%20Modo%20Real%20vs%20Protegido%20y%20UEFI/Linker/3-%20hd%20main.png)


Se propone para concluir este apartado, realizar una depuración mediante `GDB`, siendo esta una herramienta ya utilizada para el [Trabajo Práctico N°2](https://github.com/ErnestMonja/Sistemas-de-Computacion/tree/main/TP2%20-%20Stack%20frame) la cual permite depurar limpiamente los códigos en lenguaje `Assembler`. Para ello se propone primero instanciar el código de assembler mediante los siguientes comandos:

```bash
as -g -o main.o main.asm
ld --oformat binary -o main.img -T link.ld main.o
qemu-system-i386 -fda main.img -boot a -s -S -monitor stdio
```

Por otro lado, podemos abrir otra terminal de comandos e introducir los siguientes comandos:

```bash
ld -T link.ld -o main.elf main.o
ld -T link.ld --oformat binary -o main.img main.o
```

Con esto creamos un archivo `.elf` el cual será utilizado para depurar el código, y luego configuramos el entorno de `GDB` con:

```bash
gdb
    file main.elf
    target remote localhost:1234
    set architecture i8086
    break *0x7c00
    break *0x7c0d
    layout asm
    layout regs
```

De esta forma, podemos hacer uso de las instrucciones `continue` y `si`, para ir compilando las líneas de código de `Assembler` y ver como cambian los registros tal como muestran las siguientes figuras:

![Depuración GDB1](https://github.com/ErnestMonja/Sistemas-de-Computacion/blob/main/TP3%20-%20Modo%20Real%20vs%20Protegido%20y%20UEFI/Linker/4-%20Depuraci%C3%B3n%20GDB%20(1).png)

![Depuración GDB2](https://github.com/ErnestMonja/Sistemas-de-Computacion/blob/main/TP3%20-%20Modo%20Real%20vs%20Protegido%20y%20UEFI/Linker/5-%20Depuraci%C3%B3n%20GDB%20(2).png)



## 4- Desafio Final: Pasaje a Modo Protegido sin Macros
Como bien indica el título de esta sección, el objetivo de la misma consiste en crear un código en `Assembler` que nos permita pasar a modo protegido, sin la necesidad de utilizar macros. para realizar tal proceso se requiere que el procesador ejecute los siguientes 3 pasos fundamentales:
* Definir la `GDT` (Global Descriptor Table): Se trata de una parte fundamental de la arquitectura `x86` de `Intel` que ayuda a gestionar cómo se accede a la memoria y cómo se protege. Introducida con el procesador `Intel 80286`, desempeña un papel clave en la definición de los segmentos de memoria y sus atributos: la dirección base, el tamaño y los privilegios de acceso, como la ejecutabilidad y la escritura.
* Cargar la `GDT`: Usar la instrucción `LGDT`.
* Activar el bit de protección: Poner en 1 el bit 0 (`PE` - Protection Enable) del registro de control `CR0`. El registro `CR0` se puede utilizar para habilitar o deshabilitar ciertas funciones del procesador, como el modo protegido para activar el direccionamiento virtual y la paginación de memoria.
* Hacer un `JMP` lejano (Far `JMP`): Para limpiar la cola de ejecución y cargar el selector de código en `CS`.

Con estos aspectos en mente, se propone utilzar el siguiente código:

```asm
; =============================================================================
; DESAFÍO: PASO A MODO PROTEGIDO (x86)
; Compilar con: nasm -f bin boot.asm -o boot.bin
; Ejecutar con: qemu-system-x86_64 boot.bin
; =============================================================================

[bits 16]           ; Empezamos en modo real (16 bits)
[org 0x7c00]        ; Dirección de carga estándar del BIOS

start:
    cli             ; Deshabilitar interrupciones
    xor ax, ax      ; Limpiar registros de segmento
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00  ; Definir el stack abajo del bootloader

    ; 1. Cargar la GDT
    lgdt [gdt_descriptor]

    ; 2. Activar Modo Protegido en CR0
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    ; 3. Salto lejano (Far JMP) para limpiar el pipeline y cargar CS
    ; 0x08 es el offset del descriptor de código en la GDT
    jmp 0x08:init_pm

[bits 32]           ; Ya estamos en 32 bits
init_pm:
    ; 4. Cargar los selectores de datos (0x10 es el offset en la GDT)
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; --- PRUEBA DE ESCRITURA ---
    ; Como definimos que el segmento de datos empieza en 0x10000 (ver GDT),
    ; escribir en [0x0] aquí escribirá realmente en la dirección física 0x10000.
    mov byte [0x0], 'H'
    mov byte [0x1], 'I'

    ; Bucle infinito
    jmp $

; -----------------------------------------------------------------------------
; ESTRUCTURA DE LA GDT (Global Descriptor Table)
; -----------------------------------------------------------------------------
gdt_start:
    ; Descriptor Nulo (8 bytes de ceros)
    dd 0x0, 0x0

    ; Descriptor de Código (Selector 0x08)
    ; Base: 0x00000000, Límite: 0xFFFFF (4GB con granularidad de 4KB)
    ; Tipo: Ejecutable, lectura, ring 0
    dw 0xffff       ; Límite (bits 0-15)
    dw 0x0000       ; Base (bits 0-15)
    db 0x00         ; Base (bits 16-23)
    db 10011010b    ; Access byte (Presente, Ring 0, Código, Exec/Read)
    db 11001111b    ; Flags (Granularidad 4KB, 32-bit) + Límite (16-19)
    db 0x00         ; Base (bits 24-31)

    ; Descriptor de Datos (Selector 0x10)
    ; Base: 0x00010000 (ESPACIO DIFERENCIADO), Límite: 0xFFFFF
    ; Tipo: Datos, Lectura/Escritura, ring 0
    dw 0xffff       
    dw 0x0000       ; Base (bits 0-15) -> 0x0000
    db 0x01         ; Base (bits 16-23) -> 0x01 (Esto hace que empiece en 0x10000)
    db 10010010b    ; Access byte (Presente, Ring 0, Datos, Read/Write)
    db 11001111b    
    db 0x00         

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; Tamaño de la GDT
    dd gdt_start               ; Dirección de inicio

; Relleno para completar los 512 bytes del sector
times 510-($-$$) db 0
dw 0xaa55           ; Firma de arranque mágica
```



























## 5- Bibliografía
* [Imagen Booteable](https://en.wikipedia.org/wiki/Boot_image)
* [QEMU](https://es.wikipedia.org/wiki/QEMU)
* [PNP_DETECTED_FATAL_ERROR](https://learn.microsoft.com/es-es/windows-hardware/drivers/debugger/bug-check-0xca--pnp-detected-fatal-error)
* [LoJaX](https://es.wikipedia.org/wiki/LoJax)
* [BlackLotus](https://github.com/ldpreload/BlackLotus)
* [Buffer Overflow](https://www.cloudflare.com/es-es/learning/security/threats/buffer-overflow/)
* [Intel CSME](https://www.intel.com/content/dam/www/public/us/en/security-advisory/documents/intel-csme-security-white-paper.pdf)
* [Intel MEBx](https://en.wikipedia.org/wiki/Intel_Management_Engine)
* [Coreboot](https://es.wikipedia.org/wiki/Coreboot)
* [Linker](https://en.wikipedia.org/wiki/Linker_(computing))
* [Caso de Estudio de Linker](https://stackoverflow.com/questions/59881880/what-memory-is-impacted-using-the-location-counter-in-linker-script)
* [MBR](https://en.wikipedia.org/wiki/Master_boot_record)
* [IBM PC DOS](https://es.wikipedia.org/wiki/IBM_PC_DOS)
* [GDT](https://en.wikipedia.org/wiki/Global_Descriptor_Table)
* [Registro CR0](https://sites.google.com/site/masumzh/articles/x86-architecture-basics/x86-architecture-basics)
