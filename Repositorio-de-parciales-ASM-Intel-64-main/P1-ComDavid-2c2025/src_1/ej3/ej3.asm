extern malloc
extern free
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

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


;usuario_t **asignarNivelesParaNuevosUsuarios(uint32_t *ids, uint32_t cantidadDeIds, uint8_t (*deQueNivelEs)(uint32_t)) {
global asignarNivelesParaNuevosUsuarios 
asignarNivelesParaNuevosUsuarios:

push rbp
mov rbp, rsp
push r12 ;rdi es el array 
push r13 ;rsi size
push r14 ;rdx direc a f
push r15 ;direc de salida
push rbx ;ont
sub rsp, 8

mov r12, rdi
mov r13, rsi
mov r14, rdx

cmp r13, 0
jne .entrada
mov rax, 0
jmp .end

.entrada:
    imul rsi, USUARIO_SIZE
    mov rdi, rsi
    call malloc
    ;en rax queda la direc, se guarda en r15
    mov r15, rax

    xor rbx, rbx ;contador

.loop:
    cmp rbx, r13
    mov rax, r15
    jge .end

    ;case else
    mov rdi, USUARIO_SIZE
    call malloc
    ;guardo en [r15+rbx*8] la direc de rax
    mov [r15+rbx*8], rax

    ;chequeo que el usuario no este todavia
    mov edi, [r12+rbx*4] ;cargo user

    xor r9, r9
    .checkRepetido:
        cmp r9, rbx
        jge .pasaCheck
        
        mov r10d,dword[r15+r9*8] ;cae en el id 
        cmp r10d , edi
        je .noPasaCheck
        inc r9
        jmp .checkRepetido

    .noPasaCheck:
    mov rdi,[r15+rbx*8]
    call free
    inc rbx
    jmp .loop



    .pasaCheck:
    mov [rax+USUARIO_ID_OFFSET], edi
    call r14
    jmp .nuevo

.nuevo:
    ;en al esta el lvl del user
    mov r10,[r15 + rbx*USUARIO_ID_OFFSET]
    mov byte [r10+USUARIO_NIVEL_OFFSET], al  
    inc rbx
    jmp .loop

.end:
    add rsp, 8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
