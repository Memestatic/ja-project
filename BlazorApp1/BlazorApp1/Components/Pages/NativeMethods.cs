// File: NativeMethods.cs

using System.Runtime.InteropServices;

public static class NativeMethods
{
	[DllImport("../x64/Debug/JAAsm.dll", CallingConvention = CallingConvention.Cdecl)]
	public static extern int MyAdd(int a, int b);
}