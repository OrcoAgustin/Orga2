extern malloc

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - es_indice_ordenado
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - indice_a_inventario
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ITEM_NOMBRE EQU 0	
ITEM_FUERZA EQU 20
ITEM_DURABILIDAD EQU 24
ITEM_SIZE EQU 28

;; La funcion debe verificar si una vista del inventario está correctamente 
;; ordenada de acuerdo a un criterio (comparador)

;; bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador);

;; Dónde:
;; - `inventario`: Un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice`: El arreglo de índices en el inventario que representa la vista.
;; - `tamanio`: El tamaño del inventario (y de la vista).
;; - `comparador`: La función de comparación que a utilizar para verificar el
;;   orden.
;; 
;; Tenga en consideración:
;; - `tamanio` es un valor de 16 bits. La parte alta del registro en dónde viene
;;   como parámetro podría tener basura.
;; - `comparador` es una dirección de memoria a la que se debe saltar (vía `jmp` o
;;   `call`) para comenzar la ejecución de la subrutina en cuestión.
;; - Los tamaños de los arrays `inventario` e `indice` son ambos `tamanio`.
;; - `false` es el valor `0` y `true` es todo valor distinto de `0`.
;; - Importa que los ítems estén ordenados según el comparador. No hay necesidad
;;   de verificar que el orden sea estable.

global es_indice_ordenado
es_indice_ordenado:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 rdi = item_t**     inventario
	; r/m64 rsi = uint16_t*    indice
	; r/m16 dx = uint16_t     tamanio
	; r/m64 rcx = comparador_t comparador

	;;freestyle
	;contador = 0
	;cmp dx,0
	;	jmp end
	;cmp dx,1
	;jmp end
	
	;direccionitemActual = rdi[rsi+contador*2]
	;itemActual = [direccionitemActual]
	;;contador +=1
	;direccionitemSig = rdi[rsi+contador*2]
	;itemSig = [direccionitemSig]
	;cmp(itemActual, itemSig)
	;aca es ver en realidad si desp de comparar rax ==0 
	;tener cuidado con la abi xq haces un call asi que push todo
	;jne return FALSE
	;cmp contador, tamanio
	;jmp .end
	;jmp .loop

	;end. return true

	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp, 8


	;guardamos datos de los parametros
	mov r12,rdi
	mov r13,rsi
	movzx r14,dx
	mov r15,rcx

	cmp dx,0
	je .verdadero

	cmp dx,1
	je .verdadero

	mov rbx, 0
	dec r14 ;cantida de comparaciones finales que haces
	
	.loop:
	movzx r8, word[r13+rbx*2] ;accedo al indice *2 bytes
	mov rdi, [r12+r8*8] ;cargo el item en rdi

	movzx r9, word[r13+rbx*2+2]
	mov rsi, [r12+r9*8];next item 

	inc rbx

	call r15
	cmp rax,0 
	je .falso
	
	cmp rbx, r14
	jl .loop
	jge .verdadero
	
	.verdadero:
	mov rax, TRUE
	jmp .end
	
	
	.falso:
	mov rax, FALSE
	jmp .end
	
	.end:
	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret 




















;segundo ej 
;; Dado un inventario y una vista, crear un nuevo inventario que mantenga el
;; orden descrito por la misma.

;; La memoria a solicitar para el nuevo inventario debe poder ser liberada
;; utilizando `free(ptr)`.

;; item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio);

;; Donde:
;; - `inventario` un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice` es el arreglo de índices en el inventario que representa la vista
;;   que vamos a usar para reorganizar el inventario.
;; - `tamanio` es el tamaño del inventario.
;; 
;; Tenga en consideración:
;; - Tanto los elementos de `inventario` como los del resultado son punteros a
;;   `ítems`. Se pide *copiar* estos punteros, **no se deben crear ni clonar
;;   ítems**

global indice_a_inventario
indice_a_inventario:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64/ rdi = item_t**  inventario
	; r/m64 rsi = uint16_t* indice
	; r/m16 dx = uint16_t  tamanio

	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14	
	push r15
	sub rsp, 8
		
	mov r12, rdi ;inventario a copiar
	mov r13, rsi ;indice 
	movzx r14, dx ;size 

	mov rdi,r14
	imul rdi, 8

	call malloc 

	xor r10, r10 ;contador

	.loop:
		cmp r10,r14
        jge .end 
        movzx r15, word[r13+r10*2]
        mov rdi,[r12 +r15 *8] 
        mov [rax +r10*8], rdi
        inc r10
		jmp .loop

	.end:
		add rsp, 8	
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret
