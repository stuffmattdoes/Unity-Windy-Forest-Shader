Shader "Custom/Water Reflection" {
	Properties {
		_Color ("Tint", Color) = (1,1,1,1)
	}
	SubShader {
		Tags {
			"Queue" = "Transparent"		// Make our fragments render after opaque geometry, duh!
			"PreviewType" = "Plane"
		}

		pass {
			ZWrite Off
			Cull Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert		// Tells the shader which function is our Vertex shader function
			#pragma fragment frag	// Tells the shader which function is our fragment shader function

			#include "UnityCG.cginc"

			// Define what information to pass into our vertex shader
			struct appdata {
				float4 vertex : POSITION;		// Position of the mesh vertex
				float2 uv : TEXCOORD0;			// Texture coordinate position of the vertex
				half4 color : COLOR;			// Vertex color
			};

			// Define what information to pass into our fragment shader
			struct v2f {
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 screenuv : TEXCOORD1;		// UV coordinates relative to screen-space
				half4 color : COLOR;
			};

			// Vertex shader calculation
			// Takes our appdata struct defined above, does some calculations,
			// and returns a "v2f" type, which will then be sent to our fragment shader
			// All it really does is look at the vertex local position, typically a vector3
			// Although a triangle == 3 vertices, this function only runs 2 times per triangle - but can generate hundreds of fragments
			v2f vert(appdata v) {
				v2f o;														// Initialize a variable of type v2f - we'll pass this to our fragment shader later
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);					// Transforms vertex coordinates from local to screen-space
				o.uv = v.uv;
				o.screenuv = ((o.vertex.xy / o.vertex.w) + 1) * 0.5;
				o.color = v.color;
				return o;
			}

			uniform sampler2D _GlobalRefractionTex;
			float4 _Color;

			// Accepts our "v2f" variable type output from our vertex shader
			// and returns a 4-dimensional color value to be rendered as a pixel!
			float4 frag(v2f i) : SV_Target {
				return tex2D(_GlobalRefractionTex, i.screenuv) * _Color;
			}

			ENDCG
		}

	}
	FallBack "Diffuse"
}
