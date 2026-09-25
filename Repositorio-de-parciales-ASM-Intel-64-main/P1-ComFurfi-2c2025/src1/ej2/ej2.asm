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

; void borrarDelFeed(usuario_t *usuario, usuario_t *usuarioABloquear);
global borrarDelFeed    
borrarDelFeed:
push rbp
mov rbp, rsp
push r12 ;addy feed a revisar
push r13 ;addy del usr que borrar de feed
push r14 ;ultimo
push r15 ;actual

mov r12, [rdi+USUARIO_FEED_OFFSET]
mov r13, rsi

mov r14, 0
mov r15, [r12+FEED_FIRST_OFFSET]

.comparoTuit:
    cmp r15 , 0
    je .end
    mov r9d, dword[r13+USUARIO_ID_OFFSET]
    mov r10, [r15+PUBLICACION_VALUE_OFFSET]
    mov r11d, dword[r10+TUIT_ID_AUTOR_OFFSET]
    cmp r9d, r11d
    je .borrar
    jmp .noBorrar

.borrar:
    mov rdi, [r15+PUBLICACION_NEXT_OFFSET]
    cmp r14, 0 
    je .noFirst
    jmp .hayFirst

    .noFirst:
    mov [r12+FEED_FIRST_OFFSET], rdi
    jmp .borrado

    .hayFirst:
    mov [r14+PUBLICACION_NEXT_OFFSET], rdi
     
    .borrado:
    mov rdi, r15
    mov r15, [rdi+PUBLICACION_NEXT_OFFSET] 
    call free

    jmp .comparoTuit

.noBorrar:    
    mov r14, r15
    mov r15, [r14+PUBLICACION_NEXT_OFFSET]
    jmp .comparoTuit


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
push r12 ;addi de blocker
push r13 ;addi del bloqueado

mov r12, rdi
mov r13, rsi 

;Agregar el usuario bloqueado al final del arreglo de usuarios bloqueados.
mov r9, [r12+USUARIO_BLOQUEADOS_OFFSET];cargo la dire del array
mov r10d, dword[r12+USUARIO_CANT_BLOQUEADOS_OFFSET]
mov [r9 + r10*8], r13
inc r10d ;tenes que volver a escribirlo
mov dword[r12+USUARIO_CANT_BLOQUEADOS_OFFSET], r10d


;Borrar todas las publicaciones del feed del usuario bloqueador que contengan tuits del usuario bloqueado.
mov rdi, r12
mov rsi, r13 
call borrarDelFeed

;Borrar todas las publicaciones del feed del usuario bloqueado que contengan tuits del usuario bloqueador.
mov rsi, r12
mov rdi, r13
call borrarDelFeed 

.end:
    pop r13
    pop r12
    pop rbp
    ret
