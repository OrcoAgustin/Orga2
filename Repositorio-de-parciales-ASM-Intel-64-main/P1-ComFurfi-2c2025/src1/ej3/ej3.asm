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

; uint32_t recorrerRapido(publicacion_t *publicación, uint8_t (*esTuitSobresaliente)(tuit_t *), uint32_t idUser);
global recorrerRapido
recorrerRapido:
push rbp
mov rbp, rsp
push r12 ;publicación
push r13 ;f 
push r14 ;id 
push r15 ;contador
push rbx 
sub rsp,8

mov r12, rdi
mov r13, rsi
mov r14d, edx
 
xor r15, r15

.loop:
    cmp r12, 0
    je .end

    mov r11, [r12+PUBLICACION_VALUE_OFFSET]
    mov r11d, dword [r11+TUIT_ID_AUTOR_OFFSET]
    cmp r11d, r14d
    jne .noValido

    mov rdi, [r12+PUBLICACION_VALUE_OFFSET]
    call r13

    add r15b, al

    .noValido:
    mov r12, [r12+PUBLICACION_NEXT_OFFSET]
    jmp .loop

.end:
    mov rax, r15
    add rsp, 8
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
push r12 ;user 
push r13 ;func
push r14 ;res
push r15 ;contador
push rbx ; tuit
sub rsp, 8

mov r12, rdi
mov r13 ,rsi 

mov r11, [r12+USUARIO_FEED_OFFSET]
mov rdi, [r11+FEED_FIRST_OFFSET]

mov edx, dword[r12+USUARIO_ID_OFFSET]

call recorrerRapido
;en rax hay cantidad de tuits

.pedirMemo:
    ;cubrimos caso de no hay tuits en feed
    cmp rax, 0
    mov r14,0
    je .end 
    
    add rax, 1
    imul rax, 8
    mov rdi ,rax
    call malloc
    mov r14, rax

mov r11 , [r12+USUARIO_FEED_OFFSET]
mov rbx ,[r11+FEED_FIRST_OFFSET] ;cargo publicacion

mov r15, r14
.loop:
    cmp rbx,0
    je .preEnd
    
    mov r11, [rbx+PUBLICACION_VALUE_OFFSET]
    mov r11d,dword [r11+TUIT_ID_AUTOR_OFFSET]
    cmp [r12+USUARIO_ID_OFFSET], r11d
    jne .siguiente
    
    ;si son iguales
    mov rdi, [rbx+PUBLICACION_VALUE_OFFSET]
    call r13

    cmp al, 1
    jne .siguiente
    mov r10, [rbx+PUBLICACION_VALUE_OFFSET]
    mov [r15], r10
    lea r15 , [r15+8]

    .siguiente:
        mov rbx, [rbx+PUBLICACION_NEXT_OFFSET]
        jmp .loop

.preEnd:
    mov [r15],qword 0

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
