#include "pch.h"

extern "C" __declspec(dllexport) void ProcessFIRFilter(float* input, float* output, float* coefficients, int inputLength, int coefficientsLength) {
    for (int n = 0; n < inputLength; ++n) {
        for (int k = 0; k < coefficientsLength; ++k) {
            if (n - k >= 0) {
                output[n] += coefficients[k] * input[n - k];
            }
        }
    }
}