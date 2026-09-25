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

;usuario_t **asignarNivelesParaNuevosUsuarios(uint32_t *ids, uint32_t cantidadDeIds, uint8_t (*deQueNivelEs)(uint32_t)) {
global asignarNivelesParaNuevosUsuarios 
asignarNivelesParaNuevosUsuarios:
push rbp
mov rbp, rsp
push r12 ;dir al array de users
push r13 ;cant ids   
push r14 ; f
push r15 ; res
push rbx ;contador
sub rsp, 8

mov r12, rdi
mov r13, rsi
mov r14, rdx

;cubrimos el caso vacio
mov rax,0
cmp r13,0
je .end

.pedirMemo:
    mov rdi, r13
    imul rdi, 8
    call malloc
    mov r15, rax

xor rbx,rbx
.loop:
    cmp rbx, r13
    je .postCiclo

    mov rdi,8
    call malloc 
    ;rax ahora tiene la direc de el user nuevo
    mov [r15+rbx*8],rax
    mov rdi,[r12+rbx*4]
    call r14
    ;rax tiene el lvl del id [r12+rbx*4] 


    mov r10, [r15+rbx*8] ;direc del user nuevo
    mov r9d, [r12+rbx*4] ;id del user 
    mov dword [r10] , r9d ;al lado del r10 tiene que ir + USUARIO_ID_OFFSET pero es = 0
    mov [r10+USUARIO_NIVEL_OFFSET] , al
    inc rbx
    jmp .loop

.postCiclo:
    mov rax, r15

.end:
    add rsp,8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
