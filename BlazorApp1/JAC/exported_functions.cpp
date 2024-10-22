#include "pch.h"


extern "C" __declspec(dllexport) float* ProcessFIRFilter(float* input, float* coefficients, int inputLength, int coefficientsLength) {
    float* output = new float[inputLength];
	for (int i = 0; i < inputLength; i++) {
		output[i] = input[i];

	}
    return output;
}

extern "C" __declspec(dllexport) void FreeMemory(float* ptr) {
    delete[] ptr;
}