using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using SharpVoronoiLib;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.GNTerrain.Nodes
{

    [Documentation(@"
This node generates the geometry that will be used throughout the terrain generation process.  The input to this node is from a point generator.
")]

    [System.Serializable, NodeMenuItem("Terrain/Voronoi Geometry Node")]
    public class VoronoiGeometryNode : GenesisNode
    {
        [SerializeField, Input]
        PointGenerationData SeedPoints;

        [SerializeField, Output]
        TerrainGeometry Output;

        [SerializeField]
        internal bool LloydsRelaxation = true;
      
        [SerializeField]
        internal int LloydsIterations = 5;

        [SerializeField]
        internal float RelaxationStrength = 0.1f;

        public override string name => "Voronoi Terrain Geometry";
        public override bool showDefaultInspector => false;
        public override bool hasPreview => false;
        public override float nodeWidth => 300;
        internal Texture2D preview;

        Color[] clearArray = new Color[300 * 300];
        protected override void Enable()
        {
            base.Enable();
            preview = new Texture2D(300, 300);
            clearArray = preview.GetPixels();
            for (int i = 0; i < clearArray.Length; i++)
                clearArray[i] = Color.black;
            preview.SetPixels(clearArray);
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
            UpdateAllPortsLocal();
            GenerateGeometry();
            return true;
        }

        void DrawLine(Texture2D a_Texture, int x1, int y1, int x2, int y2, Color a_Color)
        {
            float xPix = x1;
            float yPix = y1;

            float width = x2 - x1;
            float height = y2 - y1;
            float length = Mathf.Abs(width);
            if (Mathf.Abs(height) > length) length = Mathf.Abs(height);
            int intLength = (int)length;
            float dx = width / length;
            float dy = height / length;
            for (int i = 0; i <= intLength; i++)
            {
                a_Texture.SetPixel((int)xPix, (int)yPix, a_Color);

                xPix += dx;
                yPix += dy;
            }
        }

        internal void GenerateGeometry()
        {
            if (SeedPoints == null)
                return;

            Output = new TerrainGeometry(SeedPoints);
            Output.pointGenerationData = SeedPoints;
            Output.Compute(LloydsRelaxation, LloydsIterations, RelaxationStrength);
            
            // Now draw us a pretty picture
            preview.SetPixels(clearArray);
            float mod = 300 / (float)Output.pointGenerationData.GetSize();
            foreach (VoronoiEdge edge in Output.GetEdges())
            {
                int x1 = Mathf.RoundToInt((float)edge.Start.X * mod);
                int y1 = Mathf.RoundToInt((float)edge.Start.Y * mod);
                int x2 = Mathf.RoundToInt((float)edge.End.X * mod);
                int y2 = Mathf.RoundToInt((float)edge.End.Y * mod);
                DrawLine(preview, x1, y1, x2, y2, Color.white);
            }
            preview.Apply();
            //this.outputPorts[0].PushData();
        }

        void Update()
        {
        }
    }
}