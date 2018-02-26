using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;

public class MeshSilhouette : MonoBehaviour {
    private struct Particle
    {
        public Vector3 position;
        public Vector3 velocity;
    }
    private const int SIZE_PARTICLE = 24;
    public Material material;
    public ComputeShader computeShader;
    public Material blurHorizontal;
    public Material blurVertical;
    public Vector2Int canny;
    public int blurIntensity = 5;
    private Texture2D texture;
    private Texture2D grayTex;
    private RenderTexture renderTexture1;
    private RenderTexture renderTexture2;
    private int mComputeShaderKernelID;
    ComputeBuffer particleBuffer;
    //private RenderTexture outputTexture;
    private Vector2Int resolution;
    private byte[] returnedResultGray;
    private byte[] returnedResultVideo;
    private void OnValidate()
    {
        canny = new Vector2Int(Mathf.Clamp(canny.x, 0, 255), Mathf.Clamp(canny.y, 75, 255));
        blurIntensity = Mathf.Clamp(blurIntensity, 0, 50);
        blurHorizontal.SetInt("_Size", blurIntensity);
        blurVertical.SetInt("_Size", blurIntensity);
    }
    // Use this for initialization
    void Awake () {
        int width = 0;
        int height = 0;
        int result = OpenCVInterop.InitSilhouette(ref width, ref height);
        if (result < 0)
        {
            if (result == -2)
            {
                Debug.LogWarningFormat("[{0}] Failed to open camera stream.", GetType());
            }

            return;
        }
        resolution = new Vector2Int(width, height);
        texture = new Texture2D(resolution.x, resolution.y, TextureFormat.RGB24, false);
        grayTex = new Texture2D(resolution.x, resolution.y, TextureFormat.RGB24, false);
        //outputTexture = new RenderTexture(resolution.x, resolution.y, 0);
        //outputTexture.enableRandomWrite = true;
        //outputTexture.Create();
        returnedResultGray = new byte[resolution.x * resolution.y * 3];
        returnedResultVideo = new byte[resolution.x * resolution.y * 3];
        renderTexture1 = new RenderTexture(resolution.x, resolution.y, 0, RenderTextureFormat.ARGB32);
        renderTexture1.Create();
        renderTexture2 = new RenderTexture(resolution.x, resolution.y, 0, RenderTextureFormat.ARGB32);
        renderTexture2.Create();
        // Initialize the Particle at the start
        Particle[] particleArray = new Particle[(width / 10) * (height / 10)];

        for (int i = 0; i < height; i += 10)
        {
            for (int j = 0; j < width; j += 10)
            {
                particleArray[(i / 10) * (width / 10) + (j / 10)].position.x = (-width / 2 + j) * 0.1f;
                particleArray[(i / 10) * (width / 10) + (j / 10)].position.y = (-height / 2 + i) * 0.1f;
                particleArray[(i / 10) * (width / 10) + (j / 10)].position.z = 0;

                particleArray[(i / 10) * (width / 10) + (j / 10)].velocity.x = 0;
                particleArray[(i / 10) * (width / 10) + (j / 10)].velocity.y = 0;
                particleArray[(i / 10) * (width / 10) + (j / 10)].velocity.z = 0;
            }
        }
        // Create the ComputeBuffer holding the Particles
        particleBuffer = new ComputeBuffer((width / 10) * (height / 10), SIZE_PARTICLE);
        particleBuffer.SetData(particleArray);

        // Find the id of the kernel
        mComputeShaderKernelID = computeShader.FindKernel("CSMain");

        // Bind the ComputeBuffer to the shader and the compute shader
        computeShader.SetBuffer(mComputeShaderKernelID, "particleBuffer", particleBuffer);
        computeShader.SetTexture(mComputeShaderKernelID, "grayTexture", renderTexture2);
        computeShader.SetTexture(mComputeShaderKernelID, "videoTexture", texture);
        //computeShader.SetTexture(mComputeShaderKernelID, "outputTexture", outputTexture);
       
        material.SetBuffer("particleBuffer", particleBuffer);
        material.SetInt("_Width", width / 10);
        material.SetInt("_Height", height / 10);
        computeShader.SetInt("width", resolution.x);
        computeShader.SetInt("height", resolution.y);
        blurHorizontal.SetInt("_Size", blurIntensity);
        blurVertical.SetInt("_Size", blurIntensity);
    }

    // Update is called once per frame
    void Update () {

        OpenCVInterop.UpdateFrame();
        IntPtr returnedPtrGray = OpenCVInterop.DetectSilhouette(canny.x, canny.y);
        if (returnedPtrGray != IntPtr.Zero)
        {
            Marshal.Copy(returnedPtrGray, returnedResultGray, 0, resolution.x * resolution.y * 3);
            grayTex.LoadRawTextureData(returnedResultGray);
            grayTex.Apply();
            Graphics.Blit(grayTex, renderTexture1, blurHorizontal);
            Graphics.Blit(renderTexture1, renderTexture2, blurVertical);
        }
        IntPtr returnedPtrVideo = OpenCVInterop.GetCurrentFrame();
        if (returnedPtrVideo != IntPtr.Zero)
        {
            Marshal.Copy(returnedPtrVideo, returnedResultVideo, 0, resolution.x * resolution.y * 3);
            texture.LoadRawTextureData(returnedResultVideo);
            texture.Apply();
        }
        computeShader.SetFloat("deltaTime", Time.deltaTime);
       
        computeShader.Dispatch(mComputeShaderKernelID, resolution.x / 10, resolution.y / 10, 1);
    }

    void OnRenderObject()
    {
        material.SetPass(0);
        Graphics.DrawProcedural(MeshTopology.Points, 1, resolution.x * resolution.y);
    }

    void OnDestroy()
    {
        OpenCVInterop.CloseSilhouette();
        if (particleBuffer != null)
            particleBuffer.Release();
    }
}
