using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System;
using System.Collections.Generic;
using System.IO;

using UnityEditor;

using UnityEngine;
using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(Texture2DOutputNode))]
    public class Texture2DOutputNodeView : GenesisNodeView
    {
        protected Texture2DOutputNode outputNode;
        protected GenesisGraph graph;
        List<(Button save, Button update)> buttons = new();

        public override void Enable(bool fromInspector)
        {
            var stylesheet = Resources.Load<StyleSheet>("ExternalOutputNodeView");

            if (styleSheets != null && !styleSheets.Contains(stylesheet))
                styleSheets.Add(stylesheet);
            outputNode = nodeTarget as Texture2DOutputNode;
            graph = owner.graph as GenesisGraph;
            base.Enable(fromInspector);
            if (!fromInspector)
            {
                BuildOutputNodeSettings();
            }
        }

        public void BuildOutputNodeSettings()
        {
            var nodeSettings = new IMGUIContainer(() =>
            {
                if (outputNode.asset == null)
                {
                    EditorGUILayout.HelpBox("This texture has not been saved yet, please click Save As to save the output texture.", MessageType.Info);
                }
                else
                {
                    EditorGUI.BeginDisabledGroup(true);
                    EditorGUILayout.ObjectField("Asset", outputNode.asset, typeof(Texture), false);
                    EditorGUI.EndDisabledGroup();
                }

                EditorGUI.BeginChangeCheck();
                var outputType = EditorGUILayout.EnumPopup("Type", outputNode.external2DOoutputType);
                if (EditorGUI.EndChangeCheck())
                {
                    outputNode.external2DOoutputType = (External2DOutputType)outputType;
                    MarkDirtyRepaint();
                }

                EditorGUI.BeginChangeCheck();
                var outputFileType = EditorGUILayout.EnumPopup("File Type", outputNode.externalFileType);
                if (EditorGUI.EndChangeCheck())
                {
                    outputNode.externalFileType = (ExternalFileType)outputFileType;
                    UpdateButtons();
                    MarkDirtyRepaint();
                }



                outputNode.previewSRGB =
                    outputNode.externalFileType == ExternalFileType.PNG &&
                        (outputNode.external2DOoutputType == External2DOutputType.Color ||
                        outputNode.external2DOoutputType == External2DOutputType.LatLongCubemapColor);

                GUILayout.Space(8);
            }
            );
            nodeSettings.AddToClassList("MaterialInspector");

            controlsContainer.Add(nodeSettings);

            // Add Buttons
            var saveButton = new Button(SaveExternal)
            {
                text = "Save As..."
            };
            var updateButton = new Button(UpdateExternal)
            {
                text = "Update"
            };

            buttons.Add((saveButton, updateButton));

            var horizontal = new VisualElement();
            horizontal.style.flexDirection = FlexDirection.Row;
            horizontal.Add(saveButton);
            horizontal.Add(updateButton);
            controlsContainer.Add(horizontal);
            UpdateButtons();

        }

        void UpdateExternal()
        {
            graph.SaveExternalTexture(nodeTarget as ExternalOutputNode, false);
            UpdateButtons();
        }
        void UpdateButtons()
        {
            foreach (var button in buttons)
            {
                if (button.save == null || button.update == null)
                    continue;


                // Manage First save or Update
                button.save.style.display = DisplayStyle.Flex;
                button.update.style.display = DisplayStyle.Flex;

                bool valid = outputNode.asset != null && (
                    (AssetDatabase.GetAssetPath(outputNode.asset).ToLower().EndsWith("exr") && outputNode.externalFileType == ExternalFileType.EXR)
                    || (AssetDatabase.GetAssetPath(outputNode.asset).ToLower().EndsWith("png") && outputNode.externalFileType == ExternalFileType.PNG));

                button.update.SetEnabled(valid);


            }
        }

        void SaveExternal()
        {
            try
            {
                EditorUtility.DisplayProgressBar("Genesis", "Saving Texture2D...", 0.1f);
                string assetPath;
                if (outputNode.asset != null)
                {
                    assetPath = AssetDatabase.GetAssetPath(outputNode.asset);
                }
                else
                {
                    string extension = "asset";

                    if (outputNode.externalFileType == ExternalFileType.EXR)
                        extension = "exr";
                    else if (outputNode.externalFileType == ExternalFileType.PNG)
                        extension = "png";
                    else if (outputNode.externalFileType == ExternalFileType.TGA)
                        extension = "tga";
                    else
                        throw new NotImplementedException($"File type not handled : '{outputNode.externalFileType}'");

                    assetPath = EditorUtility.SaveFilePanelInProject("Save Texture", outputNode.name, extension, "Save Texture", Path.GetDirectoryName(outputNode.graph.mainAssetPath));

                    if (string.IsNullOrEmpty(assetPath))
                    {
                        EditorUtility.ClearProgressBar();
                        return; // Canceled
                    }

                }

                EditorUtility.DisplayProgressBar("Genesis Noise", $"Writing to {assetPath}...", 0.3f);
                if (!outputNode.exportAlpha)
                {
                    var pixels = (outputNode.Output as Texture2D).GetPixels();
                    for (int i = 0; i < pixels.Length; i++)
                    {
                        var c = pixels[i];
                        c.a = 1f;
                        pixels[i] = c;
                    }
                    (outputNode.Output as Texture2D).SetPixels(pixels);
                    (outputNode.Output as Texture2D).Apply();
                }

                byte[] contents = null;

                if (outputNode.externalFileType == ExternalFileType.EXR)
                    contents = ImageConversion.EncodeToEXR(outputNode.Output as Texture2D);
                else if (outputNode.externalFileType == ExternalFileType.PNG)
                    contents = ImageConversion.EncodeToPNG(outputNode.Output as Texture2D);
                else if (outputNode.externalFileType == ExternalFileType.TGA)
                    contents = ImageConversion.EncodeToTGA(outputNode.Output as Texture2D);
                else
                    throw new NotImplementedException($"File type not handled : '{outputNode.externalFileType}'");

                System.IO.File.WriteAllBytes(System.IO.Path.GetDirectoryName(Application.dataPath) + "/" + assetPath, contents);

                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();

                TextureImporter importer = (TextureImporter)AssetImporter.GetAtPath(assetPath);
                switch (outputNode.external2DOoutputType)
                {
                    case External2DOutputType.Color:
                        importer.textureShape = TextureImporterShape.Texture2D;
                        importer.textureType = TextureImporterType.Default;
                        importer.sRGBTexture = true;
                        importer.alphaSource = outputNode.exportAlpha ? TextureImporterAlphaSource.FromInput : TextureImporterAlphaSource.None;
                        break;
                    case External2DOutputType.Linear:
                        importer.textureShape = TextureImporterShape.Texture2D;
                        importer.textureType = TextureImporterType.Default;
                        importer.sRGBTexture = false;
                        importer.alphaSource = outputNode.exportAlpha ? TextureImporterAlphaSource.FromInput : TextureImporterAlphaSource.None;
                        break;
                    case External2DOutputType.Normal:
                        importer.textureShape = TextureImporterShape.Texture2D;
                        importer.textureType = TextureImporterType.NormalMap;
                        importer.alphaSource = TextureImporterAlphaSource.None;
                        break;
                    case External2DOutputType.LatLongCubemapColor:
                        importer.textureShape = TextureImporterShape.TextureCube;
                        importer.generateCubemap = TextureImporterGenerateCubemap.Cylindrical;
                        importer.sRGBTexture = true;
                        importer.alphaSource = outputNode.exportAlpha ? TextureImporterAlphaSource.FromInput : TextureImporterAlphaSource.None;
                        break;
                    case External2DOutputType.LatLongCubemapLinear:
                        importer.textureShape = TextureImporterShape.TextureCube;
                        importer.generateCubemap = TextureImporterGenerateCubemap.Cylindrical;
                        importer.sRGBTexture = false;
                        importer.alphaSource = outputNode.exportAlpha ? TextureImporterAlphaSource.FromInput : TextureImporterAlphaSource.None;
                        break;
                }
                importer.SaveAndReimport();
                if (outputNode.external2DOoutputType == External2DOutputType.LatLongCubemapColor)
                    outputNode.asset = AssetDatabase.LoadAssetAtPath<Cubemap>(assetPath);
                else
                    outputNode.asset = AssetDatabase.LoadAssetAtPath<Texture2D>(assetPath);
                EditorUtility.DisplayProgressBar("Genesis Noise", $"Importing {assetPath}...", 1.0f);
            }
            finally
            {
                EditorUtility.ClearProgressBar();
            }

            UpdateButtons();

        }
    }
}
