; Archivo: calculo.s
section .text
global sumar_uno

sumar_uno:
    ; --- PRÓLOGO ---
    push rbp            ; Guarda el puntero base del llamador 
    mov rbp, rsp        ; Crea el nuevo Stack Frame 

    ; --- OPERACIÓN ---
    ; El valor entero (ya convertido en C) 
    mov rax, rdi        ; Movemos el parámetro al acumulador RAX 
    add rax, 1          ; Sumamos 1 

    ; --- EPÍLOGO ---
    pop rbp             ; Restauramos el RBP previo 
    ret                 ; Retornamos; el resultado queda en RAX 