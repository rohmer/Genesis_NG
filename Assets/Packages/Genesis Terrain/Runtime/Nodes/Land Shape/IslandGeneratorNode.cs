using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System.Diagnostics;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.GNTerrain.Nodes
{

    [Documentation(@"
")]

    [System.Serializable, NodeMenuItem("Terrain/Shape/Island Generator")]
    public class IslandGeneratorNode : GenesisNode
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

        public override string name => "Island Shape Generator";
        public override bool showDefaultInspector => false;
        public override bool hasPreview => true;
        public override bool hasSettings => false;
        public override float nodeWidth => 300;
        internal Texture2D preview;

        private Texture2D noiseTexture = null;

        public override Texture previewTexture => preview;

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

        /// <summary>
        /// Operations
        /// 0. Generate Points - Using the point generation algo, generate a set of control points (PointGenerators)
        /// 1. GenVoronoi - Compute to generate a list of 3d triangles
        /// 2. NoiseBasedHeights - Takes input of a noise function and layers it on while calling on (3)
        /// 3. IslandShape - This will attempt to force the object to be an island (Penalize heights closer to the edge)
        /// 4. DefineLand - Takes the input of triangles and defines which are in land, coloring those green on a texture, ocean is dark blue, lake is blue
        /// 5. Final height function - Take another noise input and layer it on distance to ocean.  Likely should accept some sort of a curve here for defining the distance impact.  This will lower land going
        ///     away from land, that is in the sea
        /// 6. Define land and water - Rerun define land, all points &lt; sea-level are ocean, unless they are landlocked then they are lake, everything else is land        
        /// 7. Set triangle points - Run thru all the points in the triangle and set the heights to the height in the heightmap
        /// </summary>
        /// <param name="cmd"></param>
        /// 
        protected override bool ProcessNode(CommandBuffer cmd)
        {
            bool r = base.ProcessNode(cmd);
            Output = new TerrainNodes(Input.plane, Input.pointGenerationData.GetSize());

            MarkWater();
            Output.UseCoasts = useCoasts;
            Output.AllowLakes = allowLakes;
            UpdatePortsForField("Output", true);
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
                        Output.SetNodeType(i, eTerrainNodeType.OCEAN);
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