#include "pch.h"

// Przyk�adowa funkcja eksportowana
extern "C" __declspec(dllexport) int MyMinus(int a, int b) {
    return a - b;
}

// Inna przyk�adowa funkcja eksportowana
extern "C" __declspec(dllexport) void MyProc1() {
    // Twoja logika tutaj
}
