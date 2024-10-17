using Microsoft.AspNetCore.Components.Forms;
using System;
using System.IO;
using System.Threading.Tasks;

namespace BlazorApp1.Components.Pages;
public class WavFileProcessor
{
    public int SampleRate { get; private set; }
    public int BitsPerSample { get; private set; }
    public int Channels { get; private set; }
    public float[] FloatData { get; private set; }

    public async Task ConvertWavToFloatArray(IBrowserFile browserFile)
    {
        using var stream = browserFile.OpenReadStream(2097152); // Increased the stream size to 10 MB
        using var memoryStream = new MemoryStream(2097152);
        await stream.CopyToAsync(memoryStream);
        byte[] wavFile = memoryStream.ToArray();

        SampleRate = BitConverter.ToInt32(wavFile, 24);
        BitsPerSample = BitConverter.ToInt16(wavFile, 34);
        Channels = BitConverter.ToInt16(wavFile, 22);
        long dataSize = BitConverter.ToInt32(wavFile, 40);
        byte[] data = new byte[dataSize];

        Array.Copy(wavFile, 44, data, 0, dataSize);

        int bytesPerSample = BitsPerSample / 8;
        long totalSamples = dataSize / bytesPerSample;
        FloatData = new float[totalSamples];

        float normalizationFactor = (float)Math.Pow(2, BitsPerSample);

        for (long i = 0; i < totalSamples; i++)
        {
            int sample = BitConverter.ToInt16(data, (int)(i * bytesPerSample));
            FloatData[i] = sample / normalizationFactor;
        }
    }

    public string ConvertFloatArrayToWav()
    {
        using var memoryStream = new MemoryStream();
        using var writer = new BinaryWriter(memoryStream);

        // WAV header
        writer.Write(new char[4] { 'R', 'I', 'F', 'F' });
        writer.Write(36 + FloatData.Length * 2); // File size
        writer.Write(new char[4] { 'W', 'A', 'V', 'E' });
        writer.Write(new char[4] { 'f', 'm', 't', ' ' });
        writer.Write(16); // Subchunk1Size for PCM
        writer.Write((short)1); // AudioFormat (1 for PCM)
        writer.Write((short)Channels); // NumChannels
        writer.Write(SampleRate); // SampleRate
        writer.Write(SampleRate * Channels * BitsPerSample / 8); // ByteRate
        writer.Write((short)(Channels * BitsPerSample / 8)); // BlockAlign
        writer.Write((short)BitsPerSample); // BitsPerSample

        // Data subchunk
        writer.Write(new char[4] { 'd', 'a', 't', 'a' });
        writer.Write(FloatData.Length * 2); // Subchunk2Size

        float normalizationFactor = (float)Math.Pow(2, BitsPerSample - 1);

        foreach (var sample in FloatData)
        {
            // Convert float sample to short (16-bit PCM)
            var shortSample = (short)(sample * normalizationFactor);
            writer.Write(shortSample);
        }

        writer.Flush();
        var wavData = memoryStream.ToArray();
        var audioSrc = $"data:audio/wav;base64,{Convert.ToBase64String(wavData)}";
        return audioSrc;
    }
}