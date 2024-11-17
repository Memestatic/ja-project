.data

.code

ProcessFIRFilter proc
    push rbp              ; Zapisz poprzedni¹ wartoœæ RBP
    mov rbp, rsp          ; Przypisz RSP do RBP
    jmp _start			; PrzejdŸ do pocz¹tku programu

_start:
    ; Arguments:
    ; rcx = input array pointer
    ; rdx = output array pointer
    ; r8 = coefficients array pointer
    ; r9 = outputLength
    ;

    ; Move coefficientsLength from the stack into r10
    mov r10, [rsp + 48]  ; r10 = coefficientsLength

    ; Zewnêtrzna pêtla
    mov r11, 0                      ; r11 is the index for the output array
loop_n:
    cmp r11, r9                     ; Compare current index with outputLength
    jge end_loop_n                         ; If index >= outputLength, end the loop

    ; Za³aduj zero do rejestru YMM
    vxorps ymm0, ymm0, ymm0         ; Clear ymm0 to store the sum
    vxorps ymm1, ymm1, ymm1
    vxorps ymm2, ymm2, ymm2
    vxorps ymm3, ymm3, ymm3
    vxorps ymm4, ymm4, ymm4
    vxorps ymm5, ymm5, ymm5
    vxorps ymm6, ymm6, ymm6
    vxorps ymm7, ymm7, ymm7

    ; Wewnêtrzna pêtla
    mov r12, 0                      ; r12 is the index for the coefficients array

loop_k:
    cmp r12, r10                    ; Compare current index with coefficientsLength
    jge end_loop_k             ; If index >= coefficientsLength, end the inner loop

    mov r13, r11
    sub r13, r12
    shl r13, 2                      ; Multiply by 4 to get the correct index
    cmp r13, 0
    jl end_loop_k                   ; If r13 < 0, skip this iteration

    jmp copy_loop

copy_loop:
    ; Initialize indices for loading into xmm0 and xmm1
    xor r14, r14                    ; r14 is the index for xmm0
    xor r15, r15                    ; r15 is the index for xmm1

    ; Za³aduj zero do rejestru YMM
    vxorps ymm0, ymm0, ymm0         ; Clear ymm0 to store the sum
    vxorps ymm1, ymm1, ymm1
    vxorps ymm2, ymm2, ymm2
    vxorps ymm3, ymm3, ymm3
    ;vxorps ymm4, ymm4, ymm4
    vxorps ymm5, ymm5, ymm5
    vxorps ymm6, ymm6, ymm6
    vxorps ymm7, ymm7, ymm7

    jmp load_xmm0

load_xmm0:
    cmp r14, 4                      ; Check if xmm0 is full (4 values)
    jge load_xmm1                   ; If full, start loading xmm1

    cmp r12, r10                    ; Compare current index with coefficientsLength
    jge load_xmm1             ; If index >= coefficientsLength, end the inner loop

    ; Check if n - k >= 0
    mov r13, r11
    sub r13, r12
    shl r13, 2
    cmp r13, 0                   
    jl load_xmm1                         

    ; Load value into xmm0
    vpinsrd xmm0, xmm0, DWORD PTR [rcx + r13], 0

    ; Shift values in xmm0 to the right by 1 place
    vpermilps xmm0, xmm0, 57

    ; Load coefficient as well
    vpinsrd xmm2, xmm2, DWORD PTR [r8 + r12 * 4], 0

    ; Shift values in xmm2 to the right by 1 place
    vpermilps xmm2, xmm2, 57

    inc r12                         ; Increment coefficients index
    inc r14                         ; Increment xmm0 index
    jmp load_xmm0                   ; Continue loading values

load_xmm1:
    cmp r15, 4                      ; Check if xmm1 is full (4 values)
    jge combine_ymm                ; If full, combine xmm0 and xmm1 into ymm0

    cmp r12, r10                    ; Compare current index with coefficientsLength
    jge combine_ymm             ; If index >= coefficientsLength, end the inner loop

    mov r13, r11
    sub r13, r12
    shl r13, 2
    cmp r13, 0
    jl combine_ymm

    ; Load value into xmm1
    vpinsrd xmm1, xmm1, DWORD PTR [rcx + r13], 0

    ; Shift values in xmm1 to the right by 1 place
    vpermilps xmm1, xmm1, 57

    ; Load coefficient as well
    vpinsrd xmm3, xmm3, DWORD PTR [r8 + r12 * 4], 0

    ; Shift values in xmm3 to the right by 1 place
    vpermilps xmm3, xmm3, 57

    inc r12						 ; Increment coefficients index
    inc r15                         ; Increment xmm1 index
    jmp load_xmm1                   ; Continue loading values

combine_ymm:
    ; Combine xmm0 and xmm1 into ymm0
    vinsertf128 ymm5, ymm5, xmm0, 0
    vinsertf128 ymm5, ymm5, xmm1, 1

    vinsertf128 ymm6, ymm6, xmm2, 0
    vinsertf128 ymm6, ymm6, xmm3, 1

    ; Continue with the rest of the algorithm
    jmp multiply_and_add

multiply_and_add:
    ; Mno¿enie i dodawanie do rejestru YMM
    vfmadd231ps ymm4, ymm5, ymm6    ; Multiply and add to ymm4
    jmp loop_k					  ; Continue inner loop

end_loop_k:
    ; Zapisz wynik do output
    ; Assuming ymm0 contains the 8 single-precision floating-point values

    ; First horizontal add: sum pairs of adjacent values
    ;vhaddps ymm4, ymm4, ymm4  ; ymm4 = (a0 + a1, a2 + a3, a4 + a5, a6 + a7, a0 + a1, a2 + a3, a4 + a5, a6 + a7)

    ; Second horizontal add: sum pairs of adjacent values again
    ;vhaddps ymm4, ymm4, ymm4  ; ymm4 = (a0 + a1 + a2 + a3, a4 + a5 + a6 + a7, a0 + a1 + a2 + a3, a4 + a5 + a6 + a7, ...)

    ; Third horizontal add: sum the two remaining values
    ;vhaddps ymm4, ymm4, ymm4  ; ymm4 = (a0 + a1 + a2 + a3 + a4 + a5 + a6 + a7, ..., ..., ...)

    ; The result is now in the lower 32 bits of ymm0

    vxorps xmm0, xmm0, xmm0

    vextractf128 xmm0, ymm4, 1    ; Extract the upper part of ymm0
    vaddps xmm4, xmm4, xmm0        ; Add the upper part to the lower part

    vhaddps xmm4, xmm4, xmm4
    vhaddps xmm4, xmm4, xmm4

    vmovss DWORD PTR [rdx + r11*4], xmm4  ; Store the result from the lower part of ymm0

    ; Increment output index and continue main loop
    inc r11
    jmp loop_n

end_loop_n:
    ; Zakoñcz program
    mov rsp, rbp          ; Przywróæ RSP
    pop rbp               ; Przywróæ poprzednie RBP
    ret

ProcessFIRFilter endp

END