Shader "Custom/Mask" {

	Properties {
		_MainTex ("Main Texture", 2D) = "white" {}
		_Mask ("Mask", 2D) = "white" {}
	}

	SubShader {

		Tags {
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}

		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask RGB

		Pass {
			SetTexture[_MainTex] {
				Combine texture
			}

			SetTexture[_Mask] {
				Combine previous, texture
			}

		}
	}
}
