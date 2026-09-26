; ------------------------
; Offsets para los structs
; Plataforma: x86_64 (LP64)
; ------------------------

section .data

section .text

; COMPLETAR las definiciones (serán revisadas por ABI enforcer):
; ------------------------
; Contenido
; ------------------------
CONT_NOMBRE_OFFSET      EQU 0        ; char nombre[64]
CONT_VALOR_OFFSET       EQU 64       ; uint32_t valor
CONT_COLOR_OFFSET       EQU 68       ; char color[32]
CONT_ES_TESORO_OFFSET   EQU 100      ; bool es_tesoro
CONT_PESO_OFFSET        EQU 104      ; float peso
CONT_SIZE               EQU 108      ; sizeof(Contenido) (rounded)

; ------------------------
; Habitacion
; ------------------------
HAB_ID_OFFSET          EQU 0         ; uint32_t id
HAB_VECINOS_OFFSET     EQU 4        ; uint32_t vecinos[ACC_CANT]
HAB_CONTENIDO_OFFSET   EQU 20       ; Contenido contenido
HAB_VISITAS_OFFSET     EQU 128       ; uint32_t visitas
HAB_SIZE               EQU 132      ; sizeof(Habitacion)

; ------------------------
; Mapa
; ------------------------
MAP_HABITACIONES_OFFSET    EQU 0     ; Habitacion *habitaciones
MAP_N_HABITACIONES_OFFSET  EQU 8     ; uint64_t n_habitaciones
MAP_ID_ENTRADA_OFFSET      EQU 16    ; uint32_t id_entrada
MAP_SIZE                   EQU 24    ; sizeof(Mapa)

; ------------------------
; Recorrido
; ------------------------
REC_ACCIONES_OFFSET        EQU 0     ; Accion *acciones
REC_CANT_ACCIONES_OFFSET   EQU 8     ; uint64_t cant_acciones
REC_SIZE                  EQU 16     ; sizeof(Recorrido)

; Notar que el enum aparece como puntero, entonces no afecta los offsets
;bool hayTesoro(habitacion_t *habitacion)
global hayTesoro
hayTesoro:
push rbp
mov rbp, rsp

movzx rax, byte [rdi+CONT_ES_TESORO_OFFSET+HAB_CONTENIDO_OFFSET  ]

pop rbp
ret

global  encontrarTesoroEnMapa
encontrarTesoroEnMapa:  
push rbp
mov rbp, rsp
push r12 ; mapa 
push r13 ;Recorrido
push r14 ;puntero acciones realizadas
push r15 ;habitacion actual
push rbx ;contador
sub rsp,8



mov r12, rdi
mov r13, rsi
 ;Recorrido
mov r14, rdx
xor rbx, rbx

;check de recorrido vacio
mov r10 , [r13+REC_CANT_ACCIONES_OFFSET]
cmp r10,0
je .endVacio

mov r11d, dword [r12+MAP_ID_ENTRADA_OFFSET]
mov r9 , [r12+MAP_HABITACIONES_OFFSET]
movsxd rax, r11d
imul rax, rax, HAB_SIZE ; rax = id_entrada * 132
lea r15, [r9 + rax] 

mov rdi, r15
call hayTesoro
cmp rax, 1
je .end

.loop:   
    cmp rbx, [r13+REC_CANT_ACCIONES_OFFSET]
    je .endVacio
    
    mov r11,[r13+REC_ACCIONES_OFFSET];acciones del Recorrido
    mov r10d,dword[r11+rbx*4] ;cargo en que direccion ir
    mov r8d, dword [r15 + HAB_VECINOS_OFFSET + r10*4] 
    
    cmp r8d, 99  ;es valida al habitacion?
    je .endVacio

    ;id del vecino en r8d es valido
    imul r8,HAB_SIZE
    mov r9 ,[r12+MAP_HABITACIONES_OFFSET]
    lea r15, [r9+r8]
    inc rbx
    mov rdi,r15
    call hayTesoro
    cmp al, 1
    je .endTrue
    jmp .loop

.endVacio:
    mov rax,0
    jmp .end

.endTrue:
    mov rax,1
    jmp .end

.end:
    mov [r14],rbx
    add rsp, 8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret