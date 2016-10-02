 Shader "Custom/Gradient_3Color" {
     Properties {
         [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
         [HideInInspector] _ColorTop ("Top Color", Color) = (1,1,1,1)
         [HideInInspector] _Location0 ("Top Location", float) = 1
         [HideInInspector] _ColorMid ("Mid Color", Color) = (1,1,1,1)
         [HideInInspector] _Location1 ("Mid Location", float) = 1
         [HideInInspector] _ColorBot ("Bot Color", Color) = (1,1,1,1)
         [HideInInspector] _Location2 ("Bot Location", float) = 1
         _Angle ("Angle", Range(0, 1)) = 0
     }
 
     SubShader {
         Tags {"Queue"="Background"  "IgnoreProjector"="True"}
         LOD 100
 
         ZWrite On
 
         Pass {
	         CGPROGRAM
	         #pragma vertex vert
	         #pragma fragment frag
	         #include "UnityCG.cginc"
	 
	         fixed4 _ColorTop;
	         fixed4 _ColorMid;
	         fixed4 _ColorBot;
	         float _Location0;
	         float _Location1;
	         float _Location2;
	         float _Angle;

	         struct appdata {
	         	float4 vertex : POSITION;
	         	half2 uv : TEXCOORD0;
	         };

	         struct v2f {
	             float4 pos : SV_POSITION;
	             half2 uv : TEXCOORD0;
	         };
	 
	         v2f vert (appdata v) {
				v2f o;
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;

	            // Rotation
	            v.uv = v.uv;
				float ang = _Angle * -0.01745329;				//0.01745329 is conversion of 360.0/(2*PI) as 1.0/(360.0/(2*PI)) to convert angle to radians
	            float sinX = sin(ang);
		        float cosX = cos(ang);
	    	    float sinY = sin(ang);
	        	float2x2 rotationMatrix = float2x2(cosX, -sinX, sinY, cosX);
	       		o.uv = mul(v.uv, rotationMatrix);

	             return o;
	         }

	         fixed4 frag (v2f i) : COLOR {
	             fixed4 c = lerp(_ColorBot, _ColorMid, i.uv.y / _Location0) * step(i.uv.y, _Location0);
	             c += lerp(_ColorMid, _ColorTop, (i.uv.y - _Location0) / (1 - _Location0)) * step(_Location0, i.uv.y);

	             c.a = 1;
	             return c;
	         }
	         ENDCG
         }
     }
 }