using System;
using System.Collections.Concurrent;
using System.Diagnostics;
using System.Linq;
using System.Net.Http;
using System.Threading;

namespace AutoscalingDemo
{
    public class Program
    {
        private static readonly HttpClient Client = new();
        private static readonly ConcurrentBag<int> MillisecondsElapsed = new();

        public static async void SendRequest()
        {
            var stopwatch = new Stopwatch();
            stopwatch.Start();

            // replace XXX with your URL
            var stringTask = Client.GetStringAsync("http://40.118.160.51:8000/weatherforecast");
            var message = await stringTask;

            stopwatch.Stop();
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine($"Milliseconds elapsed: {stopwatch.Elapsed.Milliseconds} to calculate result: {message}");

            Console.ForegroundColor = ConsoleColor.Green;
            MillisecondsElapsed.Add(stopwatch.Elapsed.Milliseconds);
            Console.WriteLine($"Average request time: {MillisecondsElapsed.Sum() / MillisecondsElapsed.Count} milliseconds over {MillisecondsElapsed.Count} requests");
            Console.ResetColor();
        }

        public static void Main()
        {
            for (var i = 0; i < 25; i++)
            {
                var thread = new Thread(SendRequest);
                thread.Start();

                Thread.Sleep(100);
            }

            Console.ReadKey();
        }
    }
}