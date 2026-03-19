namespace AhahGames.GenesisNoise.GNTerrain.Views
{
    using global::AhahGames.GenesisNoise.Views;

    using GraphProcessor;

    using Unity.Mathematics;
    using Unity.VisualScripting.YamlDotNet.RepresentationModel;

    using UnityEditor;
    using UnityEditor.Search;

    using UnityEngine;
    using UnityEngine.UIElements;

    [NodeCustomEditor(typeof(BiomeTextureSet))]
    public class BiomeTextureSetView : GenesisNodeView
    {
        BiomeTextureSet node => nodeTarget as BiomeTextureSet;

        ObjectField diffuse, normal, height, smoothness, ao;
        Toggle invertSmoo;

        void setTextureReadable(Texture2D texture, bool isReadable)
        {
            if (texture == null) return;

            string assetPath = AssetDatabase.GetAssetPath(texture);
            TextureImporter importer = AssetImporter.GetAtPath(assetPath) as TextureImporter;

            if (importer != null)
            {
                importer.isReadable = isReadable;
                AssetDatabase.ImportAsset(assetPath);
                AssetDatabase.Refresh();
            }
        }

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);

            diffuse = new ObjectField("Diffuse");
            diffuse.value = node.diffuseTexture;
            diffuse.objectType = typeof(Texture2D);
            diffuse.RegisterValueChangedCallback(e =>
            {
                setTextureReadable(e.newValue as Texture2D, true);
                node.diffuseTexture = (Texture2D)e.newValue;
            });
            controlsContainer.Add(diffuse);

            normal = new ObjectField("Normal");
            normal.value = node.normalTexture;
            normal.objectType = typeof(Texture2D);
            normal.RegisterValueChangedCallback(e =>
            {
                setTextureReadable(e.newValue as Texture2D, true);
                node.normalTexture = (Texture2D)e.newValue;
            });
            controlsContainer.Add(normal);

            height = new ObjectField("Height");
            height.value = node.heightTexture;
            height.objectType = typeof(Texture2D);
            height.RegisterValueChangedCallback(e =>
            {
                setTextureReadable(e.newValue as Texture2D, true);
                node.heightTexture= (Texture2D)e.newValue;
            });
            controlsContainer.Add(height);

            smoothness = new ObjectField("Smoothness");
            smoothness.value = node.smoothnessTexture;
            smoothness.objectType = typeof(Texture2D);
            smoothness.RegisterValueChangedCallback(e =>
            {
                setTextureReadable(e.newValue as Texture2D, true);
                node.smoothnessTexture = (Texture2D)e.newValue;
            });
            controlsContainer.Add(smoothness);

            invertSmoo = new Toggle("Invert Smoothness");
            invertSmoo.value = node.invertSmoothness;
            invertSmoo.RegisterValueChangedCallback(e =>
            {
                node.invertSmoothness = (bool)e.newValue;
                node.processSmoothness();
            });
            controlsContainer.Add(invertSmoo);

            ao = new ObjectField("Ambient Occulsion");
            ao.value = node.aoTexture;
            ao.objectType = typeof(Texture2D);
            ao.RegisterValueChangedCallback(e =>
            {
                setTextureReadable(e.newValue as Texture2D, true);
                node.aoTexture = (Texture2D)e.newValue;
            });
            controlsContainer.Add(ao);

        }
    }
}
