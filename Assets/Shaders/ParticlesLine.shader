// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/ParticlesLine" {
	Properties
	{
		_ParticleTex ("-", 2D) = "" {}
		[HDR] _Color("-", Color) = (1, 1, 1, 1)
		_Size ("-", Float) = 0.5
		_Depth ("-", Float) = 0.5
	}


	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 200

		Pass
		{	
			ZWrite On
			CGPROGRAM
			#pragma target 4.0
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 position : POSITION;
				float2 texcoord : TEXCOORD0; // this is the uv value of that vertex 
			};

			struct v2f
			{
				float4 position : SV_POSITION;
				half4 color: COLOR;
				float2 depth : TEXCOORD1;
			};

			struct fs_output
			{
				half4 color : SV_Target;
				float depth : SV_Depth;
			};


			sampler2D _ParticleTex;
			float4 _ParticleTex_TexelSize;
			half4 _Color;
			float _Size;
			float _Depth;


			// vertex shader
			v2f vert (appdata v)
			{
				v2f o;

				float2 uv = v.texcoord.xy + _ParticleTex_TexelSize/2;

				float4 p1 = tex2Dlod( _ParticleTex, float4(uv,0,0));

				o.position = UnityObjectToClipPos(float4(p1.xyz, 1));

				o.color = _Color;

				o.depth = o.position.zw;
				
				return o;
			}

			// fragment shader
			fs_output frag (v2f i)
			{	
				fs_output fo;
				fo.color = i.color;
				fo.depth = i.depth.x/i.depth.y * _Depth;
				return fo;
			}
			ENDCG
		}


		Pass
		{	
			Tags { "LightMode"="ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma target 4.0
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 position : POSITION;
				float2 texcoord : TEXCOORD0; // this is the uv value of that vertex 
			};

			struct v2f
			{
				float4 position : SV_POSITION;
				half4 color: COLOR;
				float2 depth : TEXCOORD1;
			};

			struct fs_output
			{
				half4 color : SV_Target;
				float depth : SV_Depth;
			};


			sampler2D _ParticleTex;
			float4 _ParticleTex_TexelSize;
			half4 _Color;
			float _Size;
			float _Depth;


			// vertex shader
			v2f vert (appdata v)
			{
				v2f o;

				float2 uv = v.texcoord.xy + _ParticleTex_TexelSize/2;

				float4 p1 = tex2Dlod( _ParticleTex, float4(uv,0,0));

				o.position = UnityObjectToClipPos(float4(p1.xyz, 1));

				o.color = _Color;

				o.depth = o.position.zw;
				
				return o;
			}

			// fragment shader
			fs_output frag (v2f i)
			{	
				fs_output fo;
				fo.color = i.color;
				fo.depth = i.depth.x/i.depth.y * _Depth;
				return fo;
			}
			ENDCG
		}



	}
}
