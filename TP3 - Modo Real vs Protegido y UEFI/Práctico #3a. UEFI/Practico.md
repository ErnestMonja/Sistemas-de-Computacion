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
- Librerías de Desarrollo: Se instaló el paquete `gnu-efi`, el cual proporciona `efi.h` y `efilib.h` para el manejo de protocolos de consola y
  los objetos de inicio necesarios para la interfaz con las tablas del sistema
- Scripts de Elace: se utilizó el archivo `elf_x86_64_efi.lds` para definir la disposición de las secciones de memoria de la aplicación dentro del firmware

#### Herramientas de Análisis y Emulación 
Antes del despliegue en hardware real, usamos herramientas para verificar la integridad del código: 

- Emulación: QEMU con soporte OVMF para simular un entorno UEFI puro sin riesgo de bloqueo del hardware del host
- Ingeniería inversa: Ghidra 12.0, utilizado para la descompilación y análisis estǽtitco del binario generado
- Inspección de Binarios: utilidades `file` y `readelf` para corroborar que el formato de salida fuera efectivamente una aplicación EFI y no un binario ELF de Linux  

<img width="1024" height="768" alt="image" src="https://github.com/user-attachments/assets/27004ffe-c428-4207-839c-34f065c6a362" />


### Implementación del Código 

El código utilizado para el archivo `aplicacion.c` es el siguiente: 

```
#include <efi.h>
#include <efilib.h>

EFI_STATUS efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable) {
    InitializeLib(ImageHandle, SystemTable);
    SystemTable->ConOut->OutputString(SystemTable->ConOut, 
        L"Iniciando analisis de seguridad...\r\n");

    // Simulación de breakpoint estático (INT3)
    unsigned char code[] = { 0xCC };

    if (code[0] == 0xCC) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, 
            L"Breakpoint estatico alcanzado.\r\n");
    }

    return EFI_SUCCESS;
}
```

Para asegurar que el binario pueda ser analizado mediante Ghidra, se utilizó una variable que define el breakpoint como un arreglo de datos 
`unsigned char code[]`. Esto permite verificar la lógica de detección sin forzar una interrupción de hardware que el firmware podría no manejar 



<img width="1427" height="790" alt="Pasted image (2)" src="https://github.com/user-attachments/assets/cd610bab-ab61-4b3a-830d-196fc9cf238b" />
Figura 1

En la imagen se ve la edición del archivo fuente `aplicacion.c` utilizando el editor Nano. Se observa la implementación final que incluye una pausa 
(`WaitForKey`) para permitir la lectura de los resultados antes del cierre de la aplicación. 

### Construcción y Análisis del Binario 
  En esta etapa se realizó la transformación del código fuente en un ejecutable compatible con el firmware y se auditó su estructura mediante ingeniería inversa 

#### Proceso de Compilación 
Paso 1: Generación del código objeto 

  `gcc -I/usr/include/efi -I/usr/include/efi/x86_64 -I/usr/include/efi/protocol \
    -fpic -ffreestanding -fno-stack-protector -fno-strict-aliasing \
    -fshort-wchar -mno-red-zone -maccumulate-outgoing-args \
    -Wall -c -o aplicacion.o aplicacion.c `

Paso 2: Linkeo (genera .so intermedio )
  `ld -shared -Bsymbolic -L/usr/lib -L/usr/lib/efi -T /usr/lib/elf_x86_64_efi.lds
/usr/lib/crt0-efi-x86_64.o aplicacion.o -o aplicacion.so -lefi -lgnuefi` 

Paso 3:  Convertir a ejecutable EFI (PE/COFF)
`objcopy -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel -j .rela -j .rel.* -j .rela.* -j .reloc
--target=efi-app-x86_64 aplicacion.so aplicacion.efi` 

<img width="512" height="220" alt="image" src="https://github.com/user-attachments/assets/cbb812a4-ffa2-4d46-a4c3-f8b546a1bcd1" />
Figura 2


