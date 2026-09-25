extern free

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
USUARIO_ID_OFFSET EQU 0
USUARIO_NIVEL_OFFSET EQU 4
USUARIO_SIZE EQU 8

PRODUCTO_USUARIO_OFFSET EQU 0
PRODUCTO_CATEGORIA_OFFSET EQU 8
PRODUCTO_NOMBRE_OFFSET EQU 17
PRODUCTO_ESTADO_OFFSET EQU 42
PRODUCTO_PRECIO_OFFSET EQU 44
PRODUCTO_ID_OFFSET EQU 48
PRODUCTO_SIZE EQU 56

PUBLICACION_NEXT_OFFSET EQU 0
PUBLICACION_VALUE_OFFSET EQU 8
PUBLICACION_SIZE EQU 16

CATALOGO_FIRST_OFFSET EQU 0
CATALOGO_SIZE EQU 8


;void removerAparicionesPosterioresDe(publicacion_t* publicacion)
global removerAparicionesPosterioresDe
removerAparicionesPosterioresDe:
push rbp
mov rbp, rsp
push r12 ;publi a comparar
push r13 ;actual
push r14 ;anterior 
push r15 

mov r12, rdi
mov r13, r12
mov r14, r12

.casoUnico:
    mov r11, [r12+PUBLICACION_NEXT_OFFSET]
    cmp r11,0
    je .end
    mov r13,r11


.loop:
    cmp r13, 0
    je .end

    mov r8, [r13+PUBLICACION_VALUE_OFFSET] ;producto de actual
    mov r9, [r12+PUBLICACION_VALUE_OFFSET] ;producto a comparar

    mov r10, [r8+PRODUCTO_USUARIO_OFFSET] ;usuario* del actual
    mov r11, [r9+PRODUCTO_USUARIO_OFFSET] ;usuario* ref 

    cmp r10,r11
    jne .noRepetido

    mov r10, [r8+PRODUCTO_NOMBRE_OFFSET]
    mov r11, [r9+PRODUCTO_NOMBRE_OFFSET]

    cmp r10, r11
    jne .noRepetido
    jmp .repetido

.repetido:
    mov r15, [r13+PUBLICACION_NEXT_OFFSET] 
    mov [r14+PUBLICACION_NEXT_OFFSET], r15  
    mov r15, r13  
    mov rdi,[r13+PUBLICACION_VALUE_OFFSET]
    call free
    mov rdi, r13
    call free
    mov r13, [r14+PUBLICACION_NEXT_OFFSET]
    jmp .loop
    

.noRepetido:
    mov rdi, r13
    mov r14, r13
    mov r13, [rdi+PUBLICACION_NEXT_OFFSET]
    jmp .loop 
    
.end:
    pop r15 
    pop r14
    pop r13
    pop r12
    pop rbp
    ret




;catalogo* removerCopias(catalogo* h)
global removerCopias
removerCopias:
push rbp
mov rbp, rsp
push r12 ;dir catalogo
push r13 ;dir publi

mov r12, rdi
mov r13, [r12 + CATALOGO_FIRST_OFFSET]

.loop:
    cmp r13, 0
    je .end
    mov rdi, r13
    call removerAparicionesPosterioresDe
    mov r13, [r13 + PUBLICACION_NEXT_OFFSET]
    jmp .loop

.end: 
    mov rax, R12
    pop r13
    pop r12
    pop rbp
    ret
