Shader "ColourReplacement" {
    Properties {
        _MainTex ("Greyscale (R) Alpha (A)", 2D) = "white" {}
        _ColorRamp ("Colour Palette", 2D) = "gray" {}
        _Clear ("NoAlpha", 2D) = "clear" {}
    }
    SubShader {
                    Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="False"  
        }
        Pass {
            Name "ColorReplacement"
         
 
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma fragmentoption ARB_precision_hint_fastest
                #include "UnityCG.cginc"
             
                struct v2f
                {
                    float4  pos : SV_POSITION;
                    float2  uv : TEXCOORD0;
                };

                v2f vert (appdata_tan v)
                {
                    v2f o;
                    o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                    o.uv = v.texcoord.xy;
                    return o;
                }
             
                sampler2D _MainTex;
                sampler2D _ColorRamp;
                sampler2D _Clear;
                float4 frag(v2f i) : COLOR
                {
                	// SURFACE COLOUR
                    float greyscale = tex2D(_MainTex, i.uv).r;
             
        			// RESULT
                    float4 result;
                    result.a = tex2D(_MainTex, i.uv).a;
                    if (result.a < 0.5)
                         result.rgb = tex2D(_Clear, i.uv).rgb;
                   else
                         result.rgb = tex2D(_ColorRamp, float2(greyscale, 0.5)).rgb;
                    return result;
                }
            ENDCG
        }
    }
    FallBack "Diffuse"
}