#### Verificacion de Formato 
Antes del análisis estatico, se valido la integridad del archivo mediante el comando `file`, confirmando que se trata de un PE32+ executable (EFI application) x86_64. Tambien pudimos verificar la incompatibilidad con herramientas ELF estandar como `readelf`, confirmando la correcta conversion del formtato, como se observa en la siguiente imagen 

<img width="512" height="51" alt="image" src="https://github.com/user-attachments/assets/27ed794b-31fa-43ec-8ce4-3fb8ab19f809" />
Figura 3: Validación del formato de salida, confirmando que se trata de un ejecutable PE32 para EFI 

Comando `readelf` 
<img width="512" height="86" alt="image" src="https://github.com/user-attachments/assets/e6af0247-92d3-4cdb-b91e-5ee8ff7fc513" />
Figura 3: El error evidencia el cambio exitoso de Magic Bytes 


#### Análisis de Ingenieria Inversa 
Se realizó una auditoria del binario utilizando Ghidra para verificar que el opcode `0xCC` fuera claramente identificable 

- Importación y reconocimiento: al cargar el archivo, Ghidra identificó automáticamente el formato PE. Esto confirma que el firmware Dell podrá interpretar el punto de entrada de la aplicación.
 <img width="2880" height="1723" alt="image" src="https://github.com/user-attachments/assets/c5f85fc9-284a-4afd-9a79-af0f3a336932" />
Figura 4

- Análisis del Punto de entrada: utilizando el CodeBrowser y el Decompiler, se localizó la función `efi_main`. Se constató como la instrucción de impresión se traduce a llamadas de los protocolos de consola de UEFI(`ConOut`)


### Configuración del Firmware y Seguridad 
Para permitir la ejecución de nuestro código personalizado, fue necesario intervenir en la configuración de seguridad del firmware. Al tratarse de una aplicación no firmada por una Autoridad de Certificación reconocida, el protocolo de Secure Boot bloquearía el incio por defecto

Para permitir la ejecución del binario no firmado, tuvimos que acceder a la configuración del firmware presionando F2 durante el arranque. 
Dentro del menú Secure Boot, se deshabilitó la opción correspondiente. Esta modificación es necesaria porque nuestra aplicación no está firmada por una autoridad de Certificación reconocida. De dejarse activo, el firmware rechazaría la carga del binario con un error de violación de política de seguridad. Adicionalmente, se verificó que el modo de arranque estuviera configurado en UEFI y no en modo Legacy/CSM 


### Ejecución en Hardware Real y Resultados 
Una vez configurada la BIOS y preparado el pendrive con el sistemade archivos FAT32, se procedio al arranque mediante el mení de dispositivos 

#### Interacción con la UEFI Shell 
Al iniciar, el firmware cedió el control a la UEFI Interactive Shell v2.2. Como se observa en la captura, el sistema realizó el mapeo de dispositivos (Mapping table), identificando el pendrive como el sistema de archivos `FS0: `

#### Verificación del Análisis de Seguridad 
Al ejecutar la aplicación, el sistema imprimió con éxito los mensajes programados. A diferencia de las pruebas en emuladores, aqui se validó la ejecución directa sobre el procesador 

 Salida detectada:

- "Iniciando analisis de seguridad"
- "Breakpoint estatico alcanzado "

Manejo de flujo: Implementamos la espera de teclado final para evitar que el firmware regresara al menú de booteo instantáneamente, permitiendo sacar una captura 

<img width="1024" height="768" alt="image" src="https://github.com/user-attachments/assets/0f7af9f0-e90d-4736-9806-261d8bc81db3" />
Ejecución en el hardware real 

### Conclusiones 
Este laboratorio permitió integrar concepetos de bajo nivel, seguridad de firmware y desarrollo de sistemas embebidos 

