using GraphProcessor;

using Microsoft.SqlServer.Server;

using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

using UnityEditor;

using UnityEngine;
using UnityEngine.Rendering;

using static UnityEditor.Rendering.CameraUI;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Output a Lit HDRP Material
")]

    [System.Serializable, NodeMenuItem("Material/HDRP/HDRP Lit")]
    public class HDRPLitMaterial : GenesisNode
    {
        public static Texture2D ConvertHeightRTToNormalTexture2D(RenderTexture heightRT, float strength = 1f, bool invertY = false, bool generateMipmaps = false)
        {
            if (heightRT == null) return null;

            // Ensure active RT and read pixels
            RenderTexture prev = RenderTexture.active;
            RenderTexture.active = heightRT;

            Texture2D src = new Texture2D(heightRT.width, heightRT.height, TextureFormat.RGBA32, false, true);
            src.ReadPixels(new Rect(0, 0, heightRT.width, heightRT.height), 0, 0);
            src.Apply();

            RenderTexture.active = prev;

            int w = src.width;
            int h = src.height;
            Color[] pixels = src.GetPixels();

            float[] height = new float[w * h];
            for (int i = 0; i < pixels.Length; i++)
            {
                Color c = pixels[i];
                height[i] = c.r; // assume height stored in red; adjust if needed
            }

            Texture2D normal = new Texture2D(w, h, TextureFormat.RGBA32, generateMipmaps, true);
            normal.wrapMode = src.wrapMode;
            normal.filterMode = FilterMode.Bilinear;

            Color[] outPixels = new Color[w * h];

            System.Func<int, int, float> sampleH = (sx, sy) =>
            {
                sx = Mathf.Clamp(sx, 0, w - 1);
                sy = Mathf.Clamp(sy, 0, h - 1);
                return height[sy * w + sx];
            };

            for (int y = 0; y < h; y++)
            {
                for (int x = 0; x < w; x++)
                {
                    float hl = sampleH(x - 1, y);
                    float hr = sampleH(x + 1, y);
                    float hd = sampleH(x, y - 1);
                    float hu = sampleH(x, y + 1);

                    float dx = (hr - hl) * 0.5f;
                    float dy = (hu - hd) * 0.5f;

                    Vector3 n = new Vector3(-dx * strength, -dy * strength, 1.0f).normalized;

                    float nx = n.x * 0.5f + 0.5f;
                    float ny = n.y * 0.5f + 0.5f;
                    float nz = n.z * 0.5f + 0.5f;

                    if (invertY) ny = 1.0f - ny;

                    outPixels[y * w + x] = new Color(nx, ny, nz, 1.0f);
                }
            }

            normal.SetPixels(outPixels);
            normal.Apply(generateMipmaps, false);

            return normal;
        }

        [Input(name = "Base Map")]
        Texture baseMap;
        [Input(name = "Mask Map")]
        Texture maskMap;
        [Input(name = "Height map")]
        Texture heightMap;
        [Input(name = "Normal Map")]
        Texture normalMap;
        [Input(name = "Bent normal map")]
        Texture bentNormalMap;
        [Input(name = "Coat Mask")]
        Texture coatMask;
        [Input(name = "Emission Map")]
        Texture emissionMap;
        [Input(name = "Detail Map")]
        Texture detailMap;
        [Input(name = "Emissive Map")]
        Texture emissiveMap;
        [Output(name = "Lit Material")]
        Material OutputMaterial;

        Texture2D preview;
        public override string name => "HDRP Lit";
        public override bool hasPreview => true;
        public override Texture previewTexture => preview;
        public override string NodeGroup => "Material";
        public override float nodeWidth => 300;

        Shader shader;

        public PrimitiveType primitiveType = PrimitiveType.Cube;
        // Below unique to URP Lit
        
        public float normalAmount=0;
        
        public float metallicAmount = 0f;
        public float smoothnessAmount = 0.5f;

        public Color baseColor = Color.white;

        public bool useEmission = false;
        public Color emissionColor;

        
        
        public enum eGlobIllum
        { 
            Realtime,
            Baked,
            None
        }

        public eGlobIllum globIllumination = eGlobIllum.None;

        public enum eSOM 
        {
            Off,
            [InspectorName("From Ambient Occulsion")]
            AO,
            [InspectorName("From AO and Bent Normals")]
            AOBent
        }

        public eSOM specOccMode = eSOM.AO;

        public bool addPrecomVelocity = false;


        protected override void Enable()
        {
            base.Enable();
            preview = new Texture2D(300, 300);
            Render();
        }
        public void Render()
        {
            shader = Shader.Find("HDRP/Lit");
            OutputMaterial = new Material(shader);
            if (baseMap != null)
            {
                OutputMaterial.SetTexture("_BaseColorMap", baseMap);
            }
            if(maskMap!=null)
            {
                OutputMaterial.SetTexture("_MaskMap", maskMap);
            }            
            if(normalMap!=null)
            {
               /* RenderTexture temp = new RenderTexture(normalMap.width, normalMap.height, 32);
                Graphics.Blit(normalMap, temp);
                
                Texture2D nmap = ConvertHeightRTToNormalTexture2D(temp, normalAmount);*/
                OutputMaterial.SetTexture("_NormalMap", normalMap);
                //OutputMaterial.SetTexture("_NormalMapOS", nmap);
                OutputMaterial.EnableKeyword("_NORMALMAP");
            }
            if(bentNormalMap!=null)
            {
                OutputMaterial.SetTexture("_BentNormalMap", bentNormalMap);
            }
            if(coatMask!=null)
            {
                OutputMaterial.SetTexture("_CoatMaskMap", coatMask);
            }
            if(emissionMap!=null)
            {
                OutputMaterial.SetTexture("_EmissiveColorMap", emissionMap);
            }
            if(detailMap!=null)
            {
                OutputMaterial.SetTexture("_DetailMap", detailMap);
            }
            if(heightMap!=null)
            {
                OutputMaterial.SetTexture("_HeightMap", heightMap);
            }

            OutputMaterial.SetColor("_BaseColor", baseColor);
            OutputMaterial.SetFloat("_Metallic", metallicAmount);
            OutputMaterial.SetFloat("_Smoothness", smoothnessAmount);
            OutputMaterial.SetFloat("_NormalScale", normalAmount);

            EditorUtility.SetDirty(OutputMaterial);

            preview = RuntimePreviewGenerator.GenerateMaterialPreview(OutputMaterial, primitiveType, 300, 300);
            //preview = AssetPreview.GetAssetPreview(OutputMaterial);

        }
    }
}