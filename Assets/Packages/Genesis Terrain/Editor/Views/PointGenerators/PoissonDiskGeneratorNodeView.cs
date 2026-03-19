namespace AhahGames.GenesisNoise.GNTerrain.Views
{
    using global::AhahGames.GenesisNoise.GNTerrain.Nodes;
    using global::AhahGames.GenesisNoise.Views;

    using GraphProcessor;

    using System;

    using UnityEngine;
    using UnityEngine.UIElements;

    [NodeCustomEditor(typeof(PoissonNoisePointGenerationNode))]
    public class PoissonPointGenerationNodeView : GenesisNodeView
    {
        PoissonNoisePointGenerationNode pointNode => nodeTarget as PoissonNoisePointGenerationNode;

        IntegerField pointNumField;
        EnumField textureSizeField;
        Image previewImage;
        IntegerField seedField;
        Slider radiusField;
        EnumField noiseField;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            pointNumField = new IntegerField("Number of Points", 6);
            pointNumField.value = pointNode.NumberOfPoints;
            pointNumField.RegisterCallback<ChangeEvent<int>>(e =>
            {
                pointNode.NumberOfPoints = e.newValue;
                previewImage.image = pointNode.pointPreview;
                pointNode.GeneratePoints();
            });
            controlsContainer.Add(pointNumField);

            textureSizeField = new EnumField("Terrain Size", eTerrainSize.x4096);
            textureSizeField.RegisterCallback<ChangeEvent<Enum>>(e =>
            {
                pointNode.TerrainSize = (eTerrainSize)e.newValue;
                pointNode.GeneratePoints();
                previewImage.image = pointNode.pointPreview;
                previewImage.MarkDirtyRepaint();
            });
            controlsContainer.Add(textureSizeField);

            noiseField = new EnumField("Noise Function", eNoiseFunction.FBM);
            noiseField.RegisterCallback<ChangeEvent<Enum>>(e =>
            {
                pointNode.NoiseFunction = (eNoiseFunction)e.newValue;
                pointNode.GeneratePoints();
                previewImage.image = pointNode.pointPreview;
                previewImage.MarkDirtyRepaint();
            });
            controlsContainer.Add(noiseField);

            radiusField = new Slider("Radius", 2.5f, Mathf.Sqrt(pointNode.Output.GetSize()));
            radiusField.showInputField = true;
            radiusField.RegisterCallback<ChangeEvent<float>>(e =>
            {
                pointNode.Radius = e.newValue;
                pointNode.GeneratePoints();
                previewImage.image = pointNode.pointPreview;
                previewImage.MarkDirtyRepaint();
            });

            controlsContainer.Add(radiusField);
            previewImage = new Image();
            previewImage.image = pointNode.pointPreview;
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