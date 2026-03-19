Shader "Hidden/Erosion_WaterUpdate"
{
    Properties
    {
        _Water ("Water", 2D) = "black" {}
        _Flux  ("Flux", 2D) = "black" {}

        _Evaporation ("Evaporation", Float) = 0.02
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

            sampler2D _Water;
            sampler2D _Flux;

            float _Evaporation;

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
                float w = tex2D(_Water, i.uv).r;

                float4 f = tex2D(_Flux, i.uv);

                float newW = w + (f.r + f.g + f.b + f.a);
                newW *= (1 - _Evaporation);

                return float4(newW, 0, 0, 1);
            }

            ENDHLSL
        }
    }
}