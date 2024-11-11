.data

    one_float DWORD 1.0f

.code

ProcessFIRFilter proc
    ; Arguments:
    ; rcx = input array pointer
    ; rdx = output array pointer
    ; r8 = coefficients array pointer
    ; r9 = inputLength
    ; [rsp + 40] = coefficientsLength (fifth argument on the stack)

    ; Move coefficientsLength from the stack into r10
    mov r10, QWORD PTR [rsp + 40]  ; r10 = coefficientsLength

    xor r11, r11                  ; Initialize output index to 0

OuterLoop:
    cmp r11, r9                   ; Check if we reached the end of input array
    jge LoopEnd                   ; Exit loop if index >= input length

    xorps xmm0, xmm0              ; Clear xmm0 to accumulate result for output sample

    ; Inner loop to apply all coefficients to the window
    xor r12, r12                  ; Initialize coefficients index (inner loop index)

InnerLoop:
    cmp r12, r10                  ; Compare coefficients index with length
    jge StoreResult               ; Break out of inner loop if weíve applied all coefficients

    ; Calculate the address of input[r11 - r12]
    mov rax, r11                  ; Move r11 to rax
    sub rax, r12                  ; rax = r11 - r12 (to access past samples)
    shl rax, 2                    ; Multiply by 4 (shift left by 2) to get byte offset

    ; Check for out-of-bounds access
    cmp rax, 0                    ; Check if rax is less than 0
    jl SkipCoefficient             ; If so, skip to the next coefficient

    ; Load the float at input[r11 - r12] into xmm1
    ;movss xmm1, DWORD PTR [rcx + rax]
    movups xmm1, XMMWORD PTR [rcx + rax] ; load 4 input samples


    ; Load coefficient[r12] into xmm2 (coefficients array pointer is in r8)
    ;movss xmm2, DWORD PTR [r8 + r12 * 4]  ; Load coefficient[r12] into xmm2
    movups xmm2, XMMWORD PTR [r8 + r12 * 4] ; load 4 coefficients

    ; Multiply input sample by coefficient and accumulate result
    ;mulss xmm1, xmm2              ; xmm1 = input * coefficient
    ;addss xmm0, xmm1              ; xmm0 += xmm1
    mulps xmm1, xmm2			  ; xmm1 = input * coefficient
    addps xmm0, xmm1			  ; xmm0 += xmm1

SkipCoefficient:
    ;inc r12                       ; Increment coefficients index
    add r12, 4                     ; Move to the next 4 coefficient
    jmp InnerLoop                 ; Repeat for next coefficient

StoreResult:
    ; Store the accumulated result in the output array
    ;movss DWORD PTR [rdx + r11 * 4], xmm0
    movups XMMWORD PTR [rdx + r11 * 4], xmm0

    add r11, 4                       ; Move to the next output position
    jmp OuterLoop                 ; Repeat for the next input sample

LoopEnd:
    ret

ProcessFIRFilter endp




ModifyFloatArray proc
        ; rcx contains the address of the float array
        ; rdx contains the length of the array (number of elements)

        xor r8, r8               ; Initialize index (r8 = 0)

    LoopStart:
        cmp r8, rdx              ; Compare index with array length
        jge LoopEnd              ; If index >= length, exit loop

        ; Load the float at array[r8] into xmm0
        movss xmm0, DWORD PTR [rcx + r8 * 4]   ; Each float is 4 bytes
        addss xmm0, xmm0                        ; Multiply by 2 (xmm0 = xmm0 * 2)
        movss DWORD PTR [rcx + r8 * 4], xmm0   ; Store the result back

        inc r8                 ; Increment index
        jmp LoopStart          ; Repeat for the next element

    LoopEnd:
        ret
ModifyFloatArray endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GrayscaleFilter PROC
    ; Arguments:
    ; rcx = wskaünik pixelBuffer
    ; rdx = width
    ; r8 = bytesPerPixel
    ; r9 = stride
    ; [rsp + 40] startRow
    ; [rsp + 48] endRow

    mov r10, QWORD PTR [rsp + 40]
    mov r11, QWORD PTR [rsp + 48]

RowLoop:
    cmp r10, r11
    jge EndProc

    ; Poczπtek bieøπcego wiersza
    mov rax, r10
    imul rax, r9
    add rax, rcx

    ; PÍtla po pikselach w wierszu
    xor r12, r12						; Zerowanie licznika pikseli

PixelLoop:
    cmp r9, rdx
    jge NextRow

    ; Ustaw piksel na kolor czerwony
    mov BYTE PTR [rax], 0               ; Ustaw B
    mov BYTE PTR [rax+1], 0             ; Ustaw G
    mov BYTE PTR [rax+2], 255           ; Ustaw R

    ; Przejdü do kolejnego piksela
    add rax, r8                        ; Przejdü do nastÍpnego piksela
    inc r9
    jmp PixelLoop

NextRow:
    inc r10
    jmp RowLoop

EndProc:
    ret
GrayscaleFilter ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end