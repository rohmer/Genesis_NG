using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System;
using System.Collections.Generic;
using System.Linq;

namespace AhahGames.GenesisNoise.Views
{
    public static class HelpTools
    {
        public static string GenerateHelpText(GenesisNode node)
        {
            string text = string.Empty;
            if (node == null)
            {
                return "<color=red><b>Node is <u>null</u>, this should never happen</b></color>";
            }
            text += string.Format("<b>Node Type</b>: {0}\n\n", node.name);
            text += string.Format("<b>Node Group</b>: {0}\n", node.NodeGroup);

            text += string.Format("<b>Description</b>: {0}", HelpTools.GetDocumentation(node.GetType()));

            text += "\n" + GetPortDoc(node);
            return text;
        }

        public static string GetDocumentation(Type targetType)
        {
            var docAttr = targetType
                .GetCustomAttributes(inherit: false)
                .OfType<DocumentationAttribute>()
                .FirstOrDefault();

            return docAttr?.markdown;
        }

        public static string GetPortDoc(GenesisNode node)
        {
            string portDoc = string.Empty;
            portDoc += "<b>Ports:</b>\n";


            List<NodePort> ports = node.GetInputPorts().ToList();
            portDoc += "  <b>Input</b>:\n";
            foreach (var port in ports)
            {
                string portInfo = string.Format("    <b>Port Name</b>: {0}\n", port.portData.displayName);
                portInfo += string.Format("    <b>Type</b>: {0}\n", port.portData.displayType.Name);
                portInfo += string.Format("    <b>Accept Multiple</b>: {0}\n", port.portData.acceptMultipleEdges);
                if (port.portData.tooltip != null)
                    portInfo += string.Format("    <b>Tooltip</b>: {0}\n", port.portData.tooltip);
                portDoc += portInfo + "\n";

            }

            ports = node.GetOutputPorts().ToList();
            portDoc += "  <b>Output</b>:\n";
            foreach (var port in ports)
            {
                string portInfo = string.Format("    <b>Port Name</b>: {0}\n", port.portData.displayName);
                portInfo += string.Format("    <b>Type</b>: {0}\n", port.portData.displayType.Name);
                portInfo += string.Format("    <b>Accept Multiple</b>: {0}\n", port.portData.acceptMultipleEdges);
                if (port.portData.tooltip != null)
                    portInfo += string.Format("    <b>Tooltip</b>: {0}\n", port.portData.tooltip);
                portDoc += portInfo + "\n";

            }



            return portDoc;
        }
    }
}