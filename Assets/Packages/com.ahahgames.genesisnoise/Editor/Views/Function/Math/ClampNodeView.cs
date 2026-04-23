using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(ClampNode))]
    public class ClampNodeView : GenesisNodeView
    {
        ClampNode clampNode => nodeTarget as ClampNode;
        DisplayValue displayValue;
        public override void Enable(bool fromInspector)
        {
            onPortConnected += AddNodeWiew_onPortConnected;
            onPortDisconnected += AddNodeWiew_onPortDisconnected;

            base.Enable(fromInspector);
            nodeTarget.Process();
            nodeTarget.onProcessed += UpdateLabel;
            onPortConnected += (p) => UpdateLabel();

            FloatField max = new FloatField("Max");
            max.value= clampNode.max != null ? TypeCaster.ToFloat(clampNode.max) : 0f;
            max.RegisterValueChangedCallback(
                e =>
                {
                    clampNode.max = max.value;
                    clampNode.Process();
                    UpdateLabel();
                });
            controlsContainer.Add(max);
            FloatField min = new FloatField("Min");
            max.value = clampNode.min != null ? TypeCaster.ToFloat(clampNode.min) : 0f;
            max.RegisterValueChangedCallback(
                e =>
                {
                    clampNode.min = min.value;
                    clampNode.Process();
                    UpdateLabel();
                });
            controlsContainer.Add(min);
        }

        private void AddNodeWiew_onPortDisconnected(PortView obj)
        {
          
        }

        private void AddNodeWiew_onPortConnected(PortView obj)
        {
          
        }

        void UpdateLabel()
        {
           
        }
    }
}
