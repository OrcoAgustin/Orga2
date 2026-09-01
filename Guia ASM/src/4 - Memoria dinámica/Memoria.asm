extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
strCmp:
	ret

; char* strClone(char* a)
strClone:
	ret

; void strDelete(char* a)
strDelete:
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:
	ret

; uint32_t strLen(char* a)
strLen:
	push rbp
	mov rbp, rsp

	mov rax, 0
	.loop:
		cmp BYTE[rdi],0
		je .salida
		inc rax
		inc rdi 
		jmp.loop
	.salida:

	mov rsp, rbp	
	pop rbp

	ret


; si quisies tener un indice haces mov r8,0 antes del loop y cambias en la linea cmp byte [rdi] por cmp byte [rdi+r8]