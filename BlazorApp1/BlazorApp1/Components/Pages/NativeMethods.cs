using System.Runtime.InteropServices;

namespace BlazorApp1.Components.Pages { 
    public delegate void ProcessFIRDelegate(float[] input, float[] output, float[] coefficients, int inputLength, int coefficientsLength);
    public static class NativeMethodsC
    {

        // C

        [DllImport("../x64/Release/JAC.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern void ProcessFIRFilter(float[] input, float[] output, float[] coefficients, int inputLength, int coefficientsLength);
    }

    public static class NativeMethodsAsm
    {

        // Asm

        [DllImport("../x64/Release/JAAsm.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern void ProcessFIRFilter(float[] input, float[] output, float[] coefficients, int inputLength, int coefficientsLength);
    }
}