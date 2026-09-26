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
extern malloc

; backpack_t *prepareBackpack(itinerary_t *itinerary, uint8_t getItemWeight(item_kind_t))
;
; Parámetros (System V AMD64 ABI):
;   rdi: itinerary_t *itinerary
;   rsi: uint8_t (*getItemWeight)(item_kind_t)
;
; Retorno:
;   rax: backpack_t *backpack
global prepareBackpack 
prepareBackpack:
    ; -------------------------------------------------------------
    ; 1. Prólogo y preservación de registros no volátiles
    ; -------------------------------------------------------------
    push rbp
    mov rbp, rsp
    push rbx                    ; rbx: contador / índice auxiliar
    push r12                    ; r12d: bitmask de items requeridos (needed_mask)
    push r13                    ; r13: puntero a la función getItemWeight
    push r14                    ; r14: puntero a la estructura backpack creada
    push r15                    ; r15: puntero al evento actual / array de items
    sub rsp, 8                  ; Alinear RSP a 16 bytes antes de cualquier llamada (call)

    xor r12d, r12d              ; needed_mask = 0
    mov r13, rsi                ; r13 = getItemWeight

    ; Si itinerary == NULL, la máscara queda en 0
    test rdi, rdi
    jz .contar_items

    ; r15 = itinerary->first
    mov r15, [rdi + ITINERARY_FIRST_OFFSET]

    ; -------------------------------------------------------------
    ; 2. Recorrer la lista de eventos del itinerario y recolectar requisitos
    ; -------------------------------------------------------------
.loop_eventos:
    test r15, r15               ; ¿Fin de la lista de eventos?
    jz .contar_items

    mov rax, [r15 + EVENT_DESTINATION_OFFSET] ; rax = ev->destination
    test rax, rax
    jz .sig_evento

    mov rdx, [rax + DESTINATION_REQUIREMENTS_OFFSET]      ; rdx = dest->requirements
    mov ecx, [rax + DESTINATION_REQUIREMENTS_SIZE_OFFSET] ; ecx = requirements_size
    test rdx, rdx
    jz .sig_evento

    xor ebx, ebx                ; i = 0

.loop_reqs:
    cmp ebx, ecx
    jge .sig_evento

    mov eax, [rdx + rbx * 4]    ; eax = requirements[i] (item_kind_t)
    bts r12d, eax               ; Prender el bit correspondiente: needed_mask |= (1 << eax)

    inc ebx
    jmp .loop_reqs

.sig_evento:
    mov r15, [r15 + EVENT_NEXT_OFFSET] ; ev = ev->next
    jmp .loop_eventos

    ; -------------------------------------------------------------
    ; 3. Contar cuántos tipos de objetos distintos se necesitan
    ; -------------------------------------------------------------
.contar_items:
    xor ebx, ebx                ; ebx = count = 0
    xor ecx, ecx                ; ecx = k = 0 (de 0 a 6)

.loop_count:
    cmp ecx, 7
    jge .alojar_mochila

    bt r12d, ecx                ; ¿Está prendido el bit k?
    jnc .no_count
    inc ebx                     ; count++

.no_count:
    inc ecx
    jmp .loop_count

    ; -------------------------------------------------------------
    ; 4. Alojar e inicializar backpack_t (16 bytes)
    ; -------------------------------------------------------------
.alojar_mochila:
    mov edi, BACKPACK_SIZE      ; 16 bytes
    call malloc
    mov r14, rax                ; r14 = puntero a backpack

    ; Configurar campos de la mochila:
    mov byte [r14 + BACKPACK_MAX_WEIGHT_OFFSET], 255   ; max_weight = 255
    mov [r14 + BACKPACK_ITEM_COUNT_OFFSET], ebx         ; item_count = count
    mov qword [r14 + BACKPACK_ITEMS_OFFSET], 0          ; items = NULL

    ; Si count == 0, terminamos (mochila vacía)
    test ebx, ebx
    jz .fin_exito

    ; -------------------------------------------------------------
    ; 5. Alojar el array de items: count * ITEM_SIZE (count * 8 bytes)
    ; -------------------------------------------------------------
    lea rdi, [rbx * ITEM_SIZE]  ; rdi = count * 8
    call malloc
    mov [r14 + BACKPACK_ITEMS_OFFSET], rax
    mov r15, rax                ; r15 = puntero para escribir en items[idx]

    ; -------------------------------------------------------------
    ; 6. Rellenar los items llamando a getItemWeight(k)
    ; -------------------------------------------------------------
    xor ebx, ebx                ; ebx = k = 0 (de 0 a 6)

.loop_rellenar:
    cmp ebx, 7
    jge .fin_exito

    bt r12d, ebx                ; ¿Se requiere el objeto k?
    jnc .sig_k

    ; Llamar a getItemWeight(k)
    mov edi, ebx                ; arg1 = kind (k)
    call r13                    ; retorno: uint8_t en al

    ; Guardar en el array de items:
    mov [r15 + ITEM_KIND_OFFSET], ebx    ; items[idx].kind = k (4 bytes)
    mov [r15 + ITEM_WEIGHT_OFFSET], al   ; items[idx].weight = peso (1 byte)

    add r15, ITEM_SIZE          ; Avanzar al siguiente item_t (8 bytes)

.sig_k:
    inc ebx
    jmp .loop_rellenar

.fin_exito:
    mov rax, r14                ; Retornar el puntero a la mochila en rax

    ; -------------------------------------------------------------
    ; 7. Epílogo: restaurar registros preservados y retornar
    ; -------------------------------------------------------------
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret


