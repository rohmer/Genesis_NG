Shader "Hidden/GaussianUnsharp"
{
    Properties
    {
        _MainTex ("Source", 2D) = "white" {}
        _Radius ("Blur Radius", Float) = 1.0
        _Amount ("Sharpen Amount", Float) = 1.0
        _Direction ("Direction", Vector) = (1,0,0,0) // (1,0)=horizontal, (0,1)=vertical
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _Radius;
            float _Amount;
            float2 _Direction;

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 texel = _MainTex_TexelSize.xy;
                float2 dir = _Direction * texel * _Radius;

                // 7-tap Gaussian weights (σ ≈ 2)
                float w0 = 0.204164;
                float w1 = 0.180384;
                float w2 = 0.123317;
                float w3 = 0.066282;

                float4 c = tex2D(_MainTex, i.uv);

                // Gaussian blur sample
                float4 blur = 0;
                blur += tex2D(_MainTex, i.uv) * w0;

                blur += tex2D(_MainTex, i.uv + dir * 1) * w1;
                blur += tex2D(_MainTex, i.uv - dir * 1) * w1;

                blur += tex2D(_MainTex, i.uv + dir * 2) * w2;
                blur += tex2D(_MainTex, i.uv - dir * 2) * w2;

                blur += tex2D(_MainTex, i.uv + dir * 3) * w3;
                blur += tex2D(_MainTex, i.uv - dir * 3) * w3;

                // Unsharp mask
                float4 sharpened = c + _Amount * (c - blur);

                return sharpened;
            }

            ENDHLSL
        }
    }
}