extern strcpy
extern malloc
extern free

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

ITEM_OFFSET_NOMBRE EQU 0
ITEM_OFFSET_ID EQU 12 ;9 pero lo alineas a 4 bytes
ITEM_OFFSET_CANTIDAD EQU 16 	

POINTER_SIZE EQU 8 ;mal decia 4
UINT32_SIZE EQU 4	;mal decia 8

; Marcar el ejercicio como hecho (`true`) o pendiente (`false`).

global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global EJERCICIO_3_HECHO
EJERCICIO_3_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global EJERCICIO_4_HECHO
EJERCICIO_4_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global ejercicio1
ejercicio1:
	add rdi, rsi
	add rdi, rdx
    add rdi, rcx
    add rdi, r8
	mov rax, rdi
	ret

;corregis llamadas a las funciones
global ejercicio2
;ejercicio2:
;	mov [rdi+ITEM_OFFSET_ID], rdi
;	mov [rdi+ITEM_OFFSET_CANTIDAD], rsi
;	call strcpy 
;	ret

;mi version
ejercicio2:
	push rbp
	mov rbp, rsp
	mov [rdi+ITEM_OFFSET_ID],esi
	mov [rdi+ITEM_OFFSET_CANTIDAD], edx
	mov rsi, rcx
	call strcpy
	mov rax, rdi
	pop rbp
	ret
	

;global ejercicio3
;ejercicio3:
;	cmp rsi, 0
;	je .vacio
;	
;	mov rcx, rdi ; array
;	mov r8, 0 ; sumatoria
;	mov r9, 0 ; i
;
;	.loop:
;	mov rdi, r8
;	mov rsi, [rcx + r9*4]
;
;	call rdx
;
;	add r8, rax
;	mov rax, r8
;
;	inc r9
;	cmp r9, rsi
;	je .end
;
;	jmp .loop
;
;	.vacio:
;	mov rax, 64
;
;	.end:
;	ret
;mi version

global ejercicio3
ejercicio3:
	push rbp
	mov rbp,rsp
	push rbx
	push r12
	push r13
	push r14
	push r15

	cmp esi, 0 ;n
	je .vacio

	mov rbx, rdi ;array
	mov r12d, esi ;n
	mov r13, rdx ;func

	mov edi,0 ;res
	mov esi, [rbx] ;array[0]

	call r13

	mov r15d, eax ;res
	mov r14d, 1 ;contador i

	;guardas los parametros de la func 
	.loop:
		cmp r14d, r12d
		je .end

		mov edi, r15d
		mov esi, [rbx+r14*4]
		call r13
		add r15d, eax
		inc r14d
		jmp .loop

	.vacio:
		mov r15d, 64
		
	.end:
		mov eax, r15d
		pop r15
		pop r14	
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret


;global ejercicio4
;ejercicio4:
;	mov r12, rdi
;	mov r13, rsi
;	mov r14, rdx
;
;	xor rdi, rdi
;	mov eax, UINT32_SIZE
;	mul esi
;	mov edi, eax
;
;	call malloc
;	mov r15, rax
;	
;	xor rbx, rbx
;	.loop:
;	
;	cmp rbx, r13
;	je .end
;
;	mov r8, [r12+rbx*POINTER_SIZE]
;	mov r9d, [r8]
;	mov rax, r14
;	mul r9d
;	mov [r15+rbx*UINT32_SIZE], eax
;	
;	mov rsi, r8 
;	call free
;
;	inc rbx
;	jmp .loop
;
;	.end:
;	mov rax, r15
;	ret

;version main
global ejercicio4
ejercicio4:
	push rbp
	mov rbp,rsp
	push rbx
	push r12
	push r13
	push r14
	push r15


	;rdi dir array
	;rsi n(size)
	;rdx constante c
	;guardamos
	mov r12, rdi ;direccion_array
	mov r13, rsi ;n 
	mov r14, rdx ;c
	mov r15, 0 ;i=0

	lea rdi, [rsi*4] ; malloc 4*n
	call malloc
	mov rbx, rax ; direcnueva


	.loop:
		cmp r15d, r13d
		je .end
		lea rdi,[r12+r15*8] ;direccion_array[i]
		mov rsi,[rdi]
		mov rdi,rsi
		mov rsi, [rdi]
		imul rsi, r14 ; [direccion_array[i]]*C
		mov [rbx+r15*4], rsi
		call free
		mov qword [r12 + r15*8], 0
		inc r15
		jmp .loop
		
	.end:
		mov rax, rbx
		pop r15
		pop r14
		pop r13
		pop r12 
		pop rbx
		pop rbp
		ret











