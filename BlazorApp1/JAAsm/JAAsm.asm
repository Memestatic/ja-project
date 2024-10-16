.CODE
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
