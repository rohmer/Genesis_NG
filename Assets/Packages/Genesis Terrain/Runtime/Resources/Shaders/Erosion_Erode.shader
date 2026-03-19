Shader "Hidden/Erosion_Erode"
{
    Properties
    {
        _Height ("Height", 2D) = "white" {}
        _Water  ("Water", 2D) = "black" {}
        _Sed    ("Sediment", 2D) = "black" {}
        _Velocity ("Velocity", 2D) = "black" {}

        _ErodeRate ("Erode Rate", Float) = 0.3
        _SedimentCapacity ("Capacity", Float) = 1.0
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
            sampler2D _Sed;
            sampler2D _Velocity;

            float _ErodeRate;
            float _SedimentCapacity;

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
                float h = tex2D(_Height, i.uv).r;
                float w = tex2D(_Water,  i.uv).r;
                float s = tex2D(_Sed,    i.uv).r;
                float2 vel = tex2D(_Velocity, i.uv).rg;

                float speed = length(vel);
                float capacity = _SedimentCapacity * speed * w;

                if (s < capacity)
                {
                    float amount = _ErodeRate * (capacity - s);
                    h -= amount;
                    s += amount;
                }

                return float4(h, w, s, 1);
            }

            ENDHLSL
        }
    }
}