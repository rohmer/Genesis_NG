Shader "Hidden/ThermalSlope"
{
    Properties
    {
        _Height ("Height", 2D) = "white" {}
        _Talus ("Talus Angle", Float) = 0.02
        _Strength ("Erosion Strength", Float) = 0.5
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
            float4 _Height_TexelSize;

            float _Talus;
            float _Strength;

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

                float hL = tex2D(_Height, i.uv + float2(-texel.x, 0)).r;
                float hR = tex2D(_Height, i.uv + float2( texel.x, 0)).r;
                float hU = tex2D(_Height, i.uv + float2(0,  texel.y)).r;
                float hD = tex2D(_Height, i.uv + float2(0, -texel.y)).r;

                float dL = h - hL;
                float dR = h - hR;
                float dU = h - hU;
                float dD = h - hD;

                float4 outflow = 0;

                if (dL > _Talus) outflow.r = (dL - _Talus) * _Strength;
                if (dR > _Talus) outflow.g = (dR - _Talus) * _Strength;
                if (dU > _Talus) outflow.b = (dU - _Talus) * _Strength;
                if (dD > _Talus) outflow.a = (dD - _Talus) * _Strength;

                return outflow;
            }

            ENDHLSL
        }
    }
}