using System.Runtime.InteropServices;

public delegate void ProcessFIRDelegate(float[] input, float[] coefficients, int inputLength, int coefficientsLength);
public static class NativeMethodsC
{

    // C

    [DllImport("../x64/Debug/JAC.dll", CallingConvention = CallingConvention.Cdecl)]
    public static extern void ProcessFIRFilter(float[] input, float[] coefficients, int inputLength, int coefficientsLength);


}

public static class NativeMethodsAsm
{

    // Asm

    [DllImport("../x64/Debug/JAAsm.dll", CallingConvention = CallingConvention.Cdecl)]
    public static extern void ProcessFIRFilter(float[] input, float[] coefficients, int inputLength, int coefficientsLength);

}