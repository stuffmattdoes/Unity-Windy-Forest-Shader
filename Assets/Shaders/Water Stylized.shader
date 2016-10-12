Shader "Custom/Water Stylized" {
	Properties {
		_MainTex ("Main Texture", 2D) = "grey" {}
		_DetailTex ("Detail Texture", 2D) = "grey" {}
		_Color ("Color Tint", color) = (1, 1, 1, 1)
		_WaveDisplacement0 ("Wave Displacement Texture", 2D) = "white" {}
		_Magnitude0 ("Magnitude", Range(0, 1)) = 1
//		_LightTexture ("Light Reflection", 2D) = "white" {}
//		_LightMagnitude ("Light Intensity", Range(0, 1)) = 1
//		_Direction ("Wave Direction", vector) = (0, 0, 0, 0)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
		

			// --------------
			// Shader structs
			// --------------

			// Vert struct
			struct appdata {
				float4 vertex : POSITION;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 uv2 : TEXCOORD2;
			};

			// Frag struct
			struct v2f {
				float4 vertex : SV_POSITION;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 uv2 : TEXCOORD2;
			};


			// ----------------
			// Shader functions
			// ----------------

			// Properties
			sampler2D _MainTex;
			float4 _Color;
			sampler2D _WaveDisplacement0;
			float _Magnitude0;
//			sampler2D _LightTexture;
//			float _LightMagnitude;
//			vector _Direction;

			float4 _MainTex_ST;		// "_ST" suffix means "scale transfer," which is originally what the texture material properties were labeled
			float4 _WaveDisplacement0_ST;
//			float4 _LightTexture_ST;

			// Vertex function
			v2f vert (appdata v) {
				v2f o;
				o.vertex = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv0 = TRANSFORM_TEX(v.uv0, _MainTex);				// This function gives us access to the material inspector's tile/offset values
				o.uv1 = TRANSFORM_TEX(v.uv1, _WaveDisplacement0);
//				o.uv2 = TRANSFORM_TEX(v.uv2, _LightTexture);
				return o;
			}

			// Fragment function
			float4 frag (v2f i) : SV_Target {

				float2 distuv = float2(
					i.uv1.x,
					i.uv1.y - _Time.x
				);

				float2 disp0 = tex2D(_WaveDisplacement0, distuv).xy;
				disp0 = ((disp0 * 2) - 1) * (_Magnitude0 / 10);
				float4 mainTexture = tex2D(_MainTex, i.uv0 + disp0);
//				float4 lightTexture = tex2D(_LightTexture, i.uv2);
				float4 col = mainTexture * _Color;
//				col += (lightTexture * _LightMagnitude);
				return col;
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
