using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System;
using System.ComponentModel;
using System.IO;

using UnityEditor;
using UnityEditor.UIElements;

using UnityEngine;
using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(HDRPLitMaterial))]
    public class HDRPLitMaterialNodeView : GenesisNodeView
    {
        HDRPLitMaterial node => nodeTarget as HDRPLitMaterial;

        EnumField workflow, surfaceType;
        Toggle shadows, clipping;
        ColorField eColor;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            EnumField preview = new EnumField("Preview Primitive", node.primitiveType);
            preview.RegisterValueChangedCallback(
                e =>
                {
                    node.primitiveType = (PrimitiveType)preview.value;
                    node.Render();
                });
            controlsContainer.Add(preview);

            var foldout = new Foldout { text = "Surface Options", value = false };

            ColorField baseColor = new ColorField("Base Color");
            baseColor.value = node.baseColor;
            baseColor.RegisterValueChangedCallback(
                e =>
                {
                    node.baseColor = baseColor.value;
                    node.Render();
                });
            foldout.Add(baseColor);

            Slider metallic = new Slider("Metallic", 0f, 1f);
            metallic.value = node.metallicAmount;
            metallic.showInputField = true;
            metallic.RegisterValueChangedCallback(
                e =>
                {
                    node.metallicAmount = metallic.value;
                    node.Render();
                });
            foldout.Add(metallic);

            Slider smooth = new Slider("Smoothness", 0f, 1f);
            smooth.value = node.smoothnessAmount;
            smooth.showInputField = true;
            smooth.RegisterValueChangedCallback(
                e =>
                {
                    node.smoothnessAmount = smooth.value;
                    node.Render();
                });
            foldout.Add(smooth);
            
            Slider normal = new Slider("Normal Intensity", 0, 8f);
            normal.value = node.normalAmount;
            normal.showInputField = true;
            normal.RegisterValueChangedCallback(
                e =>
                {
                    node.normalAmount = normal.value;
                    node.Render();
                });
            foldout.Add(normal);

            ColorField emis = new ColorField("Emission Color");
            emis.value = node.emissionColor;
            emis.RegisterValueChangedCallback(
                e =>
                {
                    node.emissionColor = emis.value;
                    node.Render();
                });
            foldout.Add(emis);

            
            controlsContainer.Add(foldout);
        }
    }
}