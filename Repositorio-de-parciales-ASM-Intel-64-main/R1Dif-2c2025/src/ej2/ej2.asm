;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
ITEM_KIND_OFFSET EQU 0
ITEM_WEIGHT_OFFSET EQU 4
ITEM_SIZE EQU 8

BACKPACK_ITEMS_OFFSET EQU 0
BACKPACK_MAX_WEIGHT_OFFSET EQU 8
BACKPACK_ITEM_COUNT_OFFSET EQU 12
BACKPACK_SIZE EQU 16

DESTINATION_NAME_OFFSET EQU 0
DESTINATION_REQUIREMENTS_OFFSET EQU 32
DESTINATION_REQUIREMENTS_SIZE_OFFSET EQU 40
DESTINATION_SIZE EQU 48

EVENT_NEXT_OFFSET EQU 0
EVENT_DESTINATION_OFFSET EQU 8
EVENT_SIZE EQU 16

ITINERARY_FIRST_OFFSET EQU 0
ITINERARY_SIZE EQU 8

NULL EQU 0

extern backpackContainsItem
extern free_event

; bool meetsRequirements(backpack_t *backpack, destination_t *dest)
;
; Parámetros recibidos (System V AMD64 ABI):
;   rdi: backpack_t *backpack    -> puntero a la mochila del usuario
;   rsi: destination_t *dest     -> puntero al destino con sus requisitos
;
; Retorno:
;   rax (al): bool -> true (1) si la mochila contiene todos los objetos requeridos por el destino, false (0) sino.
global meetsRequirements
meetsRequirements:
    push rbp
    mov rbp, rsp
    push rbx                       ; contador de requisitos (i)
    push r12                       ; backpack
    push r13                       ; destination
    push r14                       ; requirements array
    push r15                       ; requirements_size
    sub rsp, 8                     ; 6 pushes (48 bytes) + 8 = 56 bytes -> sub 8 alinea a 16 bytes

    mov r12, rdi
    mov r13, rsi

    mov r14, [r13 + DESTINATION_REQUIREMENTS_OFFSET]
    mov r15d, [r13 + DESTINATION_REQUIREMENTS_SIZE_OFFSET]
    xor ebx, ebx                   ; i = 0

.loop:
    cmp ebx, r15d
    jge .true

    ; bool backpackContainsItem(backpack_t *backpack, item_kind_t kind)
    mov rdi, r12
    mov esi, [r14 + rbx * 4]       ; kind es item_kind_t (4 bytes)
    call backpackContainsItem

    test al, al
    jz .false

    inc ebx
    jmp .loop

.true:
    mov eax, 1
    jmp .fin

.false:
    xor eax, eax

.fin:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; void filterPossibleDestinations(itinerary_t *itinerary, backpack_t *backpack)
global filterPossibleDestinations
filterPossibleDestinations:
    push rbp
    mov rbp, rsp
    push rbx                       ; puntero a itinerary_t*
    push r12                       ; puntero a backpack_t*
    push r13                       ; prev (event_t *prev)
    push r14                       ; curr (event_t *curr)
    push r15                       ; next (event_t *next)
    sub rsp, 8                     ; 6 pushes -> sub 8 alinea a 16 bytes

    test rdi, rdi
    jz .fin

    mov rbx, rdi                   ; rbx = itinerary
    mov r12, rsi                   ; r12 = backpack
    xor r13, r13                   ; prev = NULL
    mov r14, [rbx + ITINERARY_FIRST_OFFSET] ; curr = itinerary->first

.loop:
    test r14, r14                  ; ¿curr == NULL?
    jz .fin

    ; Guardar next = curr->next antes de posiblemente liberar curr
    mov r15, [r14 + EVENT_NEXT_OFFSET]

    ; meetsRequirements(backpack, curr->destination)
    mov rdi, r12
    mov rsi, [r14 + EVENT_DESTINATION_OFFSET]
    call meetsRequirements

    test al, al
    jnz .conservar_evento

    ; --- ELIMINAR EVENTO curr ---
    test r13, r13
    jnz .eliminar_medio

    ; Caso cabeza (prev == NULL): actualizamos itinerary->first
    mov [rbx + ITINERARY_FIRST_OFFSET], r15
    jmp .hacer_free

.eliminar_medio:
    ; Caso intermedio: conectamos prev->next = next
    mov [r13 + EVENT_NEXT_OFFSET], r15

.hacer_free:
    mov rdi, r14
    call free_event

    ; Avanzamos curr al siguiente (prev se mantiene igual)
    mov r14, r15
    jmp .loop

.conservar_evento:
    ; Avanzamos ambos: prev = curr, curr = next
    mov r13, r14
    mov r14, r15
    jmp .loop

.fin:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret