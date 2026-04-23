Shader "Hidden/Genesis/AnisotropicKuwahara"
{
    Properties
    {
        // Source image
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        // Direction map
        [InlineTexture]_DirectionMap_2D("Direction Map", 2D) = "black" {}
        [InlineTexture]_DirectionMap_3D("Direction Map", 3D) = "black" {}
        [InlineTexture]_DirectionMap_Cube("Direction Map", Cube) = "black" {}

        _Radius("Radius", Range(1, 8)) = 4
        _Sectors("Sectors", Range(1, 8)) = 8
        _Anisotropy("Anisotropy", Range(1, 4)) = 2
        _StructureRadius("Structure Radius", Range(1, 4)) = 2

        _DirectionStrength("Direction Strength", Range(0, 1)) = 1
        _DirectionIsVector("Direction Is Vector", Int) = 0

        _DebugMode("Debug Mode", Int) = 0
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

            TEXTURE_SAMPLER_X(_Source);
            TEXTURE_SAMPLER_X(_DirectionMap);

            float _Radius;
            float _Sectors;
            float _Anisotropy;
            float _StructureRadius;

            float _DirectionStrength;
            int   _DirectionIsVector;

            int _DebugMode;

            // ------------------------------------------------------------
            float Luma(float3 c)
            {
                return dot(c, float3(0.2126, 0.7152, 0.0722));
            }

            // Sobel gradient
            void ComputeGradient(float3 uv, float3 texel, out float gx, out float gy)
            {                
                float3 tl = SAMPLE_X(_Source, uv + float3(-texel.x, -texel.y, 0), 0).rgb;
                float3  t = SAMPLE_X(_Source, uv + float3( 0,       -texel.y, 0), 0).rgb;
                float3 tr = SAMPLE_X(_Source, uv + float3( texel.x, -texel.y, 0), 0).rgb;

                float3 l  = SAMPLE_X(_Source, uv + float3(-texel.x,  0, 0), 0).rgb;
                float3 r  = SAMPLE_X(_Source, uv + float3( texel.x,  0, 0), 0).rgb;

                float3 bl = SAMPLE_X(_Source, uv + float3(-texel.x,  texel.y, 0), 0).rgb;
                float3  b = SAMPLE_X(_Source, uv + float3( 0,        texel.y, 0), 0).rgb;
                float3 br = SAMPLE_X(_Source, uv + float3( texel.x,  texel.y, 0), 0).rgb;

                float lt = Luma(tl),  mt = Luma(t),  rt = Luma(tr);
                float lm = Luma(l),                rm = Luma(r);
                float lb = Luma(bl), mb = Luma(b), rb = Luma(br);

                gx = (rt + 2*rm + rb) - (lt + 2*lm + lb);
                gy = (lb + 2*mb + rb) - (lt + 2*mt + rt);
            }
            // Structure tensor
            void ComputeStructureTensor(float3 uv, float3 texel, int r,
                                        out float Jxx, out float Jxy, out float Jyy)
            {
                float sx = 0, sxy = 0, sy = 0;
                int count = 0;

                for (int j = -r; j <= r; j++)
                for (int i = -r; i <= r; i++)
                {
                    float3 suv = uv + float3(i, j, 0) * texel;

                    float gx, gy;
                    ComputeGradient(suv, texel, gx, gy);

                    sx  += gx * gx;
                    sxy += gx * gy;
                    sy  += gy * gy;
                    count++;
                }

                float inv = 1.0 / count;
                Jxx = sx  * inv;
                Jxy = sxy * inv;
                Jyy = sy  * inv;
            }

            // Orientation + coherence
            void OrientationFromTensor(float Jxx, float Jxy, float Jyy,
                                       out float theta, out float coherence)
            {
                theta = 0.5 * atan2(2.0 * Jxy, Jxx - Jyy);

                float tr  = Jxx + Jyy;
                float det = Jxx * Jyy - Jxy * Jxy;
                float d   = max(tr*tr*0.25 - det, 0.0);

                float l1 = tr*0.5 + sqrt(d);
                float l2 = tr*0.5 - sqrt(d);

                coherence = (l1 - l2) / (l1 + l2 + 1e-5);
            }

            // ------------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;
                float3 texel = float3(0.01,0.01,0.01);

                // --- Structure tensor orientation
                float Jxx, Jxy, Jyy;
                ComputeStructureTensor(uv, texel, _StructureRadius, Jxx, Jxy, Jyy);

                float thetaTensor, coherence;
                OrientationFromTensor(Jxx, Jxy, Jyy, thetaTensor, coherence);

                // --- Direction map orientation
                float4 dirSample = SAMPLE_X(_DirectionMap, uv, i.direction);

                float thetaMap;

                if (_DirectionIsVector == 1)
                {
                    float2 v = normalize(dirSample.xy * 2 - 1);
                    thetaMap = atan2(v.y, v.x);
                }
                else
                {
                    thetaMap = dirSample.r * 6.2831853; // angle in [0,1]
                }

                // --- Blend tensor orientation with direction map
                float theta = lerp(thetaTensor, thetaMap, _DirectionStrength);

                // Debug: orientation
                if (_DebugMode == 1)
                {
                    float2 d = float2(cos(theta), sin(theta)) * 0.5 + 0.5;
                    return float4(d, 0, 1);
                }

                // Debug: coherence
                if (_DebugMode == 2)
                {
                    return float4(coherence.xxx, 1);
                }

                // --- Kuwahara ellipse basis
                float2 e1 = float2(cos(theta), sin(theta));
                float2 e2 = float2(-e1.y, e1.x);

                float a = _Radius * _Anisotropy;
                float b = _Radius;

                int sectors = (int)_Sectors;
                float sectorAngle = 6.2831853 / sectors;

                float3 mean[8];
                float  meanL[8];
                float  var[8];
                int    count[8];

                for (int s = 0; s < 8; s++)
                {
                    mean[s]  = 0;
                    meanL[s] = 0;
                    var[s]   = 0;
                    count[s] = 0;
                }

                // --- First pass: accumulate
                for (int j = -_Radius; j <= _Radius; j++)
                for (int i = -_Radius; i <= _Radius; i++)
                {
                    float3 p = float3(i, j,0);

                    float u = dot(p, e1);
                    float v = dot(p, e2);

                    float ua = u / a;
                    float vb = v / b;
                    if (ua*ua + vb*vb > 1.0)
                        continue;

                    float ang = atan2(v, u);
                    if (ang < 0) ang += 6.2831853;

                    int s = clamp((int)floor(ang / sectorAngle), 0, sectors-1);

                    float3 c = SAMPLE_X(_Source, uv + p * texel, i.direction).rgb;
                    float  l = Luma(c);

                    mean[s]  += c;
                    meanL[s] += l;
                    count[s] += 1;
                }

                // --- Variance pass
                for (int s = 0; s < sectors; s++)
                {
                    if (count[s] == 0)
                    {
                        var[s] = 1e6;
                        continue;
                    }

                    float inv = 1.0 / count[s];
                    float3 m  = mean[s] * inv;
                    float  mL = meanL[s] * inv;

                    float accum = 0;
                    int   n     = 0;

                    for (int j = -_Radius; j <= _Radius; j++)
                    for (int i = -_Radius; i <= _Radius; i++)
                    {
                        float3 p = float3(i, j,0);

                        float u = dot(p, e1);
                        float v = dot(p, e2);

                        float ua = u / a;
                        float vb = v / b;
                        if (ua*ua + vb*vb > 1.0)
                            continue;

                        float ang = atan2(v, u);
                        if (ang < 0) ang += 6.2831853;

                        int sIdx = clamp((int)floor(ang / sectorAngle), 0, sectors-1);
                        if (sIdx != s) continue;

                        float l = Luma(SAMPLE_X(_Source, uv + p * texel, i.direction).rgb);
                        accum += (l - mL) * (l - mL);
                        n++;
                    }

                    var[s] = (n > 0) ? (accum / n) : 1e6;
                    mean[s] = m;
                }

                // --- Pick best sector
                float bestVar = 1e9;
                int bestS = 0;

                for (int s = 0; s < sectors; s++)
                {
                    if (var[s] < bestVar)
                    {
                        bestVar = var[s];
                        bestS = s;
                    }
                }

                return float4(mean[bestS], 1);
            }

            ENDHLSL
        }
    }
}