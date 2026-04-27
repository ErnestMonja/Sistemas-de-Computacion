# =============================================================================
# DESAFÍO FINAL: MODO PROTEGIDO (Sintaxis AT&T)
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

    # 2. Cargar la GDT: Usamos la dirección absoluta (0x7c00 + offset) para que lgdt la encuentre
    lgdt gdt_descriptor

    # 3. Activar bit PE en CR0
    mov %cr0, %eax
    or $0x1, %eax
    mov %eax, %cr0

    # 4. Salto lejano (Far JMP) para pasar a 32 bits y cargar CS. En AT&T la sintaxis es: ljmp $selector, $offset
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
    .byte 0xCF          
    .byte 0x90          # acceso: datos, ring 0, lectura/escritura -- se modifica de 0x92 a 0x90 para solo lectura
    .byte 0x00          
gdt_end:

gdt_descriptor:
    .word gdt_end - gdt_start - 1    # tamaño
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

    # --- ESCRIBIR "MP" EN PANTALLA ---
    # Usamos el offset 0x98000 para que sumado a la base (0x20000) de 0xB8000
    
    # Carácter 'M' en la primera posición
    movb $'M', 0x98000
    # Atributo de color (0x0F = Blanco sobre negro)
    movb $0x0F, 0x98001
    
    # Carácter 'P' en la segunda posición (2 bytes después)
    movb $'P', 0x98002
    movb $0x0F, 0x98003

    # --- PRUEBA DE ESCRITURA EN RAM ---
    # Esto sigue escribiendo en la dirección física 0x20000
    movb $'O', (0x0)
    movb $'K', (0x1)

    jmp .

# Relleno para llegar a los 510 bytes y firma de arranque
.fill 510 - (. - _start), 1, 0
.word 0xAA55