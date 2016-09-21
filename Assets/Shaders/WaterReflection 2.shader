Shader "Custom/Water Reflection 2" {

	Properties {
		_MainTex("Main Texture", 2D) = "white" {}
		_Color("Tint", color) = (1, 1, 1, 1)
		_DisplaceTex0("Main Wave", 2D) = "white" {}
		_Magnitude0 ("Main Wave Distortion", Range(0,1)) = 0.5
//		_Speed0 ("Main Wave Speed", Range(0,1)) = 0.5
		_Speed0 ("Main Wave Speed", float) = 5
		_Direction0 ("Main Wave Direction", vector) = (1, 1, 1)
		_DisplaceTex1("Secondary Wave", 2D) = "white" {}
		_Magnitude1 ("Secondary Wave Distortion", Range(0,1)) = 0.5
//		_Speed1 ("Secondary Wave Speed", Range(0,1)) = 0.5
		_Speed1 ("Secondary Wave Speed", float) = 5
		_Direction1 ("Secondary Wave Direction", vector) = (1, 1, 1)
	}

	SubShader {

		Tags{
			"PreviewType" = "Plane"
		}

		pass {
			CGPROGRAM
			#pragma vertex vert		// Tells the shader which function is our Vertex shader function
			#pragma fragment frag	// Tells the shader which function is our fragment shader function

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
			// These must be redefined from our "properties" object above

			sampler2D _MainTex;
			float4 _Color;
			sampler2D _DisplaceTex0;
			float _Magnitude0;
			float _Speed0;
			vector _Direction0;
			sampler2D _DisplaceTex1;
			float _Magnitude1;
			float _Speed1;
			vector _Direction1;

			// UV Variables
			// _ST variables are automatically populated with the texture scale (x,y) and offset (z,w) values
			// from the correspondingly-named texture (such as _MainTexure)
			float4 _MainTex_ST;
			float4 _DisplaceTex0_ST;
			float4 _DisplaceTex1_ST;


			// Vertex shader

			v2f vert(appdata v) {
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);		// Unity function - transforms vertex coordinates from local to screen space
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);			// Unity function - allows access to tiling/offset in material inspector (requires texture property appended with "_ST")
				o.uv1 = TRANSFORM_TEX(v.uv1, _DisplaceTex0);
				o.uv2 = TRANSFORM_TEX(v.uv2, _DisplaceTex1);
				return o;
			}


			// Fragment shader

			float4 frag(v2f i) : SV_Target {

				// The first displacement texture
				// uv animation
				float2 distpuv0 = float2(
					i.uv1.x + _Time.x * _Direction0.x,
					i.uv1.y + _Time.y * _Direction0.y
				);

				float2 disp0 = tex2D(_DisplaceTex0, distpuv0).xy;
				disp0 = ((disp0 * 2) - 1) * _Magnitude0;

				// The second displacement texture
				float2 distpuv1 = float2(
					i.uv2.x + _Time.x * _Direction1.x,
					i.uv2.y + _Time.y * _Direction1.y
				);

				float2 disp1 = tex2D(_DisplaceTex1, distpuv1).xy;
				disp1 = ((disp1 * 2) - 1) * _Magnitude1;

				float disp2 = disp0 + disp1;

				float4 col = tex2D(_MainTex, i.uv + disp2) * _Color;
				return col;
			}

			ENDCG
		}

	}
	FallBack "Diffuse"
}
