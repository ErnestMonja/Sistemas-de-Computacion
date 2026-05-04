## Práctico #3a UEFI 


### Introducción 
El presente trabajo tiene como objetivo el desarrollo y ejecución de un aplicación UEFI (Unified Extensible Firmware Interface) de 64
bits para realizar análisis de seguridad básico en el firmware en una computadora real, en nuestro caso usamos una Dell Inspiron con
procesador Intel Core Ultra 9. Se busca detectar la presencia de un breakpoint estático (`0xCC`) en una región de memoria simulada, replicando 
patrones de análisis utilizados en Ghidra 


### Entorno de Desarrollo 
Para garantizar la compatibilidad con el etándar UEFI de 64 bits, se configuró un entorno de desarrollo robusto sobre el sistema operativo `Ubuntu 24.04 LTS` y la cadena de herramientas de `GNU-EFI`.

Las pruebas físicas se realizaron sobre una estación de trabajo portátil con capacidades de procesamiento de última generación, permitiendo validar el comportamiento del binario en arquitecturas x86_64 

- Modelo: Dell Inspiron 14 Plus 7440
- Procesador: Intel COre Ultra 9 185H
- Memoria: 32 GB RAM
- Almacenamiento: 1TB NVMe SSD

Se utilizó la cadena de herramientas de GNU para la generación de binarios PE32+ (Portable Executable), formato requerido por el firmware UEFI

- Compilador: `gcc`
- Har
- Librerías de Desarrollo: Se instaló el paquete `gnu-efi`, el cual proporciona `efi.h` y `efilib.h` para el manejo de protocolos de consola y
  los objetos de inicio necesarios para la interfaz con las tablas del sistema
- Scripts de Elace: se utilizô el archivo `elf_x86_64_efi,lds` para definir la disposición de las secciones de memoria de la aplicación dentro del firmware

#### Herramientas de Análisis y Emulación 
Antes del despligue en hardware real, usamos herramientas para verififcar la integridad del código: 

- Emulación: QEMU con soporte OVMF para simular un entorno UEFI puro sin riesgo de bloqueo del hardware del host
- Ingeniería inversa: Ghidra 12.0, utilizado para la descompilación y análisis estǽtitco del binario generado
- Inspección de Binarios: utilidades `file` y `readlf` para corroborar que el formato de salida fuera efectivamente una aplicación EFI y no un binario ELF de Linux  

### Implementación del Código 

El código utilizado para el archivo `aplicacion.c` es el siguiente: 

`#include <efi.h>
#include <efilib.h>

EFI_STATUS efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable) {
    InitializeLib(ImageHandle, SystemTable);
    Print(L"Iniciando analisis de seguridad...\n");

    // Inyección de un software breakpoint (INT3)
    __asm__ __volatile__ ("int $3");

    Print(L"Breakpoint estatico alcanzado.\n");
    return EFI_SUCCESS;
}`

Para asegurar que el binario pueda ser analizado mediante Ghidra, se utilizó una variable que define el breakpoint como un arreglo de datos 
`unsigned char code[]`. Esto permite verificar la lógica de detección sin forzar una interrupción de hardware que el firmware podría no manejar 



<img width="1427" height="790" alt="Pasted image (2)" src="https://github.com/user-attachments/assets/cd610bab-ab61-4b3a-830d-196fc9cf238b" />

En la imagen se ve la edición del archivo fuente `aplicacion.c` utilizando el editor Nano. Se observa la implementación final que incluye una pausa 
(`WaitForKey`) para permitir la lectura de los resultados antes del cierre de la aplicación. 

### Construcción y Análisis del Binario 
  En estaetapa se realizó la transformación del código fuente en un ejecutable compatible con el firmware y se auditó su estructura mediante ingeniería inversa 

#### Proceso de Compilación 
Paso 1: Generación del código objeto 

  `gcc -I/usr/include/efi -I/usr/include/efi/x86_64 -I/usr/include/efi/protocol \
    -fpic -ffreestanding -fno-stack-protector -fno-strict-aliasing \
    -fshort-wchar -mno-red-zone -maccumulate-outgoing-args \
    -Wall -c -o aplicacion.o aplicacion.c `

#### Importación y Reconocimiento de Formato 
Al cargar el archivo en Ghidra, la herramienta identificó automǽticamente el formato como Portable Executable(PE) para arquitectura x86_64. Esto confirma que le proceso de conversión mediante ``
