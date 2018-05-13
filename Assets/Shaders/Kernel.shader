Shader "Custom/Kernel" {
	Properties {
		_MainTex ("-", 2D) = "" {}
		_Spectrum("-", 2D) = ""{}
		_Freq ("-", Vector) = (1,1,1, 1)
		_Range("-", Float) = 10
		_NoiseParams("-", Vector) = (0.2, 0.1, 1, 0) // (frequency, amplitude)		
		_TimeSpan("-", Float) = 0
		_TimeTotal("-", Float) = 0
	}

	CGINCLUDE

	
	#pragma multi_compile NOISE_OFF NOISE_ON

	#include "UnityCG.cginc"
	#include "ClassicNoise3D.cginc"

	sampler2D _MainTex;
	sampler2D _Spectrum;
	float4 _NoiseParams;
	float _Range;
	float _TimeSpan;
	float4 _Freq;
	float _TimeTotal;

	float4 new_particle(float2 uv){
		return float4( uv.x * _Range - _Range/2 , 0  , uv.y *_Range - _Range/2 , 0);
	}


	float4 frag_init(v2f_img i) : SV_Target
	{
		return new_particle(i.uv);
	}


	float4 frag_update(v2f_img i) : SV_Target
	{	

		float x = i.uv.x * _Range - _Range/2;
		float z =  i.uv.y *_Range - _Range/2;

		float4 p = tex2D(_MainTex, i.uv);
		float3 pos = p.xyz;
		float velocity = p.w;

		// float newforce = tex2D(_Spectrum, float2( sqrt( pow(i.uv.x -0.5, 2) + pow(i.uv.y - 0.5, 2) ), 0 ) ).x;

		// if(newforce > 0){
		// 	pos.y = pos.y + newforce * 0.5;
		// }

		// float noiseCurrentX = cnoise( float3( x * _NoiseParams.x , z * _NoiseParams.x , _TimeTotal * _NoiseParams.z)) +1 ;
		// pos.y += noiseCurrentX  * _Freq.x * _NoiseParams.y;	

		// float noiseCurrentY = cnoise( float3( x * _NoiseParams.x ,  z * _NoiseParams.x , _TimeTotal * _NoiseParams.z)) +1;
		// pos.y += noiseCurrentY  *  _Freq.y * _NoiseParams.y;	

		float noiseCurrentZ = cnoise( float3( x * _NoiseParams.x  , z * 1.25 * _NoiseParams.x  , _TimeTotal * _NoiseParams.z) ) ;
		pos.y += abs( noiseCurrentZ ) * _Freq.x  * _NoiseParams.y;	
		

		float gravity = 9.8;		
		pos.y = pos.y - velocity * _TimeSpan - 0.5 * gravity * pow(_TimeSpan,2); 
		velocity = velocity + gravity * _TimeSpan;

		if(pos.y < 0){
			pos.y = 0;
			velocity = 0;
		}

		// return float4( i.uv.x * _Range - _Range/2 , pos.y  , i.uv.y *_Range - _Range/2 , velocity);
		return float4( x , pos.y , z , velocity);
		


	}

	ENDCG

	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert_img
			#pragma fragment frag_init
			ENDCG
		}

		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert_img
			#pragma fragment frag_update
			ENDCG 
		}
	}
}
