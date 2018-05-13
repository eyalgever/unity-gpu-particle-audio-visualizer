Shader "Custom/Kernel" {
	Properties {
		_MainTex ("-", 2D) = "" {}
		_Spectrum("-", 2D) = ""{}
		_Freq ("-", Vector) = (1,1,1, 1)
		_Range("-", Float) = 10
		_NoiseParams("-", Vector) = (0.2, 0.1, 1, 0) // (frequency, amplitude, animation)		
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
		float4 p = tex2D(_MainTex, i.uv);
		float3 pos = p.xyz;
		float velocity = p.w;

		// float newforce = tex2D(_Spectrum, float2( sqrt( pow(i.uv.x -0.5, 2) + pow(i.uv.y - 0.5, 2) ), 0 ) ).x;

		// if(newforce > 0){
		// 	pos.y = pos.y + newforce * 0.5;
		// }

		float noiseCurrentX = abs(cnoise( float3(pos.x*2, pos.z*2, _TimeTotal)) );
		pos.y += noiseCurrentX * 0.4 * _Freq.x;	

		float noiseCurrentY = abs(cnoise( float3(pos.x, pos.z, _TimeTotal)) );
		pos.y += noiseCurrentY * 0.15 *  _Freq.y;	

		float noiseCurrentZ = abs(cnoise( float3(pos.x*0.5, pos.z*0.5, _TimeTotal)) );
		pos.y += noiseCurrentZ * 0.15 * _Freq.z;	
		

		float gravity = 9.8;		
		pos.y = pos.y - velocity * _TimeSpan - 0.5 * gravity * pow(_TimeSpan,2); 
		velocity = velocity + gravity * _TimeSpan;

		if(pos.y < 0){
			pos.y = 0;
			velocity = 0;
		}

		return float4( i.uv.x * _Range - _Range/2 , pos.y  , i.uv.y *_Range - _Range/2 , velocity);

		


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
