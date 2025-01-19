.code

; Definicja procedury ProcessFIRFilter
ProcessFIRFilter proc
    push rbp                     ; Zachowanie wartoœci bazowego wskaŸnika stosu
    mov rbp, rsp                 ; Ustawienie nowego bazowego wskaŸnika stosu
    jmp _start                   ; Przejœcie do etykiety _start

_start:
    ; Opis argumentów przekazywanych do procedury:
    ; rcx = wskaŸnik do tablicy wejœciowej (input array)
    ; rdx = wskaŸnik do tablicy wyjœciowej (output array)
    ; r8  = wskaŸnik do tablicy wspó³czynników (coefficients array)
    ; r9  = d³ugoœæ tablicy wyjœciowej (outputLength)
    ; [rsp + 48] = d³ugoœæ tablicy wspó³czynników (coefficientsLength)
    ; r10 = d³ugoœæ tablicy wspó³czynników (przechowywana w r10 dla wydajnoœci)

    mov r10, [rsp + 48]          ; Pobranie d³ugoœci tablicy wspó³czynników z stosu

    mov rax, r10
    dec rax                      ; rax = coefficientsLength - 1

    ; Inicjalizacja indeksu dla tablicy wyjœciowej
    mov r11, 0                   ; r11 = indeks aktualny dla output array

loop_n:
    cmp r11, r9                  ; Porównanie bie¿¹cego indeksu z outputLength
    jge end_loop_n               ; Jeœli indeks >= outputLength, zakoñcz pêtlê zewnêtrzn¹

    ; Inicjalizacja indeksu dla tablicy wspó³czynników
    mov r12, 0                   ; r12 = indeks aktualny dla coefficients array

    cmp r11, rax                 ; Sprawdzenie, czy r11 < coefficientsLength - 1
    jl skip_coef                 ; Jeœli tak, przejdŸ do pomijania obliczeñ wspó³czynników

    ; Czyszczenie rejestrów YMM, aby przygotowaæ je do akumulacji wyników
    vxorps ymm0, ymm0, ymm0      ; Zerowanie ymm0
    vxorps ymm4, ymm4, ymm4      ; Zerowanie ymm4
    vxorps ymm5, ymm5, ymm5      ; Zerowanie ymm5
    vxorps ymm6, ymm6, ymm6      ; Zerowanie ymm6

loop_k:
    cmp r12, r10                 ; Porównanie indeksu wspó³czynników z coefficientsLength
    jge end_loop_k               ; Jeœli indeks >= coefficientsLength, zakoñcz pêtlê wewnêtrzn¹

    mov r13, r11                 ; Kopiowanie bie¿¹cego indeksu wyjœciowego do r13
    sub r13, r12                 ; Obliczenie odpowiedniego indeksu wejœciowego
    shl r13, 2                   ; Przemno¿enie indeksu przez 4 (rozmiar float) dla obliczeñ adresów

    cmp r13, 0                   ; Sprawdzenie, czy obliczony indeks jest nieujemny
    jl end_loop_k                ; Jeœli indeks < 0, pomiñ tê iteracjê

    sub r13, 28                  ; Korekta indeksu wejœciowego (offset)
    
    ; £adowanie danych wejœciowych i wspó³czynników do rejestrów YMM
    vmovups ymm5, YMMWORD PTR [rcx + r13]      ; £adowanie 8 floatów z input array
    vmovups ymm6, YMMWORD PTR [r8 + r12 * 4]   ; £adowanie 8 floatów z coefficients array

    add r12, 8                   ; Zwiêkszenie indeksu wspó³czynników o 8 (przetwarzanie wektorowe)
    jmp multiply_and_add         ; Przejœcie do etapu mno¿enia i akumulacji

multiply_and_add:
    ; Wykonanie operacji mno¿enia i dodania dla wektorów
    vfmadd231ps ymm4, ymm5, ymm6  ; ymm4 += ymm5 * ymm6
    jmp loop_k                    ; Kontynuacja pêtli wewnêtrznej

end_loop_k:
    ; Redukcja YMM4 do pojedynczej wartoœci float
    vxorps xmm0, xmm0, xmm0                  ; Zerowanie rejestru xmm0
    vextractf128 xmm0, ymm4, 1                ; Wyodrêbnienie górnej czêœci YMM4 do xmm0
    vaddps xmm4, xmm4, xmm0                   ; Dodanie górnej czêœci do dolnej
    vhaddps xmm4, xmm4, xmm4                  ; Suma horyzontalna 8 floatów do 4
    vhaddps xmm4, xmm4, xmm4                  ; Suma horyzontalna 4 floatów do 2
    vmovss DWORD PTR [rdx + r11 * 4], xmm4    ; Przechowanie wyniku jako pojedynczego float w output array

    ; Inkrementacja indeksu wyjœciowego i kontynuacja pêtli zewnêtrznej
    inc r11
    jmp loop_n

skip_coef:
    ; Je¿eli bie¿¹cy indeks wyjœciowy < coefficientsLength - 1, pomiñ obliczenia wspó³czynników
    inc r11                     ; Inkrementacja indeksu wyjœciowego
    jmp loop_n                  ; Kontynuacja pêtli zewnêtrznej

end_loop_n:
    ; Zakoñczenie procedury FIR filter
    mov rsp, rbp                ; Przywrócenie wskaŸnika stosu
    pop rbp                     ; Przywrócenie bazowego wskaŸnika stosu
    ret                         ; Powrót z procedury

ProcessFIRFilter endp

END