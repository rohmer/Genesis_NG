Shader "Hidden/Genesis/SymmetrySlice"
{
    Properties
    {
        // Source texture
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        // Number of slices (wedges)
        _Slices("Slice Count", Range(1, 32)) = 6

        // Mirror inside each slice
        [Enum(Disabled,0,Enabled,1)]_Mirror("Mirror Slice", Int) = 1

        // Softness of slice boundaries
        _Feather("Feather", Range(0, 0.5)) = 0.0

        // Center of symmetry
        _Center("Center", Vector) = (0.5, 0.5, 0.5, 0)

        // Wrap mode
        [Enum(Wrap,0,Clamp,1)]_Mode("Wrap Mode", Int) = 0 // 0 = wrap, 1 = clamp
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 250

        Pass
        {
            HLSLPROGRAM
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE

            TEXTURE_SAMPLER_X(_Source);

            float _Slices;
            int _Mirror;
            float _Feather;
            float4 _Center;
            int _Mode;

            float3 SampleSource(float3 uv, float3 dir)
            {
                return SAMPLE_X(_Source, uv, dir).rgb;
            }

            float3 WrapOrClamp(float3 uv)
            {
                return (_Mode == 0) ? frac(uv) : saturate(uv);
            }

            float3 ApplySymmetrySlice(float3 uv)
            {
                float3 c = _Center.xyz;
                float3 p = uv - c;

                float angle = atan2(p.y, p.x);
                float radius = length(p);

                // Normalize angle to 0..2π
                angle = fmod(angle + 6.2831853, 6.2831853);

                float sliceAngle = 6.2831853 / _Slices;

                // Which slice are we in?
                float sliceIndex = floor(angle / sliceAngle);

                // Angle inside the slice
                float localAngle = angle - sliceIndex * sliceAngle;

                // Mirror inside slice
                if (_Mirror == 1)
                {
                    float half = sliceAngle * 0.5;
                    localAngle = abs(localAngle - half);
                }

                // Reconstruct angle
                float finalAngle = localAngle;

                float3 dir = float3(cos(finalAngle), sin(finalAngle),0);
                return c + dir * radius;
            }

            float SliceMask(float2 uv)
            {
                if (_Feather <= 0.0001)
                    return 1.0;

                float2 c = _Center.xy;
                float2 p = uv - c;

                float angle = atan2(p.y, p.x);
                angle = fmod(angle + 6.2831853, 6.2831853);

                float sliceAngle = 6.2831853 / _Slices;
                float localAngle = fmod(angle, sliceAngle);

                float d = min(localAngle, sliceAngle - localAngle);
                float edge = smoothstep(0.0, _Feather * sliceAngle, d);

                return edge;
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                float3 uv = i.localTexcoord.xyz;

                float mask = SliceMask(uv);

                // Apply symmetry slice warp
                float3 warped = ApplySymmetrySlice(uv);

                // Wrap or clamp
                warped = WrapOrClamp(warped);

                float3 col = SampleSource(warped, i.direction);

                return float4(col * mask, 1);
            }

            ENDHLSL
        }
    }
}