Shader "Terrain/ThermalErosion8"
{
    Properties
    {
        _MainTex ("Heightmap", 2D) = "white" {}
        _Talus ("Angle of Repose", Range(0, 0.1)) = 0.01
        _Strength ("Erosion Strength", Range(0, 1)) = 0.5
        _TexelSize ("Texel Size", Vector) = (0.001, 0.001, 0, 0)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _Talus;
            float _Strength;

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float h = tex2D(_MainTex, uv).r;
                float4 texel = _MainTex_TexelSize;

                float deposit = 0;
                float loss = 0;

                // 8-Neighbor offsets
                float2 offsets[8] = {
                    float2(-1,-1), float2(0,-1), float2(1,-1),
                    float2(-1, 0),               float2(1, 0),
                    float2(-1, 1), float2(0, 1), float2(1, 1)
                };

                for (int n = 0; n < 8; n++) {
                    float2 neighborUV = uv + offsets[n] * texel.xy;
                    float nh = tex2D(_MainTex, neighborUV).r;

                    // Outgoing: Am I taller than my neighbor?
                    float diff_out = h - nh;
                    if (diff_out > _Talus) {
                        loss += (diff_out - _Talus) * _Strength * 0.125; 
                    }

                    // Incoming: Is my neighbor taller than me?
                    float diff_in = nh - h;
                    if (diff_in > _Talus) {
                        deposit += (diff_in - _Talus) * _Strength * 0.125;
                    }
                }

                float finalH = h + deposit - loss;
                return float4(finalH, finalH, finalH, 1.0);
            }
            ENDCG
        }
    }
}