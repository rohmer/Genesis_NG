using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(RandomPointInCubeNode))]
    public class RandomPointInCubeNodeView : GenesisNodeView
    {
        RandomPointInCubeNode node => nodeTarget as RandomPointInCubeNode;
        Vector3Field p1, p2;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            nodeTarget.onProcessed += UpdateLabel;
            onPortConnected += (p) => UpdateLabel();
            onPortDisconnected += (p) => UpdateLabel();
            node.Process();

            p1 = new Vector3Field("P1"); p2 = new Vector3Field("P2");
            p1.RegisterValueChangedCallback(evt =>
            {
                node.pt1 = evt.newValue;
                node.Process();
                NotifyNodeChanged();
            });
            p1.Q<Label>().style.minWidth = 25;

            p2.RegisterValueChangedCallback(evt =>
            {
                node.pt2 = evt.newValue;
                node.Process();
                NotifyNodeChanged();
            });
            p2.value = node.pt2;
            p2.Q<Label>().style.minWidth = 25;
            controlsContainer.Add(p1);
            controlsContainer.Add(p2);


        }

        void UpdateLabel()
        {
            node.Process();
        }
    }
}
