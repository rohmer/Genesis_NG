using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Views
{
    [NodeCustomEditor(typeof(RandomPointInSphereNode))]
    public class RandomPointInSphereNodeView : GenesisNodeView
    {
        RandomPointInSphereNode node => nodeTarget as RandomPointInSphereNode;
        Vector3Field p1;
        FloatField radius;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            nodeTarget.onProcessed += UpdateLabel;
            onPortConnected += (p) => UpdateLabel();
            onPortDisconnected += (p) => UpdateLabel();

            node.Process();
            p1 = new Vector3Field("Center");
            radius = new FloatField("Radius");
            p1.RegisterValueChangedCallback(evt =>
            {
                node.pt1 = evt.newValue;
                node.Process();
                NotifyNodeChanged();
            });
            p1.Q<Label>().style.minWidth = 25;

            radius.RegisterValueChangedCallback(evt =>
            {
                node.radius = evt.newValue;
                node.Process();
                NotifyNodeChanged();
            });
            radius.value = node.radius;
            radius.Q<Label>().style.minWidth = 25;
            controlsContainer.Add(p1);
            controlsContainer.Add(radius);


        }

        void UpdateLabel()
        {
            node.Process();
        }
    }
}
