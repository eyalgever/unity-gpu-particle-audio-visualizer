Shader "Custom/Particles" {
	Properties
	{
		_ParticleTex ("-", 2D) = "" {}
		[HDR] _Color("-", Color) = (1, 1, 1, 1)

	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 200

		Pass
		{
			CGPROGRAM
			#pragma target 3.0
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
				float4 position: SV_POSITION;
				half4 color: COLOR;
			};

			sampler2D _ParticleTex;
			float4 _ParticleTex_TexelSize;
			half4 _Color;
			
			v2f vert (appdata v)
			{
				v2f o;

				float2 uv = v.texcoord.xy + _ParticleTex_TexelSize/2;

				float4 p1 = tex2Dlod( _ParticleTex, float4(uv,0,0));

				o.position = UnityObjectToClipPos(float4(p1.xyz, 1));

				o.color = _Color;
				
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{	
				half4 col = i.color;
				return col;
			}
			ENDCG
		}
	}
}
