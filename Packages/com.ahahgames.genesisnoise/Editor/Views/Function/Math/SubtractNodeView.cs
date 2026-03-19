using AhahGames.GenesisNoise.Nodes;
using AhahGames.GenesisNoise.Views;

using GraphProcessor;

using UnityEngine.UIElements;

[NodeCustomEditor(typeof(SubtractNode))]
public class SubtractNodeView : GenesisNodeView
{
    SubtractNode subtractNode => nodeTarget as SubtractNode;
    Label value;
    public override void Enable(bool fromInspector)
    {
        onPortConnected += SubtractNodeWiew_onPortConnected;
        onPortDisconnected += SubtractNodeWiew_onPortDisconnected;

        base.Enable(fromInspector);
        nodeTarget.Process();
        nodeTarget.onProcessed += UpdateLabel;
        onPortConnected += (p) => UpdateLabel();
        onPortDisconnected += (p) => UpdateLabel();
        value = new Label();
        value.RegisterValueChangedCallback(evt =>
        {
            subtractNode.output = evt.newValue;
            NotifyNodeChanged();
        });
        value.SetEnabled(false);

        controlsContainer.Add(value);
    }

    private void SubtractNodeWiew_onPortDisconnected(PortView obj)
    {
        value.SetEnabled(false);
    }

    private void SubtractNodeWiew_onPortConnected(PortView obj)
    {
        subtractNode.Process();
        value.SetEnabled(true);
        if (subtractNode.output != null)
            value.text = subtractNode.output.ToString();
    }

    void UpdateLabel()
    {
        subtractNode.Process();
        value.SetEnabled(true);

        if (subtractNode.output == null)
        {
            value.text = "null";
            return;
        }
        value.text = subtractNode.output.ToString();
    }
}

