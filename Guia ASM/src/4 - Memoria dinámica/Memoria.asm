extern malloc
extern free
extern fprintf

section .data
	str_null: db "NULL", 0

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
strCmp:
;rdi va a A, rsi va a b, el retorno en EAX
	push rbp
	mov rbp, rsp

	cmp rdi,0
	je .fin

	cmp rsi, 0
	je .fin

	.bucle:
		movzx edx, byte [rdi]
		movzx r8d, byte [rsi]

		cmp edx, r8d
		jb .ret1
		ja .ret2 
		
		cmp edx, 0
		je .ret0 

		inc rdi
		inc rsi
		jmp .bucle

	.ret0:
		xor eax, eax
		jmp .fin	
	
	.ret1:
		xor eax, eax
		mov eax, 1	
		jmp .fin

	.ret2:
		xor eax, eax
		mov eax, -1
		
	.fin:
		pop rbp	
		ret

; char* strClone(char* a)
strClone:

	push rbp
	mov rbp, rsp
	push rbx
	push r12

	mov r12, rdi ;preservo rdi

	call strLen ;rax es len
	
	lea rdi, [rax+1]
	call malloc ;rax arranca nuevo spot

	mov rbx, rax
	.bucle:
		mov dl,byte[r12 +rcx] ;leer caracter de A
		mov byte[rbx+rcx],dl ;lo escribo

		cmp dl,0 ; termino?
		je .fin

		inc rcx
		jmp .bucle

	.fin:
		mov rax, rbx
		pop r12
		pop rbx
		pop rbp
		ret

; void strDelete(char* a)
strDelete:
	push rbp
	mov rbp, rsp

	call free

	pop rbp
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:
	push rbp
	mov rbp, rsp

	cmp rdi, 0
	je .vacio
	
	.novacio:
		mov rdx, rdi
		mov rdi, rsi
		mov rsi, rdx
		xor eax, eax
		call fprintf
		jmp .fin
	
	.vacio:
		mov rdi, rsi
		mov rsi, str_null
		xor eax, eax
		call fprintf
		mov rsi, rdi
			

	.fin:
		pop rbp
		ret

; uint32_t strLen(char* a)
strLen:
	xor rax, rax
	.bucle:
		cmp byte [rdi+rax], 0
		je .fin
		inc rax
		jmp .bucle

	.fin: ret


