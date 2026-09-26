extern malloc


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

;llega un recorrido y una posicion del mismo, devuelve la opuesta
global invertirAccion 
invertirAccion:
push rbp
mov rbp, rsp
push r12
push r13

mov r12, rdi
mov r13, rsi

mov r11,[r12+REC_ACCIONES_OFFSET]

mov r10d, dword[r11+r13*4]

cmp r10d, 0
je .norte

cmp r10d, 1
je .sur

cmp r10d, 2
je .este

cmp r10d, 3
je .oeste


.norte:
    mov eax, 1
    jmp .end

.sur:
    mov eax, 0
    jmp .end

.este: 
    mov eax, 3
    jmp .end

.oeste: 
    mov eax, 2
    jmp .end

.end:
    pop r13
    pop r12
    pop rbp
    ret



global  invertirRecorridoConDirecciones
invertirRecorridoConDirecciones:
push rbp
mov rbp, rsp
push r12 ;Recorrido
push r13 ;largo del Recorrido
push r14 ;contador
push r15 ;array res

mov r12, rdi
mov r13, rsi
xor r14, r14

mov rax, 0
cmp r13, 0
je .end

mov rdi, 16 
call malloc
mov r15, rax

mov rdi, r13
imul rdi, 4
call malloc

;armamos el array res
mov [r15+REC_ACCIONES_OFFSET],rax
mov [r15+REC_CANT_ACCIONES_OFFSET], r13

;ahora llenamos los movimientos
.loop
    mov r10 ,r13
    sub r10, 1
    cmp r14, r13
    je .preEnd

    mov rdi, r12
    mov r9, r10
    sub r9, r14
    mov rsi, r9
    call invertirAccion

    mov r10, [r15+REC_ACCIONES_OFFSET]
    mov [r10+r14*4], eax

    inc r14
    jmp .loop

.preEnd:
    mov rax, r15

.end:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
    
