Shader "Hidden/ThermalApply"
{
    Properties
    {
        _Height ("Height", 2D) = "white" {}
        _Flow   ("Flow", 2D) = "black" {}
    }

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _Height;
            sampler2D _Flow;
            float4 _Height_TexelSize;

            struct appdata { float4 vertex:POSITION; float2 uv:TEXCOORD0; };
            struct v2f { float4 pos:SV_POSITION; float2 uv:TEXCOORD0; };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float2 texel = _Height_TexelSize.xy;

                float h = tex2D(_Height, i.uv).r;

                float4 f = tex2D(_Flow, i.uv);

                float outflow = f.r + f.g + f.b + f.a;

                float inflow =
                    tex2D(_Flow, i.uv + float2( texel.x, 0)).r + // from right
                    tex2D(_Flow, i.uv + float2(-texel.x, 0)).g + // from left
                    tex2D(_Flow, i.uv + float2(0, -texel.y)).b + // from up
                    tex2D(_Flow, i.uv + float2(0,  texel.y)).a;  // from down

                float newH = h - outflow + inflow;

                return float4(newH, 0, 0, 1);
            }

            ENDHLSL
        }
    }
}