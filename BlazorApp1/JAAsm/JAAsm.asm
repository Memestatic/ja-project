;-------------------------------------------------------------------------
;.586
;INCLUDE C:\masm32\include\windows.inc 

.CODE
;-------------------------------------------------------------------------
; To jest przyk³adowa funkcja. 
;-------------------------------------------------------------------------
;parametry funkcji: RCX RDX R8 R9 stos, 
;lub zmiennoprzec.  XMM0 1 2 3
MyProc1 proc		
add 	rcx, rdx
mov 	rax, rcx
jnc ET1
ror	rcx,1
mul 	rcx
ret
ET1:	
neg 	rax
ret
MyProc1 endp

;-------------------------------------------------------------------------
; This is a sample function that takes two integer arguments and returns their sum.
;-------------------------------------------------------------------------
; Function parameters: RCX, RDX
MyAdd proc
	; Add the values in RCX and RDX
	add		rcx, rdx
	; Move the result to RAX (return value)
	mov		rax, rcx
	; Return from the procedure
	ret
MyAdd endp

END 			;no entry point
;-------------------------------------------------------------------------
