using System;
using System.Runtime.InteropServices;
using UnityEngine;

static class OpenCVInterop
{
    [StructLayout(LayoutKind.Sequential, Size = 12)]
    public struct CvCircle
    {
        public float X, Y, Radius;
    }

    [DllImport("OpenCVForUnity")]
    public static extern int InitCircles(ref int outCameraWidth, ref int outCameraHeight);

    [DllImport("OpenCVForUnity")]
    public static extern int CloseCircles();

    [DllImport("OpenCVForUnity")]
    public static extern int SetScale(int downscale);

    [DllImport("OpenCVForUnity")]
    public unsafe static extern void DetectCircles(CvCircle * balls, int maxOutballsCount, ref int outDetectedBallsCount, int lowH, int lowS, int lowV, int highH, int highS, int highV, int sensitivityValue, int frameFilter);

    [DllImport("OpenCVForUnity")]
    public static extern int InitSilhouette(ref int outCameraWidth, ref int outCameraHeight);

    [DllImport("OpenCVForUnity")]
    public static extern void UpdateFrame();

    [DllImport("OpenCVForUnity", CallingConvention = CallingConvention.StdCall)]
    public static extern IntPtr GetCurrentFrame();

    [DllImport("OpenCVForUnity", CallingConvention = CallingConvention.StdCall)]
    public static extern IntPtr DetectSilhouette(int lowCanny, int highCanny);

    [DllImport("OpenCVForUnity", CallingConvention = CallingConvention.StdCall)]
    public static extern IntPtr DetectFlow();

    [DllImport("OpenCVForUnity")]
    public static extern void CloseFlow();

    [DllImport("OpenCVForUnity")]
    public static extern void CloseSilhouette();

    [DllImport("OpenCVForUnity")]
    public static extern int InitFlow(ref int width, ref int height);
}
