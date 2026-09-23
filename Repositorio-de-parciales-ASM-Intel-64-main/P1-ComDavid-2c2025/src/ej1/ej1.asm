extern malloc

extern malloc

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
USUARIO_ID_OFFSET EQU 0
USUARIO_NIVEL_OFFSET EQU 4
USUARIO_SIZE EQU 8
USUARIO_NIVEL_OFFSET EQU 4
USUARIO_SIZE EQU 8

PRODUCTO_USUARIO_OFFSET EQU 0
PRODUCTO_CATEGORIA_OFFSET EQU 8
PRODUCTO_NOMBRE_OFFSET EQU 17
PRODUCTO_ESTADO_OFFSET EQU 42
PRODUCTO_PRECIO_OFFSET EQU 44
PRODUCTO_ID_OFFSET EQU 48
PRODUCTO_SIZE EQU 56
PRODUCTO_CATEGORIA_OFFSET EQU 8
PRODUCTO_NOMBRE_OFFSET EQU 17
PRODUCTO_ESTADO_OFFSET EQU 42
PRODUCTO_PRECIO_OFFSET EQU 44
PRODUCTO_ID_OFFSET EQU 48
PRODUCTO_SIZE EQU 56

PUBLICACION_NEXT_OFFSET EQU 0
PUBLICACION_VALUE_OFFSET EQU 8
PUBLICACION_SIZE EQU 16
PUBLICACION_VALUE_OFFSET EQU 8
PUBLICACION_SIZE EQU 16

CATALOGO_FIRST_OFFSET EQU 0
CATALOGO_SIZE EQU 8

;bool productoValido (producto*)
global productoValido
productoValido:
mov r9 , [rdi+PRODUCTO_USUARIO_OFFSET]
movzx r10, byte [r9+USUARIO_NIVEL_OFFSET]
movzx r11, word [rdi+PRODUCTO_ESTADO_OFFSET]

cmp r11, 1
jne .noValido
cmp  r10, 1
jl .noValido
jmp .valido

.noValido:
    mov rax, 0
    ret

.valido:
    mov rax, 1
    ret

;producto_t* filtrarPublicacionesNuevasDeUsuariosVerificados (catalogo*)
global filtrarPublicacionesNuevasDeUsuariosVerificados
filtrarPublicacionesNuevasDeUsuariosVerificados:

push rbp
mov rbp, rsp
push r12 ;dir de entrada
push r13 ;primer item
push r14 ;dir res
push r15 ;res desplazada
sub rsp,8

mov r12, rdi
mov r13, [r12 + CATALOGO_FIRST_OFFSET]

mov r10, 1
mov r11, r13

.recorrerRapido:
    cmp r11, 0
    je .pedirMemoria
    mov r11 , [r11 + PUBLICACION_NEXT_OFFSET]
    inc r10
    jmp .recorrerRapido

.pedirMemoria:
    imul r10,8
    mov rdi, r10
    call malloc

mov r14, rax
mov r15, rax

.loop:
    cmp r13, 0
    je .fin
    ;13 es publicacion
    mov rdi,[r13+PUBLICACION_VALUE_OFFSET]
    call productoValido
    mov r8, rax
    cmp r8, 1
    je .itemValido
    jmp .postCiclo

.postCiclo:
    mov r13, [r13 +PUBLICACION_NEXT_OFFSET]
    jmp .loop


.itemValido:
    mov r11, [r13+PUBLICACION_VALUE_OFFSET]
    mov [r15], r11
    add r15, 8
    jmp .postCiclo


.fin:
    mov qword[r15], 0
    mov rax, r14
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
