Shader "Hidden/Genesis/SplatterCircular"
{
    Properties
    {
        [Tooltip(Number of splats)]
        _Count("Count", Int) = 32

        [Tooltip(Base radius of the circle)]
        _Radius("Radius", Float) = 0.35

        [Tooltip(Global scale multiplier)]
        _GlobalScale("Global Scale", Float) = 1.0

        [Tooltip(Radial jitter amount)]
        _RadialJitter("Radial Jitter", Float) = 0.1

        [Tooltip(Angular jitter amount)]
        _AngularJitter("Angular Jitter", Float) = 0.1

        [Tooltip(PerSplat scale randomness)]
        _ScaleJitter("Scale Jitter", Float) = 0.25

        [Tooltip(PerSplat rotation randomness)]
        _RotationJitter("Rotation Jitter", Float) = 1.0

        [Tooltip(PerSplat opacity randomness)]
        _OpacityJitter("Opacity Jitter", Float) = 0.5

        [Tooltip(Soft falloff of splats)]
        _Falloff("Falloff", Float) = 2.0

        [Tooltip(Blend mode)]
        [Enum(Max,0,Add,1,Min,2)]_BlendMode("Blend Mode", Int) = 0

        [Tooltip(Optional input splat shape)]
        _SplatTex("Splat Texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            int _Count;
            float _Radius;
            float _GlobalScale;
            float _RadialJitter;
            float _AngularJitter;
            float _ScaleJitter;
            float _RotationJitter;
            float _OpacityJitter;
            float _Falloff;
            int _BlendMode;

            sampler2D _SplatTex;

            // ---------------------------------------------------------
            // Hash RNG
            // ---------------------------------------------------------
            float hash(float n)
            {
                return frac(sin(n * 12.9898) * 43758.5453);
            }

            float2 hash2(float n)
            {
                return float2(hash(n), hash(n + 17.123));
            }

            // ---------------------------------------------------------
            // Splat shape (default = radial falloff)
            // ---------------------------------------------------------
            float sampleSplat(float2 uv, float rot)
            {
                // rotate
                float s = sin(rot);
                float c = cos(rot);
                float2 ruv = float2(
                    uv.x * c - uv.y * s,
                    uv.x * s + uv.y * c
                );

                // sample texture if provided
                float tex = tex2D(_SplatTex, ruv * 0.5 + 0.5).r;

                // fallback radial shape
                float d = length(ruv);
                float radial = saturate(1.0 - pow(d, _Falloff));

                return max(tex, radial);
            }

            // ---------------------------------------------------------
            // Main
            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i)
            {
                float2 uv = i.localTexcoord.xy;

                #ifdef CRT_CUBE
                    uv = IN.localTexcoord.xy; // cube faces handled externally
                #endif

                float2 p = uv - 0.5;

                float result = 0.0;

                for (int i = 0; i < _Count; i++)
                {
                    float fi = float(i);

                    // base angle
                    float baseAngle = (fi / _Count) * 6.2831853;

                    // jitter
                    float2 jitter = hash2(fi);
                    float ang = baseAngle + (jitter.x - 0.5) * _AngularJitter;
                    float rad = _Radius + (jitter.y - 0.5) * _RadialJitter;

                    // splat center
                    float2 center = float2(cos(ang), sin(ang)) * rad;

                    // per‑splat scale
                    float scale = _GlobalScale * lerp(1.0, jitter.x, _ScaleJitter);

                    // per‑splat rotation
                    float rot = (jitter.y - 0.5) * _RotationJitter * 6.2831853;

                    // per‑splat opacity
                    float opacity = lerp(1.0, jitter.x, _OpacityJitter);

                    // local uv
                    float2 suv = (p - center) / scale;

                    float s = sampleSplat(suv, rot) * opacity;

                    // blend
                    if (_BlendMode == 0)       result = max(result, s);
                    else if (_BlendMode == 1)  result += s;
                    else if (_BlendMode == 2)  result = (i == 0) ? s : min(result, s);
                }

                return float4(saturate(result), saturate(result), saturate(result), 1.0);
            }

            ENDHLSL
        }
    }
}