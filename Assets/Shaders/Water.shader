Shader "Custom/Water" {
	Properties {
		[NoScaleOffset] _BumpMap ("Normal Map ", 2D) = "bump" {}
		[NoScaleOffset] _ReflectiveColor ("Reflective color (RGB) fresnel (A) ", 2D) = "" {}
		_Color ("Tint", color) = (1, 1, 1, 1)
		_WaveScale ("Wave scale", Range (0, 1)) = 0.063
		_ReflDistort ("Reflection distort", Range (0,1)) = 0.44
		_WaveSpeed ("Wave speed (map1 x,y; map2 x,y)", Vector) = (19,9,-16,-7)
	}

	Subshader {
		Tags {
			"WaterMode"="Refractive"
			"RenderType"="Opaque"
		}

		Pass {

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
//			#pragma multi_compile WATER_REFLECTIVE

			// Include library to give us additional properties/methods
			#include "UnityCG.cginc"

			#define HAS_REFLECTION 1


			// --------------
			// Shader Structs
			// --------------

			// Struct to pass to vertex shader
			struct appdata {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			// Struct to pass to fragment shader
			struct v2f {
				float4 pos : SV_POSITION;
				float4 ref : TEXCOORD0;
				float2 bumpuv0 : TEXCOORD1;
				float2 bumpuv1 : TEXCOORD2;
				float3 viewDir : TEXCOORD3;
				UNITY_FOG_COORDS(4)
			};


			// ----------------
			// Shader Functions
			// ----------------

			// Vertex shader properties
			uniform float4 _WaveScale4;		// The "4" appended to the "_WaveScale" variable basically converts the original as a float4
//			float _WaveScale;
			uniform float4 _WaveOffset;
			uniform float _ReflDistort;

			// Vertex shader
			v2f vert(appdata v) {
				v2f o;
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);

				// scroll bump waves
				float4 temp;
				float4 wpos = mul (_Object2World, v.vertex);
				temp.xyzw = wpos.xzxz * (_WaveScale4 * 4) + _WaveOffset;
				o.bumpuv0 = temp.xy;
				o.bumpuv1 = temp.wz;
				
				// object space view direction (will normalize per pixel)
				o.viewDir.xzy = WorldSpaceViewDir(v.vertex);
				o.ref = ComputeScreenPos(o.pos);

				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}

			// Fragment shader properties
			sampler2D _ReflectionTex;
			sampler2D _ReflectiveColor;
			sampler2D _BumpMap;
			float4 _Color;

			// Fragment shader
			half4 frag( v2f i ) : SV_Target {
				i.viewDir = normalize(i.viewDir);
				
				// combine two scrolling bumpmaps into one
				half3 bump1 = UnpackNormal(tex2D( _BumpMap, i.bumpuv0 )).rgb;
				half3 bump2 = UnpackNormal(tex2D( _BumpMap, i.bumpuv1 )).rgb;
				half3 bump = (bump1 + bump2) * 0.5;
				
				// fresnel factor
				half fresnelFac = dot( i.viewDir, bump );
				
				// perturb reflection/refraction UVs by bumpmap, and lookup colors
				float4 uv1 = i.ref; uv1.xy += bump * _ReflDistort / 2;
				half4 refl = tex2Dproj( _ReflectionTex, UNITY_PROJ_COORD(uv1) );
				
				// final color is between refracted and reflected based on fresnel
				half4 color;
				half4 water = tex2D( _ReflectiveColor, float2(fresnelFac,fresnelFac) );
				color.rgb = lerp( water.rgb * _Color, refl.rgb, water.a );
				color.a = refl.a * water.a;

				UNITY_APPLY_FOG(i.fogCoord, color);
				return color;
			}
			ENDCG

		}
	}
}
