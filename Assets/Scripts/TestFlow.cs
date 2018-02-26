using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;

public class TestFlow : MonoBehaviour {
    private Texture2D texture;
    private Renderer renderer;
    private Vector2Int resolution;
   
    // Use this for initialization
    void Awake () {
        int width = 0;
        int height = 0;
        int result = OpenCVInterop.InitFlow(ref width, ref height);
        if (result < 0)
        {
            if (result == -2)
            {
                Debug.LogWarningFormat("[{0}] Failed to open camera stream.", GetType());
            }

            return;
        }
        resolution = new Vector2Int(width, height);
        texture = new Texture2D(resolution.x / 5, resolution.y / 5, TextureFormat.RGBA32, false);
        renderer = GetComponent<Renderer>();
        renderer.material.SetTexture("_DeformationTex", texture);
        //renderer.material.mainTexture = texture;
    }

    // Update is called once per frame
    void Update () {
        IntPtr returnedPtr = OpenCVInterop.DetectFlow();
        byte[] returnedResult = new byte[(resolution.x / 5) * (resolution.y / 5) * 4];
        Marshal.Copy(returnedPtr, returnedResult, 0, (resolution.x / 5) * (resolution.y / 5) * 4);
        texture.LoadRawTextureData(returnedResult);
        texture.Apply();

    }

    private void OnApplicationQuit()
    {
        OpenCVInterop.CloseFlow();    
    }
}
