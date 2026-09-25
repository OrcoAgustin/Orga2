extern malloc

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

; uint32_t contarRapido(usuario_t*usuario, uint8_t (*esTuitSobresaliente)(tuit_t *));
global contarRapido
contarRapido:
push rbp
mov rbp, rsp
push r12 ;feed usr
push r13 ;f
push r14 ; publi que se mueve
push r15 ; id usr
push rbx ;res
sub rsp, 8

mov r12, [rdi+FEED_FIRST_OFFSET]
mov r13, rsi
mov r14, [r12+FEED_FIRST_OFFSET]
mov r15d, dword[rdi+USUARIO_ID_OFFSET] 
xor ebx, ebx

.loop:
    cmp r14, 0
    je .end
    mov r11, [r14+PUBLICACION_VALUE_OFFSET]
    mov r10d, [r11+TUIT_ID_AUTOR_OFFSET]
    cmp r10d, r15d
    jne .siguiente
    
    mov rdi, r11
    call r13
    movzx eax, al
    add ebx, eax

.siguiente:
    mov r14, [r14+PUBLICACION_NEXT_OFFSET]
    jmp .loop

.end:
    mov eax, ebx
    add rsp,8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret







; tuit_t **trendingTopic(usuario_t *usuario, uint8_t (*esTuitSobresaliente)(tuit_t *));
global trendingTopic 
trendingTopic:
push rbp
mov rbp, rsp
push r12 ; usr
push r13 ; f
push r14 ;dir del res
push r15 ;publi
push rbx ;contador 
sub rsp, 8

mov r12, rdi
mov r13, rsi

;hay que pedir memo para la res.
call contarRapido

mov edi, eax ;cantidad de tts
cmp rdi , 0
je .endVacio
inc rdi
imul rdi, 8

call malloc

mov r14, rax
mov r9,[r12+USUARIO_FEED_OFFSET]
mov r15, [r9+FEED_FIRST_OFFSET] ;publicacion
xor rbx, rbx
.loop:
    cmp r15, 0
    je .endNoVacio
    
    mov r11, [r15+PUBLICACION_VALUE_OFFSET]
    mov r10d, [r11+TUIT_ID_AUTOR_OFFSET]

    mov r9d, [r12+USUARIO_ID_OFFSET] 

    cmp r10d, r9d
    jne .noTT

    mov rdi, r11
    call r13

    cmp rax,1
    jne .noTT

    mov r11, [r15+PUBLICACION_VALUE_OFFSET]
    mov [r14+rbx*8], r11
    inc rbx

.noTT:
    mov r15, [r15+PUBLICACION_NEXT_OFFSET]
    jmp .loop

.endNoVacio:
    mov [r14+rbx*8], 0
    mov rax, r14
    jmp .end

.endVacio:
    mov rax, 0

.end:   
    add rsp,8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
