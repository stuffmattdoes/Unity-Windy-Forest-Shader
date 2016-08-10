Shader "Custom/Diffuse Bump" {
	Properties {
		_MainText ("Texture", 2D) = "black" {}
		_BumpMap ("Bump Map", 2D) = "bump" {}
	}
	SubShader {
		Tags { "RenderType" = "Opaque" }
		CGPROGRAM
		#pragma surface surf Lambert

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
		};

		sampler2D _MainTex;
		sampler2D _BumpMap;

		void surf (Input IN, inout SUrfaceOutput o) {
			o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
			o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));
		}

		ENDCG
	}

	Fallback "Diffuse"
}