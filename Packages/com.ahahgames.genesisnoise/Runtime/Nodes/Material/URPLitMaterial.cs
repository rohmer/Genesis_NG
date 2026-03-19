using GraphProcessor;

using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

using UnityEditor;

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
        [Input, SerializeField, HideInInspector]
        public List<MaterialTextureSettings> materialTextureSettings = new();

        public override string NodeGroup => "Material";

        [SerializeField, Output]
        public Material material;

        protected override void Enable()
        {
            base.Enable();
            if (material == null)
            {
                Shader urpLit = Shader.Find("Univeral Render Pipeline/Lit");
                if (urpLit == null)
                {
                    Debug.LogWarning("Could not find URP Lit Shader, is URP Installed?");
                    return;
                }
                material = new Material(urpLit);
            }
        }
        [CustomPortBehavior(nameof(materialTextureSettings))]
        IEnumerable<PortData> GetInputPorts(List<SerializableEdge> edges)
        {
            Type displayType = TextureUtils.GetTypeFromDimension(settings.GetResolvedTextureDimension(graph));
            foreach (string port in updateInputs())
            {
                yield return new PortData
                {
                    displayName = port,
                    displayType = displayType,
                    identifier = System.Guid.NewGuid().ToString()
                };
                materialTextureSettings.Add(new MaterialTextureSettings()
                {
                    name = port
                });
            }
        }
        internal List<string> updateInputs()
        {
            materialTextureSettings.Clear();
            List<string> inputs = new();
            MaterialProperty[] properties = MaterialEditor.GetMaterialProperties(new[] { material });

            foreach (var property in properties)
            {
                if ((property.propertyFlags & (ShaderPropertyFlags.HideInInspector | ShaderPropertyFlags.PerRendererData)) != 0)
                    continue;

                int idx = material.shader.FindPropertyIndex(property.name);
                var propertyAttributes = material.shader.GetPropertyAttributes(idx);

                // Retrieve the port view from the property name

                // We only display textures that are excluded from the filteredOutProperties (i.e they are not exposed as ports)
                if (property.propertyType == ShaderPropertyType.Texture)
                {
                    string displayName = property.displayName;
                    displayName = Regex.Replace(displayName, @"_2D|_3D|_Cube", "", RegexOptions.IgnoreCase);
                    inputs.Add(displayName);
                }
            }
            return inputs;
        }
    }
}