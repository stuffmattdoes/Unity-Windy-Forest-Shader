Shader "Custom/Distortion"
{
	Properties
	{
		_MainTex("Texture", 2D) = "black" {}
		_DistTex("Distortion Texture", 2D) = "grey" {}
		_DistMask("Distortion Mask", 2D) = "black" {}
	}

		SubShader
		{
			Tags {
				"Queue" = "Transparent"
				"RenderType" = "Transparent"
				"PreviewType" = "Plane"
			}
			LOD 100
			ZWrite Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			sampler2D _DistTex;
			sampler2D _DistMask;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;

				float2x2 rotationMatrix;
				float sinTheta;
				float cosTheta;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float2 distScroll = float2(_Time.x, _Time.x);
				fixed2 dist = (tex2D(_DistTex, i.uv + distScroll).rg - 0.5) * 2;
//				fixed distMask = tex2D(_DistMask, i.uv)[0];

//				fixed4 col = tex2D(_MainTex, i.uv + dist * distMask * 0.025);
				fixed4 col = tex2D(_MainTex, i.uv + dist * 0.025);
				fixed bg = col.a;
				return col;
		}
		ENDCG
	}
	}

	CustomEditor "GoldenMaterialEditor"
}
