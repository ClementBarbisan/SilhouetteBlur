using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;

public class SilhouetteDeformation : MonoBehaviour {
    public Vector2Int canny;
    private Texture2D grayTex;
    private Texture2D texture;
    private RenderTexture renderTexture1;
    private RenderTexture renderTexture2;
    private Renderer renderer;
    private Vector2Int resolution;
    public Material blurHorizontal;
    public Material blurVertical;
    public int blurIntensity = 5;
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
        returnedResultGray = new byte[resolution.x * resolution.y * 3];
        returnedResultVideo = new byte[resolution.x * resolution.y * 3];
        renderTexture1 = new RenderTexture(resolution.x, resolution.y, 0, RenderTextureFormat.ARGB32);
        renderTexture1.Create();
        renderTexture2 = new RenderTexture(resolution.x, resolution.y, 0, RenderTextureFormat.ARGB32);
        renderTexture2.Create();
        renderer = GetComponent<Renderer>();
        //renderer.material.mainTexture = renderTexture2;
        renderer.material.SetTexture("_GrayTex", renderTexture2);
        renderer.material.SetTexture("_VideoTex", texture);
        blurHorizontal.SetInt("_Size", blurIntensity);
        blurVertical.SetInt("_Size", blurIntensity);
        blurHorizontal.SetInt("_Resolution", resolution.x);
        blurVertical.SetInt("_Resolution", resolution.y);
        blurHorizontal.mainTexture = grayTex;
        blurVertical.mainTexture = renderTexture1;
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
        renderer.material.SetFloat("time", Time.time);
    }
    void OnDestroy()
    {
        OpenCVInterop.CloseSilhouette();
    }
}
