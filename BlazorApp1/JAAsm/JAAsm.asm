.code

ProcessFIRFilter proc
    push rbp
    mov rbp, rsp
    jmp _start

_start:
    ; Arguments:
    ; rcx = input array pointer
    ; rdx = output array pointer
    ; r8 = coefficients array pointer
    ; r9 = outputLength
    ; [rsp + 48] = coefficientsLength

    ; r10 = coefficientsLength
    mov r10, [rsp + 48]  
    
    mov rax, r10
    dec rax
    ; Outer loop
    mov r11, 0      ; r11 is the index for the output array
loop_n:
    cmp r11, r9     ; Compare current index with outputLength
    jge end_loop_n      ; If index >= outputLength, end the loop

    ; Inner loop
    mov r12, 0      ; r12 is the index for the coefficients array

    cmp r11, rax
    jl skip_coef

    ; Clear ymm registers
    vxorps ymm0, ymm0, ymm0
    vxorps ymm1, ymm1, ymm1
    vxorps ymm2, ymm2, ymm2
    vxorps ymm3, ymm3, ymm3
    vxorps ymm4, ymm4, ymm4
    vxorps ymm5, ymm5, ymm5
    vxorps ymm6, ymm6, ymm6

loop_k:
    cmp r12, r10        ; Compare current index with coefficientsLength
    jge end_loop_k      ; If index >= coefficientsLength, end the inner loop

    mov r13, r11
    sub r13, r12
    shl r13, 2      ; Multiply by 4 to get the correct index
    cmp r13, 0
    jl end_loop_k       ; If r13 < 0, skip this iteration


    sub r13, 28
    vmovups ymm5, YMMWORD PTR [rcx + r13]
    vmovups ymm6, YMMWORD PTR [r8 + r12 * 4]

    add r12, 8
    jmp multiply_and_add

multiply_and_add:
    ; Multiply and add to ymm4
    vfmadd231ps ymm4, ymm5, ymm6        ; ymm4 += ymm5 * ymm6
    jmp loop_k      ; Continue inner loop

end_loop_k:

    vxorps xmm0, xmm0, xmm0

    vextractf128 xmm0, ymm4, 1      ; Extract the upper part of ymm0
    vaddps xmm4, xmm4, xmm0     ; Add the upper part to the lower part

    vhaddps xmm4, xmm4, xmm4
    vhaddps xmm4, xmm4, xmm4

    vmovss DWORD PTR [rdx + r11 * 4], xmm4  ; Store the result from the lower part of ymm0

    ; Increment output index and continue main loop
    inc r11
    jmp loop_n

skip_coef:
    ; Increment output index and continue main loop
    inc r11
    jmp loop_n

end_loop_n:
    ; End algorithm
    mov rsp, rbp
    pop rbp
    ret

ProcessFIRFilter endp

END