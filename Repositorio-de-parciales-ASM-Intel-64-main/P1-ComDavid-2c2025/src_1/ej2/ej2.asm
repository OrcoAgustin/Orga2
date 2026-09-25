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

global removerAparicionesPosterioresDe
removerAparicionesPosterioresDe:

push rbp
push r12 ;publi de entrada, rdi
push r13 ;anterior
push r14 ;comparar
sub rsp, 8

cmp [rdi+PUBLICACION_NEXT_OFFSET],0
je .end

mov r12, rdi
mov r13, rdi
mov r14, rdi

.loop:
    cmp [r14+PUBLICACION_NEXT_OFFSET],0
    je .end

    mov r14, [r14+PUBLICACION_NEXT_OFFSET]

    mov r8, [r12+PUBLICACION_VALUE_OFFSET]
    mov r8, [r8+PRODUCTO_NOMBRE_OFFSET]
    
    mov r9, [r14+PUBLICACION_VALUE_OFFSET]
    mov r9, [r9+PRODUCTO_NOMBRE_OFFSET]

    cmp r8, r9
    jne .noBorrar

    mov r8, [r12+PUBLICACION_VALUE_OFFSET]
    mov r8, [r8+PRODUCTO_USUARIO_OFFSET]
    
    mov r9, [r14+PUBLICACION_VALUE_OFFSET]
    mov r9, [r9+PRODUCTO_USUARIO_OFFSET]

    cmp r8, r9
    je .borrar
    jne .noBorrar

 
.noBorrar:
    mov r13, r14
    jmp .loop

.borrar:
    mov r10,[r13+PUBLICACION_NEXT_OFFSET]
    mov r10, [r14+PUBLICACION_NEXT_OFFSET]
    mov [r13+PUBLICACION_NEXT_OFFSET], r10
    mov rdi, [r14+PUBLICACION_VALUE_OFFSET]
    call free
    mov rdi, r14
    call free
    mov r14, r13
    jmp .loop

.end:
    add rsp, 8
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
push r12;catalogo
push r13
push r14;item
sub rsp, 8

;guardamos rdi(catalogo)
mov r12, rdi

cmp [rdi+ CATALOGO_FIRST_OFFSET],0
je .end

;cargar primer publi en rdi
mov rdi, [rdi+CATALOGO_FIRST_OFFSET]

.loop:
    mov r14,rdi
    call removerAparicionesPosterioresDe
    cmp [r14+PUBLICACION_NEXT_OFFSET],0
    je .end

    ;tiene otro item distinto
    mov r14,[r14+PUBLICACION_NEXT_OFFSET]
    mov rdi, r14
    jmp .loop



.end:
    mov rax, r12
    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
