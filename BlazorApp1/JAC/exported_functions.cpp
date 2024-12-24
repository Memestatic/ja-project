#include "pch.h"

extern "C" __declspec(dllexport) void ProcessFIRFilter(float* input, float* output, float* coefficients, int inputLength, int coefficientsLength) {
    for (int n = 0; n < inputLength; ++n) {
        if (n < coefficientsLength - 1) {
            output[n] = 0;
            continue;
        }

        for (int k = 0; k < coefficientsLength; ++k) {
            if (n - k >= 0) {
                output[n] += coefficients[coefficientsLength - 1 - k] * input[n - k];
            }
            else {
                break;
            }
        }
    }
}