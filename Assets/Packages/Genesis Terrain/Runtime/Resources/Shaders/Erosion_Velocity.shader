Shader "Hidden/Erosion_Velocity"
{
    Properties
    {
        _Height ("Height", 2D) = "white" {}
        _Water  ("Water", 2D) = "black" {}
        _Velocity ("Velocity", 2D) = "black" {}

        _Gravity ("Gravity", Float) = 9.8
        _Damping ("Damping", Float) = 0.4
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
            sampler2D _Velocity;
            float4 _Height_TexelSize;

            float _Gravity;
            float _Damping;

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

                float2 vel = tex2D(_Velocity, i.uv).rg;

                float hw = h + w;

                float hL = tex2D(_Height, i.uv + float2(-texel.x, 0)).r + tex2D(_Water, i.uv + float2(-texel.x, 0)).r;
                float hR = tex2D(_Height, i.uv + float2( texel.x, 0)).r + tex2D(_Water, i.uv + float2( texel.x, 0)).r;
                float hU = tex2D(_Height, i.uv + float2(0,  texel.y)).r + tex2D(_Water, i.uv + float2(0,  texel.y)).r;
                float hD = tex2D(_Height, i.uv + float2(0, -texel.y)).r + tex2D(_Water, i.uv + float2(0, -texel.y)).r;

                float2 grad = float2(hR - hL, hU - hD);

                vel = vel * (1 - _Damping) + normalize(grad) * _Gravity;

                return float4(vel, 0, 0);
            }

            ENDHLSL
        }
    }
}