1. Portabilidad UEFI: Se demostró que el formato PE32+ es el estándar universal para la comunicaión con el firmware, permitiendo que un binario compilado en Ubuntu corra en una arquitectura de hardware mederna sin necesidad de un sistema operativo intermedio
2. La desactivación del Secure Boot es un paso mandatorio y esto hace que evidencie como el hardware protege la cadena de confianza
3. Mediante Ghidra, pudimos validar que las vulnerabilidades o marcas de depuración, como el breakpoint `0xCC`, son detectables mediante análisis estático, una técnica fundamental en la prevención de malware de arranque 



## Preguntas de Razonamiento

1. Al ejecutar el comando map y dh, vemos
protocolos e identificadores en lugar de puertos de hardware fijos. ¿Cuál es la
ventaja de seguridad y compatibilidad de este modelo frente al antiguo BIOS?

Como se observa en la imagen, al iniciar la Shell, el comando `map` se ejecuta automáticamente mostrando la tabla de mapeo. En lugar de direcciones físicas rígidas, observamos rutas lógicas. Esto garantiza que, si conectamos el pendrive en un puerto USB distinto, el sistema UEFI pueda localizar el protocolo de archivos (FS0:) dinámicamente, mejorando la compatibilidad frente al modelo de direccionamiento fijo de BIOS 


2. Observando las variables Boot#### y
BootOrder, ¿cómo determina el Boot Manager la secuencia de arranque?

En la imagen, se puede evidenciar que el sistema gestiona el arranque mediante variables globales. La variable `BootOrder` defina la prioridad, mientras que las variables ``Boot####` especifican la ubicación fisica y lógica de cada cargador de arranque. Esta estructura permite que, al desconectar el pendrive utilizado en este laboratorio, el Boot Manager salte automaticamente a la siguiente opción válida sin intervención del usuario 

3.  En el mapa de memoria (memmap), existen
regiones marcadas como RuntimeServicesCode. ¿Por qué estas áreas son un
objetivo principal para los desarrolladores de malware (Bootkits)?

Como se analizó mediante la inspección de variables que se muestran en la imagen, las regiones de tipo `RuntimeServices` son fundamentales para el funcionamiento continuo del sistema. Sin embargo, desde el punto de vista de la seguridad,  respresentan la superficie de ataque más crítica para los Bootkits. Debido a que este código permanece residente en memoria tras el inicio del SO y opera con altos privilegios, un atacante podría subvertir la seguridad del sistema de manera persistente e invisible para las herramieentas de protección convencionales.

4. ¿Por qué utilizamos
SystemTable->ConOut->OutputString en lugar de la función printf de C?

En este laboratorio se utilizó `OutputString`a través de la `SystemTable` en lugar del tradicional `pintf`. Esto se debe a que las aplicaciones UEFI se ejecutan antes de cualquier sistema operativo, careciendo de acceso a la biblioteca estándar de C. `OutputString` utiliza los protocolos nativos del firmware para interacturar con el búfer de videp, garantizando que le mensaje sea visible en el hardware fisico 

5.  En el pseudocódigo de Ghidra, la condición
0xCC suele aparecer como -52. ¿A qué se debe este fenómeno y por qué
importa en ciberseguridad?

El fenómeno ocurre porque Ghidra interpreta el byte `0xCC` como un entero con signo de 8 bits (signed char). En representación en complemento a dos, este significa `-52` en decimal. Esto no es un error del descompilador sino una decisión de tipado: si la variable `code[]` se declara como char en lugar de unsigned char, el compilador trata el valor como negativo. 
En ciberseguridad esto es importante por dos razones. Primero, las herramientas de detección de malware y las reglas YARA que buscan el patrón `0xCC` en positivo o en hexadecimal podrían no correlacionar correctamente si el analista trabaja sobre pseudocódigo de Ghidra son considerar la representación con signo, generando falsos negativos. Segundo, un desarrollador de malware podría aprovechar esta ambiguedad construyendo breakpoints de forma que sean dificiles de identificar mediante búsqueda literal de bytes en herramientas de análisis estático que operen sobre representaciones de alto nivel en lugar del binario crudo 

