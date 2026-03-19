using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System;
using System.IO;

using UnityEditor;
using UnityEditor.UIElements;

using UnityEngine;
using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(ColorizeNode))]
    public class ColorizeNodeView : GenesisNodeView
    {
        ColorizeNode colorizeNode => nodeTarget as ColorizeNode;
        int materialHash = -1;

        ObjectField debugCustomRenderTextureField;
        ObjectField debugShaderField;
        ObjectField debugMaterialField;

        DateTime lastModified;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            if (!fromInspector)
            {
                if (colorizeNode.material != null && !owner.graph.IsObjectInGraph(colorizeNode.material))
                {
                    if (owner.graph.IsExternalSubAsset(colorizeNode.material))
                    {
                        colorizeNode.material = new Material(colorizeNode.material);
                        colorizeNode.material.hideFlags = HideFlags.HideInHierarchy | HideFlags.HideInInspector;
                    }
                    if (colorizeNode.material.shader.name != ShaderNode.DefaultShaderName)
                        owner.graph.AddObjectToGraph(colorizeNode.material);
                }

                if (colorizeNode.shader != null)
                    lastModified = File.GetLastWriteTime(AssetDatabase.GetAssetPath(colorizeNode.shader));
                var lastWriteDetector = schedule.Execute(DetectShaderChanges);
                lastWriteDetector.Every(200);

                InitializeDebug();

                onPortDisconnected += ResetMaterialPropertyToDefault;
            }

            if (colorizeNode.DisplayMaterialInspector)
            {
                Action<bool> safeMaterialGUI = (bool init) =>
                {
                    // Copy fromInspector to avoid having the same value (lambda capture fromInspector pointer)
                    bool f = fromInspector;
                    if (!init)
                        MaterialGUI(f);
                };
                safeMaterialGUI(true);
                var materialIMGUI = new IMGUIContainer(() => safeMaterialGUI(false));

                materialIMGUI.AddToClassList("MaterialInspector");

                EditorUtilities.ScheduleAutoHide(materialIMGUI, owner);

                controlsContainer.Add(materialIMGUI);
            }

            Label colorLabel = new("Color Gradient:");
            controlsContainer.Add(colorLabel);
            var gradientField = new GradientField()
            {
                value = colorizeNode.gradient,
                colorSpace = ColorSpace.Gamma
            };
            gradientField.style.height = 32;
            gradientField.RegisterValueChangedCallback(e =>
            {
                owner.RegisterCompleteObjectUndo("Gradient Updated");
                colorizeNode.gradient = (Gradient)e.newValue;
                NotifyNodeChanged();
                colorizeNode.UpdateTexture();
            });
            controlsContainer.Add(gradientField);
        }

        ~ColorizeNodeView() => onPortDisconnected -= ResetMaterialPropertyToDefault;

        void DetectShaderChanges()
        {
            if (colorizeNode.shader == null)
                return;

            var shaderPath = AssetDatabase.GetAssetPath(colorizeNode.shader);
            var modificationDate = File.GetLastWriteTime(shaderPath);

            if (lastModified != modificationDate)
            {
                schedule.Execute(() =>
                {
                    // Reimport the shader:
                    AssetDatabase.ImportAsset(shaderPath);

                    colorizeNode.ValidateShader();

                    ForceUpdatePorts();
                    NotifyNodeChanged();
                }).ExecuteLater(100);
            }
            lastModified = modificationDate;
        }

        void InitializeDebug()
        {
            colorizeNode.onProcessed += () =>
            {
                debugCustomRenderTextureField.value = colorizeNode.output;
            };

            debugCustomRenderTextureField = new ObjectField("CRT")
            {
                value = colorizeNode.output,
                objectType = typeof(CustomRenderTexture)
            };

            debugShaderField = new ObjectField("Shader")
            {
                value = colorizeNode.shader,
                objectType = typeof(Shader)
            };

            debugContainer.Add(debugCustomRenderTextureField);
            debugContainer.Add(debugShaderField);
        }

        void MaterialGUI(bool fromInspector)
        {
            if (colorizeNode.material == null)
                return;

            if (materialHash != -1 && materialHash != GetMaterialHash(colorizeNode.material))
                NotifyNodeChanged();
            materialHash = GetMaterialHash(colorizeNode.material);

            // Update the GUI when shader is modified
            if (MaterialPropertiesGUI(colorizeNode.material, fromInspector))
            {
                // ForceUpdatePorts might affect the VisualElement hierarchy, thus it can't be called from an ImGUI context
                schedule.Execute(() =>
                {
                    colorizeNode.ValidateShader();
                    ForceUpdatePorts();
                }).ExecuteLater(1);
            }
        }

        void ResetMaterialPropertyToDefault(PortView pv)
        {
            foreach (var p in colorizeNode.ListMaterialProperties(null))
            {
                if (pv.portData.identifier == p.identifier)
                    colorizeNode.ResetMaterialPropertyToDefault(colorizeNode.material, p.identifier);
            }
        }

        public override void BuildContextualMenu(ContextualMenuPopulateEvent evt)
        {
            base.BuildContextualMenu(evt);

            if (colorizeNode.shader != null)
            {
                evt.menu.InsertAction(2, "📜 Open Shader Code", (e) =>
                {
                    AssetDatabase.OpenAsset(colorizeNode.shader);
                });
            }
        }

        public override void OnRemoved()
        {
            if (colorizeNode.material != null)
                owner.graph.RemoveObjectFromGraph(colorizeNode.material);
        }
    }

}