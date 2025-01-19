.code

; Definicja procedury ProcessFIRFilter
ProcessFIRFilter proc
    push rbp                     ; Zachowanie warto�ci bazowego wska�nika stosu
    mov rbp, rsp                 ; Ustawienie nowego bazowego wska�nika stosu
    jmp _start                   ; Przej�cie do etykiety _start

_start:
    ; Opis argument�w przekazywanych do procedury:
    ; rcx = wska�nik do tablicy wej�ciowej (input array)
    ; rdx = wska�nik do tablicy wyj�ciowej (output array)
    ; r8  = wska�nik do tablicy wsp�czynnik�w (coefficients array)
    ; r9  = d�ugo�� tablicy wyj�ciowej (outputLength)
    ; [rsp + 48] = d�ugo�� tablicy wsp�czynnik�w (coefficientsLength)
    ; r10 = d�ugo�� tablicy wsp�czynnik�w (przechowywana w r10 dla wydajno�ci)

    mov r10, [rsp + 48]          ; Pobranie d�ugo�ci tablicy wsp�czynnik�w z stosu

    mov rax, r10
    dec rax                      ; rax = coefficientsLength - 1

    ; Inicjalizacja indeksu dla tablicy wyj�ciowej
    mov r11, 0                   ; r11 = indeks aktualny dla output array

loop_n:
    cmp r11, r9                  ; Por�wnanie bie��cego indeksu z outputLength
    jge end_loop_n               ; Je�li indeks >= outputLength, zako�cz p�tl� zewn�trzn�

    ; Inicjalizacja indeksu dla tablicy wsp�czynnik�w
    mov r12, 0                   ; r12 = indeks aktualny dla coefficients array

    cmp r11, rax                 ; Sprawdzenie, czy r11 < coefficientsLength - 1
    jl skip_coef                 ; Je�li tak, przejd� do pomijania oblicze� wsp�czynnik�w

    ; Czyszczenie rejestr�w YMM, aby przygotowa� je do akumulacji wynik�w
    vxorps ymm0, ymm0, ymm0      ; Zerowanie ymm0
    vxorps ymm4, ymm4, ymm4      ; Zerowanie ymm4
    vxorps ymm5, ymm5, ymm5      ; Zerowanie ymm5
    vxorps ymm6, ymm6, ymm6      ; Zerowanie ymm6

loop_k:
    cmp r12, r10                 ; Por�wnanie indeksu wsp�czynnik�w z coefficientsLength
    jge end_loop_k               ; Je�li indeks >= coefficientsLength, zako�cz p�tl� wewn�trzn�

    mov r13, r11                 ; Kopiowanie bie��cego indeksu wyj�ciowego do r13
    sub r13, r12                 ; Obliczenie odpowiedniego indeksu wej�ciowego
    shl r13, 2                   ; Przemno�enie indeksu przez 4 (rozmiar float) dla oblicze� adres�w

    cmp r13, 0                   ; Sprawdzenie, czy obliczony indeks jest nieujemny
    jl end_loop_k                ; Je�li indeks < 0, pomi� t� iteracj�

    sub r13, 28                  ; Korekta indeksu wej�ciowego (offset)
    
    ; �adowanie danych wej�ciowych i wsp�czynnik�w do rejestr�w YMM
    vmovups ymm5, YMMWORD PTR [rcx + r13]      ; �adowanie 8 float�w z input array
    vmovups ymm6, YMMWORD PTR [r8 + r12 * 4]   ; �adowanie 8 float�w z coefficients array

    add r12, 8                   ; Zwi�kszenie indeksu wsp�czynnik�w o 8 (przetwarzanie wektorowe)
    jmp multiply_and_add         ; Przej�cie do etapu mno�enia i akumulacji

multiply_and_add:
    ; Wykonanie operacji mno�enia i dodania dla wektor�w
    vfmadd231ps ymm4, ymm5, ymm6  ; ymm4 += ymm5 * ymm6
    jmp loop_k                    ; Kontynuacja p�tli wewn�trznej

end_loop_k:
    ; Redukcja YMM4 do pojedynczej warto�ci float
    vxorps xmm0, xmm0, xmm0                  ; Zerowanie rejestru xmm0
    vextractf128 xmm0, ymm4, 1                ; Wyodr�bnienie g�rnej cz�ci YMM4 do xmm0
    vaddps xmm4, xmm4, xmm0                   ; Dodanie g�rnej cz�ci do dolnej
    vhaddps xmm4, xmm4, xmm4                  ; Suma horyzontalna 8 float�w do 4
    vhaddps xmm4, xmm4, xmm4                  ; Suma horyzontalna 4 float�w do 2
    vmovss DWORD PTR [rdx + r11 * 4], xmm4    ; Przechowanie wyniku jako pojedynczego float w output array

    ; Inkrementacja indeksu wyj�ciowego i kontynuacja p�tli zewn�trznej
    inc r11
    jmp loop_n

skip_coef:
    ; Je�eli bie��cy indeks wyj�ciowy < coefficientsLength - 1, pomi� obliczenia wsp�czynnik�w
    inc r11                     ; Inkrementacja indeksu wyj�ciowego
    jmp loop_n                  ; Kontynuacja p�tli zewn�trznej

end_loop_n:
    ; Zako�czenie procedury FIR filter
    mov rsp, rbp                ; Przywr�cenie wska�nika stosu
    pop rbp                     ; Przywr�cenie bazowego wska�nika stosu
    ret                         ; Powr�t z procedury

ProcessFIRFilter endp

END