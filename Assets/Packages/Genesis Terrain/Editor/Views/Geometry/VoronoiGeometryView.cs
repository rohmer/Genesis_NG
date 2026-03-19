namespace AhahGames.GenesisNoise.GNTerrain.Views
{
    using global::AhahGames.GenesisNoise.GNTerrain.Nodes;
    using global::AhahGames.GenesisNoise.Views;

    using GraphProcessor;

    using System;

    using UnityEngine;
    using UnityEngine.UIElements;

    [NodeCustomEditor(typeof(VoronoiGeometryNode))]
    public class VoronoiGeometryNodeView : GenesisNodeView
    {
        VoronoiGeometryNode node => nodeTarget as VoronoiGeometryNode;

        SliderInt relaxNumber;
        Toggle relax;
        Slider relaxStrength;
        Image previewImage;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            // Precreate so we dont get a null
            relaxNumber = new SliderInt("Number of Relaxations", 1, 50);
            relaxStrength = new Slider("Relax iteration strength", 0.01f, 1.0f);

            relax = new Toggle("Use Lloyd's Relaxation");
            relax.value = node.LloydsRelaxation;
            relax.RegisterValueChangedCallback(evt =>
            {
                node.LloydsRelaxation = evt.newValue;
                if (node.LloydsRelaxation)
                {
                    relaxNumber.SetEnabled(true);
                    relaxStrength.SetEnabled(true);
                }
                else
                {
                    relaxNumber.SetEnabled(false);
                    relaxStrength.SetEnabled(false);
                }
                node.GenerateGeometry();
            });
            controlsContainer.Add(relax);

            relaxNumber.value = node.LloydsIterations;
            relaxNumber.SetEnabled(node.LloydsRelaxation);
            relaxNumber.showInputField = true;
            relaxNumber.RegisterValueChangedCallback(e =>
            {
                node.LloydsIterations = e.newValue;
                node.GenerateGeometry();
            });

            relaxStrength.value = node.RelaxationStrength;
            relaxStrength.SetEnabled(node.LloydsRelaxation);
            relaxStrength.RegisterValueChangedCallback(e =>
            {
                node.RelaxationStrength = e.newValue;
                node.GenerateGeometry();
            });
            relaxStrength.showInputField = true;
            controlsContainer.Add(relaxNumber);
            controlsContainer.Add(relaxStrength);


            previewImage = new Image();
            previewImage.image = node.preview;
            previewImage.RegisterCallback<ChangeEvent<Texture2D>>(
                e =>
                {
                    previewImage.image = e.newValue;
                });
            Box b = new Box();
            b.Add(previewImage);
            controlsContainer.Add(b);

        }

    }
}