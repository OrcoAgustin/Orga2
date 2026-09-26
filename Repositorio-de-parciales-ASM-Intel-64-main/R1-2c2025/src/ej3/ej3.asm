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

;uint32_t sumarTesoros(Mapa *mapa, uint32_t actual, bool *visitado);
;
; Parámetros recibidos (System V AMD64 ABI):
;   rdi: Mapa* mapa
;   esi: uint32_t actual
;   rdx: bool* visitado
;
; Retorno:
;   eax: uint32_t (suma acumulada de valores de tesoros)

global  sumarTesoros
sumarTesoros:
    ; -------------------------------------------------------------
    ; 1. Prólogo y preservación de registros no volátiles (callee-saved)
    ; -------------------------------------------------------------
    push rbp
    mov rbp, rsp
    push rbx                    ; rbx: índice del bucle de vecinos (0 a 3)
    push r12                    ; r12: puntero a Mapa (mapa)
    push r13                    ; r13d: acumulador del valor de los tesoros
    push r14                    ; r14: puntero al arreglo de visitados (visitado)
    push r15                    ; r15: puntero a la Habitacion actual
    sub rsp, 8                  ; Alinear RSP a 16 bytes antes de realizar calls

    ; Guardamos los argumentos en registros que sobreviven a las llamadas
    mov r12, rdi                ; r12 = mapa
    mov esi, esi                ; Limpiamos los 32 bits superiores de rsi (rsi = (uint64_t)actual)
    mov r14, rdx                ; r14 = visitado

    ; -------------------------------------------------------------
    ; 2. Caso base 1: verificar si el índice actual es válido
    ;    (actual >= mapa->n_habitaciones o actual == 99)
    ; -------------------------------------------------------------
    cmp rsi, [r12 + MAP_N_HABITACIONES_OFFSET]
    jae .ret_cero

    ; -------------------------------------------------------------
    ; 3. Caso base 2: verificar si la habitación actual ya fue visitada
    ;    visitado es un bool* (1 byte por elemento: 0 = false, 1 = true)
    ; -------------------------------------------------------------
    cmp byte [r14 + rsi], 1
    je .ret_cero

    ; -------------------------------------------------------------
    ; 4. Marcar la habitación actual como visitada
    ;    visitado[actual] = true (1)
    ; -------------------------------------------------------------
    mov byte [r14 + rsi], 1

    ; -------------------------------------------------------------
    ; 5. Obtener el puntero a la Habitacion actual:
    ;    &mapa->habitaciones[actual] = habitaciones + (actual * HAB_SIZE)
    ; -------------------------------------------------------------
    mov rax, [r12 + MAP_HABITACIONES_OFFSET] ; rax = mapa->habitaciones
    imul rcx, rsi, HAB_SIZE                 ; rcx = actual * HAB_SIZE (132 bytes)
    add rax, rcx                            ; rax = dirección de habitaciones[actual]
    mov r15, rax                            ; r15 guarda la dirección de la habitación actual

    ; -------------------------------------------------------------
    ; 6. Verificar si la habitación actual contiene un tesoro:
    ;    Inicializamos el acumulador (r13d) en 0.
    ;    Si contenido.es_tesoro == 1, sumamos contenido.valor al acumulador.
    ; -------------------------------------------------------------
    xor r13d, r13d                          ; acumulador = 0
    cmp byte [r15 + HAB_CONTENIDO_OFFSET + CONT_ES_TESORO_OFFSET], 1
    jne .iniciar_recorrido_vecinos

    ; Sumar el valor del tesoro (uint32_t de 4 bytes)
    mov r13d, [r15 + HAB_CONTENIDO_OFFSET + CONT_VALOR_OFFSET]

.iniciar_recorrido_vecinos:
    ; -------------------------------------------------------------
    ; 7. Recorrer recursivamente las 4 habitaciones vecinas:
    ;    vecinos[0..3] = [ACC_NORTE, ACC_SUR, ACC_ESTE, ACC_OESTE]
    ;    Cada vecino es un uint32_t (4 bytes).
    ; -------------------------------------------------------------
    xor ebx, ebx                            ; ebx = i = 0 (contador de vecinos)

.loop_vecinos:
    cmp ebx, 4                              ; ¿Recorrimos los 4 vecinos?
    jge .fin_recorrido

    ; Cargar el id del vecino i: habitacion->vecinos[i]
    mov esi, [r15 + HAB_VECINOS_OFFSET + rbx * 4]

    ; Preparar los argumentos para la llamada recursiva:
    ;   rdi: mapa (r12)
    ;   esi: id del vecino (ya cargado en esi)
    ;   rdx: visitado (r14)
    mov rdi, r12
    mov rdx, r14

    call sumarTesoros                       ; llamada recursiva

    ; El retorno de la llamada viene en eax (uint32_t)
    add r13d, eax                           ; acumulador += resultado

    inc ebx                                 ; i++
    jmp .loop_vecinos

.fin_recorrido:
    ; Colocar el acumulador total en el registro de retorno eax
    mov eax, r13d
    jmp .fin

.ret_cero:
    ; Retornar 0 ante índice inválido o habitación ya visitada
    xor eax, eax

.fin:
    ; -------------------------------------------------------------
    ; 8. Epílogo: restaurar registros preservados y retornar
    ; -------------------------------------------------------------
    add rsp, 8                              ; Deshacer alineamiento de pila
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

    
