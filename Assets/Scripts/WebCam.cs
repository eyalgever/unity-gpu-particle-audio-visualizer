using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WebCam : MonoBehaviour {
	public Texture2D tex;
	public Shader shad;
	public bool renderWebCamtex;

	void OnGUI(){
		if (renderWebCamtex) {
			Rect rect = new Rect (0, 0, Screen.width, Screen.height);
			Graphics.DrawTexture (rect, tex, new Material(shad));	
		}
	}
}
