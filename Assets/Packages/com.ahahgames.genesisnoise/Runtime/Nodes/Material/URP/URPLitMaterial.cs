using GraphProcessor;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Output a Lit URP Material
")]

    [System.Serializable, NodeMenuItem("Material/URP/Lit")]
    public class URPLitMaterial : GenesisNode
    {
        [Input(name = "Base Map")]
        Texture baseMap = default;
        [Input(name = "Metallic Map")]
        Texture metallicMap = default;
        [Input(name = "Normal Map")]
        Texture normalMap = default;
        [Input(name = "Height map")]
        Texture heightMap;
        [Input(name = "Occulsion Map")]
        Texture occulsionMap;
        [Input(name = "Emission Map")]
        Texture emissionMap;
        [Input(name = "Detail Mask Map")]
        Texture detailMaskMap;
        [Input(name = "Detail Base Map")]
        Texture detailBaseMap;
        [Input(name = "Detail Normal Map")]
        Texture detailNormalMap;
        [Output(name ="Lit Material")]
        Material OutputMaterial;

        Texture2D preview;
        public override string name => "URP Lit";
        public override bool hasPreview => true;
        public override Texture previewTexture => preview;
        public override string NodeGroup => "Material";
        public override float nodeWidth => 300;

        Shader shader; 

        public PrimitiveType primitiveType = PrimitiveType.Cube;
        // Below unique to URP Lit

        public enum eWorkflowMode
        {
            Specular=0,
            Metallic=1  
        }

        [SerializeField]
        public eWorkflowMode workflowMode;

        public enum eSurfaceType
        {
            Opaque=0,
            Transparent=1
        }
        [SerializeField]
        public eSurfaceType surfaceType;

        public bool alphaClipping = false;
        public bool receiveShadows = true;

        public float metallicAmount = 0f;
        public float smoothnessAmount = 0.5f;
        public float normalAmount = 10f;

        public enum eSmoothSource
        {
            [InspectorName("Metallic Alpha")]
            metallic=0,
            [InspectorName("Albedo Alpha")]
            albedo=1
        }
        public eSmoothSource smoothSource;
        public Color baseColor = Color.white;

        public bool useEmission = false;
        public Color emissionColor;

        public Vector2 tiling=new Vector2(1,1);
        public Vector2 offset=new Vector2(0,0);

        public Vector2 detailTiling = new Vector2(1, 1);
        public Vector2 detailOffset = new Vector2(0, 0);

        // Advanced Options
        public bool specularHighlights = true;
        public bool environmentReflections = true;
        public int sortingPriority = 0;
        public bool gpuInstancing = false;
        public bool albemic = false;

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
            if(baseMap!=null)
            {
                OutputMaterial.SetTexture("_BaseMap", baseMap);
            }
            if(metallicMap!=null)
            {
                OutputMaterial.SetTexture("_MetallicGlossMap", metallicMap);
            }
            if(normalMap!=null)
            {
                OutputMaterial.SetTexture("_BumpMap", normalMap);
                OutputMaterial.EnableKeyword("_NORMALMAP");
                OutputMaterial.SetFloat("_BumpScale", normalAmount);

            }
            OutputMaterial.SetFloat("_Smoothness", smoothnessAmount);
            OutputMaterial.SetFloat("_Metallic", metallicAmount);
            OutputMaterial.SetColor("_BaseColor", baseColor);
            if(useEmission)
            {
                OutputMaterial.SetColor("_EmissionColor", emissionColor);
            }
            preview = RuntimePreviewGenerator.GenerateMaterialPreview(OutputMaterial, primitiveType, 300, 300);

        }
    }
}
