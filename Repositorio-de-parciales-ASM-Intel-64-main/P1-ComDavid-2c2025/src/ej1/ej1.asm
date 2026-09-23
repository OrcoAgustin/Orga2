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
;bool productoValido (producto_t*)
global productoValido
productoValido:
push rbp
mov rbp, rsp
push r12
sub rsp, 8

mov r12, rdi

movzx r9, word[r12+PRODUCTO_ESTADO_OFFSET] ;estado del producto
mov r10, [r12+USUARIO_ID_OFFSET] ;usuario
movzx r11, byte[r10+USUARIO_NIVEL_OFFSET] ;nivel
cmp r9, 1
jne .falso
cmp r11,1
jl .falso
jmp .true

.falso:
    mov rax,0
    jmp .end

.true:
    mov rax,1
    jmp .end

.end:
    add rsp,8
    pop r12
    pop rbp
    ret



;producto_t* filtrarPublicacionesNuevasDeUsuariosVerificados (catalogo*)
global filtrarPublicacionesNuevasDeUsuariosVerificados
filtrarPublicacionesNuevasDeUsuariosVerificados:
push rbp
mov rbp, rsp
push r12 ;direc de entrada
push r13 ;publi
push r14 ;direc res
push r15 ;donde estamos del res


mov r12, rdi
mov r13 , [r12+CATALOGO_FIRST_OFFSET] ;la publi

mov r10, 1
;contador, arrancamos en 1 porque tenemos el 0 del final, 

lea r11, [r13] ;iterarlo tranqui sin perder el primero
.recorrerRapido:
    cmp r11,0
    je .pedirMemo
    inc r10
    mov r11, [r11+PUBLICACION_NEXT_OFFSET]
    jmp .recorrerRapido

.pedirMemo:
    lea r15, [r10*8]
    lea rdi, [r10*8]
    call malloc

.casoVacio:
    cmp r15,8
    mov [rax],0
    je .end

mov r14, rax ;guardamos return 
mov r15, r14 ;guardamos r15 el "contador" del actual 

.loop:
    cmp r13, 0
    je .postCiclo
    mov rbx , [r13+PUBLICACION_VALUE_OFFSET] ;cargo producto
    cmp [rbx],0
    je .postCiclo
    mov rdi, rbx
    call productoValido
.tag:
    cmp rax, 1
    je .agregarProd
    jmp .preCiclo

.agregarProd:    
    mov qword[r15],rbx
    add r15,8

.preCiclo:
    mov r13 ,[r13+PUBLICACION_NEXT_OFFSET]
    jmp .loop

.postCiclo:
    mov qword[r15],0
    mov rax, r14
    jmp .end

.end:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret





