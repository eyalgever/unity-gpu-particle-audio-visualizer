using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Emitter : MonoBehaviour {

	#region Editor Properties
	public int size;
	public int range;
	[ColorUsageAttribute(true,true,0f,8f,0.125f,3f)] 
	public Color color;
	public int spectrumSize = 256;
	public float pointSize = 0.5f;

	public float depthDebug = 0.5f;


	
	[SerializeField] Shader _kernelShader;
	[SerializeField] Shader _particleShader;
	[SerializeField] Shader _debugShader;
	[SerializeField] Shader _debugSpectrumShader;

	#endregion



	#region Basic Variables
	Mesh _mesh;
	Material _kernelMaterial;
	Material _particleMaterial;
	Material _debugMaterial;
	Material _debugSpectrumMaterial;
	RenderTexture _particleBuffer;
	RenderTexture _particleBuffer2;
	Texture2D spectrumBuffer;

	#endregion


	#region Properties

	int BufferWidth {get{return size;}}
	int BufferHeight {get{return size;}}
	static float deltaTime{
		get{ 
			return  Application.isPlaying && Time.frameCount > 1 ? Time.deltaTime: 1.0f/ 10; 
		}
	} 

	#endregion



	#region Utilities Functions
	Mesh CreateMesh(){				
		// Vertices, UV, Indexes
		Vector3[] Vertices = new Vector3[ BufferHeight * BufferWidth ];
		Vector2[] UVs = new Vector2[ BufferHeight * BufferWidth];

		int ii = 0;
		for(int x = 0; x< BufferWidth; x++){
			for(int y = 0; y< BufferHeight; y++){
				
				Vertices[ii] = Vector3.zero;
				
				float u = (float)x / (float)BufferWidth;
				float v = (float)y / (float)BufferHeight;

				UVs[ii] = new Vector2(u,v);

				ii++;
			}
		}

		int[] Indexes = new int[UVs.Length];
		for(var i = 0; i< UVs.Length; i++) Indexes[i] = i;

		Mesh _m = new Mesh();
		_m.vertices = Vertices;
		_m.uv = UVs;
		_m.SetIndices(Indexes, MeshTopology.Points, 0);
//		_m.SetIndices(Indexes, MeshTopology.LineStrip, 0);
		_m.bounds = new Bounds(Vector3.zero, Vector3.one * 1000);
		return _m;
	}

	Material CreateMaterial(Shader shader){
		Material mat = new Material(shader);
		mat.hideFlags = HideFlags.DontSave;
		return mat;
	}

	RenderTexture CreateBuffer(){
		var buffer = new RenderTexture(BufferWidth, BufferHeight, 0, RenderTextureFormat.ARGBFloat);
		buffer.hideFlags = HideFlags.DontSave;
		buffer.filterMode = FilterMode.Point;
		buffer.wrapMode = TextureWrapMode.Repeat;
		return buffer; 
	}

	#endregion

	#region MonoBehavior Functions

	void Start(){
		if(_mesh == null) _mesh = CreateMesh();

		if(_particleBuffer) DestroyImmediate(_particleBuffer);

		_particleBuffer = CreateBuffer();
		_particleBuffer2 = CreateBuffer();
		spectrumBuffer = new Texture2D( spectrumSize, 1) ;

		if(!_kernelMaterial) _kernelMaterial = CreateMaterial(_kernelShader);
		if(!_particleMaterial) _particleMaterial = CreateMaterial(_particleShader);
		if(!_debugMaterial) _debugMaterial = CreateMaterial(_debugShader);
		if(!_debugSpectrumMaterial) _debugSpectrumMaterial = CreateMaterial(_debugSpectrumShader);

		var m = _kernelMaterial;
		m.SetFloat("_Range", range);
		m.SetVector("_NoiseParams", new Vector4(0,0,0,0));

		Graphics.Blit(null, _particleBuffer, _kernelMaterial, 0);	
	}
	
	void Update () {
		
		float[] spectrum = new float[spectrumSize]; 
		AudioListener.GetSpectrumData(spectrum, 0, FFTWindow.Triangle);
		for(int i = 0; i < spectrumSize; i++){
			float val = spectrum[i] * 50f;			
			spectrumBuffer.SetPixel(i, 0, new Color(val,val,val,1.0f));			
		}		
		spectrumBuffer.Apply();

		for (int i = 1; i < spectrum.Length - 1; i++)
        {
            Debug.DrawLine(new Vector3(i - 1, spectrum[i] + 10, 0), new Vector3(i, spectrum[i + 1] + 10, 0), Color.red);
            Debug.DrawLine(new Vector3(i - 1, Mathf.Log(spectrum[i - 1]) + 10, 2), new Vector3(i, Mathf.Log(spectrum[i]) + 10, 2), Color.cyan);
            Debug.DrawLine(new Vector3(Mathf.Log(i - 1), spectrum[i - 1] - 10, 1), new Vector3(Mathf.Log(i), spectrum[i] - 10, 1), Color.green);
            Debug.DrawLine(new Vector3(Mathf.Log(i - 1), Mathf.Log(spectrum[i - 1]), 3), new Vector3(Mathf.Log(i), Mathf.Log(spectrum[i]), 3), Color.blue);
        }


		var m = _kernelMaterial;
		m.SetFloat("_Range", range);
		m.SetVector("_NoiseParams", new Vector4(0,0,0,0));
		m.SetFloat("_TimeSpan",Time.deltaTime);
		m.SetTexture("_Spectrum", spectrumBuffer);

		var temp = _particleBuffer;
		_particleBuffer = _particleBuffer2;
		_particleBuffer2 = temp;

		Graphics.Blit(_particleBuffer , _particleBuffer2, _kernelMaterial, 1);	

		// set particle material parameters and render
		_particleMaterial.SetTexture("_ParticleTex", _particleBuffer);
		_particleMaterial.SetColor("_Color", color);
		_particleMaterial.SetFloat ("_Size", pointSize);
		_particleMaterial.SetFloat ("_Depth", depthDebug);
		Graphics.DrawMesh(_mesh, transform.position, transform.rotation, _particleMaterial, 0);

	}

	void OnDestroy()
	{
		if(_mesh) DestroyImmediate(_mesh);

		if(_particleBuffer) DestroyImmediate(_particleBuffer);
		if(_particleBuffer2) DestroyImmediate(_particleBuffer2);

		if(_kernelMaterial) DestroyImmediate(_kernelMaterial);
		if(_particleMaterial) DestroyImmediate(_particleMaterial);		
	}

	void OnGUI(){
		var rect = new Rect(0, 0, 64, 64);
        Graphics.DrawTexture(rect, _particleBuffer, _debugMaterial) ;

		rect = new Rect(64,0,64,64);
		Graphics.DrawTexture(rect, spectrumBuffer, _debugSpectrumMaterial);
	}

	#endregion
}



/* 
	#gpgpu computation

	Input: noise paramaters 
	Output: height, velocity

	#render:
	Input: position x/y/z

*/
