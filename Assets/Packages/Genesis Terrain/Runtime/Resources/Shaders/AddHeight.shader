Shader "Hidden/AddHeight"
{
    Properties {}
    SubShader
    {
        ZWrite Off ZTest Always Cull Off Blend Off

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            sampler2D _Pickup;
            sampler2D _Transport;

            float4 vert(float4 v:POSITION) : SV_POSITION { return v; }
            struct v2f { float4 pos:SV_POSITION; float2 uv:TEXCOORD0; };

            float frag(v2f i) : SV_Target
            {
                float h = tex2D(_MainTex, i.uv).r;
                float er = tex2D(_Pickup, i.uv).r;
                float tr = tex2D(_Transport, i.uv).r;
                return h - er + tr;
            }
            ENDHLSL
        }
    }
}