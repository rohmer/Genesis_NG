## Custom Node View ##

Most of the time creating a view is unnecessary, as the default view provided by the base class is sufficient for most nodes. However, if you want to create a custom view for your node, you can create a new class that inherits from `ShaderNodeView`. This class will define

However, if you want to modify the default view, you can create a new class that inherits from `ShaderNodeView` and override the `Initialize` method to customize the layout of the node's properties.

Example of a custom view
```csharp
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
```

In this example, we create a custom view for the `Levels` node that includes a MinMaxSlider for adjusting the luminance remap and a histogram preview of the output texture. The histogram is updated whenever the node's output changes, and the MinMaxSlider is hidden when the node is in automatic mode.

[NodeCustomEditor(typeof(Levels))] - This is required for defining the class this is a custom editor for

```cSharp
public override void Enable(bool fromInspector)
        {
            levelsNode = nodeTarget as Levels;

            base.Enable(fromInspector);
```

The Enable method is called when the node view is created. We first call the base implementation to set up the default view, and then we add our custom UI elements (the MinMaxSlider and the histogram preview) to the controlsContainer.

We also set a levelsNode as a convience function to call the Node class.
base.Enable(fromInspector) must be called before accessing nodeTarget, as it is initialized in the base Enable method.

```cSharp
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
```
In this block we create a slider.  It should be noted the RegisterValueChangedCallback is used to set the actual values on the node

Finally, we add the slider to the controlsContainer, which is a VisualElement that contains all the UI elements for the node view.
