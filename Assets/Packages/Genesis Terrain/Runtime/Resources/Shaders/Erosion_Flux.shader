Shader "Hidden/Erosion_Flux"
{
    Properties
    {
        _Height ("Height", 2D) = "white" {}
        _Water  ("Water", 2D) = "black" {}
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
            sampler2D _Water;
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
                float w = tex2D(_Water,  i.uv).r;

                float hw = h + w;

                float hL = tex2D(_Height, i.uv + float2(-texel.x, 0)).r + tex2D(_Water, i.uv + float2(-texel.x, 0)).r;
                float hR = tex2D(_Height, i.uv + float2( texel.x, 0)).r + tex2D(_Water, i.uv + float2( texel.x, 0)).r;
                float hU = tex2D(_Height, i.uv + float2(0,  texel.y)).r + tex2D(_Water, i.uv + float2(0,  texel.y)).r;
                float hD = tex2D(_Height, i.uv + float2(0, -texel.y)).r + tex2D(_Water, i.uv + float2(0, -texel.y)).r;

                float fL = max(0, hw - hL);
                float fR = max(0, hw - hR);
                float fU = max(0, hw - hU);
                float fD = max(0, hw - hD);

                return float4(fL, fR, fU, fD);
            }

            ENDHLSL
        }
    }
}