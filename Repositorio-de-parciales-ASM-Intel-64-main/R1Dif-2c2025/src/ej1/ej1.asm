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

; bool canItemFitInBackpack(backpack_t *backpack, item_t *item)
;
; Parámetros recibidos (System V AMD64 ABI):
;   rdi: backpack_t *backpack -> puntero a la mochila
;   rsi: item_t *item         -> puntero al objeto que se quiere agregar
;
; Retorno:
;   rax (al): bool -> true (1) si el item entra sin superar max_weight, false (0) sino.

global canItemFitInBackpack
canItemFitInBackpack:
    ; -------------------------------------------------------------
    ; 1. Prólogo y preservación de registros callee-saved
    ; -------------------------------------------------------------
    push rbp
    mov rbp, rsp
    push r12                    ; r12: puntero a backpack
    push r13                    ; r13: puntero a item
    push r14                    ; r14d: índice de iteración (i = 0 .. item_count-1)
    push r15                    ; r15b: peso restante disponible en la mochila

    ; Guardamos los argumentos en registros no volátiles
    mov r12, rdi
    mov r13, rsi

    ; -------------------------------------------------------------
    ; 2. Inicialización de contadores y peso
    ; -------------------------------------------------------------
    xor r14d, r14d                                      ; i = 0
    mov r10d, [r12 + BACKPACK_ITEM_COUNT_OFFSET]        ; r10d = cantidad de items en la mochila
    mov r15b, [r12 + BACKPACK_MAX_WEIGHT_OFFSET]        ; r15b = capacidad máxima de peso

    ; -------------------------------------------------------------
    ; 3. Bucle para restar el peso de los objetos ya presentes
    ;    (recorremos backpack->items y restamos cada items[i].weight)
    ; -------------------------------------------------------------
.loop:
    cmp r14d, r10d                                      ; ¿Ya procesamos todos los items presentes?
    jge .verificar_nuevo_item

    ; Leemos el array de items: backpack->items
    mov rdi, [r12 + BACKPACK_ITEMS_OFFSET]

    ; Leemos items[i].weight (offset ITEM_WEIGHT_OFFSET = 4 dentro de cada struct de tamaño ITEM_SIZE = 8)
    mov al, byte [rdi + r14 * ITEM_SIZE + ITEM_WEIGHT_OFFSET]
    sub r15b, al                                        ; peso_restante -= items[i].weight

    inc r14d                                            ; i++
    jmp .loop

    ; -------------------------------------------------------------
    ; 4. Comprobar si el nuevo objeto entra en el peso restante
    ; -------------------------------------------------------------
.verificar_nuevo_item:
    mov r13b, byte [r13 + ITEM_WEIGHT_OFFSET]           ; r13b = peso del nuevo item
    cmp r13b, r15b                                      ; ¿peso_nuevo <= peso_restante?
    jle .entra
    jmp .no_entra

.entra:
    mov rax, 1                                          ; Retorna true (1)
    jmp .fin

.no_entra:
    mov rax, 0                                          ; Retorna false (0)
    jmp .fin

    ; -------------------------------------------------------------
    ; 5. Epílogo: restaurar registros callee-saved y retornar
    ; -------------------------------------------------------------
.fin:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret