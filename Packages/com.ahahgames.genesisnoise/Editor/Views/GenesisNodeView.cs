using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Nodes;
using AhahGames.GenesisNoise.PropertyDrawers;


using GraphProcessor;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

using UnityEditor;

using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UIElements;


namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(GenesisNode))]
    public class GenesisNodeView : BaseNodeView
    {
        protected VisualElement previewContainer;

        protected new GenesisGraphView owner => base.owner as GenesisGraphView;
        protected new GenesisNode nodeTarget => base.nodeTarget as GenesisNode;

        Dictionary<Material, MaterialProperty[]> previousMaterialProperties = new();
        internal Dictionary<Material, MaterialEditor> materialEditors = new();

        protected virtual string header => string.Empty;
        protected override bool hasSettings => nodeTarget.hasSettings;

        protected GenesisSettingsView settingsView;

        Label processTimeLabel;
        Image pinIcon, helpIcon;
        Texture2D icon = null;
        const string stylesheetName = "GenesisCommon";

        protected override VisualElement CreateSettingsView()
        {
            settingsView = new GenesisSettingsView(nodeTarget.settings, owner);
            settingsView.AddToClassList("RTSettingsView");

            var currentDim = nodeTarget.settings.dimension;
            settingsView.RegisterChangedCallback(() =>
            {
                nodeTarget.OnSettingsChanged();

                // When the dimension is updated, we need to update all the node ports in the graph
                var newDim = nodeTarget.settings.dimension;
                if (currentDim != newDim)
                {
                    // We delay the port refresh to let the settings finish it's update 
                    schedule.Execute(() =>
                    {
                        {
                            // Refresh ports on all the nodes in the graph
                            nodeTarget.UpdateAllPortsLocal();
                            RefreshPorts();
                        }
                    }).ExecuteLater(1);
                    currentDim = newDim;
                }
            });

            return settingsView;
        }

        private void setNodeTheme()
        {
            var root = titleContainer;

            //root.style.backgroundColor = nodeTarget.GetThemeColor();
            var title = root.Q("title");
            Label titleLabel = root.Q<Label>("title-label");

            if (icon == null)
            {
                icon = nodeTarget.GetThemeIcon();
                if (icon != null)
                {
                    Image i = new();
                    i.image = icon;
                    title.Insert(0, i);
                }
            }
            Image bg = new();
            bg.image = nodeTarget.GetHeaderGradient();
            bg.StretchToParentSize();
            title.style.backgroundImage = (Texture2D)bg.image;

            title.AddToClassList("NodeTitle");
            title.style.backgroundRepeat = new BackgroundRepeat(Repeat.Repeat, Repeat.Repeat);
            title.style.backgroundSize = BackgroundPropertyHelper.ConvertScaleModeToBackgroundSize(ScaleMode.ScaleToFit);
            Color[] borderColors = nodeTarget.GetBorderColors();
            title.style.backgroundColor = nodeTarget.GetBackgroundColor();
            title.style.backgroundSize = new BackgroundSize(BackgroundSizeType.Cover);
            //root.style.color = Color.yellow; // theme.TitleTextColor;
            root.style.borderBottomColor = borderColors[2];
            root.style.borderTopColor = borderColors[0];
            root.style.borderLeftColor = borderColors[3];
            root.style.borderRightColor = borderColors[1];
            root.style.backgroundPositionX = BackgroundPropertyHelper.ConvertScaleModeToBackgroundPosition(ScaleMode.ScaleToFit);
            root.style.backgroundPositionY = BackgroundPropertyHelper.ConvertScaleModeToBackgroundPosition(ScaleMode.ScaleToFit);
            root.style.backgroundSize = BackgroundPropertyHelper.ConvertScaleModeToBackgroundSize(ScaleMode.ScaleToFit);
            root.style.backgroundRepeat = BackgroundPropertyHelper.ConvertScaleModeToBackgroundRepeat(ScaleMode.ScaleToFit);

        }

        public override void Enable(bool fromInspector)
        {
            var stylesheet = Resources.Load<StyleSheet>(stylesheetName);
            if (!styleSheets.Contains(stylesheet))
                styleSheets.Add(stylesheet);

            nodeTarget.onProcessed += UpdateTexturePreview;

            if (nodeTarget.setPosition)
            {
                this.SetPosition(new Rect(50, 50, 50, 50));
            }
            // Fix the size of the node
            style.width = nodeTarget.nodeWidth;


            controlsContainer.AddToClassList("ControlsContainer");

            if (!String.IsNullOrEmpty(header))
            {
                var title = new Label(header);
                title.AddToClassList("PropertyEditorTitle");
                controlsContainer.Add(title);
            }

            // No preview in the inspector, we display it in the preview
            if (!fromInspector)
            {
                helpIcon = new Image { image = EditorUtilities.helpIcon, scaleMode = ScaleMode.ScaleToFit };
                var helpButton = new Button(() =>
                {
                    showHelp();
                });

                helpButton.Add(helpIcon);
                helpButton.AddToClassList("HelpButton");
                rightTitleContainer.Add(helpButton);

                pinIcon = new Image { image = EditorUtilities.pinIcon, scaleMode = ScaleMode.ScaleToFit };
                var pinButton = new Button(() =>
                {
                    if (nodeTarget.isPinned)
                        UnpinView();
                    else
                        PinView();
                });
                pinButton.Add(pinIcon);
                if (nodeTarget.isPinned)
                    PinView();

                pinButton.AddToClassList("PinButton");
                rightTitleContainer.Add(pinButton);

                previewContainer = new VisualElement();
                previewContainer.AddToClassList("Preview");
                controlsContainer.Add(previewContainer);
                UpdateTexturePreview();
            }

            InitProcessingTimeLabel();

            if (nodeTarget.showDefaultInspector)
                DrawDefaultInspector(fromInspector);
            setNodeTheme();
            //nodeTarget.height = this.layout.height;


        }

        public override void Disable()
        {
            foreach (var materialEditor in materialEditors.Values)
                UnityEngine.Object.DestroyImmediate(materialEditor);
            materialEditors.Clear();
            base.Disable();
        }

        ~GenesisNodeView()
        {
            GenesisPropertyDrawer.UnregisterGraph(owner.graph);
            owner.genesisNodeInspector.RemovePinnedView(this);
        }

        void UpdateTexturePreview()
        {
            nodeTarget.height = this.layout.height;
            if (nodeTarget.hasPreview)
            {
                if (previewContainer != null && previewContainer.childCount == 0 || CheckDimensionChanged())
                    CreateTexturePreview(previewContainer, nodeTarget);
            }
        }

        bool CheckDimensionChanged()
        {
            if (nodeTarget.previewTexture is CustomRenderTexture crt && crt != null)
                return crt.dimension.ToString() != previewContainer.name;
            else if (nodeTarget.previewTexture is Texture2D && previewContainer.name == "Texture2D")
                return true;
            else if (nodeTarget.previewTexture is Texture2DArray && previewContainer.name == "Texture2DArray")
                return true;
            else if (nodeTarget.previewTexture is Texture3D && previewContainer.name == "Texture3D")
                return true;
            else if (nodeTarget.previewTexture is Cubemap && previewContainer.name == "Cubemap")
                return true;
            else
                return false;
        }

        internal bool CheckPropertyChanged(Material material, MaterialProperty[] properties)
        {
            bool propertyChanged = false;
            MaterialProperty[] oldProperties;
            previousMaterialProperties.TryGetValue(material, out oldProperties);

            if (oldProperties != null)
            {
                // Check if shader was changed (new/deleted properties)
                if (properties.Length != oldProperties.Length)
                {
                    propertyChanged = true;
                }
                else
                {
                    for (int i = 0; i < properties.Length; i++)
                    {
                        if (properties[i].propertyType != oldProperties[i].propertyType)
                            propertyChanged = true;
                        if (properties[i].displayName != oldProperties[i].displayName)
                            propertyChanged = true;
                        if (properties[i].propertyFlags != oldProperties[i].propertyFlags)
                            propertyChanged = true;
                        if (properties[i].name != oldProperties[i].name)
                            propertyChanged = true;
                    }
                }
            }

            previousMaterialProperties[material] = MaterialEditor.GetMaterialProperties(new[] { material });

            return propertyChanged;
        }

        // Custom property draw, we don't want things that are connected to an edge or useless like the render queue
        static Regex visibleIfRegex = new(@"VisibleIf\((.*?),(.*)\)");
        protected bool MaterialPropertiesGUI(Material material, bool fromInspector, bool autoLabelWidth = true)
        {
            if (material == null || material.shader == null)
                return false;

            if (autoLabelWidth)
            {
                EditorGUIUtility.wideMode = false;
                EditorGUIUtility.labelWidth = nodeTarget.nodeWidth / 3.0f;
            }

            MaterialProperty[] properties = MaterialEditor.GetMaterialProperties(new[] { material });
            var portViews = GetPortViewsFromFieldName(nameof(ShaderNode.materialInputs));

            MaterialEditor editor;
            if (!materialEditors.TryGetValue(material, out editor))
            {
                foreach (var assembly in AppDomain.CurrentDomain.GetAssemblies())
                {
                    var editorType = assembly.GetType("UnityEditor.MaterialEditor");
                    if (editorType != null)
                    {
                        editor = materialEditors[material] = UnityEditor.Editor.CreateEditor(material, editorType) as MaterialEditor;
                        GenesisPropertyDrawer.RegisterEditor(editor, this, owner.graph);
                        break;
                    }
                }

            }

            bool propertiesChanged = CheckPropertyChanged(material, properties);

            foreach (var property in properties)
            {
                if ((property.propertyFlags & (ShaderPropertyFlags.HideInInspector | ShaderPropertyFlags.PerRendererData)) != 0)
                    continue;

                int idx = material.shader.FindPropertyIndex(property.name);
                var propertyAttributes = material.shader.GetPropertyAttributes(idx);
                if (!fromInspector && propertyAttributes.Contains("ShowInInspector"))
                    continue;

                // Retrieve the port view from the property name
                var portView = portViews?.FirstOrDefault(p => p.portData.identifier == property.name);
                if (portView != null && portView.connected)
                    continue;

                // We only display textures that are excluded from the filteredOutProperties (i.e they are not exposed as ports)
                if (property.propertyType == ShaderPropertyType.Texture && nodeTarget is ShaderNode sn)
                {
                    if (!sn.GetFilterOutProperties().Contains(property.name))
                        continue;
                }


                // TODO: cache to improve the performance of the UI
                var visibleIfAtribute = propertyAttributes.FirstOrDefault(s => s.Contains("VisibleIf"));
                if (!string.IsNullOrEmpty(visibleIfAtribute))
                {
                    var match = visibleIfRegex.Match(visibleIfAtribute);
                    if (match.Success)
                    {
                        string propertyName = match.Groups[1].Value;
                        string[] accpectedValues = match.Groups[2].Value.Split(',');

                        if (material.HasProperty(propertyName))
                        {
                            float f = material.GetFloat(propertyName);

                            bool show = false;
                            foreach (var value in accpectedValues)
                            {
                                float f2;
                                float.TryParse(value, out f2);

                                if (f == f2)
                                    show = true;
                            }

                            if (!show)
                                continue;
                        }
                        else
                            continue;
                    }
                }

                // Hide all the properties that are not supported in the current dimension
                var currentDimension = nodeTarget.settings.GetResolvedTextureDimension(owner.graph);
                string displayName = property.displayName;

                bool is2D = displayName.Contains(GenesisNoiseUtility.texture2DPrefix);
                bool is3D = displayName.Contains(GenesisNoiseUtility.texture3DPrefix);
                bool isCube = displayName.Contains(GenesisNoiseUtility.textureCubePrefix);

                if (is2D || is3D || isCube)
                {
                    if (currentDimension == TextureDimension.Tex2D && !is2D)
                        continue;
                    if (currentDimension == TextureDimension.Tex3D && !is3D)
                        continue;
                    if (currentDimension == TextureDimension.Cube && !isCube)
                        continue;
                    displayName = Regex.Replace(displayName, @"_2D|_3D|_Cube", "", RegexOptions.IgnoreCase);
                }

                // In ShaderGraph we can put [Inspector] in the name of the property to show it only in the inspector and not in the node
                if (property.displayName.ToLower().Contains("[inspector]"))
                {
                    if (fromInspector)
                        displayName = Regex.Replace(property.displayName, @"\[inspector\]\s*", "", RegexOptions.IgnoreCase);
                    else
                        continue;
                }

                float h = editor.GetPropertyHeight(property, displayName);

                // We always display textures on a single line without scale or offset because they are not supported
                if (property.propertyType == ShaderPropertyType.Texture)
                    h = EditorGUIUtility.singleLineHeight;

                Rect r = EditorGUILayout.GetControlRect(true, h);
                if (property.name.Contains("Vector2"))
                    property.vectorValue = (Vector4)EditorGUI.Vector2Field(r, displayName, (Vector2)property.vectorValue);
                else if (property.name.Contains("Vector3"))
                    property.vectorValue = (Vector4)EditorGUI.Vector3Field(r, displayName, (Vector3)property.vectorValue);
                else if (property.propertyType == ShaderPropertyType.Range)
                {
                    if (material.shader.GetPropertyAttributes(idx).Any(a => a.Contains("IntRange")))
                        property.floatValue = EditorGUI.IntSlider(r, displayName, (int)property.floatValue, (int)property.rangeLimits.x, (int)property.rangeLimits.y);
                    else
                        property.floatValue = EditorGUI.Slider(r, displayName, property.floatValue, property.rangeLimits.x, property.rangeLimits.y);
                }
                else if (property.propertyType == ShaderPropertyType.Texture)
                    property.textureValue = (Texture)EditorGUI.ObjectField(r, displayName, property.textureValue, typeof(Texture), false);
                else
                    editor.ShaderProperty(r, property, displayName);
            }

            return propertiesChanged;
        }

        // Custom property draw, we don't want things that are connected to an edge or useless like the render queue
        protected int GetMaterialHash(Material material)
        {
            int hash = 0;

            if (material == null || material.shader == null)
                return hash;

            MaterialProperty[] properties = MaterialEditor.GetMaterialProperties(new[] { material });
            var portViews = GetPortViewsFromFieldName(nameof(ShaderNode.materialInputs));

            foreach (var property in properties)
            {
                if ((property.propertyFlags & (ShaderPropertyFlags.HideInInspector | ShaderPropertyFlags.PerRendererData)) != 0)
                    continue;

                // Retrieve the port view from the property name
                var portView = portViews?.FirstOrDefault(p => p.portData.identifier == property.name);
                if (portView != null && portView.connected)
                    continue;

                switch (property.propertyType)
                {
                    case ShaderPropertyType.Float:
                        hash += property.floatValue.GetHashCode();
                        break;
                    case ShaderPropertyType.Color:
                        hash += property.colorValue.GetHashCode();
                        break;
                    case ShaderPropertyType.Range:
                        hash += property.rangeLimits.GetHashCode();
                        hash += property.floatValue.GetHashCode();
                        break;
                    case ShaderPropertyType.Vector:
                        hash += property.vectorValue.GetHashCode();
                        break;
                    case ShaderPropertyType.Texture:
                        hash += property.textureValue?.GetHashCode() ?? 0;
                        hash += property.textureScaleAndOffset.GetHashCode();
                        hash += property.textureDimension.GetHashCode();
                        break;
                }
            }

            return hash;
        }

        internal void PinView()
        {
            nodeTarget.isPinned = true;
            pinIcon.tintColor = new Color32(245, 127, 23, 255);
            pinIcon.image = EditorUtilities.unpinIcon;
            schedule.Execute(() =>
            {
                owner.genesisNodeInspector.AddPinnedView(this);
            }).ExecuteLater(1);
        }

        internal void UnpinView()
        {
            owner.genesisNodeInspector.RemovePinnedView(this);
            nodeTarget.isPinned = false;
            pinIcon.tintColor = Color.white;
            pinIcon.image = EditorUtilities.pinIcon;
            //pinIcon.transform.rotation = Quaternion.identity;
        }

        protected void CreateTexturePreview(VisualElement previewContainer, GenesisNode node)
        {
            previewContainer.Clear();

            if (node.previewTexture == null)
                return;

            VisualElement texturePreview = new();
            previewContainer.Add(texturePreview);

            CreateTexturePreviewImGUI(texturePreview, node);

            previewContainer.name = node.previewTexture.dimension.ToString();

            Button togglePreviewButton = null;
            togglePreviewButton = new Button(() =>
            {
                nodeTarget.isPreviewCollapsed = !nodeTarget.isPreviewCollapsed;
                UpdatePreviewCollapseState();
            });
            togglePreviewButton.ClearClassList();
            togglePreviewButton.AddToClassList("PreviewToggleButton");
            previewContainer.Add(togglePreviewButton);

            UpdatePreviewCollapseState();

            void UpdatePreviewCollapseState()
            {
                if (!nodeTarget.isPreviewCollapsed)
                {
                    texturePreview.style.display = DisplayStyle.Flex;
                    togglePreviewButton.RemoveFromClassList("Collapsed");
                    nodeTarget.previewVisible = true;
                }
                else
                {
                    texturePreview.style.display = DisplayStyle.None;
                    togglePreviewButton.AddToClassList("Collapsed");
                    nodeTarget.previewVisible = false;
                }
            }
        }

        Rect GetPreviewRect(Texture texture)
        {
            float width = nodeTarget.nodeWidth; // force preview in width
            float scaleFactor = width / texture.width;
            float height = Mathf.Min(nodeTarget.nodeWidth, texture.height * scaleFactor);
            return GUILayoutUtility.GetRect(1, width, 1, height);
        }

        protected virtual void DrawPreviewSettings(Texture texture)
        {
            GUILayout.Space(6);

            if (Event.current.type == EventType.KeyDown)
            {
                if (Event.current.keyCode == KeyCode.Delete)
                    owner.DelayedDeleteSelection();
            }

            using (new GUILayout.HorizontalScope(EditorStyles.toolbar, GUILayout.Height(12)))
                DrawPreviewToolbar(texture);
        }

        protected virtual void DrawPreviewToolbar(Texture texture)
        {
            EditorGUI.BeginChangeCheck();

            bool r = GUILayout.Toggle((nodeTarget.previewMode & PreviewChannels.R) != 0, "R", EditorStyles.toolbarButton);
            bool g = GUILayout.Toggle((nodeTarget.previewMode & PreviewChannels.G) != 0, "G", EditorStyles.toolbarButton);
            bool b = GUILayout.Toggle((nodeTarget.previewMode & PreviewChannels.B) != 0, "B", EditorStyles.toolbarButton);
            bool a = GUILayout.Toggle((nodeTarget.previewMode & PreviewChannels.A) != 0, "A", EditorStyles.toolbarButton);

            if (EditorGUI.EndChangeCheck())
            {
                owner.RegisterCompleteObjectUndo("Updated Preview Masks");
                nodeTarget.previewMode =
                (r ? PreviewChannels.R : 0) |
                (g ? PreviewChannels.G : 0) |
                (b ? PreviewChannels.B : 0) |
                (a ? PreviewChannels.A : 0);
            }

            if (texture.mipmapCount > 1)
            {
                GUILayout.Space(8);

                nodeTarget.previewMip = GUILayout.HorizontalSlider(nodeTarget.previewMip, 0.0f, texture.mipmapCount - 1, GUILayout.Width(64));
                GUILayout.Label($"Mip #{Mathf.RoundToInt(nodeTarget.previewMip)}", EditorStyles.toolbarButton);
            }

            GUILayout.FlexibleSpace();

            if (nodeTarget.canEditPreviewSRGB)
            {
                EditorGUI.BeginChangeCheck();

                bool srgb = GUILayout.Toggle(nodeTarget.previewSRGB, "sRGB", EditorStyles.toolbarButton);

                if (EditorGUI.EndChangeCheck())
                {
                    owner.RegisterCompleteObjectUndo("Updated Preview Masks");
                    nodeTarget.previewSRGB = srgb;
                }
            }

        }

        void DrawTextureInfoHover(Rect previewRect, Texture texture)
        {
            Rect infoRect = previewRect;
            infoRect.yMin += previewRect.height - 24;
            infoRect.height = 20;
            previewRect.yMax -= 4;

            // Check if the mouse is in the graph view rect:
            if (!(EditorWindow.mouseOverWindow is GenesisGraphWindow genesisWindow && genesisWindow.GetCurrentGraph() == owner.graph))
                return;

            // On Hover : Transparent Bar for Preview with information
            if (previewRect.Contains(Event.current.mousePosition) && !infoRect.Contains(Event.current.mousePosition))
            {
                EditorGUI.DrawRect(infoRect, new Color(0, 0, 0, 0.65f));

                infoRect.xMin += 8;

                // Shadow
                GUI.color = Color.white;
                int slices = (texture.dimension == TextureDimension.Cube) ? 6 : TextureUtils.GetSliceCount(texture);
                GUI.Label(infoRect, $"{texture.width}x{texture.height}{(slices > 1 ? "x" + slices.ToString() : "")} - {nodeTarget.settings.GetGraphicsFormat(owner.graph)}", EditorStyles.boldLabel);
            }
        }

        void CreateTexturePreviewImGUI(VisualElement previewContainer, GenesisNode node)
        {
            if (node.showPreviewExposure)
            {
                var previewExposure = new Slider(0, 10)
                {
                    label = "Preview EV100",
                    value = node.previewEV100,
                };
                previewExposure.RegisterValueChangedCallback(e =>
                {
                    node.previewEV100 = e.newValue;
                });
                previewContainer.Add(previewExposure);
            }

            var previewImageSlice = new IMGUIContainer(() =>
            {
                if (node.previewTexture == null)
                    return;

                if (node.previewTexture.dimension == TextureDimension.Tex3D)
                {
                    EditorGUI.BeginChangeCheck();
                    EditorGUIUtility.labelWidth = 70;
                    node.previewSlice = EditorGUILayout.Slider("3D Slice", node.previewSlice, 0, TextureUtils.GetSliceCount(node.previewTexture) - 1);
                    EditorGUIUtility.labelWidth = 0;
                    if (EditorGUI.EndChangeCheck())
                        MarkDirtyRepaint();
                }

                DrawPreviewSettings(node.previewTexture);

                Rect previewRect = GetPreviewRect(node.previewTexture);
                DrawImGUIPreview(node, previewRect, node.previewSlice);

                DrawTextureInfoHover(previewRect, node.previewTexture);
            })
            { name = "ImGUIPreview" };

            EditorUtilities.ScheduleAutoHide(previewContainer, owner);

            previewContainer.Add(previewImageSlice);
        }

        protected Vector2 GetPreviewMousePositionBetween01(Vector2 mousePosition)
        {
            if (nodeTarget.previewTexture == null)
                return Vector2.zero;

            var local = previewContainer.WorldToLocal(mousePosition);

            // Add the padding we have on top of the preview
            local.y -= EditorGUIUtility.singleLineHeight + 13;

            // scale mouse position with preview size:
            float width = nodeTarget.nodeWidth - 8;
            float scaleFactor = width / nodeTarget.previewTexture.width;
            float height = Mathf.Min(width, nodeTarget.previewTexture.height * scaleFactor);
            local.x /= width;
            local.y /= height;

            local.x = Mathf.Clamp01(local.x);
            local.y = Mathf.Clamp01(local.y);

            return local;
        }

        protected virtual void DrawImGUIPreview(GenesisNode node, Rect previewRect, float currentSlice)
        {
            switch (node.previewTexture.dimension)
            {
                case TextureDimension.Tex2D:
                    GenesisNoiseUtility.texture2DPreviewMaterial.SetTexture("_MainTex", node.previewTexture);
                    GenesisNoiseUtility.texture2DPreviewMaterial.SetVector("_Size", new Vector4(node.previewTexture.width, node.previewTexture.height, 1, 1));
                    GenesisNoiseUtility.texture2DPreviewMaterial.SetVector("_Channels", EditorUtilities.GetChannelsMask(nodeTarget.previewMode));
                    GenesisNoiseUtility.texture2DPreviewMaterial.SetFloat("_PreviewMip", nodeTarget.previewMip);
                    GenesisNoiseUtility.texture2DPreviewMaterial.SetFloat("_EV100", nodeTarget.previewEV100);
                    GenesisNoiseUtility.texture2DPreviewMaterial.SetFloat("_IsSRGB", nodeTarget.previewSRGB ? 1 : 0);

                    if (Event.current.type == EventType.Repaint)
                        EditorGUI.DrawPreviewTexture(previewRect, node.previewTexture, GenesisNoiseUtility.texture2DPreviewMaterial, ScaleMode.ScaleToFit, 0, 0);
                    break;
                case TextureDimension.Tex3D:
                    GenesisNoiseUtility.texture3DPreviewMaterial.SetTexture("_Texture3D", node.previewTexture);
                    GenesisNoiseUtility.texture3DPreviewMaterial.SetVector("_Channels", EditorUtilities.GetChannelsMask(nodeTarget.previewMode));
                    GenesisNoiseUtility.texture3DPreviewMaterial.SetFloat("_PreviewMip", nodeTarget.previewMip);
                    GenesisNoiseUtility.texture3DPreviewMaterial.SetFloat("_Depth", currentSlice / nodeTarget.settings.GetResolvedDepth(owner.graph));
                    GenesisNoiseUtility.texture3DPreviewMaterial.SetFloat("_EV100", nodeTarget.previewEV100);
                    GenesisNoiseUtility.texture3DPreviewMaterial.SetFloat("_IsSRGB", nodeTarget.previewSRGB ? 1 : 0);

                    if (Event.current.type == EventType.Repaint)
                        EditorGUI.DrawPreviewTexture(previewRect, Texture2D.whiteTexture, GenesisNoiseUtility.texture3DPreviewMaterial, ScaleMode.ScaleToFit, 0, 0, ColorWriteMask.Red);
                    break;
                case TextureDimension.Cube:
                    GenesisNoiseUtility.textureCubePreviewMaterial.SetTexture("_Cubemap", node.previewTexture);
                    GenesisNoiseUtility.textureCubePreviewMaterial.SetVector("_Channels", EditorUtilities.GetChannelsMask(nodeTarget.previewMode));
                    GenesisNoiseUtility.textureCubePreviewMaterial.SetFloat("_PreviewMip", nodeTarget.previewMip);
                    GenesisNoiseUtility.textureCubePreviewMaterial.SetFloat("_EV100", nodeTarget.previewEV100);
                    GenesisNoiseUtility.textureCubePreviewMaterial.SetFloat("_IsSRGB", nodeTarget.previewSRGB ? 1 : 0);

                    if (Event.current.type == EventType.Repaint)
                        EditorGUI.DrawPreviewTexture(previewRect, Texture2D.whiteTexture, GenesisNoiseUtility.textureCubePreviewMaterial, ScaleMode.ScaleToFit, 0, 0);
                    break;
                default:
                    Debug.LogError(node.previewTexture + " is not a supported type for preview");
                    break;
            }
        }

        private void showHelp()
        {
            /*if (nodeTarget.graph.helpWindow == null)
            {
                nodeTarget.graph.helpWindow = new HelpWindow(this);
                var graphSize = owner.layout;
                Vector2 nodeSize = new Vector2(400, 500);
                float margin = 20f;
                Vector2 position = new Vector2(
                    graphSize.width - nodeSize.x - margin,
                    margin);
                nodeTarget.graph.helpWindow.SetPosition(new Rect(position, nodeSize));
                nodeTarget.graph.helpWindow.HelpObject = nodeTarget;
                owner.AddElement(nodeTarget.graph.helpWindow);
            }
            else
            {
                bool shown = false;
                foreach (var element in owner.graphElements)
                    if (element is HelpWindow)
                        shown = true;
                if (!shown)
                    owner.AddElement(nodeTarget.graph.helpWindow);
                nodeTarget.graph.helpWindow.HelpObject = nodeTarget;
            }*/
        }
        // Fix for CS0070, CS7036, and CS1002 errors in the BuildContextualMenu method
        public override void BuildContextualMenu(ContextualMenuPopulateEvent evt)
        {
            base.BuildContextualMenu(evt);
        }

        void InitProcessingTimeLabel()
        {
            if (processTimeLabel != null)
                return;

            processTimeLabel = new Label();
            processTimeLabel.style.unityTextAlign = TextAnchor.MiddleCenter;

            Add(processTimeLabel);

            schedule.Execute(() =>
            {
                // Update processing time every 200 millis

                float time = nodeTarget.processingTime;
                if (time > 0.1f)
                {
                    processTimeLabel.text = FormatProcessingTime(time);
                    // Color range based on the time:
                    float weight = time / 30; // We consider 30 ms as slow
                    processTimeLabel.style.color = new Color(2.0f * weight, 2.0f * (1 - weight), 0);
                }
            }).Every(200);
        }

        internal virtual string FormatProcessingTime(float time) => time.ToString("F2") + " ms";

        public void RefreshSettingsValues() => settingsView.RefreshSettingsValues();
    }
}
