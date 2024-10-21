using System.Runtime.InteropServices;

public static class NativeMethods
{

    // C

    [DllImport("../x64/Debug/JAC.dll", CallingConvention = CallingConvention.Cdecl)]
    public static extern IntPtr ProcessFIRFilter(float[] input, float[] coefficients, int inputLength, int coefficientsLength);

    [DllImport("../x64/Debug/JAC.dll", CallingConvention = CallingConvention.Cdecl)]
    public static extern void FreeMemory(IntPtr ptr);
}