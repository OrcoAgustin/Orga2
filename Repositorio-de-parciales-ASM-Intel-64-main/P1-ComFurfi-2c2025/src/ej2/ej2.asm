extern free

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
TUIT_MENSAJE_OFFSET EQU 0
TUIT_FAVORITOS_OFFSET EQU 140
TUIT_RETUITS_OFFSET EQU 142
TUIT_ID_AUTOR_OFFSET EQU 144
TUIT_SIZE EQU 148

PUBLICACION_NEXT_OFFSET EQU 0
PUBLICACION_VALUE_OFFSET EQU 8
PUBLICACION_SIZE EQU 16

FEED_FIRST_OFFSET EQU 0 
FEED_SIZE EQU 8

USUARIO_FEED_OFFSET EQU 0;
USUARIO_SEGUIDORES_OFFSET EQU 8; 
USUARIO_CANT_SEGUIDORES_OFFSET EQU 16; 
USUARIO_SEGUIDOS_OFFSET EQU 24; 
USUARIO_CANT_SEGUIDOS_OFFSET EQU 32; 
USUARIO_BLOQUEADOS_OFFSET EQU 40; 
USUARIO_CANT_BLOQUEADOS_OFFSET EQU 48; 
USUARIO_ID_OFFSET EQU 52; 
USUARIO_SIZE EQU 56

; void eliminarDelFeed(feed_t *feed, usuario_t *usuarioABloquear);
global eliminarDelFeed 
eliminarDelFeed:
push rbp
mov rbp, rsp
push r12;feed a revisar
push r13;user que buscar
push r14;ultima publi
push r15;publi actual

mov r12, rdi
mov r13, rsi

mov r14, [r12+FEED_FIRST_OFFSET]
mov r15, r14


.checkFirst:
    cmp r15, 0
    je .end
    mov r10, [r15+PUBLICACION_VALUE_OFFSET] ;cargo el tuit
    mov r11d , dword[r10+TUIT_ID_AUTOR_OFFSET]

    mov r9d, dword[r13+USUARIO_ID_OFFSET]

    cmp r11d, r9d
    jne .noBorrar

    ;hay que borrar el first
    mov r10, [r15+PUBLICACION_NEXT_OFFSET]
    mov r14, r10

    mov rdi, r15
    call free

    mov r15, r14
    mov [r12+FEED_FIRST_OFFSET], r14
    jmp .checkFirst


.loop:
    cmp r15,0
    je .end

    mov r10, [r15+PUBLICACION_VALUE_OFFSET] ;cargo el tuit
    mov r11d , dword[r10+TUIT_ID_AUTOR_OFFSET]

    mov r9d, dword[r13+USUARIO_ID_OFFSET]

    cmp r11d,r9d
    je .borrar
    jmp .noBorrar

.borrar:
    mov r11, [r15+PUBLICACION_NEXT_OFFSET]
    mov [r14+PUBLICACION_NEXT_OFFSET], r11
    mov rdi, r15
    call free

    mov r15,[r14+PUBLICACION_NEXT_OFFSET]
    jmp .loop

.noBorrar:
    mov r14, r15
    mov r15,[r15+PUBLICACION_NEXT_OFFSET]
    jmp .loop



.end:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

; void bloquearUsuario(usuario_t *usuario, usuario_t *usuarioABloquear);
global bloquearUsuario 
bloquearUsuario:
push rbp
mov rbp, rsp
push r12 ;addy blocker
push r13 ;addy bloqueado
push r14
push r15

mov r12, rdi
mov r13, rsi

;Agregar el usuario bloqueado al final del arreglo de usuarios bloqueados.
mov r10,[r12+USUARIO_BLOQUEADOS_OFFSET]

;cargamos cant bloqueados y sumamos 1 a la cant 
mov r11d, dword[r12+USUARIO_CANT_BLOQUEADOS_OFFSET]
mov [r10+r11*8],r13
inc r11d

mov dword[r12+USUARIO_CANT_BLOQUEADOS_OFFSET], r11d


mov rdi, [r12+USUARIO_FEED_OFFSET]
mov rsi, r13
call eliminarDelFeed

mov rdi, [r13+USUARIO_FEED_OFFSET]
mov rsi, r12
call eliminarDelFeed

.end:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
