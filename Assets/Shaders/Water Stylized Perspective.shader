Shader "Custom/Water Stylized Perspective" {
	Properties {
		_MainTex ("Main Texture", 2D) = "grey" {}
		_DetailTex ("Detail Texture", 2D) = "grey" {}
		_DetailMagnitude ("Detail Magnitude", Range(0, 1)) = 0.5
		_Color ("Color Tint", color) = (1, 1, 1, 1)
		_WaveDisplacement0 ("Wave Displacement Texture", 2D) = "white" {}
		_Magnitude0 ("Displacement", Range(0, 1)) = 0.5
	}
	SubShader {
		Tags {
			"RenderType"="Opaque"
		}
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
//			#pragma target 3.0		// Using shader model 3.0 because 

			#include "UnityCG.cginc"
		

			// --------------
			// Shader structs
			// --------------

			// Vert struct
			struct appdata {
				float4 vertex : POSITION;
				float2 uv0 : TEXCOORD0;		// _MainTex
				float2 uv1 : TEXCOORD1;		// _WaveDisplacement0
				float2 uv2 : TEXCOORD2;		// _DetailTex
				float4 screenUV : TEXCOORD3;
			};

			// Frag struct
			struct v2f {
				float4 vertex : SV_POSITION;
				float2 uv0 : TEXCOORD0;		// _MainTex
				float2 uv1 : TEXCOORD1;		// _WaveDisplacement0
				float2 uv2 : TEXCOORD2;		// _DetailTex
				float4 screenUV : TEXCOORD3;
			};


			// ----------------
			// Shader functions
			// ----------------

			// Vertex properties
			sampler2D _MainTex;
			sampler2D _DetailTex;
			float4 _Color;
			sampler2D _WaveDisplacement0;

			float4 _MainTex_ST;				// "_ST" suffix means "scale transfer," which is originally what the texture material properties were labeled
			float4 _DetailTex_ST;
			float4 _WaveDisplacement0_ST;

			// Vertex function
			v2f vert (appdata v) {
				v2f o;

				// Main texture
				// Use the worldspace coords instead of the mesh's UVs.
				o.vertex = mul (UNITY_MATRIX_MVP, v.vertex);
				float2 worldXY = mul(_Object2World, v.vertex).xz;	// Use x,z instead of x,y because our plane is rotated 90deg
                o.uv0 = TRANSFORM_TEX(worldXY, _MainTex);

                // Displacement texture
				o.uv1 = TRANSFORM_TEX(v.uv1, _WaveDisplacement0);

                // Detail Texture (world-space coordinates)
                o.uv2 = TRANSFORM_TEX(worldXY, _DetailTex);

                // Screen-space calculations
//                o.vertex = mul(UNITY_MATRIX_MVP, float4(pos, 1.0));

				return o;
			}

			// Surface struct
			struct Input {
				float2 uv_DetailTex;
				float4 screenPos;
			};

			// Fragment properties
			float _Magnitude0;
			float _DetailMagnitude;

			// Fragment function
			float4 frag (v2f i) : SV_Target {

				// Displacement texture
				float2 distuv = float2 (
					i.uv1.x,
					i.uv1.y + _Time.x
				);

				float2 disp0 = tex2D(_WaveDisplacement0, distuv).xy;
				disp0 = ((disp0 * 2) - 1) * (_Magnitude0 / 10);

				// Detail texture
				float4 detailTex = tex2D(_DetailTex, i.uv2 + disp0);
				detailTex = ((detailTex * 2) - 1) * _DetailMagnitude / 5;

				// Main texture
				float4 mainTex = tex2D(_MainTex, i.uv0 + disp0 + detailTex);

				float4 col = mainTex * _Color;
				return col;
			}


			ENDCG
		}
	}
	FallBack "Diffuse"
}