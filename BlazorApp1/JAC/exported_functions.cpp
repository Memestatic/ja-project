#include "pch.h"

// Przykładowa funkcja eksportowana
extern "C" __declspec(dllexport) int MyMinus(int a, int b) {
    return a - b;
}

// Inna przykładowa funkcja eksportowana
extern "C" __declspec(dllexport) void MyProc1() {
    // Twoja logika tutaj
}
