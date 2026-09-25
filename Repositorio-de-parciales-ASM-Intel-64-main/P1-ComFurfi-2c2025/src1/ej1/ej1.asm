extern malloc
extern strcpy

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



; void agregarTuitAFeed(tuit_t tuit, usuario_t *usuario  )
global agregarTuitAFeed
agregarTuitAFeed:
push rbp
mov rbp,rsp
push r12 ;dir del tuit
push r13 ;feed del user
push r14 ;direc de la publi
sub rsp, 8

mov r12, rdi
mov r13, [rsi+USUARIO_FEED_OFFSET]

mov rdi, PUBLICACION_SIZE
call malloc
mov r14, rax

mov r11,[r13+FEED_FIRST_OFFSET]
mov [r14], r11
mov [r14+PUBLICACION_VALUE_OFFSET], r12
mov [r13+FEED_FIRST_OFFSET], r14

.end:
    add rsp, 8
    pop r14
    pop r13
    pop r12 
    pop rbp
    ret


; tuit_t *publicar(char *mensaje, usuario_t *usuario);
global publicar
publicar:
push rbp
mov rbp, rsp
push r12;rdi,mensaje
push r13;rsi,user
push r14;dir del tuit
push r15 ;contador
push rbx ;dir de followers
sub rsp, 8

mov r12, rdi
mov r13, rsi

mov rdi, TUIT_SIZE
call malloc

;guardamos addy del tweet y lo armamos
mov r14,rax

lea rdi,[r14+TUIT_MENSAJE_OFFSET]
mov rsi,r12
call strcpy

mov word [r14+TUIT_FAVORITOS_OFFSET],0
mov word [r14+TUIT_RETUITS_OFFSET],0

mov eax,[r13+USUARIO_ID_OFFSET]
mov [r14+TUIT_ID_AUTOR_OFFSET],eax

;ya esta el tuit armado
mov rdi, r14
mov rsi, r13
call agregarTuitAFeed

xor r15d, r15d
mov rbx, [r13+USUARIO_SEGUIDORES_OFFSET]

.loop:
    cmp r15d,dword[r13+USUARIO_CANT_SEGUIDORES_OFFSET]
    je .end
    mov rdi, r14
    mov rsi,[rbx+r15*8]
    call agregarTuitAFeed
    inc r15d
    jmp .loop

.end:
    mov rax, r14
    add rsp, 8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
