Shader "Custom/Wavy Forest" {

	// TODO
	// - Add wave texture to simulate rolling wind front

	// DONE
	// - Add distortion mask

	Properties {

		// Shader properties are denoted by:
		// 1. The variable name _MainTex
		// 2. The inspector label "Base (RGB)"
		// 3. The variable type 2D
		// 4. The default value "white"

		_Color ("Color Tint", Color) = (1,1,1,1)
		_RampTex ("Color Ramp", 2D) = "gray" {}
		_MainTex ("Base Texture (RGB)", 2D) = "white" {}
		_MaskTex ("Mask Texture (R)", 2D) = "gray" {}
		_DarkTex ("Shadow Texture (G)", 2D) = "black" {}
		_DarkAmount ("Shadow Amount", range(0.1, 1)) = 0.5
		_DistMaskTex ("Distortion Mask (B)", 2D) = "black" {}
		_DistMaskAmount ("Distortion Mask Amount", range(0, 1)) = 0.5
//		_WaveTex ("Wave Texture (A)", 2D) = "white" {}
		_SpeedX ("Speed X", float) = 1.5
		_Intensity ("Waviness", range(0, 1)) = 0.5
		_TileX ("Tile X", float) = 5
	}

	SubShader {
		Tags {
			"Queue"="Transparent"
			"RenderType"="Transparent"
		}

		LOD 200

		CGPROGRAM
		#pragma surface surf Lambert alpha

		sampler2D _RampTex;
		sampler2D _MainTex;
		sampler2D _MaskTex;
		sampler2D _DarkTex;
		sampler2D _DistMaskTex;

		float _DarkAmount;
		float _SpeedX;
		float _Intensity;
		float _TileX;
		float _DistMaskAmount;

		half4 _Color;

		struct Input {
			float2 uv_MainTex;
			float2 uv_MaskTex;
			float2 uv_DarkTex;
			float2 uv_DistMaskTex;
		};

		void surf (Input IN, inout SurfaceOutput o)
		{	

			// Adjust a few values to something reasonable
			_Intensity *= 0.01;
			_DarkAmount *= 35;

			float2 uvDistMask = IN.uv_DistMaskTex;
			half4 distMask = tex2D (_DistMaskTex, uvDistMask);

			// Apply our shadow area
			float2 uvDark = IN.uv_DarkTex;
			uvDark.x += sin((uvDark.x - uvDark.y) * _TileX + _Time.g * _SpeedX) * _Intensity * ( 1 - distMask.b * _DistMaskAmount);
			half4 dark = tex2D (_DarkTex, uvDark);

			// Wavy calculations
			float2 uvMain = IN.uv_MainTex;
			uvMain.x += sin((uvMain.x - uvMain.y) * _TileX + _Time.g * _SpeedX) * _Intensity * ( 1 - distMask.b * _DistMaskAmount);

			// Mask calculations
			float2 uvMask = IN.uv_MaskTex;
			uvMask.x += sin((uvMask.x - uvMask.y) * _TileX + _Time.g * _SpeedX) * _Intensity * ( 1 - distMask.b * _DistMaskAmount);
			half4 mask = tex2D (_MaskTex, uvMask);
			half4 c = tex2D (_MainTex, uvMain);


			// Increase our brightness by a bit
			c += 0.05;

			// Adjust our contrast
			c *= 0.95;

			// Now let's darken the intended shadow areas with our shadow texture
			c -= (dark.g / _DarkAmount);

			// Apply our color ramp
            fixed3 rampColor = tex2D(_RampTex, c.rgb);

			o.Albedo = rampColor.rgb * _Color;
			o.Alpha = mask.r;
		}

		ENDCG
	}
	Fallback "Diffuse"

}