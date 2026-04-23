using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System;
using System.Collections.Generic;

using UnityEditor;

using UnityEngine;
using UnityEngine.UIElements;

using Object = UnityEngine.Object;

namespace AhahGames.GenesisNoise.Editor
{
    [InitializeOnLoad]
    class GenesisSmallIconRenderer
    {
        static Dictionary<string, GenesisGraph> genesisAssets = new();

        static GenesisSmallIconRenderer() => EditorApplication.projectWindowItemOnGUI += DrawSmallIcon;

        static void DrawSmallIcon(string assetGUID, Rect rect)
        {
            if (rect.height != 16)
                return;
            GenesisGraph graph;
            if (genesisAssets.TryGetValue(assetGUID, out graph))
            {
                if (graph.mainOutputTexture == null)
                    return;
                DrawSmallIcon(rect, graph, Selection.Contains(graph.mainOutputTexture));
                return;
            }
            string assetPath = AssetDatabase.GUIDToAssetPath(assetGUID);
            var texture = AssetDatabase.LoadAssetAtPath<Texture>(assetPath);
            if (texture == null)
                return;
            graph = EditorUtilities.GetGraphAtPath(assetPath);
            if (graph != null)
            {
                genesisAssets.Add(assetGUID, graph);
                DrawSmallIcon(rect, graph, Selection.Contains(texture));
            }
        }
        static void DrawSmallIcon(Rect rect, GenesisGraph graph, bool focused)
            => DrawSmallIcon(rect, GenesisNoiseUtility.icon32, focused);

        static void DrawSmallIcon(Rect rect, Texture2D mixtureIcon, bool focused)
        {
            Rect clearRect = new(rect.x, rect.y, 20, 16);
            Rect iconRect = new(rect.x + 2, rect.y + 1, 14, 14);

            // TODO: find a way to detect the focus of the project window instantaneously (probably with reflection from the project window)
            bool windowFocused = false; //EditorWindow.focusedWindow.GetType().Name.Contains("ProjectBrowser");
            focused = false;

            // Draw a quad of the color of the background
            Color backgroundColor;
            if (EditorGUIUtility.isProSkin)
                backgroundColor = focused ? windowFocused ? new Color32(44, 93, 135, 255) : new Color32(72, 72, 72, 255) : new Color32(56, 56, 56, 255);
            else
                backgroundColor = focused ? windowFocused ? new Color32(62, 125, 231, 255) : new Color32(143, 143, 143, 255) : new Color32(194, 194, 194, 255);

            EditorGUI.DrawRect(clearRect, backgroundColor);
            GUI.DrawTexture(iconRect, mixtureIcon);
        }
    }

    abstract class GenesisNoiseEditor : UnityEditor.Editor
    {
        protected abstract string defaultTextureEditorTypeName { get; }
        protected UnityEditor.Editor defaultTextureEditor;
        protected GenesisGraph graph;
        protected VisualElement root;
        protected VisualElement parameters;

        protected ExposedParameterFieldFactory exposedParameterFactory;

        protected virtual void OnEnable()
        {
            // Load the mixture graph:
            graph = EditorUtilities.GetGraphAtPath(AssetDatabase.GetAssetPath(target));

            if (graph != null)
            {
                exposedParameterFactory = new ExposedParameterFieldFactory(graph);
                graph.onExposedParameterListChanged += UpdateExposedParameters;
                graph.onExposedParameterModified += UpdateExposedParameters;
                Undo.undoRedoPerformed += UpdateExposedParameters;
            }

            CreateDefaultTextureEditor();
        }

        void CreateDefaultTextureEditor()
        {
            foreach (var assembly in AppDomain.CurrentDomain.GetAssemblies())
            {
                var editorType = assembly.GetType(defaultTextureEditorTypeName);
                if (editorType != null)
                {
                    UnityEditor.Editor.CreateCachedEditor(targets, editorType, ref defaultTextureEditor);
                    return;
                }
            }

            throw new Exception($"Cannot load default texture editor: {defaultTextureEditorTypeName}");
        }

        protected virtual void OnDisable()
        {
            if (graph != null)
            {
                graph.onExposedParameterListChanged -= UpdateExposedParameters;
                graph.onExposedParameterModified -= UpdateExposedParameters;
                Undo.undoRedoPerformed -= UpdateExposedParameters;
                exposedParameterFactory.Dispose();
                exposedParameterFactory = null;
            }

            if (defaultTextureEditor != null)
                DestroyImmediate(defaultTextureEditor);

        }
        // This block of functions allow us to use the default behavior of the texture inspector instead of re-writing
        // the preview / static icon code for each texture type, we use the one from the default texture inspector.
        UnityEditor.Editor GetPreviewEditor() => defaultTextureEditor;
        public override string GetInfoString() => GetPreviewEditor().GetInfoString();
        public override void ReloadPreviewInstances() => GetPreviewEditor().ReloadPreviewInstances();
        public override bool RequiresConstantRepaint() => GetPreviewEditor().RequiresConstantRepaint();
        public override bool UseDefaultMargins() => GetPreviewEditor().UseDefaultMargins();
        public override void DrawPreview(Rect previewArea) => GetPreviewEditor().DrawPreview(previewArea);
        public override GUIContent GetPreviewTitle() => GetPreviewEditor().GetPreviewTitle();
        public override bool HasPreviewGUI() => GetPreviewEditor().HasPreviewGUI();
        public override void OnInteractivePreviewGUI(Rect r, GUIStyle background) => GetPreviewEditor().OnInteractivePreviewGUI(r, background);
        public override void OnPreviewGUI(Rect r, GUIStyle background) => GetPreviewEditor().OnPreviewGUI(r, background);
        public override void OnPreviewSettings() => GetPreviewEditor().OnPreviewSettings();

