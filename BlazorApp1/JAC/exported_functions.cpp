#include "pch.h"

extern "C" __declspec(dllexport) int MyMinus(int a, int b) {
    return a - b;
}



extern "C" __declspec(dllexport) float* ProcessFIRFilter(float* input, float* coefficients, int inputLength, int coefficientsLength) {
    float* output = new float[inputLength];
	for (int i = 0; i < inputLength; i++) {
		output[i] = input[i];
		/*for (int j = 0; j < coefficientsLength; j++) {
			if (i - j >= 0) {
				output[i] += input[i - j] * coefficients[j];
			}
		}*/
	}
    return output;
}

extern "C" __declspec(dllexport) void FreeMemory(float* ptr) {
    delete[] ptr;
}