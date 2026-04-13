using GraphProcessor;

using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Inspects values during graph authoring and debugging.
")]

    [System.Serializable, NodeMenuItem("Utility/Debug")]
    public class DebugNode : GenesisNode
    {
        [Input] object Input;

        [SerializeField]
        public string value;

        public override string NodeGroup => "Utility";
        public override string name => "Debug";

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            List<NodePort> ports = this.GetInputPorts();
            NodePort input = ports[0];
            input.PullData();
            if (Input != null)
                value = Input.ToString();
            return base.ProcessNode(cmd);

        }

        public override bool hasPreview => false;
        internal override float processingTime => base.processingTime;

        public void Update()
        {
            List<NodePort> ports = this.GetInputPorts();
            NodePort input = ports[0];
            input.PullData();
        }
    }
}
