using AhahGames.Telemetry;

using System;

using UnityEngine;

namespace AhahGames.GenesisNoise.Nodes
{
    [Serializable]
    public abstract class FixedShaderNode : ShaderNode
    {
        public abstract string ShaderName { get; }
        public abstract bool DisplayMaterialInspector { get; }
        public override Texture previewTexture => output;

        public override void InitializePorts()
        {
            UpdateShaderAndMaterial();
            base.InitializePorts();
        }
        protected override void Enable()
        {
            UpdateShaderAndMaterial();

            base.Enable();
        }



        void UpdateShaderAndMaterial()
        {
            if (shader == null)
            {
                shader = Shader.Find(ShaderName);
            }
            if (material != null && material.shader != shader)
            {
                material.shader = shader;
            }
            if (material == null)
            {
                if (shader == null)
                {
                    TelemetryLogger.Logger.LogError(string.Format("{0} shader could not be found", ShaderName));
                    return;
                }
                material = new Material(shader);
                material.hideFlags = HideFlags.HideInHierarchy | HideFlags.HideInInspector;
            }
        }

        public override bool canProcess
        {
            get
            {
                UpdateShaderAndMaterial();
                return base.canProcess;
            }
        }

    }
}