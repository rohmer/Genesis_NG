Shader "Hidden/Genesis/Aurora"
{
    Properties
    {	
        // Colors
        GREEN_COLOR("Aurora color - dominant, lower-mid altitude",Vector)=(0.05, 0.9, 0.2,1)
        RED_COLOR("Aurora color - upper altitude, very diffuse",Vector)=(0.9, 0.1, 0.08,1)
        RED_COLOR("lower border, razor sharp", Vector)=(0.12, 0.15, 0.95,1)
        // Ray marching
        MARCH_STEPS("Volume samples - more = smoother", int)=60
        SLAB_BASE("Altitude where aurora slab begins", float)=0.85
        STRIDE_POWER("Polynomial stride - less aggressive for smoother sampling",float)=1.4
        STRIDE_SCALE("Base stride multiplier",float)=0.002
        DITHER_STRENGTH("Per-sample jitter to kill banding",float)=0.006
        FALLOFF_RATE("Exponential decay per sample",float)=0.07
        BRIGHTNESS("Final intensity multiplier",float)=1.7

        // Curtain noise
        NOISE_ITERS("Triangle wave octaves, more for smoother detail", Range(1,20))=6
        NOISE_SHARPNESS("Pow exponent", float)=1.1
        NOISE_SCALE("Accumulator multiplier",float)=25.0
        CURTAIN_SKEW("Domain rotation for anisotropic banding",float)=0.06

        // stars
        [Enum(Disabled,0,Enabled,1)]USE_STARS("Add Stars", int)=1
        [VisibleIf(USE_STARS,1)]STAR_LAYERS("Number of star layers",Range(1,20))=1
        [VisibleIf(USE_STARS,1)]STAR_THRESHOLD("Star Threshold",float)=0.0005
        [VisibleIf(USE_STARS,1)]STAR_POINT_SHARPNESS("Gaussian falloff for star core",float)=800.0
        [VisibleIf(USE_STARS,1)]STAR_HALO_SHARPNESS("Gaussian falloff for soft halo",float)=80.0
        [VisibleIf(USE_STARS,1)]STAR_HALO_INTENSITY("Halo brightness relative to core",float)=0.15

        SEED("Seed value",float)=1.0

    }
	
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #define BUILTIN_TARGET_API	
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/FastNoiseLite.hlsl"

            #pragma vertex   CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _ USE_CUSTOM_UV

            // 557.7nm oxygen green — dominant, lower-mid altitude
            #define GREEN_ALT_CENTER  0.25
            #define GREEN_ALT_WIDTH   0.35
            #define GREEN_NOISE_SCALE 1.0       // baseline (0.7s transition)
            #define GREEN_INTENSITY   0.75      // strongest line

            // 630.0nm oxygen red — upper altitude, very diffuse
            #define RED_ALT_CENTER    0.65
            #define RED_ALT_WIDTH     0.45      // wide spread (110s transition)
            #define RED_NOISE_SCALE   0.6       // sample at larger scale = smoother
            #define RED_INTENSITY     0.45      // weaker than green (quenching)

            // 427.8nm nitrogen blue — lower border, razor sharp
            #define BLUE_ALT_CENTER   0.08
            #define BLUE_ALT_WIDTH    0.12      // narrow band (<0.001s transition)
            #define BLUE_NOISE_SCALE  1.6       // sharp detail
            #define BLUE_INTENSITY    0.3       // weakest of the three

            // --- Camera ---
            #define CAM_FOCAL         1.0       // focal length
            #define CAM_TILT          0      // base tilt above horizon (~30°) — keeps aurora centered
            #define PAN_SPEED_X       0.04      // horizontal pan speed
            #define PAN_SPEED_Y       0.025     // vertical wobble speed
            #define PAN_AMP_X         0.35      // horizontal pan range
            #define PAN_AMP_Y         0.12      // vertical wobble range — subtle so we stay in the band

            // --- Sky ---
            #define SKY_ZENITH        float3(0.02, 0.02, 0.06)  // straight up — deep blue-black
            #define SKY_LOW           float3(0.06, 0.08, 0.15)   // toward edges — slightly lighter

            int MARCH_STEPS;
            float SLAB_BASE,STRIDE_POWER,STRIDE_SCALE,DITHER_STRENGTH,FALLOFF_RATE,BRIGHTNESS;
            int NOISE_ITERS;
            float NOISE_SPEED,NOISE_SHARPNESS,NOISE_SCALE,CURTAIN_SKEW;
            float SEED;
            int USE_STARS,STAR_LAYERS;
            float STAR_THRESHOLD,STAR_POINT_SHARPNESS,STAR_HALO_INTENSITY,STAR_HALO_SHARPNESS;
            float4 RED_COLOR,GREEN_COLOR,BLUE_COLOR;

            // ---- 2D rotation ----
            float2x2 rot2(float a)
            {
                float c = cos(a);
                float s = sin(a);
                return float2x2(c, s,
                               -s, c);
            }

            // ---- triangle-wave noise ----
            float tri(float x)
            {
                return clamp(abs(frac(x) - 0.5), 0.01, 0.49);
            }

            float2 tri2(float2 p)
            {
                return float2(
                    tri(p.x) + tri(p.y),
                    tri(p.y + tri(p.x))
                );
            }

            // Constant rotation matrix
            static const float2x2 noiseRot = float2x2(
                0.9563,  0.2924,
               -0.2924,  0.9563
            );

            // ---- curtain noise ----
            float curtainNoise(float2 p, float speed)
            {
                float z  = 1.8;
                float z2 = 2.5;
                float acc = 0.0;

                p = mul(p, rot2(p.x * CURTAIN_SKEW));
                float2 bp = p;

                for (int i = 0; i < NOISE_ITERS; i++)
                {
                    float2 dg = tri2(bp * 1.85) * 0.75;
                    dg = mul(dg, rot2(SEED * speed));

                    p -= dg / z2;

                    bp *= 1.3;
                    z2 *= 0.45;
                    z  *= 0.42;

                    p *= 1.21 + (acc - 1.0) * 0.02;

                    acc += tri(p.x + tri(p.y)) * z;

                    p = mul(p, -noiseRot);
                }

                float d = max(acc * NOISE_SCALE, 0.001);
                return clamp(1.0 / pow(d, NOISE_SHARPNESS), 0.0, 0.55);
            }

            // ---- hash ----
            float hash21(float2 n)
            {
                return frac(sin(dot(n, float2(12.9898, 4.1414))) * 43758.5453);
            }

            // ---- altitude envelope ----
            float altitudeEnvelope(float h, float center, float width)
            {
                float d = h - center;
                float spread = (d < 0.0) ? width * 0.4 : width;
                return exp(-(d * d) / (spread * spread));
            }

            // ---- volumetric aurora ----
            float4 aurora(float3 ro, float3 rd, float2 fragCoord)
            {
                float4 col    = float4(0,0,0,0);
                float4 avgCol = float4(0,0,0,0);

                float maxI = (float)MARCH_STEPS;

                for (int i = 0; i < MARCH_STEPS; i++)
                {
                    float fi = (float)i;

                    float dither = DITHER_STRENGTH * hash21(fragCoord) * smoothstep(0.0, 15.0, fi);

                    float t = ((SLAB_BASE + pow(fi, STRIDE_POWER) * STRIDE_SCALE) - ro.y)
                              / (rd.y * 2.0 + 0.4);

                    t -= dither;

                    float3 pos = ro + t * rd;
                    float h = fi / maxI;

                    float densityR = curtainNoise(pos.zx * RED_NOISE_SCALE,   NOISE_SPEED);
                    float densityG = curtainNoise(pos.zx * GREEN_NOISE_SCALE, NOISE_SPEED);
                    float densityB = curtainNoise(pos.zx * BLUE_NOISE_SCALE,  NOISE_SPEED);

                    float envR = altitudeEnvelope(h, RED_ALT_CENTER,   RED_ALT_WIDTH);
                    float envG = altitudeEnvelope(h, GREEN_ALT_CENTER, GREEN_ALT_WIDTH);
                    float envB = altitudeEnvelope(h, BLUE_ALT_CENTER,  BLUE_ALT_WIDTH);

                    float3 emission =
                        GREEN_COLOR * densityG * envG * GREEN_INTENSITY +
                        RED_COLOR   * densityR * envR * RED_INTENSITY +
                        BLUE_COLOR  * densityB * envB * BLUE_INTENSITY;

                    float totalDensity = densityG * envG;

                    float4 sampleCol = float4(emission, totalDensity);

                    avgCol = lerp(avgCol, sampleCol, 0.5);

                    col += avgCol *
                           exp2(-fi * FALLOFF_RATE - 2.5) *
                           smoothstep(0.0, 5.0, fi);
                }

                return col * BRIGHTNESS;
            }

            // ---- hash22 ----
            float2 hash22(float2 p)
            {
                float2 h = float2(
                    dot(p, float2(127.1, 311.7)),
                    dot(p, float2(269.5, 183.3))
                );
                return frac(sin(h) * 43758.5453123);
            }

            // ---- stars ----
            float3 stars(float3 rd)
            {
                float2 angles = float2(
                    atan2(rd.x, rd.z),
                    asin(clamp(rd.y, -1.0, 1.0))
                );

                float3 c = 0;

                for (int i = 0; i < STAR_LAYERS; i++)
                {
                    float fi = (float)i;
                    float scale = 25.0 + fi * 10.0;

                    float2 grid = angles * scale;
                    float2 id = floor(grid);
                    float2 gv = frac(grid) - 0.5;

                    float2 rn = hash22(id + fi * 100.0);
                    float rn3 = hash21(id + fi * 73.0);

                    float2 starPos = (rn - 0.5) * 0.7;

                    float d = length(gv - starPos);

                    float star =
                        exp(-d * d * STAR_POINT_SHARPNESS) +
                        exp(-d * d * STAR_HALO_SHARPNESS) * STAR_HALO_INTENSITY;

                    star *= step(rn3, STAR_THRESHOLD * 80.0 + fi * fi * 0.02);

                    star *= 0.8 + 0.2 * sin(SEED * 1.5 + rn.x * 100.0);

                    c += star * (lerp(float3(1.0, 0.49, 0.1),
                                      float3(0.75, 0.9, 1.0),
                                      rn.y) * 0.15 + 0.85);
                }

                return c * 0.7;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float2 resolution = _ScreenParams.xy;
                float2 p=i.localTexcoord.xy;
                float3 rd = normalize(float3(p.x, p.y, CAM_FOCAL));

                // Tilt up so we're looking across the aurora band
                rd.yz = mul(rd.yz, rot2(CAM_TILT));

                // Slow wandering pan
                rd.xz = mul(rd.xz, rot2(sin(SEED * PAN_SPEED_X) * PAN_AMP_X +
                                        cos(SEED * 0.031) * 0.1));

                rd.yz = mul(rd.yz, rot2(sin(SEED * PAN_SPEED_Y) * PAN_AMP_Y));

                float3 ro = float3(0.0, 0.0, -6.7);

                // Sky gradient
                float zenithDot = max(dot(rd, float3(0.0, 1.0, 0.0)), 0.0);
                float3 col = lerp(SKY_LOW, SKY_ZENITH, zenithDot);

                // Stars
                if(USE_STARS==1)
                    col += stars(rd);

                // Aurora — skip only rays pointing below horizon
                if (rd.y > 0.0)
                {
                    float4 aur = smoothstep(0.0, 1.5, aurora(ro, rd,i.localTexcoord.xy));
                    col = col * (1.0 - aur.a) + aur.rgb;
                }

                return float4(col, 1.0);
            }

            ENDHLSL
        }
    }
}