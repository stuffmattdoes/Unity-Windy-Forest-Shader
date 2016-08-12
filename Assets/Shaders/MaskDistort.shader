Shader "Custom/MaskDistort" {
	Properties {

		// Shader properties are denoted by:
		// 1. The variable name _MainTex
		// 2. The inspector label "Base (RGB)"
		// 3. The variable type 2D
		// 4. The default value "white"

		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Mask ("Mask", 2D) = "white" {}
		_Cutoff ("Alpha Cutoff", range(0, 1)) = 0.1
		_DistTex ("Distortion", 2D) = "white" {}
//		_Alpha ("Alpha", range(0, 1)) = 1
		_SpeedX ("Speed X", float) = 1.5
//		_SpeedY ("Speed Y", float) = 1.5
//		_Scale ("Scale", range(0.005, 0.2)) = 0.03
		_Scale ("Scale", range(0, 1)) = 0.5
		_TileX ("Tile X", float) = 5
//		_TileY ("Tile Y", float) = 5
	}

	SubShader {
		Tags {
			"Queue"="Transparent"
			"RenderType"="Transparent"
		}

		LOD 200

		CGPROGRAM
		#pragma surface surf Lambert alpha alphatest:_Cutoff

		sampler2D _MainTex;
		float4 uv_MainTex_ST;
		sampler2D _Mask;
		float4 uv_Mask_ST;
		sampler2D _DistTex;

		float _Alpha;
		float _SpeedX;
		float _SpeedY;
		float _Scale;
		float _TileX;
		float _TileY;

		struct Input {
			float2 uv_MainTex;
			float2 uv_Mask;
		};

		void surf (Input IN, inout SurfaceOutput o)
		{	
			_Scale *= 0.05;

			// Wavy calculations
			float2 uv = IN.uv_MainTex;
			uv.x += sin((uv.x - uv.y) * _TileX + _Time.g * _SpeedX) * _Scale;

			// Mask calculations
			float2 uvMask = IN.uv_Mask;
			uvMask.x += sin((uvMask.x - uvMask.y) * _TileX + _Time.g * _SpeedX) * _Scale;
			half4 mask = tex2D (_Mask, uvMask);

			half4 c = tex2D (_MainTex, uv);
			o.Albedo = c.rgb;
			o.Alpha = mask.a;
		}

		ENDCG
	}
	Fallback "Diffuse"

}