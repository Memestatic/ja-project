#include "pch.h"
#include <stdlib.h>  // Include for malloc and free

extern "C" __declspec(dllexport) void ProcessFIRFilter(float* input, float* coefficients, int inputLength, int coefficientsLength) {
    for (int i = inputLength - 1; i >= 0; i--) {
        float temp = 0.f;
        for (int j = 0; j < coefficientsLength; j++) {
            if (i - j >= 0) {
                temp += input[i - j] * coefficients[j];
            }
        }
        input[i] = temp;  // Modify input directly
    }
}