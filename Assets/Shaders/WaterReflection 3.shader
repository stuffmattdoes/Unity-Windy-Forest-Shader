Shader "Custom/Water Reflection 3" {

	Properties {
	_MainTex ("Main Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		_DisplaceTex0("Main Wave", 2D) = "white" {}
		_Magnitude0 ("Main Wave Distortion", Range(0,1)) = 0.5
		_DisplaceTex1("Secondary Wave", 2D) = "white" {}
		_Magnitude1 ("Secondary Wave Distortion", Range(0,1)) = 0.5
	}

	SubShader {
		LOD 200

		Tags {
//			"Queue" = "Transparent"
		}

		pass {	

//			Blend srcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			// -------------
			// Input Structs
			// -------------

			// Vertex struct

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 uv2 : TEXCOORD2;
			};


			// Fragment struct

			struct v2f {
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 uv2 : TEXCOORD2;
			};


			// ----------------
			// Shader Functions
			// ----------------


			// Property variables

			float4 _Color;
			sampler2D _DisplaceTex0;
			float _Magnitude0;
			sampler2D _DisplaceTex1;
			float _Magnitude1;

			float4 _DisplaceTex0_ST;
			float4 _DisplaceTex1_ST;

			// Vertex function

			v2f vert (appdata v) {
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv1 = TRANSFORM_TEX(v.uv1, _DisplaceTex0);
				o.uv2 = TRANSFORM_TEX(v.uv2, _DisplaceTex1);
				return o;
			}


			// Fragment function

			float4 frag (v2f i) : SV_Target {

				// Main wave
				float2 distpuv0 = float2(
					i.uv1.x + _Time.x * 0.5,
					i.uv1.y + _Time.y * 0.025
				);
				float disp0 = tex2D(_DisplaceTex0, distpuv0) * _Magnitude0;

				// Secondary wave
				float2 distpuv1 = float2(
					i.uv2.x + _Time.x * -0.5,
					i.uv2.y + _Time.y * 0.01
				);
				float disp1 = tex2D(_DisplaceTex1, distpuv1) * _Magnitude1;

				float4 col = (disp0 + disp1) / 2 * _Color;
				return col;
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
