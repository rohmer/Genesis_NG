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
    [NodeCustomEditor(typeof(URPLitMaterial))]
    public class URPLitMaterialNodeView : GenesisNodeView
    {
        URPLitMaterial node => nodeTarget as URPLitMaterial;

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

            
            // Surface Inputs
            var sFold = new Foldout() { text = "Surface Inputs", value = false };
            ColorField bColor = new ColorField("Base Color");
            bColor.value = node.baseColor;
            bColor.RegisterValueChangedCallback(
                e =>
                {
                    node.baseColor = node.color;
                    node.Render();
                });
            sFold.Add(bColor);

            Slider metallic = new Slider("Metallic", 0f, 1f);
            metallic.value = node.metallicAmount;
            metallic.showInputField = true;
            metallic.RegisterValueChangedCallback(
                e =>
                {
                    node.metallicAmount = metallic.value;
                    node.Render();
                });
            sFold.Add(metallic);

            Slider smooth = new Slider("Smoothness", 0f, 1f);
            smooth.value = node.smoothnessAmount;
            smooth.showInputField = true;
            smooth.RegisterValueChangedCallback(
                e =>
                {
                    node.smoothnessAmount = smooth.value;
                    node.Render();
                });
            sFold.Add(smooth);

            Toggle emission = new Toggle("Emission");
            emission.value = node.useEmission;
            emission.RegisterValueChangedCallback(
                e =>
                {
                    node.useEmission = emission.value;
                    node.Render();
                    if (emission.value)
                        eColor.enabledSelf = true;
                    else
                        eColor.enabledSelf= false;
                });
            sFold.Add(emission);

            eColor = new ColorField("Emission Color");
            if (!emission.value)
                eColor.enabledSelf = false;
            else
                eColor.enabledSelf = true;
            eColor.value = node.emissionColor;
            eColor.RegisterValueChangedCallback(
                e =>
                {
                    node.emissionColor = eColor.value;
                    node.Render();
                });
            sFold.Add(eColor);

            Vector2Field tiling = new Vector2Field("Tiling");
            tiling.value = node.tiling;
            tiling.RegisterValueChangedCallback(
                e =>
                {
                    node.tiling = tiling.value;
                    node.Render();
                });
            sFold.Add(tiling);

            Vector2Field offset = new Vector2Field("Offset");
            offset.value = node.offset;
            offset.RegisterValueChangedCallback(
                e =>
                {
                    node.offset = offset.value;
                    node.Render();
                });
            sFold.Add(offset);
            controlsContainer.Add(sFold);

            // Detail options
            Foldout dFold = new Foldout() { text = "Detail Inputs", value = false };
            Vector2Field dTiling = new Vector2Field("Tiling");
            dTiling.value = node.tiling;
            dTiling.RegisterValueChangedCallback(
                e =>
                {
                    node.detailTiling = dTiling.value;
                    node.Render();
                });
            dFold.Add(dTiling);

            Vector2Field doffset = new Vector2Field("Offset");
            doffset.value = node.detailOffset;
            offset.RegisterValueChangedCallback(
                e =>
                {
                    node.detailOffset = doffset.value;
                    node.Render();
                });
            dFold.Add(doffset);
            controlsContainer.Add(dFold);

            
        }
    }
}