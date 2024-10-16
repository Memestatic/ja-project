// File: NativeMethods.cs

using System.Runtime.InteropServices;

public static class NativeMethods
{
	[DllImport("../x64/Debug/JAAsm.dll", CallingConvention = CallingConvention.Cdecl)]
	public static extern int MyAdd(int a, int b);

    //[DllImport("../x64/Debug/JAC.dll", CallingConvention = CallingConvention.Cdecl)]
    //public static extern IntPtr ApplyFIRFilterFromDLL(byte[] audioData, int dataLength, IntPtr outputLength);

    [DllImport("../x64/Debug/JAC.dll", CallingConvention = CallingConvention.Cdecl)]
    public static extern int MyMinus(int a, int b);
}