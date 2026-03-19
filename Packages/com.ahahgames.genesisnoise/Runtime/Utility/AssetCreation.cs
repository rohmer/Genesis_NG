using AhahGames.GenesisNoise.Graph;

using System.IO;

using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.ProjectWindowCallback;

using UnityEngine;

namespace AhahGames.GenesisNoise.Utility
{
    public class AssetCreation
    {
        public static readonly string Extension = "asset";
        public static readonly string customTextureShaderTemplate = "Templates/CustomTextureShaderTemplate";

        public static readonly string shaderNodeCSharpTemplate = "Templates/FixedShaderNodeTemplate";
        public static readonly string shaderNodeCGTemplate = "Templates/FixedShaderTemplate";
        public static readonly string shaderNodeDefaultName = "GenesisNoiseShaderNode.cs";
        public static readonly string shaderName = "GenesisNoiseShader.shader";
        public static readonly string csharpComputeShaderNodeTemplate = "Templates/CsharpComputeShaderNodeTemplate";
        public static readonly string computeShaderTemplate = "Templates/ComputeShaderTemplate";
        public static readonly string computeShaderDefaultName = "GenesisNoiseCompute.compute";
        public static readonly string computeShaderNodeDefaultName = "GenesisNoiseCompute.cs";
        public static readonly string cSharpGenesisNoiseNodeTemplate = "Templates/CSharpGenesisNoiseNodeTemplate";
        public static readonly string cSharpGenesisNoiseNodeName = "New GenesisNoise Node.cs";
        public static readonly string cSharpGenesisNoiseNodeViewTemplate = "Templates/CSharpGenesisNoiseNodeViewTemplate";
        public static readonly string cSharpGenesisNoiseNodeViewName = "New GenesisNoise Node View.cs";
        public static readonly string customMipMapShaderTemplate = "Templates/CustomMipMapTemplate";

        [MenuItem("Assets/Genesis Noise/Noise Graph", false, 150)]
        public static void CreateGenesisNoiseGraph()
        {
            var graphItem = ScriptableObject.CreateInstance<GenesisGraph>();
            /*ProjectWindowUtil.StartNameEditingIfProjectWindowExists(0, graphItem,
                $"Genesis Noise Graph.{Extension}", GenesisNoiseUtility.icon, null);*/
            Selection.selectionChanged += SelectionChanged;
            ProjectWindowUtil.CreateAsset(graphItem, "GenesisNoiseGraph.asset");
            //AssetDatabase.CreateAsset(graphItem, "GenesisNoiseGraph.asset");

            Selection.activeObject = graphItem;

            EditorApplication.delayCall += () => EditorGUIUtility.PingObject(graphItem.mainOutputTexture);

        }

        public static void SelectionChanged()
        {
            EditorGUIUtility.SetIconForObject(Selection.activeObject, EditorUtilities.logo);
            Selection.selectionChanged -= SelectionChanged;
        }

        [OnOpenAsset(0)]
        public static bool OnBaseGraphOpened(int instanceID, int line)
        {
            var asset = EditorUtility.InstanceIDToObject(instanceID) as GenesisGraph;
            if (asset != null)
            {
                var path = AssetDatabase.GetAssetPath(asset);

                var graph = EditorUtilities.GetGraphAtPath(path);
                if (graph == null)
                    return false;
                GenesisMainWindow.Open(graph);
                return true;
            }

            return false;
        }

        abstract class GenesisGraphAction : EndNameEditAction
        {
            public abstract GenesisGraph CreateNoiseGraphAsset();

            public override void Action(int instanceId, string pathName, string resourceFile)
            {
                var genesisNoise = CreateNoiseGraphAsset();
                genesisNoise.name = Path.GetFileNameWithoutExtension(pathName);
                genesisNoise.hideFlags = HideFlags.HideInHierarchy;

                AssetDatabase.CreateAsset(genesisNoise, pathName);
                genesisNoise.outputTextures.Clear();
                GenesisGraphProcessor.RunOnce(genesisNoise);
                genesisNoise.SaveAllTextures(false);


                ProjectWindowUtil.ShowCreatedAsset(GenesisNoiseUtility.windowIcon);
                Selection.activeObject = genesisNoise.mainOutputTexture;
                EditorApplication.delayCall += () => EditorGUIUtility.PingObject(genesisNoise.mainOutputTexture);
            }
        }

        class CreateGraphAction : GenesisGraphAction
        {
            public override GenesisGraph CreateNoiseGraphAsset()
            {
                var g = ScriptableObject.CreateInstance<GenesisGraph>();
                g.ClearObjectReferences();

                return g;
            }
        }


    }
}