        public override VisualElement CreateInspectorGUI()
        {
            if (graph == null)
                return base.CreateInspectorGUI();

            CreateRootElement();


            UpdateExposedParameters(null);
            root.Add(CreateTextureSettingsView());
            root.Add(CreateAdvancedSettingsView());

            return root;
        }

        protected void CreateRootElement()
        {
            root = new VisualElement();

            var styleSheet = Resources.Load<StyleSheet>("GenesisNoiseInspector");
            if (styleSheet != null)
                root.styleSheets.Add(styleSheet);
        }

        protected void UpdateExposedParameters(ExposedParameter param) => UpdateExposedParameters();
        protected void UpdateExposedParameters()
        {
            if (root == null)
                return;

            if (parameters == null || !root.Contains(parameters))
            {
                parameters = new VisualElement() { name = "ExposedParameters" };
                root.Add(parameters);
            }

            parameters.Clear();

            bool header = true;
            bool showUpdateButton = false;
            foreach (var param in graph.exposedParameters)
            {
                if (param.settings.isHidden)
                    continue;

                if (header)
                {
                    var headerLabel = new Label("Exposed Parameters");
                    headerLabel.AddToClassList("Header");
                    parameters.Add(headerLabel);
                    header = false;
                    showUpdateButton = true;
                }
                VisualElement prop = new();
                prop.AddToClassList("Indent");
                prop.style.display = DisplayStyle.Flex;
                var p = exposedParameterFactory.GetParameterValueField(param, (newValue) =>
                {
                    param.value = newValue;
                    graph.NotifyExposedParameterValueChanged(param);
                });
                prop.Add(p);
                parameters.Add(prop);
            }

            if (showUpdateButton)
            {
                var updateButton = new Button(() =>
                {
                    GenesisGraphProcessor.RunOnce(graph);
                    graph.SaveAllTextures(false);
                })
                { text = "Update Texture(s)" };
                updateButton.AddToClassList("Indent");
                updateButton.AddToClassList("UpdateTextureButton");
                parameters.Add(updateButton);
            }
        }

        VisualElement CreateTextureSettingsView()
        {
            var textureSettings = new VisualElement();

            var t = target as Texture;

            var settingsLabel = new Label("Texture Settings");
            settingsLabel.AddToClassList("Header");
            textureSettings.Add(settingsLabel);

            var settings = new VisualElement();
            settings.AddToClassList("Indent");
            textureSettings.Add(settings);

            var wrapMode = new EnumField("Wrap Mode", t.wrapMode);
            wrapMode.RegisterValueChangedCallback(e =>
            {
                Undo.RegisterCompleteObjectUndo(t, "Changed wrap mode");
                t.wrapMode = (TextureWrapMode)e.newValue;
                graph.settings.wrapMode = (OutputWrapMode)t.wrapMode;
            });
            settings.Add(wrapMode);

            var filterMode = new EnumField("Filter Mode", t.filterMode);
            filterMode.RegisterValueChangedCallback(e =>
            {
                Undo.RegisterCompleteObjectUndo(t, "Changed filter mode");
                t.filterMode = (FilterMode)e.newValue;
                graph.settings.filterMode = (OutputFilterMode)t.filterMode;
            });
            settings.Add(filterMode);

            var aniso = new SliderInt("Aniso Level", 1, 9);
            aniso.RegisterValueChangedCallback(e =>
            {
                Undo.RegisterCompleteObjectUndo(t, "Changed aniso level");
                t.anisoLevel = e.newValue;
            });
            settings.Add(aniso);

            return textureSettings;
        }

        VisualElement CreateAdvancedSettingsView()
        {
            var advanced = new VisualElement();
            var container = new VisualElement();
            container.AddToClassList("Indent");

            var advancedLabel = new Label("Advanced Settings");
            advancedLabel.AddToClassList("Header");
            advanced.Add(advancedLabel);

            advanced.Add(container);

            return advanced;
        }
        public override Texture2D RenderStaticPreview(string assetPath, Object[] subAssets, int width, int height)
        {
            // If the CRT is not a realtime mixture, then we display the default inspector
            if (defaultTextureEditor == null)
            {
                Debug.LogError("Can't generate static preview for asset " + target);
                return base.RenderStaticPreview(assetPath, subAssets, width, height);
            }

            var defaultPreview = defaultTextureEditor.RenderStaticPreview(assetPath, subAssets, width, height);

            if (graph == null)
                return defaultPreview;


            Texture2D genesisIcon = GenesisNoiseUtility.icon32;

            float scaleFactor = Mathf.Max(genesisIcon.width / (float)defaultPreview.width, 1) * 2.5f;
            for (int x = 0; x < width / 2.5f; x++)
                for (int y = 0; y < height / 2.5f; y++)
                {
                    var iconColor = genesisIcon.GetPixel((int)(x * scaleFactor), (int)(y * scaleFactor));
                    var color = Color.Lerp(defaultPreview.GetPixel(x, y), iconColor, iconColor.a);
                    defaultPreview.SetPixel(x, y, color);
                }

            defaultPreview.Apply();

            return defaultPreview;
        }

        // By default textures don't have any CustomEditors so we can define them for Genesis
        [CustomEditor(typeof(Texture2D), false)]
        class GenesisInspectorTexture2D : GenesisNoiseEditor
        {
            protected override string defaultTextureEditorTypeName => "UnityEditor.TextureInspector";
        }



    }
}