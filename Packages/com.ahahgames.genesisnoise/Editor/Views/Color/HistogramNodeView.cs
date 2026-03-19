using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System.Collections.Generic;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(HistogramNode))]
    public class HistogramNodeView : GenesisNodeView
    {
        HistogramNode targetNode;

        List<MinMaxSlider> sliders = new();

        public override void Enable(bool fromInspector)
        {
            targetNode = nodeTarget as HistogramNode;

            base.Enable(fromInspector);

            var slider = new MinMaxSlider("Luminance", targetNode.min, targetNode.max, 0, 1);
            sliders.Add(slider);
            slider.RegisterValueChangedCallback(e =>
            {
                owner.RegisterCompleteObjectUndo("Changed Luminance remap");
                targetNode.min = e.newValue.x;
                targetNode.max = e.newValue.y;
                foreach (var s in sliders)
                    if (s != null && s.parent != null)
                        s.SetValueWithoutNotify(e.newValue);
                NotifyNodeChanged();
            });
            controlsContainer.Add(slider);


        }
    }
}