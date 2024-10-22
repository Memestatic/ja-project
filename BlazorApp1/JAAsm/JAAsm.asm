section .data

section .text
global ProcessFIRFilter
global FreeMemory

; float* ProcessFIRFilter(float* input, float* coefficients, int inputLength, int coefficientsLength)
ProcessFIRFilter:
    ; Prologue
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Move parameters into registers
    mov rcx, [rbp+16]  ; input
    mov rdx, [rbp+24]  ; coefficients
    mov r8d, [rbp+32]  ; inputLength
    mov r9d, [rbp+40]  ; coefficientsLength

    ; Allocate memory for output
    mov eax, r8d
    imul eax, 4
    call malloc
    mov rsi, rax  ; output

    ; Initialize loop counter
    xor rdi, rdi  ; i = 0

.loop_start:
    ; Check if i >= inputLength
    cmp rdi, r8d
    jge .loop_end

    ; output[i] = input[i]
    movss xmm0, [rcx + rdi*4]
    movss [rsi + rdi*4], xmm0

    ; Increment loop counter
    inc rdi
    jmp .loop_start

.loop_end:
    ; Epilogue
    leave
    ret

; void FreeMemory(float* ptr)
FreeMemory:
    ; Prologue
    push rbp
    mov rbp, rsp
    
    ; Move parameter into register
    mov rcx, [rbp+16]  ; ptr
    
    ; Free memory
    call free

    ; Epilogue
    leave
    ret