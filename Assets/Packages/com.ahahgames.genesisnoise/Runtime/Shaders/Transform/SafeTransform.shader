Shader "Hidden/Genesis/SafeTransform"
{
    Properties
    {
        [InlineTexture]_Source_2D("Source", 2D) = "white" {}
        [InlineTexture]_Source_3D("Source", 3D) = "white" {}
        [InlineTexture]_Source_Cube("Source", Cube) = "white" {}

        [KeywordEnum(None, Tiled)] _TilingMode("Tiling Mode", Float) = 1
        _Tile("Tile", Range(1, 16)) = 1
        [KeywordEnum(Manual, Random)] _OffsetMode("Offset Mode", Float) = 0
        _Offset("Offset", Vector) = (0.0, 0.0, 0.0, 0.0)
        _Rotation("Rotation (turns)", Range(0, 1)) = 0.0
        [Toggle] _TileSafeRotation("Tile Safe Rotation", Float) = 1
        [Enum(None,0,X,1,Y,2,X+Y,3)] _Symmetry("Symmetry", Float) = 0
        _BackgroundColor("Background Color", Color) = (0.0, 0.0, 0.0, 1.0)
        [KeywordEnum(Automatic, Manual)] _MipmapMode("Mipmap Mode", Float) = 0
        _MipmapLevel("Mipmap Level", Range(0, 10)) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            HLSLPROGRAM
            #include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment GenesisFragment
            #pragma target 3.0

            #pragma shader_feature CRT_2D CRT_3D CRT_CUBE
            #pragma shader_feature _TILINGMODE_NONE _TILINGMODE_TILED
            #pragma shader_feature _OFFSETMODE_MANUAL _OFFSETMODE_RANDOM
            #pragma shader_feature _MIPMAPMODE_AUTOMATIC _MIPMAPMODE_MANUAL

            TEXTURE_SAMPLER_X(_Source);

            float4 _Offset;
            float _Tile;
            float _Rotation;
            float _TileSafeRotation;
            float _Symmetry;
            float4 _BackgroundColor;
            float _MipmapLevel;

            float2 Rotate2D(float2 p, float angle)
            {
                float s = sin(angle);
                float c = cos(angle);
                return float2(
                    p.x * c - p.y * s,
                    p.x * s + p.y * c
                );
            }

            float2 Hash22(float2 p)
            {
                float3 p3 = frac(float3(p.xyx) * float3(0.1031, 0.1030, 0.0973));
                p3 += dot(p3, p3.yzx + 33.33);
                return frac((p3.xx + p3.yz) * p3.zy);
            }

            float2 GetEffectiveOffset()
            {
            #if defined(_OFFSETMODE_RANDOM)
                return Hash22(_Offset.xy * 37.0 + float2(_Tile, _Tile));
            #else
                return _Offset.xy;
            #endif
            }

            float GetEffectiveRotationTurns()
            {
                float turns = _Rotation;

                // Substance only documents "safe" snapping behavior, not the
                // exact snap list. Quarter-turn snapping is the blur-safe
                // equivalent for Genesis' texture-space implementation.
                if (_TileSafeRotation > 0.5)
                    turns = round(turns * 4.0) * 0.25;

                return turns;
            }

            float2 ApplySymmetry(float2 uv)
            {
                float2 centered = uv - 0.5;

                if (_Symmetry == 1.0 || _Symmetry == 3.0)
                    centered.x = -abs(centered.x);

                if (_Symmetry == 2.0 || _Symmetry == 3.0)
                    centered.y = -abs(centered.y);

                return centered + 0.5;
            }

            float2 SnapToOutputPixelGrid(float2 tiledUv)
            {
                float2 resolution = float2(_CustomRenderTextureWidth, _CustomRenderTextureHeight);
                return (floor(tiledUv * resolution) + 0.5) / resolution;
            }

            float2 TransformUV(float2 uv)
            {
                float2 centered = uv - 0.5;
                centered = Rotate2D(centered, GetEffectiveRotationTurns() * 6.28318530718);
                uv = centered + 0.5;
                uv += GetEffectiveOffset();
                uv = ApplySymmetry(uv);
                return uv;
            }

            float4 SampleSafe(float2 uv, float3 dir)
            {
                float tile = max(_Tile, 1.0);
                float2 tiledUv = SnapToOutputPixelGrid(TransformUV(uv) * tile);

            #if defined(_TILINGMODE_TILED)
                float2 sampleUv = frac(tiledUv);
            #else
                bool inside = all(tiledUv >= 0.0) && all(tiledUv <= tile);
                if (!inside)
                    return _BackgroundColor;

                float2 sampleUv = saturate(tiledUv / tile);
            #endif

                float lod = 0.0;
            #if defined(_MIPMAPMODE_MANUAL)
                lod = _MipmapLevel;
            #else
                lod = max(0.0, log2(tile));
            #endif

                return SAMPLE_LOD_X(_Source, float3(sampleUv, 0.5), dir, lod);
            }

            float4 genesis(v2f_customrendertexture i) : SV_Target
            {
                return SampleSafe(i.localTexcoord.xy, i.direction);
            }

            ENDHLSL
        }
    }
}
