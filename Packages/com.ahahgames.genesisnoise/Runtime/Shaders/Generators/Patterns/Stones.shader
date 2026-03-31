Shader "Hidden/Genesis/Stones"
{	
	Properties
	{
		   // Layout & shaping
        _Tiling            ("World tiling (stones per unit)", Float) = 2.0
        _StoneRoundness    ("Stone roundness", Range(0.25, 4)) = 1.4
        _MortarWidth       ("Mortar width", Range(0.0, 0.25)) = 0.06
        _MortarSoftness    ("Mortar softness", Range(0.0, 0.25)) = 0.03
        _HeightStrength    ("Height to normal strength", Range(0, 2)) = 0.8
        _TriplanarSharpness("Tri-planar sharpness", Range(0.1, 8.0)) = 2.0
        _AOIntensity       ("Ambient occlusion intensity", Range(0,1)) = 0.35
        _EdgeWear          ("Edge wear (darken near borders)", Range(0,1)) = 0.25
        _Seed              ("Seed", Float) = 1.0

        // Palette
        _ColorA            ("Stone color A", Color) = (0.42, 0.40, 0.38, 1)
        _ColorB            ("Stone color B", Color) = (0.55, 0.52, 0.48, 1)
        _MortarColor       ("Mortar color", Color)   = (0.18, 0.17, 0.16, 1)

        // Lighting
        _LightDir          ("Light direction (world)", Vector) = (0.5, 0.7, 0.5, 0)
        _LightColor        ("Light color", Color) = (1, 0.97, 0.92, 1)
        _Ambient           ("Ambient color", Color) = (0.18, 0.2, 0.23, 1)

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
			#include "Packages/com.ahahgames.genesisnoise/Runtime/Shaders/ValueNoise.hlsl"
			
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma shader_feature _ USE_CUSTOM_UV
            //========================
            // Properties (CBUFFER)
            //========================
            float     _Tiling;
            float     _StoneRoundness;
            float     _MortarWidth;
            float     _MortarSoftness;
            float     _HeightStrength;
            float     _TriplanarSharpness;
            float     _AOIntensity;
            float     _EdgeWear;
            float     _Seed;

            float4    _ColorA;
            float4    _ColorB;
            float4    _MortarColor;

            float4    _LightDir;   // xyz direction (normalized preferred)
            float4    _LightColor; // rgb
            float4    _Ambient;    // rgb

            //========================
            // Utilities
            //========================
            float hash21(float2 p)
            {
                // 2D -> 1D hash in [0,1)
                p = frac(p * float2(123.34, 456.21));
                p += dot(p, p + 34.45);
                return frac(p.x * p.y);
            }

            float2 hash22(float2 p)
            {
                float n = sin(dot(p, float2(41.0, 289.0)));
                return frac(float2(8.0, 1.0) * 262144.0 * n);
            }

            // Voronoi metrics:
            // - nearD: distance to nearest site (F1)
            // - edge:  difference between F2 and F1 (proxy for border proximity; ~0 at edges)
            // - cellID: per-cell id in [0,1)
            void VoronoiMetrics(float2 uv, out float nearD, out float edge, out float cellID)
            {
                float2 gv = floor(uv);
                float2 lv = frac(uv);

                float best = 1e9;
                float second = 1e9;
                float id = 0.0;

                [unroll]
                for (int y = -1; y <= 1; y++)
                {
                    [unroll]
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 cell = float2(x, y);
                        float2 cellPos = gv + cell;
                        // jitter site within cell
                        float2 j = hash22(cellPos + _Seed) - 0.5;
                        float2 d  = cell + j - lv;
                        float  d2 = dot(d, d);

                        if (d2 < best)
                        {
                            second = best;
                            best   = d2;
                            id     = hash21(cellPos + 17.0);
                        }
                        else if (d2 < second)
                        {
                            second = d2;
                        }
                    }
                }

                float f1 = sqrt(best);
                float f2 = sqrt(second);
                nearD = f1;
                edge  = max(f2 - f1, 0.0);
                cellID = frac(id);
            }

            // Stone height profile from distance to cell center
            float StoneHeight(float nearD, float roundness)
            {
                // Assume typical max radius per cell ~0.6; normalize and shape
                float r = saturate(1.0 - nearD / 0.6);
                // Bulge control
                return pow(r, roundness);
            }

            // Finite difference height-to-normal for a planar UV
            float3 HeightToNormal2D(float2 uv, float du, float dv, float roundness)
            {
                float nd, ed, id;
                // Center height
                VoronoiMetrics(uv, nd, ed, id);
                float hC = StoneHeight(nd, roundness);

                // X+ sample
                VoronoiMetrics(uv + float2(du, 0), nd, ed, id);
                float hX = StoneHeight(nd, roundness);

                // Y+ sample
                VoronoiMetrics(uv + float2(0, dv), nd, ed, id);
                float hY = StoneHeight(nd, roundness);

                float dx = (hX - hC);
                float dy = (hY - hC);
                float3 n = normalize(float3(-dx, -dy, 1.0));
                return n;
            }

            // One planar projection “layer”: builds color, height, mortar, and normal in that plane
            void StoneLayer2D(float2 uv, float roundness,
                              out float3 albedo, out float height, out float mortar, out float3 nTS)
            {
                float nearD, edge, cid;
                VoronoiMetrics(uv, nearD, edge, cid);

                // Height: bulge toward cell centers
                height = StoneHeight(nearD, roundness);

                // Mortar mask: near edges where edge ~ 0
                float w = _MortarWidth;
                float s = max(_MortarSoftness, 1e-4);
                mortar = 1.0 - smoothstep(w, w + s, edge);

                // Variation by cell ID
                float3 baseCol = lerp(_ColorA.rgb, _ColorB.rgb, cid);

                // Edge wear darkening toward borders
                float wear = smoothstep(0.0, w + s, edge);
                baseCol *= lerp(1.0, 1.0 - _EdgeWear, 1.0 - wear);

                // AO approximation: darken crevices (low edge region and low height)
                float ao = 1.0 - _AOIntensity * (1.0 - saturate(edge / (w + s))) * (1.0 - height);
                albedo = baseCol * ao;

                // Tangent-space normal (for the plane): finite difference
                float du = 1.0 / max(_Tiling * 128.0, 32.0); // tiny step relative to tiling
                float dv = du;
                nTS = HeightToNormal2D(uv, du, dv, roundness);
            }

            // Tri-planar blend of three planar stone layers
            void StoneTriplanar(float3 posWS, float3 nrmWS,
                                out float3 albedo, out float3 nrmWSOut)
            {
                float3 an = abs(nrmWS);
                // Sharpen or soften projection weights
                float power = _TriplanarSharpness;
                float3 w = pow(an, power);
                w = w / max(w.x + w.y + w.z, 1e-4);

                float scale = _Tiling;

                // X-projection (YZ)
                float2 uvX = posWS.yz * scale;
                float3 aX; float hX; float mX; float3 nX;
                StoneLayer2D(uvX, _StoneRoundness, aX, hX, mX, nX);
                // Map tangent normal (x-plane) to world: x-axis is normal axis
                float3 nWX = normalize(float3(nX.z, nX.x, nX.y)); // TS (u=y, v=z, w=+x) -> WS

                // Y-projection (ZX)
                float2 uvY = posWS.zx * scale;
                float3 aY; float hY; float mY; float3 nY;
                StoneLayer2D(uvY, _StoneRoundness, aY, hY, mY, nY);
                float3 nWY = normalize(float3(nY.y, nY.z, nY.x)); // TS (u=z, v=x, w=+y) -> WS

                // Z-projection (XY)
                float2 uvZ = posWS.xy * scale;
                float3 aZ; float hZ; float mZ; float3 nZ;
                StoneLayer2D(uvZ, _StoneRoundness, aZ, hZ, mZ, nZ);
                float3 nWZ = normalize(float3(nZ.x, nZ.y, nZ.z)); // TS (u=x, v=y, w=+z) -> WS

                // Blend albedo and normals by weights
                albedo   = aX * w.x + aY * w.y + aZ * w.z;
                nrmWSOut = normalize(nWX * w.x + nWY * w.y + nWZ * w.z);
            }


           
			float4 genesis(v2f_customrendertexture i)
            {
				float3 posWS = i.localTexcoord;
                float3 geoN  = normalize(i.globalTexcoord);

                float3 albedo;
                float3 nrmWS;
                StoneTriplanar(posWS, geoN, albedo, nrmWS);

                // Perturb normal by height strength
                nrmWS = normalize(lerp(geoN, nrmWS, saturate(_HeightStrength)));

                // Simple direct light + ambient
                float3 L = normalize(_LightDir.xyz);
                float NdotL = saturate(dot(nrmWS, L));
                float3 lit = _Ambient.rgb + _LightColor.rgb * NdotL;

                float3 col = albedo * lit;

                return float4(col, 1.0);




			}
			ENDHLSL
		}		
	}
}