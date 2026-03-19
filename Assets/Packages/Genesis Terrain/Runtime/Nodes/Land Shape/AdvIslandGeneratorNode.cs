using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System.Diagnostics;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.GNTerrain.Nodes
{

    [Documentation(@"
")]

    [System.Serializable, NodeMenuItem("Terrain/Shape/Advanced Island Generator")]
    public class AdvIslandGeneratorNode : GenesisNode
    {
        [SerializeField, Input]
        internal TerrainGeometry Input;
        [SerializeField, Input(name = "Noise Function", allowMultiple = false)]
        internal CustomRenderTexture NoiseFunction;
        [SerializeField, Output]
        internal TerrainNodes Output = new TerrainNodes();
        [SerializeField, ShowInInspector]
        internal bool useCoasts = true;
        [SerializeField]
        internal bool forceEdgeOcean = true;
        [SerializeField]
        internal AnimationCurve heightCurve;
        [SerializeField]
        internal float noiseInfluence = 0.5f;       // 0 - 1, 1 would yield almost exactly the noise map         
        [SerializeField]
        internal bool allowLakes = true;

        public override string name => "Advanced Island Shape Generator";
        public override bool showDefaultInspector => false;
        public override bool hasPreview => true;
        public override bool hasSettings => false;
        public override float nodeWidth => 300;
        internal Texture2D preview;

        public override Texture previewTexture => preview;

        private Texture2D noiseTexture = null;

        Color[] clearArray = new Color[300 * 300];

        protected override void Enable()
        {
            base.Enable();
            preview = new Texture2D(300, 300);
            clearArray = preview.GetPixels();
            for (int i = 0; i < clearArray.Length; i++)
                clearArray[i] = Color.black;
            preview.SetPixels(clearArray);
            if (heightCurve == null)
            {
                heightCurve = AnimationCurve.EaseInOut(0, 0, 1, 1);
            }
        }

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            bool r = base.ProcessNode(cmd);
            Output = new TerrainNodes(Input.plane, Input.pointGenerationData.GetSize());
            MarkWater();

            return true;
        }

        internal void MarkWater()
        {
            Output.UseCoasts = useCoasts;
            Output.AllowLakes = allowLakes;

            int size = Input.pointGenerationData.GetSize();
            // We have ocean, now we need to mark land
            Vector2 midpoint = new Vector2(size / 2.0f, size / 2.0f);
            float maxDist = Vector2.Distance(Vector2.zero, midpoint);

            Stopwatch stopwatch = new Stopwatch();
            stopwatch.Start();
            Texture2D noiseMap = null;
            if (NoiseFunction != null && noiseTexture == null)
            {
                float deltaRT = (float)NoiseFunction.width / (float)size;
                NoiseFunction.Update();

                noiseMap = new Texture2D(NoiseFunction.width, NoiseFunction.height, TextureFormat.RGBA32, false);
                RenderTexture prev = RenderTexture.active;
                RenderTexture.active = NoiseFunction;
                noiseMap.ReadPixels(new Rect(0, 0, NoiseFunction.width, NoiseFunction.height), 0, 0);
                RenderTexture.active = prev;
                noiseMap.Apply();
            }
            else
            {
                noiseMap = new Texture2D(Input.pointGenerationData.GetSize(), Input.pointGenerationData.GetSize());
            }
            float mod = 300 / (float)Input.pointGenerationData.GetSize();

            float minX = float.MaxValue;
            float minY = float.MaxValue;
            uint minID = 0;

            for (uint i = 0; i < Output.NodeCount; i++)
            {
                TerrainNode? tn = Output.GetNodeByID(i);
                if (tn != null)
                {
                    TerrainNode node = ((TerrainNode)tn);
                    Vector2 centroid = node.Centroid;
                    float minDist = centroid.x;
                    minDist = Mathf.Min(minDist,
                        (float)size - centroid.x);
                    minDist = Mathf.Min(minDist,
                        centroid.y);
                    minDist = Mathf.Min(minDist, (float)size - centroid.y);
                    float distPct = minDist / maxDist;
                    float noiseValue = 0.0f;
                    if (noiseMap != null)
                    {
                        noiseValue = noiseMap.GetPixel(Mathf.RoundToInt(centroid.x), Mathf.RoundToInt(centroid.y)).grayscale;
                    }

                    float heightFraction = heightCurve.Evaluate(distPct);
                    float noiseFraction = noiseValue * noiseInfluence;

                    float t = heightFraction - noiseFraction - 0.05f;
                    if (t < 0.0f || (node.isEdge && forceEdgeOcean))
                    {
                        Output.SetNodeType(i, eTerrainNodeType.LAKE);
                    }
                    else
                    {
                        Output.SetNodeType(i, eTerrainNodeType.LAND);
                    }

                    if (node.Centroid.x < minX && node.Centroid.y < minY && node.NodeType == eTerrainNodeType.LAKE)
                    {
                        minX = node.Centroid.x;
                        minY = node.Centroid.y;
                        minID = node.id;
                    }
                }
            }
            stopwatch.Stop();
            UnityEngine.Debug.Log($"MarkWater took: {stopwatch.ElapsedMilliseconds}");

            stopwatch.Restart();
            Output.MarkOcean(minID);
            if (!allowLakes)
            {
                for (uint i = 0; i < Output.NodeCount; i++)
                {
                    if (Output.nodes[i].NodeType == eTerrainNodeType.LAKE)
                        Output.SetNodeType(i, eTerrainNodeType.LAND);
                }
            }
            stopwatch.Stop();
            UnityEngine.Debug.Log($"MarkOcean took: {stopwatch.ElapsedMilliseconds}");

            stopwatch.Restart();
            Output.MarkCoast();
            stopwatch.Stop();
            UnityEngine.Debug.Log($"MarkCoast took: {stopwatch.ElapsedMilliseconds}");

            stopwatch.Restart();
            Output.GenerateMapGPU(size);
            stopwatch.Stop();
            UnityEngine.Debug.Log($"GenerateMap took: {stopwatch.ElapsedMilliseconds}");

            stopwatch.Restart();
            preview = Output.GeneratePreview(300);
            preview.Apply();
            stopwatch.Stop();
            UnityEngine.Debug.Log($"GeneratePreview took: {stopwatch.ElapsedMilliseconds}");

        }
    }
}
