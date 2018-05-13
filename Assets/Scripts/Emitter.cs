using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Emitter : MonoBehaviour {

	#region Editor Properties
	public int size;
	public int range;
	[ColorUsageAttribute(true,true,0f,8f,0.125f,3f)] 
	public Color color;
	const int spectrumSize = 512;
	const int freqBandSize = 8;
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

		

		Mesh _m = new Mesh();
		_m.vertices = Vertices;
		_m.uv = UVs;
		_m.subMeshCount = BufferHeight;

		int[] Indexes = new int[BufferWidth];

		int cnt = 0;
		for(var i = 0; i< BufferHeight; i++){
			for(var k = 0; k< BufferWidth; k++){
				Indexes[k] = cnt;
				cnt++;
			}
			_m.SetIndices(Indexes, MeshTopology.LineStrip,i);
		}

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
		spectrumBuffer = new Texture2D( freqBandSize, 1) ;

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

		for(int i = 0; i <spectrumSize; i++){
			float val = spectrum[i];			
			spectrumBuffer.SetPixel(i, 0, new Color(val,val,val,1.0f));			
		}		
		spectrumBuffer.Apply();


		float[] _freqBand = new float [freqBandSize];
		int count = 0;
		for( int i = 0; i< _freqBand.Length; i++){
			
			int sampleCount = (int)Mathf.Pow(2,i)*2;
			if(i==7) sampleCount += 2;

			for( int k = 0; k< sampleCount; k++){
				_freqBand[i] += spectrum[count] * (count + 1);
				count++;
			}
			_freqBand[i] = _freqBand[i] / count; 
		}			


		var m = _kernelMaterial;
		m.SetFloat("_Range", range);
		m.SetVector("_NoiseParams", new Vector4(0,0,0,0));
		m.SetFloat("_TimeSpan",Time.deltaTime);
		m.SetFloat("_TimeTotal", Time.time*0.5f);
		m.SetTexture("_Spectrum", spectrumBuffer);
		m.SetVector("_Freq", new Vector4(
			(_freqBand[0] + _freqBand[1]+ _freqBand[2])/3,
			(_freqBand[3] + _freqBand[4]+ _freqBand[5])/3,
			(_freqBand[6] + _freqBand[7])/2,
			0
		));
		

		var temp = _particleBuffer;
		_particleBuffer = _particleBuffer2;
		_particleBuffer2 = temp;

		Graphics.Blit(_particleBuffer , _particleBuffer2, _kernelMaterial, 1);	

		// set particle material parameters and render
		_particleMaterial.SetTexture("_ParticleTex", _particleBuffer);
		_particleMaterial.SetColor("_Color", color);
		_particleMaterial.SetFloat ("_Size", pointSize);
		_particleMaterial.SetFloat ("_Depth", depthDebug);

		for (int i = 0; i < BufferHeight; i++) {
			Graphics.DrawMesh(_mesh, transform.position, transform.rotation, _particleMaterial, 0, null, i);	
		}

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
