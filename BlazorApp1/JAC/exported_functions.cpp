#include "pch.h"
#include <stdlib.h>  // Include for malloc and free

extern "C" __declspec(dllexport) void ProcessFIRFilter(float* input, float* coefficients, int inputLength, int coefficientsLength) {
    float* tempOutput = (float*)malloc(inputLength * sizeof(float));  // Allocate memory
    for (int i = 0; i < inputLength; i++) {
        tempOutput[i] = 0.f;
        for (int j = 0; j < coefficientsLength; j++) {
            if (i - j >= 0) {
                tempOutput[i] += input[i - j] * coefficients[j];  // Corrected indexing
            }
        }
    }
    for (int i = 0; i < inputLength; i++) {
        input[i] = tempOutput[i];  // Modify input directly
    }

    free(tempOutput);  // Free the allocated memory
}