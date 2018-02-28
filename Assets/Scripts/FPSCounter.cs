
using UnityEngine;
using System.Collections;

public class FPSCounter : MonoBehaviour 
{
	private float _oldTime;
	private float _time;
	private float _fps;
    public GUIStyle style;

	void Start () 
	{
		_fps = 0.0f;
	}
	
	void Update () 
	{
        _time = Time.time;
        _fps = 1.0f / (_time - _oldTime);
        _oldTime = _time;
	}

	void OnGUI()
	{
		GUI.Label( new Rect( 10.0f, 10.0f, 100.0f, 20.0f), "FPS: " + _fps, style);
	}
}
