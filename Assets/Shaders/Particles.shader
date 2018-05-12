// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Particles" {
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
			#pragma geometry geom
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 position : POSITION;
				float2 texcoord : TEXCOORD0; // this is the uv value of that vertex 
			};

			struct v2f
			{
				float4 position : POSITION;
				half4 color: COLOR;
			};

			struct fs_input
			{
				float4 position : SV_POSITION;
				half4 color : COLOR;
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

				o.position = float4(p1.xyz, 1);

//				o.position = UnityObjectToClipPos(float4(p1.xyz, 1));

				o.color = _Color;
				
				return o;
			}

			[maxvertexcount(4)]
			void geom (point v2f p[1], inout TriangleStream<fs_input> triStream)
			{
				float3 up = float3( 0, 1, 0);
				float3 look = _WorldSpaceCameraPos - p[0].position;
				look.y = 0;
				look = normalize(look);
				float3 right = cross(up, look);

				float halfS = _Size;

				float4 v[4];
				v[0] = float4(p[0].position + halfS * right - halfS * up, 1.0f);
				v[1] = float4(p[0].position + halfS * right + halfS * up, 1.0f);
				v[2] = float4(p[0].position - halfS * right - halfS * up, 1.0f);
				v[3] = float4(p[0].position - halfS * right + halfS * up, 1.0f);


				fs_input pIn;
				pIn.position = UnityObjectToClipPos(v[0]);
				pIn.color = p[0].color;
				pIn.depth = pIn.position.zw;
				triStream.Append(pIn);

				pIn.position = UnityObjectToClipPos(v[1]);
				pIn.color = p[0].color;
				pIn.depth = pIn.position.zw;
				triStream.Append(pIn);

				pIn.position = UnityObjectToClipPos(v[2]);
				pIn.color = p[0].color;
				pIn.depth = pIn.position.zw;
				triStream.Append(pIn);

				pIn.position = UnityObjectToClipPos(v[3]);
				pIn.color = p[0].color;
				pIn.depth = pIn.position.zw;
				triStream.Append(pIn);

			}

			// fragment shader
			fs_output frag (fs_input i)
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
			#pragma geometry geom
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 position : POSITION;
				float2 texcoord : TEXCOORD0; // this is the uv value of that vertex 
			};

			struct v2f
			{
				float4 position : POSITION;
				half4 color: COLOR;
			};

			struct fs_input
			{
				float4 position : SV_POSITION;
				half4 color : COLOR;
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

				o.position = float4(p1.xyz, 1);

//				o.position = UnityObjectToClipPos(float4(p1.xyz, 1));

				o.color = _Color;
				
				return o;
			}

			[maxvertexcount(4)]
			void geom (point v2f p[1], inout TriangleStream<fs_input> triStream)
			{
				float3 up = float3( 0, 1, 0);
				float3 look = _WorldSpaceCameraPos - p[0].position;
				look.y = 0;
				look = normalize(look);
				float3 right = cross(up, look);

				float halfS = _Size;

				float4 v[4];
				v[0] = float4(p[0].position + halfS * right - halfS * up, 1.0f);
				v[1] = float4(p[0].position + halfS * right + halfS * up, 1.0f);
				v[2] = float4(p[0].position - halfS * right - halfS * up, 1.0f);
				v[3] = float4(p[0].position - halfS * right + halfS * up, 1.0f);


				fs_input pIn;
				pIn.position = UnityObjectToClipPos(v[0]);
				pIn.color = p[0].color;
				pIn.depth = pIn.position.zw;
				triStream.Append(pIn);

				pIn.position = UnityObjectToClipPos(v[1]);
				pIn.color = p[0].color;
				pIn.depth = pIn.position.zw;
				triStream.Append(pIn);

				pIn.position = UnityObjectToClipPos(v[2]);
				pIn.color = p[0].color;
				pIn.depth = pIn.position.zw;
				triStream.Append(pIn);

				pIn.position = UnityObjectToClipPos(v[3]);
				pIn.color = p[0].color;
				pIn.depth = pIn.position.zw;
				triStream.Append(pIn);

			}

			// fragment shader
			fs_output frag (fs_input i)
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
