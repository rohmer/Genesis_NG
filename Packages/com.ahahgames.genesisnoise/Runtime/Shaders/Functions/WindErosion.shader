Shader "Hidden/Genesis/WindErosion"
{
    Properties
    {
        _MainTex("Source Heightmap", 2D) = "white" {}
        _Strength("Overall Strength", Range(0,10)) = 2.0
        _Bias("Height Bias", Range(-1,1)) = 0.0
        _Contrast("Height Contrast", Range(0.1,4.0)) = 1.0

        _WindAngle("Wind Angle Degrees", Range(0,360)) = 0.0
        _WindStrength("Wind Strength", Range(0,4)) = 1.0
        _SampleLength("Sample Length (px)", Range(1,64)) = 16.0
        _SampleCount("Sample Count", Range(1,16)) = 6

        _Aniso("Anisotropy Across Wind", Range(0,2)) = 0.5
        _Turbulence("Turbulence Strength", Range(0,2)) = 0.6
        _NoiseScale("Noise Scale", Range(0.1,16)) = 4.0

        _SlopeWeight("Slope Weight", Range(0,4)) = 0.5
        _DeltaWeight("Delta Weight", Range(0,4)) = 0.5
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #define BUILTIN_TARGET_API
            #include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"

            #pragma vertex   CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;

            float _Strength;
            float _Bias;
            float _Contrast;

            float _WindAngle;
            float _WindStrength;
            float _SampleLength;
            float _SampleCount;

            float _Aniso;
            float _Turbulence;
            float _NoiseScale;

            float _SlopeWeight;
            float _DeltaWeight;

            // ---------------------------------------------------------
            float sampleHeight(float2 uv)
            {
                float h = tex2D(_MainTex, uv).r;
                h = saturate(h + _Bias);
                h = pow(h, _Contrast);
                return h;
            }

            // cheap hash
            float hash21(float2 p)
            {
                p = frac(p * float2(123.34, 456.21));
                p += dot(p, p + 45.32);
                return frac(p.x * p.y);
            }

            // simple 2D value noise
            float noise(float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);

                float a = hash21(i + float2(0,0));
                float b = hash21(i + float2(1,0));
                float c = hash21(i + float2(0,1));
                float d = hash21(i + float2(1,1));

                float2 u = f * f * (3.0 - 2.0 * f);
                return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
            }

            // fbm
            float fbm(float2 uv)
            {
                float v = 0.0;
                float amp = 0.5;
                float2 shift = float2(100,100);
                for (int i = 0; i < 4; ++i)
                {
                    v += amp * noise(uv);
                    uv = uv * 2.0 + shift;
                    amp *= 0.5;
                }
                return v;
            }

            // ---------------------------------------------------------
            // 3x3 Sobel for slope
            float2 sobel(float2 uv)
            {
                float2 t = _MainTex_TexelSize.xy;

                float h00 = sampleHeight(uv + float2(-t.x, -t.y));
                float h10 = sampleHeight(uv + float2(0, -t.y));
                float h20 = sampleHeight(uv + float2(t.x, -t.y));

                float h01 = sampleHeight(uv + float2(-t.x, 0));
                float h11 = sampleHeight(uv);
                float h21 = sampleHeight(uv + float2(t.x, 0));

                float h02 = sampleHeight(uv + float2(-t.x, t.y));
                float h12 = sampleHeight(uv + float2(0, t.y));
                float h22 = sampleHeight(uv + float2(t.x, t.y));

                float dx = (h20 + 2*h21 + h22) - (h00 + 2*h01 + h02);
                float dy = (h02 + 2*h12 + h22) - (h00 + 2*h10 + h20);

                return float2(dx, dy) * 0.5;
            }

            // ---------------------------------------------------------
            float localDelta(float2 uv)
            {
                float2 t = _MainTex_TexelSize.xy;

                float hC = sampleHeight(uv);
                float hAvg =
                    ( sampleHeight(uv + float2( t.x, 0)) +
                      sampleHeight(uv + float2(-t.x, 0)) +
                      sampleHeight(uv + float2(0,  t.y)) +
                      sampleHeight(uv + float2(0, -t.y)) +
                      sampleHeight(uv + float2( t.x, t.y)) +
                      sampleHeight(uv + float2(-t.x, t.y)) +
                      sampleHeight(uv + float2( t.x, -t.y)) +
                      sampleHeight(uv + float2(-t.x, -t.y)) ) * (1.0/8.0);

                return hC - hAvg; // positive = peak, negative = valley
            }

            // ---------------------------------------------------------
            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.localTexcoord.xy;

                // preprocess height
                float hC = sampleHeight(uv);

                // wind direction unit vector from angle (degrees)
                float ang = radians(_WindAngle);
                float2 wind = float2(cos(ang), sin(ang));
                // texel-space step for one pixel in UV
                float2 texel = _MainTex_TexelSize.xy;

                // convert sample length in pixels to UV
                float maxLenUV = _SampleLength * texel.x; // assume square texels; small error if not

                // anisotropic cross-wind offset
                float2 cross = float2(-wind.y, wind.x);

                // sample upstream along wind direction
                float upstreamSum = 0.0;
                float weightSum = 0.0;

                // jittered sampling to reduce banding
                float jitter = hash21(uv * 437.0) - 0.5;

                for (int s = 1; s <= (int)max(1.0, _SampleCount); ++s)
                {
                    float t = (s + jitter) / _SampleCount; // 0..1
                    float distUV = t * maxLenUV;

                    // anisotropic spread: small offset across wind to simulate gust spread
                    float spread = _Aniso * (t * 0.5);

                    float2 sampleUV = uv - wind * distUV + cross * spread * texel.x;

                    // clamp to avoid sampling outside
                    sampleUV = clamp(sampleUV, 0.0, 1.0);

                    float hs = sampleHeight(sampleUV);

                    // weight closer samples more
                    float w = 1.0 / (0.5 + t * 2.0);
                    upstreamSum += hs * w;
                    weightSum += w;
                }

                float upstreamAvg = upstreamSum / max(1e-6, weightSum);

                // directional abrasion: if upstream is higher than center, wind carries particles that abrade center
                float dirAbrasion = saturate(upstreamAvg - hC);

                // slope term (wind less effective on very steep faces)
                float2 g = sobel(uv);
                float slope = length(g) * _SlopeWeight;
                float slopeFactor = saturate(1.0 - slope);

                // local curvature/delta to accentuate ridges and troughs
                float delta = abs(localDelta(uv)) * _DeltaWeight;

                // turbulence to create streak variation
                float n = fbm(uv * _NoiseScale);
                float turb = lerp(1.0 - _Turbulence, 1.0 + _Turbulence, n);

                // combine terms
                float windFactor = _WindStrength * dirAbrasion * slopeFactor * turb;
                float erosion = (windFactor + delta * 0.25) * _Strength;

                // clamp and output
                erosion = saturate(erosion);

                return float4(erosion, erosion, erosion, 1.0);
            }

            ENDHLSL
        }
    }
}

