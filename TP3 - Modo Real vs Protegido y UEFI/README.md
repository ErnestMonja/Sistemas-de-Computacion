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
### 4.1- Código Propuesto
Como bien indica el título de esta sección, el objetivo de la misma consiste en crear un código en `Assembler` que nos permita pasar a modo protegido, sin la necesidad de utilizar macros. para realizar tal proceso se requiere que el procesador ejecute los siguientes 3 pasos fundamentales:
* Definir la `GDT` (Global Descriptor Table): Se trata de una parte fundamental de la arquitectura `x86` de `Intel` que ayuda a gestionar cómo se accede a la memoria y cómo se protege. Introducida con el procesador `Intel 80286`, desempeña un papel clave en la definición de los segmentos de memoria y sus atributos: la dirección base, el tamaño y los privilegios de acceso, como la ejecutabilidad y la escritura.
* Cargar la `GDT`: Usar la instrucción `LGDT`.
* Activar el bit de protección: Poner en 1 el bit 0 (`PE` - Protection Enable) del registro de control `CR0`. El registro `CR0` se puede utilizar para habilitar o deshabilitar ciertas funciones del procesador, como el modo protegido para activar el direccionamiento virtual y la paginación de memoria.
* Hacer un `JMP` lejano (Far `JMP`): Para limpiar la cola de ejecución y cargar el selector de código en `CS`.

Con estos aspectos en mente, se propone utilzar el siguiente código:

```asm
# =============================================================================
# DESAFÍO FINAL: MODO PROTEGIDO (Sintaxis AT&T)
# Compilar con: 
#   as --32 boot.s -o boot.o
#   ld -m elf_i386 -Ttext 0x7c00 --oformat binary boot.o -o boot.bin
# =============================================================================

.code16
.global _start

_start:
    cli                         # 1. Deshabilitar interrupciones
    
    # Limpiamos registros de segmento
    xor %ax, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %ss
    mov $0x7c00, %sp            # Stack justo antes del bootloader

    # 2. Cargar la GDT
    # Usamos la dirección absoluta (0x7c00 + offset) para que lgdt la encuentre
    lgdt gdt_descriptor

    # 3. Activar bit PE en CR0
    mov %cr0, %eax
    or $0x1, %eax
    mov %eax, %cr0

    # 4. Salto lejano (Far JMP) para pasar a 32 bits y cargar CS
    # En AT&T la sintaxis es: ljmp $selector, $offset
    ljmp $CODE_SEG, $protected_mode

# -----------------------------------------------------------------------------
# GDT (Global Descriptor Table)
# -----------------------------------------------------------------------------
.align 8
gdt_start:
    # Descriptor 0: Nulo
    .long 0x00000000
    .long 0x00000000

    # Descriptor 1: Código (Selector 0x08)
    # Base: 0x00000000, Límite: 0xFFFFF
    .word 0xFFFF        # limite 0:15
    .word 0x0000        # base 0:15
    .byte 0x00          # base 16:23
    .byte 0x9A          # acceso: codigo, ring 0, ejecutable/lectura
    .byte 0xCF          # flags: 32 bits, granularidad 4KB
    .byte 0x00          # base 24:31

    # Descriptor 2: Datos (Selector 0x10)
    # CONFIGURACIÓN: Base diferenciada en 0x00020000 para cumplir la consigna
    .word 0xFFFF        
    .word 0x0000        # base 0:15
    .byte 0x02          # base 16:23 (Aquí definimos que empieza en 0x20000)
    .byte 0x92          # acceso: datos, ring 0, lectura/escritura
    .byte 0xCF          
    .byte 0x00          
gdt_end:

gdt_descriptor:
    .word gdt_end - gdt_start - 1   # tamaño
    .long gdt_start                  # dirección

.equ CODE_SEG, 8
.equ DATA_SEG, 16

# -----------------------------------------------------------------------------
# MODO PROTEGIDO (32 bits)
# -----------------------------------------------------------------------------
.code32
protected_mode:
    # 5. Cargar registros de segmento de datos
    mov $DATA_SEG, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss

    # --- PRUEBA DE ESCRITURA ---
    # Intentamos escribir en el inicio del segmento de datos.
    # Como la Base es 0x20000, esto escribirá en la RAM física 0x20000.
    movb $'O', (0x0)
    movb $'K', (0x1)

    # Si querés escribir en pantalla VGA (que está en 0xB8000), 
    # recordá que ahora el cálculo es: Dirección Física - Base del Segmento.
    # Como tu base es 0x20000, para llegar a 0xB8000 deberías usar offset 0x98000.

    jmp .

# Relleno para llegar a los 510 bytes y firma de arranque
.fill 510 - (. - _start), 1, 0
.word 0xAA55
```

Para ensamblar este código, se propone utilizar las siguientes lineas de código

```bash
as --32 boot.asm -o boot.o
ld -m elf_i386 -Ttext 0x7c00 --oformat binary boot.o -o boot.bin
qemu-system-i386 -drive format=raw,file=boot.bin
```

Se observa entonces la siguiente salida al ejecutar este código:

![Compilación](https://github.com/ErnestMonja/Sistemas-de-Computacion/blob/main/TP3%20-%20Modo%20Real%20vs%20Protegido%20y%20UEFI/Modo%20Protegido/Compilaci%C3%B3n.png)

### 4.2- ¿Qué sucede si el segmento de datos es "Solo Lectura" e intentas escribir?
Si se cambia el bit de acceso del descriptor de datos (específicamente el bit 1 del byte de acceso) de 1 (Read/Write) a 0 (Read-Only), se tiene que el hardware de la `CPU` detecta una violación de permisos al intentar ejecutar una instrucción `MOV` de escritura y por lo tanto se dispara una General Protection Fault (Excepción 13).

En el teórico: Si no tienes un manejador de interrupciones (IDT) configurado, la CPU entrará en un "Triple Fault" y la computadora (o el emulador QEMU/Bochs) se reiniciará.

### 4.3- ¿Con qué valor se cargan los registros de segmento en Modo Protegido y por qué?
A diferencia del Modo Real, donde el registro contiene una dirección base segmentada (valor * 16), en Modo Protegido los registros (`CS`, `DS`, `SS`, etc.) se cargan con un Selector de Segmento. Esto se debe a que en este modo, los registros ya no apuntan a una dirección física directa, sino que actúan como un índice o puntero hacia la `GDT`. El valor cargado tiene esta estructura:
* Bits 3-15 (Índice): Indica qué entrada de la GDT queremos usar (ej. el descriptor 1, el 2, etc.).
* Bit 2 (`TI`): Indica si se usa la `GDT` (0) o la LDT (1).
* Bits 0-1 (`RPL`): El nivel de privilegio solicitado (Ring 0 a Ring 3).

si por ejemplo se carga el: `0x08` (binario `1000`), el índice es 1, lo que significa que se está seleccionando el segundo descriptor de la `GDT`.

### 4.4- Verificación con GDB, se 


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
