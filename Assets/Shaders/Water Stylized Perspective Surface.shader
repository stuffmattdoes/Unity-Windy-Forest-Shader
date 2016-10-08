Shader "Custom/Water Stylized Perspective Surface" {
	Properties {
		_MainTex ("Main Texture", 2D) = "white" {}
		_DetailTex ("Detail Texture", 2D) = "grey" {}
		_DetailMag ("Detail Intensity", Range(0, 1)) = 0.5
//		_Color ("Tint", color) = (1, 1, 1, 1)
		_RampTex ("Color Ramp Texture", 2D) = "grey" {}
		_FresnelAmount ("Fresnel Amount", Range(-100, 100)) = 0
		_WaveDisplacement ("Wave Displacement", 2D) = "black" {}
		_WaveMag ("Wave Intensity", Range(0, 1)) = 0.5
		_WaveSpeed ("Wave Speed", float) = 1

		// Wave Properties
//		[HideInInspector] _WaveScale ("Wave scale", Range (0, 1)) = 0.063
		_ReflAmount ("Reflection Amount", Range(0, 1)) = 0.5
//		[HideInInspector] _WaveSpeed ("Wave Speed (map1 x,y; map2 x,y)", Vector) = (19,9,-16,-7)
	}
	SubShader {
		Tags {
			"RenderType" = "Opaque"
		}

		LOD 200

		CGPROGRAM
		#pragma surface surf Standard
//		#pragma multi_compile_fog
//		#pragma target 3.0

		#include "UnityCG.cginc"


		// -------------
		// Shader Inputs
		// -------------

		// Surface struct
		struct Input {
			float2 uv_MainTex;
			float2 uv_DetailTex;
			float2 uv_WaveDisplacement;
			float3 worldPos;				// Reserved property for world space position
			float4 screenPos;				// Reserved property for screen space position. Typically used for reflection/screen space effects
			float3 viewDir;
		};


		// ----------------
		// Shader Functions
		// ----------------

		// Properties
		sampler2D _MainTex;
		sampler2D _DetailTex;
		float _DetailMag;
//		half4 _Color;
		sampler2D _RampTex;
		float _FresnelAmount;
		sampler2D _WaveDisplacement;
		float _WaveMag;
		float _WaveSpeed;
		sampler2D _ReflectionTex;
		float _ReflAmount;
		float _ReflDistort;
	
		// Surface shader
		void surf (Input IN, inout SurfaceOutputStandard o) {

			// Displacement calculations
			float2 uvDisp = float2 (
				IN.uv_WaveDisplacement.x,
				IN.uv_WaveDisplacement.y - (_Time.x * _WaveSpeed / 2)
			);

			// Main Texture
			float2 uvMainTex = IN.uv_MainTex;

			// Displacement Texture
			float2 waveDisp = tex2D(_WaveDisplacement, uvDisp);
			waveDisp = ((waveDisp * 2) - 1) * (_WaveMag / 10);
			
			// Detail Texture
			float2 screenUV = IN.screenPos.xy / IN.screenPos.w;
			half4 detailTex = tex2D (_DetailTex, screenUV + waveDisp);
			detailTex = ((detailTex * 2) - 1) * _DetailMag / 5;

			// Reflection (texture obtained from script)
			float4 uv1 = IN.screenPos;
			half4 refl = tex2Dproj( _ReflectionTex, UNITY_PROJ_COORD(uv1));
			refl = ((refl * 2) - 1) * _ReflAmount;

			// Fresnel lighting
			half3 bumpTex = UnpackNormal(tex2D( _WaveDisplacement, IN.uv_WaveDisplacement )).rgb;
			half3 bump = bumpTex;
 			half fresnelFac = dot(IN.viewDir, -bump);
			half4 fres = tex2D(_RampTex, float2(fresnelFac, fresnelFac));

			// Apply our properties
			float2 uvFinal = uvMainTex + uvDisp + detailTex + waveDisp;
			half4 col = tex2D(_MainTex, uvFinal);
			fixed3 rampColor = tex2D(_RampTex, col.rgb);			// Ramp Color
			rampColor += refl;									// Add our reflection

			o.Albedo = rampColor * fres / 2;
		}

		ENDCG
	}
	FallBack "Diffuse"
}
