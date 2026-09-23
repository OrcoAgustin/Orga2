extern malloc

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

global productoValido
productoValido:
    ;es valido si tiene 1 en valor de PRODUCTO_ESTADO_OFFSET
    ;y usuario nivel 1 o mas
    ;en rdi te entra el producto_t*
    push rbp 
    mov rbp, rsp
    
    mov si, word[rdi+PRODUCTO_ESTADO_OFFSET]
    cmp si, 1
    ;chequeamos estado
    jne .falso
    
    mov rsi, [rdi+USUARIO_ID_OFFSET]
    mov sil, byte[rsi+USUARIO_NIVEL_OFFSET]
    ;chequeamos nivel
    cmp sil, 1
    jl .falso
    jmp .true

    .true:
        mov rax,1
        jmp .end

    .falso:
        mov rax, 0
        jmp .end

    .end:
        pop rbp
        ret

;producto_t* filtrarPublicacionesNuevasDeUsuariosVerificados (catalogo*)
global filtrarPublicacionesNuevasDeUsuariosVerificados
filtrarPublicacionesNuevasDeUsuariosVerificados:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    push rbx

    mov r12, rdi

    ;recorrer rapido para ver malloc
    xor r10, r10
    mov rdi, [r12+CATALOGO_FIRST_OFFSET]
    .recorrerRapido:
        cmp rdi, 0
        je .finRecorrer
        inc r10
        mov rdi, [rdi +PUBLICACION_NEXT_OFFSET]
        jmp .recorrerRapido   
    .finRecorrer:


    inc r10 ;extra para el final de la cola
    imul r10, 8
    mov rdi, r10
    call malloc

    ;direc del array en r13
    mov r13, rax
    mov rbx, rax

    ;cargar primer publicacion
    mov r14, [r12 + CATALOGO_FIRST_OFFSET]
    cmp r14, 0
    je .cerrarLoop

    .loop:
        ;producto de la publicacion
        mov r15, [r14 + PUBLICACION_VALUE_OFFSET]
        mov rdi, r15

        call productoValido
        ;en rax tengo si es true 

        cmp rax, 0
        je .preLoop

        ;dio true por ende se carga
        mov [r13], r15
        ;salta 8 bytes por el puntero
        ;r13 ya estaba corriendo sobre el final del nuevo array
        add r13, 8         
        
    .preLoop:    
        cmp [r14+PUBLICACION_NEXT_OFFSET], 0
        je .cerrarLoop
        mov r14, [r14+PUBLICACION_NEXT_OFFSET]
        jmp .loop

    .cerrarLoop:
        mov qword[r13+PUBLICACION_NEXT_OFFSET], 0

    .end:
        mov rax,rbx 
        pop rbx
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbp
        ret
