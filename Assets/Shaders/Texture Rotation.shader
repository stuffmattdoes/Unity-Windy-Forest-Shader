Shader "Custom/Texture Rotation" {
	Properties {
		_MainTex ("Main Texture", 2D) = "grey" {}
		_Rotation ("Rotation", float) = 0.5
	}
	SubShader {
		Tags {
			"RenderType" = "Opaque"
		}

		LOD 200

		CGPROGRAM
		#pragma vertex vert
		#pragma surface surf Lambert
		sampler2D _MainTex;
 
        struct Input {
            float2 uv_MainTex;
        };
 
        float _Rotation;
        void vert (inout appdata_full v) {
            float sinX = sin ( _Rotation );
            float cosX = cos ( _Rotation );
            float sinY = sin ( _Rotation );
            float2x2 rotationMatrix = float2x2( cosX, -sinX, sinY, cosX);
//			float2x2 rotationMatrix = float2x2( 1, 0, 0, 1);
            v.texcoord.xy = mul ( v.texcoord.xy, rotationMatrix );
        }
 
        void surf (Input IN, inout SurfaceOutput o) {  
            half4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
		ENDCG
	}

	FallBack "Diffuse"
}
