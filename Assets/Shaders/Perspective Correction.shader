Shader "Custom/Perspective Correction" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Perspective ("Perspective Correction", float) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"


			// --------------
			// Shader Structs
			// --------------

			// Vertex struct
			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			// Fragment struct
			struct v2f {
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};


			// ----------------
			// Shader Functions
			// ----------------

			// Properties
			sampler2D _MainTex;
			float _Perspective;

			float4 _MainTex_ST;		// "_ST" suffix means "scale transfer," which is originally what the texture material properties were labeled. Tiling = XY, offset = ZW

			// Vertex function
			v2f vert (appdata v) {
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);		// Translates mesh vertices into the camera views model-view-projection matrix (basically local space to world space)
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);			// This gives us access to our textures tiling/offset properties in the material inspector
				return o;
			}

			// Fragment function
			float4 frag (v2f i) : SV_Target {
				float2 perspectiveCorrect = float2(
					i.uv.x,
					i.uv.y + _Time.x
				) * _Perspective;

				float4 col = tex2D(_MainTex, i.uv + perspectiveCorrect);
				return col;
			}





//            v2f vert(appdata v) {
//                v2f o;
//                o.uv = v.uv;
//                
//                // Create a skew transformation matrix
//                float p = _Perspective;
//
//                float4x4 transformMatrix = float4x4(
//                    p,0,0,0,
//                    0,1,0,0,
//                    0,0,1,0,
//                    0,0,0,1);
//                
//                float4 skewedVertex = mul(transformMatrix, v.vertex);
//                o.vertex = mul(UNITY_MATRIX_MVP, skewedVertex);
//                return o;
//            }
//
//            fixed4 frag(v2f i) : SV_Target {
//                fixed4 col = tex2D(_MainTex, i.uv);
//                return col;
//            }





			ENDCG
		}
	}
	FallBack "Diffuse"
}
