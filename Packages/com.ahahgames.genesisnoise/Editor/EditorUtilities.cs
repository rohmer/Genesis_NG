using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Nodes;
using AhahGames.GenesisNoise.Views;

using System.IO;
using System.Linq;

using UnityEditor;

using UnityEngine;
using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise
{
    public static class EditorUtilities
    {
        public static readonly string shaderGraphTexture2DTemplate = "Templates/ShaderGraphTexture2DTemplate";
        public static readonly string shaderGraphTexture3DTemplate = "Templates/ShaderGraphTexture3DTemplate";
        public static readonly string shaderGraphTextureCubeTemplate = "Templates/ShaderGraphTextureCubeTemplate";
        public static readonly string shaderTextTexture2DTemplate = "Templates/ShaderTextTexture2DTemplate";
        public static readonly string shaderTextTexture3DTemplate = "Templates/ShaderTextTexture3DTemplate";
        public static readonly string shaderTextTextureCubeTemplate = "Templates/ShaderTextTextureCubeTemplate";
        public static readonly string computeShaderTemplate = "Templates/ComputeTemplate";

        public static GenesisGraph GetGraphAtPath(string path)
           => AssetDatabase.LoadAllAssetsAtPath(path).FirstOrDefault(o => o is GenesisGraph) as GenesisGraph;

        static string GetCurrentProjectWindowPath()
        {
            string path = "Assets";

            foreach (UnityEngine.Object obj in Selection.GetFiltered(typeof(UnityEngine.Object), SelectionMode.Assets))
            {
                path = AssetDatabase.GetAssetPath(obj);
                if (!string.IsNullOrEmpty(path) && File.Exists(path))
                {
                    path = Path.GetDirectoryName(path);
                    break;
                }
            }

            return path;
        }

        static string GetAssetTemplatePath<T>(string name) where T : Object
            => AssetDatabase.GetAssetPath(Resources.Load<T>(name));

        static string GetGenesisAssetFolderPath(GenesisGraph graph)
        {
            var path = AssetDatabase.GetAssetPath(graph);

            return Path.GetDirectoryName(path) + "/" + Path.GetFileNameWithoutExtension(path);
        }

        static T CopyAssetWithNameFromTemplate<T>(GenesisGraph graph, string name, string templatePath) where T : Object
        {
            var newDirectory = GetGenesisAssetFolderPath(graph);

            if (!Directory.Exists(newDirectory))
                Directory.CreateDirectory(newDirectory);

            var newPath = newDirectory + "/" + name;
            newPath = AssetDatabase.GenerateUniqueAssetPath(newPath);

            AssetDatabase.CopyAsset(templatePath, newPath);

            AssetDatabase.Refresh();

            var asset = AssetDatabase.LoadAssetAtPath<T>(newPath);
            ProjectWindowUtil.ShowCreatedAsset(asset);
            EditorGUIUtility.PingObject(asset);
            return asset;
        }

        public static Shader CreateNewShaderGraph(GenesisGraph graph, string name, OutputDimension dimension)
        {
            name += ".shadergraph";
            // TODO:
            switch (dimension)
            {
                case OutputDimension.Texture2D:
                    return CopyAssetWithNameFromTemplate<Shader>(graph, name, GetAssetTemplatePath<Shader>(shaderGraphTexture2DTemplate));
                case OutputDimension.Texture3D:
                    return CopyAssetWithNameFromTemplate<Shader>(graph, name, GetAssetTemplatePath<Shader>(shaderGraphTexture3DTemplate));
                case OutputDimension.CubeMap:
                    return CopyAssetWithNameFromTemplate<Shader>(graph, name, GetAssetTemplatePath<Shader>(shaderGraphTextureCubeTemplate));
                default:
                    Debug.LogError("Can't find template to create new shader for dimension: " + dimension);
                    return null;
            }
        }

        public static Shader CreateNewShaderText(GenesisGraph graph, string name, OutputDimension dimension)
        {
            name += ".shader";
            switch (dimension)
            {
                case OutputDimension.Texture2D:
                    return CopyAssetWithNameFromTemplate<Shader>(graph, name, GetAssetTemplatePath<Shader>(shaderTextTexture2DTemplate));
                case OutputDimension.Texture3D:
                    return CopyAssetWithNameFromTemplate<Shader>(graph, name, GetAssetTemplatePath<Shader>(shaderTextTexture3DTemplate));
                case OutputDimension.CubeMap:
                    return CopyAssetWithNameFromTemplate<Shader>(graph, name, GetAssetTemplatePath<Shader>(shaderTextTextureCubeTemplate));
                default:
                    Debug.LogError("Can't find template to create new shader for dimension: " + dimension);
                    return null;
            }
        }

        public static ComputeShader CreateComputeShader(GenesisGraph graph, string name)
        {
            name += ".compute";
            return CopyAssetWithNameFromTemplate<ComputeShader>(graph, name, GetAssetTemplatePath<ComputeShader>(computeShaderTemplate));
        }

        internal static Texture2D LoadIcon(string resourceName)
        {
            if (UnityEditorInternal.InternalEditorUtility.HasPro())
            {
                string darkIconPath = Path.GetDirectoryName(resourceName) + "/d_" + Path.GetFileName(resourceName);
                var darkIcon = Resources.Load<Texture2D>(darkIconPath);
                if (darkIcon != null)
                    return darkIcon;
            }

            return Resources.Load<Texture2D>(resourceName);
        }

        static Texture2D _resizeIcon;
        public static Texture2D resizeIcon
        {
            get => _resizeIcon == null ? _resizeIcon = LoadIcon("Icons/resize") : _resizeIcon;
        }

        static Texture2D _closeIcon;
        public static Texture2D closeIcon
        {
            get => _closeIcon == null ? _closeIcon = LoadIcon("Icons/close") : _closeIcon;
        }

        static Texture2D _minimizeIcon;
        public static Texture2D minimizeIcon
        {
            get => _minimizeIcon == null ? _minimizeIcon = LoadIcon("Icons/minimize") : _minimizeIcon;
        }

        static Texture2D _maximizeIcon;
        public static Texture2D maximizeIcon
        {
            get => _maximizeIcon == null ? _maximizeIcon = LoadIcon("Icons/maximize") : _maximizeIcon;
        }

        static Texture2D _windowIcon;
        public static Texture2D windowIcon
        {
            get => _windowIcon == null ? _windowIcon = LoadIcon("Icons/Genesis_32") : _windowIcon;
        }

        static Texture2D _recipeIcon;
        public static Texture2D recipeIcon
        {
            get => _recipeIcon == null ? _recipeIcon = LoadIcon("Icons/recipe") : _recipeIcon;
        }

        static Texture2D _logo;
        public static Texture2D logo
        {
            get => _logo == null ? _logo = LoadIcon("Icons/Genesis_64") : _logo;
        }
        static Texture2D _bugIcon;
        public static Texture2D bugIcon
        {
            get => _bugIcon == null ? _bugIcon = LoadIcon("Icons/Bug") : _bugIcon;
        }

        static Texture2D _pinIcon;
        public static Texture2D pinIcon
        {
            get => _pinIcon == null ? _pinIcon = LoadIcon("Icons/Pin") : _pinIcon;
        }

        static Texture2D _helpIcon;
        public static Texture2D helpIcon
        {
            get => _helpIcon == null ? _helpIcon = LoadIcon("Icons/Help24") : _helpIcon;
        }

        static Texture2D _unpinIcon;
        public static Texture2D unpinIcon
        {
            get => _unpinIcon == null ? _unpinIcon = LoadIcon("Icons/Unpin") : _unpinIcon;
        }

        static Texture2D _compareIcon;
        public static Texture2D compareIcon
        {
            get => _compareIcon == null ? _compareIcon = LoadIcon("Icons/CompareImages") : _compareIcon;
        }

        static Texture2D _fitIcon;
        public static Texture2D fitIcon
        {
            get => _fitIcon == null ? _fitIcon = LoadIcon("Icons/Fit") : _fitIcon;
        }

        static Texture2D _githubIcon;
        public static Texture2D githubIcon
        {
            get => _githubIcon == null ? _githubIcon = LoadIcon("Icons/Github") : _githubIcon;
        }

        static Texture2D _featureRequest;
        public static Texture2D featureRequestIcon
        {
            get => _featureRequest == null ? _featureRequest = LoadIcon("Icons/FeatureRequest") : _featureRequest;
        }

        static Texture2D _documentation;
        public static Texture2D documentationIcon
        {
            get => _documentation == null ? _documentation = LoadIcon("Icons/Documentation") : _documentation;
        }

        static Texture2D _lockOpen;
        public static Texture2D lockOpen
        {
            get => _lockOpen == null ? _lockOpen = LoadIcon("Icons/LockOpened") : _lockOpen;
        }

        static Texture2D _lockClose;
        public static Texture2D lockClose
        {
            get => _lockClose == null ? _lockClose = LoadIcon("Icons/LockClosed") : _lockClose;
        }

        static Texture2D _settings;
        public static Texture2D settingsIcon
        {
            get => _settings == null ? _settings = LoadIcon("Icons/Settings") : _settings;
        }

        static Texture2D _settings24;
        public static Texture2D settingsIcon24
        {
            get => _settings24 == null ? _settings24 = LoadIcon("Icons/Settings24") : _settings24;
        }

        static Texture2D _discordIcon;
        public static Texture2D discordIcon
        {
            get => _discordIcon == null ? _discordIcon = LoadIcon("Icons/Discord") : _discordIcon;
        }

        static Texture2D _assetStoreIcon;
        public static Texture2D assetStoreIcon
        {
            get => _assetStoreIcon == null ? _assetStoreIcon = LoadIcon("Icons/AssetStore") : _assetStoreIcon;
        }

        public static Vector4 GetChannelsMask(PreviewChannels channels)
        {
            return new Vector4(
                (channels & PreviewChannels.R) == 0 ? 0 : 1,
                (channels & PreviewChannels.G) == 0 ? 0 : 1,
                (channels & PreviewChannels.B) == 0 ? 0 : 1,
                (channels & PreviewChannels.A) == 0 ? 0 : 1
                );
        }

        public static void ScheduleAutoHide(VisualElement target, GenesisGraphView view)
        {
            target.schedule.Execute(() =>
            {
                target.visible = float.IsNaN(target.worldBound.x) || target.worldBound.Overlaps(view.worldBound);
            }).Every(16); // refresh the visible for 60hz screens (should not cause problems for higher refresh rates)
        }
    }
}



