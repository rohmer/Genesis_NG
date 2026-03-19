using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System.Collections.Generic;

using UnityEditor;


using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(Levels))]
    public class LevelsNodeView : GenesisNodeView
    {
        Levels levelsNode;

        // Workaround to update the sliders we have in the inspector / node
        // When serialization issues are fixed, we could have a drawer for min max and avoid to manually write the UI for it
        List<MinMaxSlider> sliders = new();
        protected VisualElement histogramContainer;

        public override void Enable(bool fromInspector)
        {
            levelsNode = nodeTarget as Levels;

            base.Enable(fromInspector);

            var slider = new MinMaxSlider("Luminance", levelsNode.min, levelsNode.max, 0, 1);
            sliders.Add(slider);
            slider.RegisterValueChangedCallback(e =>
            {
                owner.RegisterCompleteObjectUndo("Changed Luminance remap");
                levelsNode.min = e.newValue.x;
                levelsNode.max = e.newValue.y;
                foreach (var s in sliders)
                    if (s != null && s.parent != null)
                        s.SetValueWithoutNotify(e.newValue);
                NotifyNodeChanged();
            });
            controlsContainer.Add(slider);
            histogramContainer = new VisualElement();
            histogramContainer.AddToClassList("Histogram");
            controlsContainer.Add(histogramContainer);

            var mode = this.Q<EnumField>();

            mode.RegisterValueChangedCallback((m) =>
            {
                UpdateMinMaxSliderVisibility((Levels.Mode)m.newValue);
            });
            UpdateMinMaxSliderVisibility(levelsNode.mode);

            // Compute histogram only when the inspector is selected
            if (fromInspector)
            {
                owner.graph.afterCommandBufferExecuted += UpdateHistogram;
                controlsContainer.RegisterCallback<DetachFromPanelEvent>(e =>
                {
                    owner.graph.afterCommandBufferExecuted -= UpdateHistogram;
                });
            }

            void UpdateHistogram()
            {
                if (levelsNode.output != null)
                {
                    var cmd = CommandBufferPool.Get("Update Histogram");
                    HistogramUtility.ComputeHistogram(cmd, levelsNode.output, levelsNode.histogramData);
                    Graphics.ExecuteCommandBuffer(cmd);
                }
            }

            UpdateHistogram();

            void UpdateMinMaxSliderVisibility(Levels.Mode mode)
            {
                if (mode == Levels.Mode.Automatic)
                    slider.style.display = DisplayStyle.None;
                else
                    slider.style.display = DisplayStyle.Flex;
            }

            if (fromInspector)
            {
                var histogram = new HistogramView(levelsNode.histogramData, owner);
                controlsContainer.Add(histogram);
            }
            else
            {
                // Create our node based editor
                Texture2D texture = new(1, 1);
                texture.Reinitialize(Mathf.RoundToInt(nodeTarget.nodeWidth - 10), 100);
                HistogramUtility.SetupHistogramPreviewMaterial(levelsNode.histogramData);

                histogramContainer.Clear();
                if (levelsNode.histogramData.previewMaterial == null)
                {
                    return;
                }
                float width = nodeTarget.nodeWidth; // force preview in width
                float scaleFactor = width / texture.width;
                float height = Mathf.Min(nodeTarget.nodeWidth, texture.height * scaleFactor);

                EditorGUI.DrawPreviewTexture(contentRect, Texture2D.whiteTexture, levelsNode.histogramData.previewMaterial);
            }
        }
    }
}