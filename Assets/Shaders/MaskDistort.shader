Shader "Custom/MaskDistort" {

	// TODO
	// 1. Distribute X tiling by consistent steps instead of texture width to ensure consistency across multiple textures
	//		^ Replace "_TileX" with "_DensityX" and make it happen

	Properties {

		// Shader properties are denoted by:
		// 1. The variable name _MainTex
		// 2. The inspector label "Base (RGB)"
		// 3. The variable type 2D
		// 4. The default value "white"

		_RampTex ("Color Ramp", 2D) = "gray" {}
		_MainTex ("Base Texture", 2D) = "white" {}
		_Mask ("Mask", 2D) = "white" {}
		_Cutoff ("Alpha Cutoff", range(0, 1)) = 0.1
		_SpeedX ("Speed X", float) = 1.5
		_Scale ("Scale", range(0, 1)) = 0.5
		_TileX ("Tile X", float) = 5
	}

	SubShader {
		Tags {
			"Queue"="Transparent"
			"RenderType"="Transparent"
		}

		LOD 200

		CGPROGRAM
		#pragma surface surf Lambert alpha alphatest:_Cutoff

		sampler2D _RampTex;
		sampler2D _MainTex;
		float4 uv_MainTex_ST;
		sampler2D _Mask;
		float4 uv_Mask_ST;

		float _SpeedX;
		float _Scale;
		float _TileX;

		struct Input {
			float2 uv_MainTex;
			float2 uv_Mask;
		};

		void surf (Input IN, inout SurfaceOutput o)
		{	

			// Adjust our scale to something reasonable
			_Scale *= 0.01;


			// Wavy calculations
			float2 uv = IN.uv_MainTex;
			uv.x += sin((uv.x - uv.y) * _TileX + _Time.g * _SpeedX) * _Scale;

			// Mask calculations
			float2 uvMask = IN.uv_Mask;
			uvMask.x += sin((uvMask.x - uvMask.y) * _TileX + _Time.g * _SpeedX) * _Scale;
			half4 mask = tex2D (_Mask, uvMask);
			half4 c = tex2D (_MainTex, uv);		// half4 refers to a 4 component vector using half precision floating point coordinates

			// Apply our color ramp
			fixed tempData = tex2D(_MainTex, uv);
			tempData += 0.05;
			tempData *= 0.95;
			fixed2 rampUV = fixed2(tempData, 0);
            fixed3 heatColor = tex2D(_RampTex, rampUV);

//			o.Albedo = c.rgb;
			o.Albedo = heatColor.rgb;
			o.Alpha = mask.a;
		}

		ENDCG
	}
	Fallback "Diffuse"

}