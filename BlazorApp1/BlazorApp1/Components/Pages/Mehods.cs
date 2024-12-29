using Microsoft.AspNetCore.Components.Forms;
using System;
using System.ComponentModel.DataAnnotations;
using System.IO;
using System.Threading.Tasks;

namespace BlazorApp1.Components.Pages
{
    public class MultipleOfEightAttribute : ValidationAttribute
    {
        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            if (value is int intValue)
            {
                if (intValue % 8 == 0)
                {
                    return ValidationResult.Success;
                }
                else
                {
                    return new ValidationResult("Filter length must be a multiple of 8.");
                }
            }
            return new ValidationResult("Invalid value type.");
        }
    }
    public class FilterParameters
    {
        [Range(0, 20000, ErrorMessage = "Frequency must be between 1 and 20000.")]
        public int Frequency { get; set; }

        [MultipleOfEight(ErrorMessage = "Filter length must be a multiple of 8.")]
        [Range(8, 64, ErrorMessage = "Filter length must be between 8 and 64.")]
        public int FilterLength { get; set; }
    }
    public class WavFileProcessor
    {
        public int SampleRate { get; private set; }
        public int BitsPerSample { get; private set; }
        public int Channels { get; private set; }

        public async Task<float[]> ConvertWavToFloatArray(IBrowserFile browserFile)
        {
            const int bufferSize = 4096; // Fixed buffer size
            using var stream = browserFile.OpenReadStream(30 * 1024 * 1024); // 30 MB
            using var memoryStream = new MemoryStream();

            byte[] buffer = new byte[bufferSize];
            int bytesRead;
            int headerSize = 44;
            bool headerProcessed = false;

            while ((bytesRead = await stream.ReadAsync(buffer, 0, buffer.Length)) > 0)
            {
                if (!headerProcessed)
                {
                    // Process header only once
                    SampleRate = BitConverter.ToInt32(buffer, 24);
                    BitsPerSample = BitConverter.ToInt16(buffer, 34);
                    Channels = BitConverter.ToInt16(buffer, 22);
                    headerProcessed = true;

                    // Copy remaining data after header to memory stream
                    int dataSizeToWrite = bytesRead - headerSize;
                    memoryStream.Write(buffer, headerSize, dataSizeToWrite);
                }
                else
                {
                    // Copy buffer to memory stream
                    memoryStream.Write(buffer, 0, bytesRead);
                }
            }

            byte[] wavFile = memoryStream.ToArray();
            int dataSize = wavFile.Length;
            int bytesPerSample = BitsPerSample / 8;
            int totalSamples = dataSize / bytesPerSample;
            int samplesPerChannel = totalSamples / Channels;

            float[] floatData = new float[totalSamples];
            float normalizationFactor = (float)Math.Pow(2, BitsPerSample - 1);


            // Separate channels and combine them sequentially
            for (int i = 0; i < samplesPerChannel; i++)
            {
                for (int channel = 0; channel < Channels; channel++)
                {
                    int sampleIndex = i * Channels + channel;
                    int outputIndex = channel * samplesPerChannel + i;
                    int sample = BitConverter.ToInt16(wavFile, sampleIndex * bytesPerSample);
                    floatData[outputIndex] = sample / normalizationFactor;
                }
            }

            Console.WriteLine($"Channels: {Channels}");

            return floatData;
        }

        public string ConvertFloatArrayToWav(float[] floatData)
        {
            using var memoryStream = new MemoryStream();
            using var writer = new BinaryWriter(memoryStream);

            int samplesPerChannel = floatData.Length / Channels;
            int totalSamples = samplesPerChannel * Channels;

            // WAV header
            writer.Write(new char[4] { 'R', 'I', 'F', 'F' });
            writer.Write(36 + totalSamples * 2); // File size
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
            writer.Write(totalSamples * 2); // Subchunk2Size

            float normalizationFactor = (float)Math.Pow(2, BitsPerSample - 1);

            // Combine samples back into interleaved format
            for (int i = 0; i < samplesPerChannel; i++)
            {
                for (int channel = 0; channel < Channels; channel++)
                {
                    int inputIndex = channel * samplesPerChannel + i;
                    var shortSample = (short)(floatData[inputIndex] * normalizationFactor);
                    writer.Write(shortSample);
                }
            }

            writer.Flush();
            var wavData = memoryStream.ToArray();
            var audioSrc = $"data:audio/wav;base64,{Convert.ToBase64String(wavData)}";
            return audioSrc;
        }

    }

    public class Coeffs
    {
        public static float[] ComputeCoefficients(double fS, double fL, int N)
        {
            // Compute sinc filter
            double[] h = new double[N];
            double center = (N - 1) / 2.0;

            for (int i = 0; i < N; i++)
            {
                double x = 2 * fL / fS * (i - center);
                h[i] = Sinc(x);
            }

            // Apply Hamming window
            double[] hammingWindow = HammingWindow(N);
            for (int i = 0; i < N; i++)
            {
                h[i] *= hammingWindow[i];
            }

            // Normalize to get unity gain
            double sumH = h.Sum();
            for (int i = 0; i < N; i++)
            {
                h[i] /= sumH;
            }

            // Convert to float[] and return
            return h.Select(coeff => (float)coeff).ToArray();
        }

        // Sinc function
        private static double Sinc(double x)
        {
            if (Math.Abs(x) < 1e-10)
            {
                return 1.0;  // Special case when x is close to zero
            }
            return Math.Sin(Math.PI * x) / (Math.PI * x);
        }

        // Hamming window generator
        private static double[] HammingWindow(int N)
        {
            double[] w = new double[N];
            for (int i = 0; i < N; i++)
            {
                w[i] = 0.54 - 0.46 * Math.Cos(2 * Math.PI * i / (N - 1));
            }
            return w;
        }
    }
}