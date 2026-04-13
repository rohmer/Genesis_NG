using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using Markdig;

using Markdown;

using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.Runtime.Utility
{
    public class NodeDocumentor : EditorWindow
    {
        private static GenesisGraphWindow graphWindow;
        private static GenesisGraph graph;
        private static int _frameCount = 0;
        static GenesisNode node;
        static readonly string nodeDocDir = "E:\\Docs\\Nodes";
        static readonly string typeDocDir = "E:\\Docs\\Types";
        static bool created = false, captured = false;
        static IDictionary<string, List<GenesisNode>> groups = new Dictionary<string, List<GenesisNode>>();
        static List<Type> nodeTypes = new();
        static int ntp = 0;
        static IList<GenesisNode> nodes = new List<GenesisNode>();
        static Dictionary<string, Type> ioTypes = new();
        static Dictionary<string, string> shaderSources = new Dictionary<string, string>();

        [MenuItem("Tools/Genesis Documentation")]
        public static void DocumentNodes()
        {
            graph = ScriptableObject.CreateInstance<GenesisGraph>();
            graph.ClearObjectReferences();
            graph.name = "Documentor";
            //graph.hideFlags = HideFlags.HideInHierarchy;

            // Load all of the shaders
            string[] shaderFiles=Directory.GetFiles(".", "*.shader", SearchOption.AllDirectories);
            foreach(string shaderFile in shaderFiles)
            {
                string shaderSource=System.IO.File.ReadAllText(shaderFile);
                string[] lines = shaderSource.Split(new[] { Environment.NewLine }, StringSplitOptions.None);
                string shaderName = "";
                foreach(string line in lines)
                {
                    if (line.Contains("Shader \""))
                    {
                        shaderName = line.Split("\"")[1];
                        break;
                    }
                }
                if(!String.IsNullOrEmpty(shaderName))
                {
                    shaderSources[shaderName]= shaderSource;
                }
            }
            
            nodeTypes = GetNodes();

            foreach (var type in nodeTypes)
            {
                GenesisNode n = (GenesisNode)Activator.CreateInstance(type);
                n.OnNodeCreated();
                try
                {
                    graph.AddNode(n);
                    if (!string.IsNullOrEmpty(n.NodeGroup))
                    {
                        if (!groups.ContainsKey(n.NodeGroup))
                            groups[n.NodeGroup] = new List<GenesisNode>();
                        groups[n.NodeGroup].Add(n);
                        nodes.Add(n);
                    }
                } catch(Exception)
                {

                }
            }
            nodes = nodes.OrderBy(x => x.name).ToList();
            groups = groups.OrderBy(x => x.Key).ToDictionary(x => x.Key, x => x.Value);

            saveImage(nodeDocDir,graph, nodes[0]);
            foreach (GenesisNode n in nodes)
            {
                createDocFile(System.IO.Path.Combine(nodeDocDir, string.Format("{0}.html", n.name.Replace(" ", ""))), n);                
            }

            foreach (var t in ioTypes)
            {
                generateTypeFile(t.Key, t.Value);
            }

            foreach(var t in groups)
            {
                writeGroupPage(nodeDocDir, t.Key, t.Value);                
            }
        }

        private static void saveImage(string docDir, GenesisGraph graph, GenesisNode node)
        {
            string name = node.name;
            name.Replace(" ", "");
            name+= ".png";
            string png = System.IO.Path.Combine(docDir, name);
            Debug.LogError(png);
            NodeSnapshotUtility.DisplayNodeAndCapturePng(graph, node, png, null, null, 20);
        }
        private static List<Type> GetNodes()
        {

            Assembly assembly = Assembly.GetExecutingAssembly();
            Type gn = typeof(GenesisNode);
            var derivedTypes = assembly.GetTypes().
                Where(t => t.IsClass && !t.IsAbstract && t.IsSubclassOf(gn));

            var nodes = new List<Type>();
            foreach (var derivedType in derivedTypes)
                nodes.Add(derivedType);
            return nodes;
        }
        private static void WaitAndCapture()
        {
            _frameCount++;
            if (_frameCount < 30) return;
            if (!captured)
            {
                CaptureNode(node);
                captured = true;
                graph.RemoveNode(node);
            }


            if (_frameCount > 60)
            {
                ntp++;
                if (ntp > nodeTypes.Count - 1)
                {
                    EditorApplication.update -= WaitAndCapture;
                }
                else
                {
                    node = (GenesisNode)Activator.CreateInstance(nodeTypes[ntp]);
                    graph.AddNode(node);
                    EditorUtility.SetDirty(graph);
                }
                _frameCount = 0;
                captured = false;
            }

        }

        private static bool CaptureNode(GenesisNode node)
        {
            Rect worldBound = node.position;

            // 2. Convert GUI-space top-left into an absolute screen point
            Vector2 guiTopLeft = new(worldBound.xMin, worldBound.yMin);
            Vector2 screenTL = GUIUtility.GUIToScreenPoint(guiTopLeft);

            // 3. Convert GUI points to actual pixels
            float ppp = EditorGUIUtility.pixelsPerPoint;

            // Get the nodeview
            List<GraphProcessor.BaseNodeView> views = GenesisMainWindow.view.nodeViews;
            if (views.Count == 0)
                return false;
            int height = (int)(views[0].layout.height * ppp);

            // Get a pic
            string png = System.IO.Path.Combine(nodeDocDir, node.name.Replace(" ", "") + ".png");

            using (var bmp = new Bitmap((int)(node.nodeWidth * ppp), (int)(500), PixelFormat.Format32bppArgb))
            using (var g = System.Drawing.Graphics.FromImage(bmp))
            {
                g.CopyFromScreen((int)(screenTL.x * ppp), (int)(25 + screenTL.y * ppp), 0, 0, bmp.Size);


                bmp.MakeTransparent(bmp.GetPixel(0, 0));
                bmp.Save(png, ImageFormat.Png);
                UnityEngine.Debug.LogError(string.Format("Wrote File: {0}", png));
            }


            // Generate documentation
            string docFile = System.IO.Path.Combine(nodeDocDir, string.Format("{0}.md", node.name.Replace(" ", "")));
            createDocFile(docFile, node);
            nodes.Add(node);
            if (groups.ContainsKey(node.NodeGroup))
                groups[node.NodeGroup].Add(node);
            else
            {
                groups[node.NodeGroup] = new List<GenesisNode>() { node };
            }
            
            return true;
        }

        public static void writeGroupPage(string docDir, string group, List<GenesisNode> nodes)
        {
            nodes = nodes.OrderBy(x => x.name).ToList();
            StringBuilder sb = new StringBuilder();
            sb.Append("<html><head><meta charset=\"utf8\"/><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/css/adminlte.min.css\"></head>");
            sb.Append("<body><script src=\"https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/js/adminlte.min.js\"></script>");
            sb.Append("<table style=\"width:100%\">\n");
            sb.Append("<tr>\n");
            foreach (KeyValuePair<string, List<GenesisNode>> kvp in groups)
            {
                string g= kvp.Key;
                if (group == g)
                {
                    sb.Append(string.Format("<td><b><a href=\"group-{0}.html\">{0}</a></b></td>", g));
                }
                else
                {
                    sb.Append(string.Format("<td><a href=\"group-{0}.html\">{0}</a></td>", g));
                }
            }
            sb.Append("</tr></table>\n\n");
            sb.Append("<div class=\"card card-info\" width=\"50%\">\n");
            sb.Append("<div class=\"card-header\">\n");
            sb.Append(string.Format("<h3 class=\"card-title\">{0}</h3>", group));
            sb.Append("</div>");
            sb.Append("<div class=\"card-body\">\n");

            foreach(GenesisNode node in nodes)
            {
                sb.Append(string.Format("<li><a href=\"{1}.html\">{0}</a>\n", node.name, node.name.Replace(" ", "")));
            }
            sb.Append("</div></div>");
            sb.Append("</body></html>");
            string path = docDir + string.Format("\\group-{0}.html", group);
            System.IO.File.WriteAllText(path, sb.ToString());
        }

        public static string GetDocumentation(Type targetType)
        {
            var docAttr = targetType
                .GetCustomAttributes(inherit: false)
                .OfType<DocumentationAttribute>()
                .FirstOrDefault();

            return docAttr?.markdown;
        }

        static bool HasUnityPage(string typename)
        {
            // Check if the Unity documentation page exists for the type
            string url = $"https://docs.unity3d.com/ScriptReference/{typename}.html";
            using var client = new System.Net.WebClient();
            try
            {
                client.DownloadString(url);
                return true;
            }
            catch (System.Net.WebException)
            {
                return false;
            }
        }

        static string unityPage(string typename)
        {
            /*string url = "https://example.com"; // Replace with your desired URL

            WebClient wc = new();
            try
            {
                string html = wc.DownloadString(url);
                HtmlDocument doc = new();
                doc.LoadHtml(html);
                // Find the first <a> tag with href containing the typename
                var linkNode = doc.DocumentNode.SelectSingleNode($"//a[contains(@href, 'content')]");
                if (linkNode != null)
                {
                    return linkNode.GetAttributeValue("href", string.Empty);
                }
                else
                {
                    return string.Empty; // No link found
                }
            }
            catch (Exception ex)
            {
                Debug.LogError($"Error fetching Unity page for {typename}: {ex.Message}");
                return string.Empty;
            }*/
            return string.Empty;
        }

        static void generateTypeFile(string typeName, Type type)
        {
            

        }
        static void createDocFile(string docFile, GenesisNode node)
        {
            string path = System.IO.Path.GetDirectoryName(docFile);            
            StringBuilder sb=new StringBuilder();
            sb.Append("<html><head><meta charset=\"utf8\"/><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/css/adminlte.min.css\"></head>");
            sb.Append("<body><script src=\"https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/js/adminlte.min.js\"></script>");
            // Draw the Groups Header
            sb.Append("<table style=\"width:100%\">\n");
            sb.Append("<tr>\n");
            foreach(KeyValuePair<string,List<GenesisNode>> kvp in groups)
            {
                string group=kvp.Key;
                if(group==node.NodeGroup)
                {
                    sb.Append(string.Format("<td><b><a href=\"group-{0}.html\">{0}</a></b></td>", group));
                } else
                {
                    sb.Append(string.Format("<td><a href=\"group-{0}.html\">{0}</a></td>", group));
                }                
            }
            sb.Append("</tr></table>\n\n");

            sb.Append(string.Format("## {0} ##\n", node.name));
            
            sb.Append(string.Format("![ {0 }]( ./{0}.png )\n", node.name.Replace(" ","")));
            sb.Append(GetDocumentation(node.GetType()));

            sb.Append("<div class=\"card card-info\" width=\"50%\">\n");
            sb.Append("<div class=\"card-header\">\n");
            sb.Append("<h3 class=\"card-title\">Inputs</h3>");
            sb.Append("</div>");
            sb.Append("<div class=\"card-body\">");
            List<NodePort> ports = node.GetInputPorts().ToList();
            if (ports.Count > 0)
            {
                sb.Append("\n");
                sb.Append("<table>\n");
                sb.Append("<tr><th>Port Name</th><th>Type</th><th>Accepts Multiple</th><th>Tool Tip</th></tr>\n");
                foreach(NodePort port in ports)
                {
                    sb.Append("<tr>");
                    sb.Append(string.Format("<td> {0} </td> ", port.portData.displayName));
                    sb.Append(string.Format("<td> {0} </td>", port.portData.displayType));
                    string mStr = "<td>❌</td>";
                    if(port.portData.acceptMultipleEdges)
                    {
                        mStr = "<td>✅</td>";
                    }
                    sb.Append(string.Format("<td> {0} </td>", mStr));
                    sb.Append(string.Format("<td> {0} </td>\n", port.portData.tooltip));
                    sb.Append("</tr>\n");
                }
            }
            sb.Append("</table>\n");
            sb.Append("</div>\n");
            sb.Append("</div>\n");

            ports = node.GetOutputPorts().ToList();
            sb.Append("<div class=\"card card-success\" width=\"50%\">\n");
            sb.Append("<div class=\"card-header\">\n");
            sb.Append("<h3 class=\"card-title\">Outputs</h3>");
            sb.Append("</div>");
            sb.Append("<div class=\"card-body\">");
            if (ports.Count > 0)
            {
                sb.Append("\n");
                sb.Append("<table>\n");
                sb.Append("<tr><th>Port Name</th><th>Type</th><th>Accepts Multiple</th><th>Tool Tip</th></tr>\n");
                foreach (NodePort port in ports)
                {
                    sb.Append("<tr>");
                    sb.Append(string.Format("<td> {0} </td> ", port.portData.displayName));
                    sb.Append(string.Format("<td> {0} </td>", port.portData.displayType));
                    string mStr = "<td>❌</td>";
                    if (port.portData.acceptMultipleEdges)
                    {
                        mStr = "<td>✅</td>";
                    }
                    sb.Append(string.Format("<td> {0} </td>", mStr));
                    sb.Append(string.Format("<td> {0} </td>\n", port.portData.tooltip));
                    sb.Append("</tr>\n");
                }
            }
            sb.Append("</table>\n");
            sb.Append("</div>\n");
            sb.Append("</div>\n");
           
            FixedShaderNode fsn= node as FixedShaderNode;
            if(fsn!=null)
            {
                if(shaderSources.ContainsKey(fsn.ShaderName))
                {
                    sb.Append("<div class=\"card card-warning\" width=\"50%\">\n");
                    sb.Append("<div class=\"card-header\">\n");
                    sb.Append("<h3 class=\"card-title\">Shader Source</h3>");
                    sb.Append("</div>");
                    sb.Append("<div class=\"card-body\">");
                    sb.Append(string.Format("<pre><code>\n{0}\n</code></pre>\n", shaderSources[fsn.ShaderName]));
                    sb.Append("</div>\n");
                    sb.Append("</div>\n");
                }
            }
            var pipeline = new MarkdownPipelineBuilder().UseAdvancedExtensions().Build();
            var document = Markdig.Markdown.Parse(sb.ToString(), pipeline);
            var result = document.ToHtml(pipeline);

            sb.Clear();            
            sb.Append(result);
            sb.Append("</body></html>");
            docFile = docFile.Replace("*", "");
            System.IO.File.WriteAllText(docFile, sb.ToString());
                        
            /*
            Tools.Markdown.Doc doc = new();
            TableColumn c1 = new();
            c1.Add(new Text("<div style=\"width:30%\">"));
            c1.Add(new Tools.Markdown.Image(string.Format("{0}\\{1}.png", path, node.name), node.name));
            c1.Alignment = TableColumn.eAlignment.Left;
            TableColumn c2 = new();
            c2.Add(new Text("<div style=\"width:60%\">"));
            c2.Add(new Text(node.name));

            Table header = new(
                c1, c2
            );

            doc.Add(header);

            // Add description
            Heading heading = new("Node Description\n", 2);

            Tools.Markdown.Box descBox = new(Tools.Markdown.Box.eBoxType.Info, Box.eBoxTheme.Primary, false, true);
            string desc = GetDocumentation(node.GetType());
            Text descText = new(desc);
            descBox.Add(heading);
            descBox.Add(descText);
            doc.Add(descBox);
            List<NodePort> ports = node.GetInputPorts().ToList();

            Box inputsBox = new(Tools.Markdown.Box.eBoxType.Info, Box.eBoxTheme.Primary, false, true);
            inputsBox.Add(new Heading("Inputs\n", 2));


            if (ports.Count > 0)
            {

                Table table = new(
                        new TableColumn(TableColumn.eAlignment.Left),
                        new TableColumn(TableColumn.eAlignment.Left),
                        new TableColumn(TableColumn.eAlignment.Left),
                        new TableColumn(TableColumn.eAlignment.Left)
                    );
                foreach (var input in ports)
                {
                    TableRow row = new(
                        new TableCell(new Badge(input.portData.displayName, Badge.eBadgeType.Info)),
                        new TableCell(new Link(string.Format("../{0}", input.portData.displayType.Name.Replace(" ", "")), input.portData.displayType.Name)));
                    if (!ioTypes.ContainsKey(input.portData.displayType.Name))
                        ioTypes.Add(input.portData.displayType.Name.Replace(" ", ""), input.portData.displayType);

                    if (input.portData.acceptMultipleEdges)
                    {
                        row.AddTableCell(new TableCell(new Badge("Accepts Multiple", Badge.eBadgeType.Success)));
                    }
                    else
                    {
                        row.AddTableCell(new TableCell(new Badge("Single Input", Badge.eBadgeType.Warning)));
                    }
                    row.AddTableCell(new TableCell(new Text(input.portData.tooltip)));
                    table.AddRow(row);
                }
                inputsBox.Add(table);
            }
            else
            {
                inputsBox.Add(new Badge("No Inputs", Badge.eBadgeType.Success));
            }
            doc.Add(inputsBox);

            Box outputsBox = new(Tools.Markdown.Box.eBoxType.Info, Box.eBoxTheme.Primary, false, true);
            outputsBox.Add(new Heading("Outputs\n", 2));
            List<NodePort> outputs = node.GetOutputPorts().ToList();
            if (outputs.Count > 0)
            {
                Table table = new(
                        new TableColumn(TableColumn.eAlignment.Left),
                        new TableColumn(TableColumn.eAlignment.Left),
                        new TableColumn(TableColumn.eAlignment.Left),
                        new TableColumn(TableColumn.eAlignment.Left)
                    );
                foreach (var output in outputs)
                {
                    TableRow row = new(
                        new TableCell(new Badge(output.portData.displayName, Badge.eBadgeType.Info)),
                        new TableCell(new Link(string.Format("../{0}", output.portData.displayType.Name.Replace(" ", "")), output.portData.displayType.Name)));

                    if (!ioTypes.ContainsKey(output.portData.displayType.Name))
                        ioTypes.Add(output.portData.displayType.Name.Replace(" ", ""), output.portData.displayType);

                    if (output.portData.acceptMultipleEdges)
                    {
                        row.AddTableCell(new TableCell(new Badge("Accepts Multiple", Badge.eBadgeType.Success)));
                    }
                    else
                    {
                        row.AddTableCell(new TableCell(new Badge("Single Output", Badge.eBadgeType.Warning)));
                    }
                    row.AddTableCell(new TableCell(new Text(output.portData.tooltip)));
                    table.AddRow(row);
                    outputsBox.Add(table);
                }
            }
            else
            {
                outputsBox.Add(new Badge("No Outputs", Badge.eBadgeType.Success));
            }
            doc.Add(outputsBox);

            // Add node group
            Box groupBox = new(Tools.Markdown.Box.eBoxType.Info, Box.eBoxTheme.Primary, false, true);
            groupBox.Add(new Heading("Nodes in Group\n", 2));
            string groupName = node.NodeGroup;
            foreach (var n in groups[groupName])
            {
                string url = string.Format("{0}.md", n.name.Replace(" ", ""));
                Bullet bullet = new(new Link(url, n.name));
                groupBox.Add(bullet);
            }
            doc.Add(groupBox);

            // Save the doc
            System.IO.File.WriteAllText(docFile, doc.ToString());
            */
        }

    }
}
