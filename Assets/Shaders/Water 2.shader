Shader "Custom/Water 2" {
	Properties {
		_MainTex ("Main Texture", 2D) = "grey" {}
		_WaveDisplacement0 ("Wave Displacement Texture", 2D) = "white" {}
		_Magnitude0 ("Magnitude", Range(0, 1)) = 1 
		_Color ("Color", color) = (1, 1, 1, 1)
		_Direction ("Wave Direction", vector) = (0, 0, 0, 0)
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
			};

			// Frag struct
			struct v2f {
				float4 vertex : SV_POSITION;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
			};


			// ----------------
			// Shader functions
			// ----------------

			// Properties
			sampler2D _MainTex;
			sampler2D _WaveDisplacement0;
			float _Magnitude0;
			float4 _Color;
			vector _Direction;

			float4 _MainTex_ST;		// "_ST" suffix means "scale transfer," which is originally what the texture material properties were labeled
			float4 _WaveDisplacement0_ST;

			// Vertex function
			v2f vert (appdata v) {
				v2f o;
				o.vertex = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv0 = TRANSFORM_TEX(v.uv0, _MainTex);				// This function gives us access to the material inspector's tile/offset values
				o.uv1 = TRANSFORM_TEX(v.uv1, _WaveDisplacement0);
				return o;
			}

			// Fragment function
			float4 frag (v2f i) : SV_Target {

				float2 distuv = float2(
					i.uv1.x,
					i.uv1.y + _Time.x
				);
//				distuv /= 15;

				float2 disp0 = tex2D(_WaveDisplacement0, distuv).xy;
				disp0 = ((disp0 * 2) - 1) * (_Magnitude0 / 10);
				float4 mainTexture = tex2D(_MainTex, i.uv0 + disp0);

				float4 col = mainTexture * _Color;
				return col;
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
