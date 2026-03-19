using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System.Collections.Generic;
using System.Diagnostics;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.GNTerrain.Nodes
{

    [Documentation(@"
")]

    [System.Serializable, NodeMenuItem("Terrain/IO Node")]
    public class HeightFieldIONode : GenesisNode
    {
        [SerializeField,Input]
        HeightField Input;
        public override bool hasPreview => true;
        public override bool hasSettings => false;

        public override float nodeWidth => 300;
        public override Texture previewTexture => preview;
        Texture2D preview;

        protected override void Enable()
        {
            base.Enable();
            preview = new Texture2D(300, 300);        
        }

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            foreach(NodePort port in this.GetInputPorts())
            {
                port.PullData();
            }
            UpdateAllPorts();
            bool r = base.ProcessNode(cmd);
            int size = Input.HeightMap.width;
            Texture2D tmp = ReadRenderTextureFloat(Input.HeightMap);
            preview = new Texture2D(300, 300);            
            float modD =  size/300;
            for (int x = 0; x < 300; x++)
            {
                for (int y = 0; y < 300; y++)
                {
                    float c = tmp.GetPixel((int)(x * modD), (int)(y * modD)).r;
                    preview.SetPixel(x, y, new Color(c, c, c, 1));                   
                }
            }
            preview.Apply();


            UnityEngine.Debug.Log("HeightFieldIONOde");
            return r;

        }

        Texture2D ReadRenderTextureFloat(RenderTexture rt)
        {
            RenderTexture prev = RenderTexture.active;
            RenderTexture.active = rt;
            Texture2D tex = new Texture2D(rt.width, rt.height, TextureFormat.RGBAFloat, false, true);
            tex.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
            tex.Apply();
            RenderTexture.active = prev;
            return tex;
        }
    }
}
