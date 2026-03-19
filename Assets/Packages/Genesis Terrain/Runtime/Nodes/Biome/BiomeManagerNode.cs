using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using Mono.Cecil;

using NUnit.Framework;

using System.Collections.Generic;
using System.Linq;

using Unity.VisualScripting.YamlDotNet.Serialization;

using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UIElements.InputSystem;
using UnityEngine.Windows;

using static AhahGames.GenesisNoise.GNTerrain.BiomeConfiguration;

namespace AhahGames.GenesisNoise.GNTerrain
{
    [Documentation(@"
            Some configuration options for MicroSplat integration.
")]
    [System.Serializable, NodeMenuItem("Terrain/Biome/Biome Manager")]

    public class BiomeManagerNode : GenesisNode
    {
        [Input(name = "Biome(s)", allowMultiple = true)]
        public List<BiomeConfig> biomes;

        [Input(name = "Temperature Map")]
        public RenderTexture TemperatureMap;

        [Input(name = "Moisture Map")]
        public RenderTexture MoistureMap;

        [Input(name = "Water Level")]
        public float WaterLevel;

        [Input(name = "Water Materials")]
        public WaterMaterialsData WaterMaterials;

        public int PostGenerationBlurRange = 10;

        public override string name => "Biome Manager";
        public override bool showDefaultInspector => false;
        public override bool hasPreview => true;
        public override bool hasSettings => false;
        public override float nodeWidth => 300;
        public override string NodeGroup => "Biomes";
        public override Texture previewTexture => preview;

        internal Texture2D preview;
        List<Texture2D> biomeMaps;

        ComputeShader coverage;
        RenderTexture coverageMap;
        Texture2D coverageTexture;

        ComputeShader createTex;
        ComputeShader createPreview;

        List<object> values = new List<object>();
        int portCount = 1;
        [CustomPortBehavior(nameof(biomes))]
        IEnumerable<PortData> ListPortBehavior(List<SerializableEdge> edges)
        {
            portCount = Mathf.Max(portCount, edges.Count + 1);
            for (int i = 0; i < portCount; i++)
            {
                yield return new PortData
                {
                    displayName = "Biome " + i,
                    displayType = typeof(BiomeConfig),
                    identifier = i.ToString()
                };
            }
        }

        [CustomPortInput(nameof(biomes), typeof(BiomeConfig))]
        void PullInputs(List<SerializableEdge> edges)
        {
            values.AddRange(edges.Select(e => e.passThroughBuffer).ToList());

        }

        protected override void Enable()
        {
            base.Enable();
            preview = new Texture2D(300, 300);
        }

        bool GetCoverage(int x, int y, float pct)
        {
            if (coverageMap == null)
            {
                coverage = Resources.Load<ComputeShader>("Shaders/CoverageShader");
                int kernel = coverage.FindKernel("CSMain");

                coverageMap = new RenderTexture(TemperatureMap.width, TemperatureMap.height, 0, RenderTextureFormat.RFloat);
                coverageMap.enableRandomWrite = true;
                coverageMap.Create();

                coverage.SetTexture(kernel, "Result", coverageMap);
                coverage.SetInts("Resolution", TemperatureMap.width, TemperatureMap.height);
                coverage.SetFloat("Scale", 8f);
                coverage.SetInt("Octaves", 10);
                coverage.SetFloat("Gain", .5f);
                coverage.SetFloat("Lacunarity", 2.0f);
                int seed = Random.Range(0, 65536);
                coverage.SetInt("Seed", seed);
                int dxdy = Mathf.CeilToInt(TemperatureMap.width / 8f);
                coverage.Dispatch(kernel, dxdy, dxdy, 1);
                coverageTexture = new Texture2D(TemperatureMap.width, TemperatureMap.height, TextureFormat.RFloat, false);
                RenderTexture.active = coverageMap;
                coverageTexture.ReadPixels(new Rect(0, 0, TemperatureMap.width, TemperatureMap.height), 0, 0);
                coverageTexture.Apply();
            }

            if (coverageTexture.GetPixel(x, y).r < pct)
                return true;

            return false;
        }

        Texture2D createTextureMap(BiomeConfig biome, int ctr)
        {
            if (createTex == null)
                createTex = Resources.Load<ComputeShader>("Shaders/CreateTextureMap");
            int kernel = createTex.FindKernel("CSMain");

            float[] wetness = new float[9];
            float[] elevation = new float[7];

            for (int i = 0; i < 9; i++)
            {
                wetness[i] = i * ((float)i / 8f);
            }
            for (int i = 0; i < 7; i++)
            {
                elevation[i] = i * ((float)i / 6f);
            }
                      

            createTex.SetTexture(kernel, "_temperatureMap", TemperatureMap);
            createTex.SetTexture(kernel, "_moistureMap", MoistureMap);
            createTex.SetFloats("_wetness", wetness);
            createTex.SetFloats("_elevation", elevation);
            createTex.SetInt("_minElevation", biome.minimumTemp);
            createTex.SetInt("_maxElevation", biome.maximumTemp);
            createTex.SetInt("_minMoisture", biome.minimumMoisture);
            createTex.SetInt("_maxMoisture", biome.maximumMoisture);            
            RenderTexture result = new RenderTexture(TemperatureMap.width, TemperatureMap.height, 1, RenderTextureFormat.ARGB32);
            result.enableRandomWrite = true;
            result.Create();

            createTex.SetTexture(kernel, "_Result", result);
            int dxdy = Mathf.CeilToInt(TemperatureMap.width / 8f);
            createTex.Dispatch(kernel, dxdy, dxdy, 1);

            Texture2D retVal = new Texture2D(result.width, result.height, TextureFormat.ARGB32, false);
            RenderTexture.active = result;
            retVal.ReadPixels(new Rect(0, 0, result.width, result.height), 0, 0);
            retVal.Apply();

            return retVal;
        }

        static Texture2D ToPreviewTexture(RenderTexture rt, int previewres = 256)
        {
            int w = rt.width;
            int h = rt.height;

            float scale = Mathf.Min((float)previewres / w, (float)previewres / h);
            int pw = Mathf.RoundToInt(w * scale);
            int ph = Mathf.RoundToInt(h * scale);

            RenderTexture tmp = RenderTexture.GetTemporary(pw, ph, 0, rt.format);
            Graphics.Blit(rt, tmp);

            Texture2D tex = new Texture2D(pw, ph, TextureFormat.RGBAFloat, false, true);

            RenderTexture prev = RenderTexture.active;
            RenderTexture.active = tmp;

            tex.ReadPixels(new Rect(0, 0, pw, ph), 0, 0);
            tex.Apply(false, false);

            RenderTexture.active = prev;
            RenderTexture.ReleaseTemporary(tmp);

            return tex;
        }
        
        void createPreviewMap()
        {
            if (createPreview == null)
                createPreview = Resources.Load<ComputeShader>("Shaders/CreateTexturePreview");
            int kernel = createPreview.FindKernel("CSMain");
            Color[] colors = new Color[32] { Color.aliceBlue, Color.antiqueWhite, Color.aquamarine, Color.azure,
            Color.beige, Color.bisque, Color.blanchedAlmond, Color.blue,
            Color.blueViolet, Color.brown, Color.crimson, Color.cyan,
            Color.darkGray, Color.darkBlue, Color.darkCyan, Color.darkGoldenRod,
            Color.darkGreen, Color.darkKhaki, Color.darkMagenta, Color.darkOliveGreen,
            Color.darkOrange, Color.darkOrchid, Color.darkRed, Color.darkSalmon,
            Color.darkSeaGreen, Color.darkSlateBlue, Color.darkSlateGray, Color.darkTurquoise,
            Color.darkViolet, Color.deepPink, Color.deepSkyBlue, Color.dimGray};

            int cptr = 0;
            RenderTexture pRT=new RenderTexture(TemperatureMap.width, TemperatureMap.height, 1, RenderTextureFormat.ARGB32);
            pRT.enableRandomWrite = true;
            pRT.Create();
            createPreview.SetTexture(kernel, "_Result", pRT);
            foreach (BiomeConfig biome in values)
            {
                Color c = colors[cptr];
                cptr++;
                if(cptr>31) { cptr = 0; }
                float[] wetness = new float[9];
                float[] elevation = new float[7];

                for (int i = 0; i < 9; i++)
                {
                    wetness[i] = i * ((float)i / 8f);
                }
                for (int i = 0; i < 7; i++)
                {
                    elevation[i] = i * ((float)i / 6f);
                }


                int maxE = biome.maximumTemp;
                int minE = biome.minimumTemp;
                int maxM = biome.maximumMoisture;
                int minM = biome.minimumTemp;
                createPreview.SetTexture(kernel, "_temperatureMap", TemperatureMap);
                createPreview.SetTexture(kernel, "_moistureMap", MoistureMap);
                createPreview.SetFloats("_wetness", wetness);
                createPreview.SetFloats("_elevation", elevation);
                createPreview.SetInt("_minElevation", biome.minimumTemp);
                createPreview.SetInt("_maxElevation", biome.maximumTemp);
                createPreview.SetInt("_minMoisture", biome.minimumMoisture);
                createPreview.SetInt("_maxMoisture", biome.maximumMoisture);
                int dxdy = Mathf.CeilToInt(TemperatureMap.width / 8f);
                createTex.Dispatch(kernel, dxdy, dxdy, 1);
            }
            preview = ToPreviewTexture(pRT, 300);
        }

        bool biomeMatch(BiomeConfig biome, float temp, float moist)
        {
            float minTemp = biome.minimumTemp * (1f / 7f);
            float maxTemp = biome.maximumTemp * (1f / 7f);
            float minMoist = biome.minimumMoisture * (1f / 5f);
            float maxMoist = biome.maximumMoisture * (1f / 5f);

            if(
                (temp>=minTemp && temp<=maxTemp) && (moist<=minMoist && moist<=maxMoist)
                )
            {
                return true;
            }

            return false;
        }

        private void cpuTexture()
        {
            Texture2D tex = new Texture2D(TemperatureMap.width, TemperatureMap.height);
            Texture2D tempMap = new Texture2D(TemperatureMap.width, TemperatureMap.height);
            RenderTexture.active = TemperatureMap;
            tempMap.ReadPixels(new Rect(0, 0, TemperatureMap.width, TemperatureMap.height), 0, 0);
            tempMap.Apply();

            Texture2D moistMap = new Texture2D(MoistureMap.width, MoistureMap.height);
            RenderTexture.active = MoistureMap;
            moistMap.ReadPixels(new Rect(0, 0, MoistureMap.width, MoistureMap.height), 0, 0);
            moistMap.Apply();

            Color[] colors = new Color[32] { Color.aliceBlue, Color.antiqueWhite, Color.aquamarine, Color.azure,
            Color.beige, Color.bisque, Color.blanchedAlmond, Color.blue,
            Color.blueViolet, Color.brown, Color.crimson, Color.cyan,
            Color.darkGray, Color.darkBlue, Color.darkCyan, Color.darkGoldenRod,
            Color.darkGreen, Color.darkKhaki, Color.darkMagenta, Color.darkOliveGreen,
            Color.darkOrange, Color.darkOrchid, Color.darkRed, Color.darkSalmon,
            Color.darkSeaGreen, Color.darkSlateBlue, Color.darkSlateGray, Color.darkTurquoise,
            Color.darkViolet, Color.deepPink, Color.deepSkyBlue, Color.dimGray};

            for (int y = 0; y < MoistureMap.height; y++)
            {
                for (int x = 0; x < MoistureMap.width; x++)
                {
                    float temp = tempMap.GetPixel(x, y).r;
                    float moist = moistMap.GetPixel(x, y).r;

                    int cPtr = 0;
                    foreach(BiomeConfig biome in values)
                    {
                        if(biomeMatch(biome,temp,moist))
                        {
                            tex.SetPixel(x, y, colors[cPtr]);
                        }
                        cPtr++;
                    }
                }
            }

            tex.Apply();
            RenderTexture rt = new RenderTexture(tex.width, tex.height,1,RenderTextureFormat.ARGB32)
            {
                wrapMode = tex.wrapMode,
                filterMode = tex.filterMode
            };
            Graphics.Blit(tex, rt);
            preview = ToPreviewTexture(rt, 300);
        }

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            bool r = base.ProcessNode(cmd);
            if (values == null || values.Count==0)
                return false;
            if (TemperatureMap == null)
                return false;
            if(MoistureMap==null) return false;
            
            int ctr = 0;
            foreach (BiomeConfig biome in values)
            {
                if (biome != null)
                {
                    biomeMaps.Add(createTextureMap(biome,ctr));
                }
                else

                {
                    biomeMaps.Add(new Texture2D(TemperatureMap.width, TemperatureMap.height));
                }
                ctr++;
            }
            cpuTexture();
            return r;
        }
    }
}