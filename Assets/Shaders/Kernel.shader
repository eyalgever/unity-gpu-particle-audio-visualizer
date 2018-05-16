Shader "Custom/Kernel" {
	Properties {
		_MainTex ("-", 2D) = "" {}
		_Freq ("-", Vector) = (1,1,1,1)
		_Range("-", Float) = 10
		_NoiseParams("-", Vector) = (0.2, 0.1, 1, 0) // (frequency, amplitude)		
		_TimeSpan("-", Float) = 0
		_TimeTotal("-", Float) = 0
	}

	CGINCLUDE

	
	// #pragma multi_compile NOISE_OFF NOISE_ON

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
		float4 p = tex2D(_MainTex, i.uv); // xyz position, w velocity positive for upward

		float noiseCurrentX = cnoise( float3( p.x * 2 * _NoiseParams.x  , p.z * 2.5 * _NoiseParams.x  , _TimeTotal * _NoiseParams.z) ) ;
		float noiseCurrentY = cnoise( float3( p.x * _NoiseParams.x  , p.z * 1.25 * _NoiseParams.x  , _TimeTotal * _NoiseParams.z) ) ;
		float noiseCurrentZ = cnoise( float3( p.x * 0.5 * _NoiseParams.x  , p.z * 0.625 * _NoiseParams.x  , _TimeTotal * _NoiseParams.z) ) ;

		p.y += abs( noiseCurrentX ) * _Freq.x  * _NoiseParams.y;
		p.y += abs( noiseCurrentY ) * _Freq.y  * _NoiseParams.y;
		p.y += abs( noiseCurrentZ ) * _Freq.z  * _NoiseParams.y;

		// p.w += abs( noiseCurrentX ) * _Freq.x * _TimeSpan  * _NoiseParams.y ;
		// p.w += abs( noiseCurrentY ) * _Freq.y * _TimeSpan  * _NoiseParams.y ;
		// p.w += abs( noiseCurrentZ ) * _Freq.z * _TimeSpan  * _NoiseParams.y ;
		

		float gravity = 9.8;		
		p.y += p.w * _TimeSpan - 0.5 * gravity * pow(_TimeSpan,2); 
		p.w -= gravity * _TimeSpan;

		if(p.y < 0){
			p.y = 0;
			p.w = 0;
		}
		return p;
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
