using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Nodes;
using AhahGames.GenesisNoise;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

using UnityEditor;

using UnityEngine;
using System.Threading;

namespace AhahGames.GenesisNoise.Runtime.Utility
{
    public static class NodeDocumentor
    {
        const string PackageName = "com.ahahgames.genesisnoise";
        const string PackageAssetRoot = "Packages/" + PackageName;
        const float SnapshotPadding = 24.0f;
        static readonly Regex NodeMenuRegex = new Regex("NodeMenuItem\\(\"([^\"]+)\"", RegexOptions.Compiled);
        static readonly List<CaptureJob> captureQueue = new List<CaptureJob>();
        static readonly List<string> captureFailures = new List<string>();

        static string packageRoot;
        static int captureIndex;
        static int captureSuccessCount;
        static bool isRunning;

        sealed class CaptureJob
        {
            public Type NodeType;
            public string DisplayName;
            public string PrimaryMenu;
            public string CategorySlug;
            public string NodeSlug;
            public string FileSlug;
            public string OutputPath;
        }

        [MenuItem("Tools/Genesis Documentation")]
        public static void GenerateDocumentation()
        {
            if (isRunning)
            {
                Debug.LogWarning("Genesis documentation generation is already running.");
                return;
            }

            try
            {
                packageRoot = GetPackageRoot();
                if (!Directory.Exists(packageRoot))
                    throw new DirectoryNotFoundException("Could not locate the Genesis package root.");

                string imageRoot = Path.Combine(packageRoot, "Documentation", "Nodes", "_images");
                RecreateDirectory(imageRoot);

                captureQueue.Clear();
                captureQueue.AddRange(BuildCaptureQueue(imageRoot));
                captureFailures.Clear();
                captureSuccessCount = 0;
                captureIndex = -1;
                isRunning = true;

                if (captureQueue.Count == 0)
                {
                    FinishGeneration();
                    return;
                }

                Debug.Log(string.Format("Generating Genesis node documentation for {0} nodes.", captureQueue.Count));
                CaptureNext();
            }
            catch (Exception ex)
            {
                Cleanup();
                Debug.LogError(string.Format("Unable to generate Genesis documentation: {0}", ex));
            }
        }

        static void CaptureNext()
        {
            captureIndex++;

            if (captureIndex >= captureQueue.Count)
            {
                FinishGeneration();
                return;
            }

            CaptureJob job = captureQueue[captureIndex];
            
            GenesisNode node;
            try
            {
                node = (GenesisNode)Activator.CreateInstance(job.NodeType);
                node.OnNodeCreated();               
                Thread.Sleep(1000);
                if (node.position.position == Vector2.zero)
                    node.position = new Rect(64.0f, 64.0f, node.position.width, node.position.height);
            }
            catch (Exception ex)
            {
                captureFailures.Add(string.Format("{0}: failed to instantiate node ({1})", job.PrimaryMenu, ex.Message));
                CaptureNext();
                return;
            }

            NodeSnapshotUtility.DisplayStandaloneNodeAndCapturePng(
                node,
                job.OutputPath,
                _ =>
                {
                    captureSuccessCount++;
                    CaptureNext();
                },
                error =>
                {
                    captureFailures.Add(string.Format("{0}: {1}", job.PrimaryMenu, error));
                    CaptureNext();
                },
                SnapshotPadding);
        }

        static void FinishGeneration()
        {
            EditorUtility.DisplayProgressBar("Genesis Documentation", "Refreshing markdown pages...", 1.0f);

            bool markdownSucceeded = RunMarkdownGenerator();
            AssetDatabase.Refresh();

            StringBuilder summary = new StringBuilder();
            summary.AppendLine(string.Format(
                "Genesis documentation generation finished. Captured {0}/{1} screenshots.",
                captureSuccessCount,
                captureQueue.Count));

            if (captureFailures.Count > 0)
            {
                summary.AppendLine(string.Format("Screenshot failures: {0}", captureFailures.Count));
                foreach (string failure in captureFailures.Take(10))
                    summary.AppendLine("- " + failure);

                if (captureFailures.Count > 10)
                    summary.AppendLine(string.Format("- ...and {0} more.", captureFailures.Count - 10));
            }

            if (!markdownSucceeded)
                summary.AppendLine("Markdown regeneration failed. Check the console output for details.");

            Cleanup();

            if (captureFailures.Count > 0 || !markdownSucceeded)
                Debug.LogWarning(summary.ToString().TrimEnd());
            else
                Debug.Log(summary.ToString().TrimEnd());
        }

        static void Cleanup()
        {
            EditorUtility.ClearProgressBar();
            captureQueue.Clear();
            captureFailures.Clear();
            captureIndex = -1;
            captureSuccessCount = 0;
            isRunning = false;
        }

        static List<CaptureJob> BuildCaptureQueue(string imageRoot)
        {
            List<CaptureJob> jobs = new List<CaptureJob>();
            string[] guids = AssetDatabase.FindAssets("t:MonoScript", new[] { PackageAssetRoot + "/Runtime/Nodes" });

            foreach (string guid in guids)
            {
                string assetPath = AssetDatabase.GUIDToAssetPath(guid);
                MonoScript script = AssetDatabase.LoadAssetAtPath<MonoScript>(assetPath);
                Type nodeType = script != null ? script.GetClass() : null;

                if (nodeType == null || nodeType.IsAbstract || !typeof(GenesisNode).IsAssignableFrom(nodeType))
                    continue;

                string fullScriptPath = GetFullPathFromAssetPath(assetPath);
                if (!File.Exists(fullScriptPath))
                    continue;

                string source = File.ReadAllText(fullScriptPath);
                List<string> menus = NodeMenuRegex.Matches(source)
                    .Cast<Match>()
                    .Select(match => match.Groups[1].Value)
                    .Distinct()
                    .ToList();

                if (menus.Count == 0)
                    continue;

                string primaryMenu = menus[0];
                string[] segments = primaryMenu.Split('/');
                string categorySlug = Slug(segments[0]);
                string nodeSlug = Slug(string.Join(" ", segments.Skip(1).ToArray()));
                if (string.IsNullOrWhiteSpace(nodeSlug))
                    nodeSlug = Slug(nodeType.Name);
                string fileSlug = Slug(Path.GetFileNameWithoutExtension(fullScriptPath));

                jobs.Add(new CaptureJob
                {
                    NodeType = nodeType,
                    DisplayName = segments.Length > 0 ? segments[segments.Length - 1] : nodeType.Name,
                    PrimaryMenu = primaryMenu,
                    CategorySlug = categorySlug,
                    NodeSlug = nodeSlug,
                    FileSlug = fileSlug,
                    OutputPath = Path.Combine(imageRoot, categorySlug, nodeSlug + ".png"),
                });
            }

            foreach (IGrouping<string, CaptureJob> duplicateGroup in jobs
                .GroupBy(job => job.OutputPath, StringComparer.OrdinalIgnoreCase)
                .Where(group => group.Count() > 1)
                .ToList())
            {
                foreach (CaptureJob job in duplicateGroup)
                {
                    string resolvedSlug = string.Format("{0}-{1}", job.NodeSlug, job.FileSlug);
                    job.OutputPath = Path.Combine(imageRoot, job.CategorySlug, resolvedSlug + ".png");
                }
            }

            List<IGrouping<string, CaptureJob>> duplicates = jobs
                .GroupBy(job => job.OutputPath, StringComparer.OrdinalIgnoreCase)
                .Where(group => group.Count() > 1)
                .ToList();

            if (duplicates.Count > 0)
                throw new InvalidOperationException("Duplicate node screenshot paths remain after resolution.");

            return jobs.OrderBy(job => job.PrimaryMenu).ToList();
        }

        static bool RunMarkdownGenerator()
        {
            string scriptPath = Path.Combine(packageRoot, "Documentation", "Generate-GenesisNodeDocs.ps1");
            if (!File.Exists(scriptPath))
            {
                Debug.LogError("Documentation generator script was not found: " + scriptPath);
                return false;
            }

            string[] shells = { "pwsh", "powershell" };
            foreach (string shell in shells)
            {
                if (TryRunMarkdownGenerator(shell, scriptPath))
                    return true;
            }

            return false;
        }

        static bool TryRunMarkdownGenerator(string shellExecutable, string scriptPath)
        {
            try
            {
                System.Diagnostics.ProcessStartInfo startInfo = new System.Diagnostics.ProcessStartInfo
                {
                    FileName = shellExecutable,
                    Arguments = string.Format("-NoProfile -ExecutionPolicy Bypass -File \"{0}\"", scriptPath),
                    WorkingDirectory = packageRoot,
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    CreateNoWindow = true,
                };

                using (System.Diagnostics.Process process = System.Diagnostics.Process.Start(startInfo))
                {
                    if (process == null)
                    {
                        Debug.LogError("Failed to start the markdown generator process.");
                        return false;
                    }

                    string stdout = process.StandardOutput.ReadToEnd();
                    string stderr = process.StandardError.ReadToEnd();
                    process.WaitForExit();

                    if (!string.IsNullOrWhiteSpace(stdout))
                        Debug.Log(stdout.Trim());

                    if (process.ExitCode == 0)
                    {
                        if (!string.IsNullOrWhiteSpace(stderr))
                            Debug.LogWarning(stderr.Trim());

                        return true;
                    }

                    string errorMessage = string.IsNullOrWhiteSpace(stderr) ? "No error output was provided." : stderr.Trim();
                    Debug.LogError(string.Format(
                        "Markdown generation failed via {0} with exit code {1}. {2}",
                        shellExecutable,
                        process.ExitCode,
                        errorMessage));
                    return false;
                }
            }
            catch (Exception ex)
            {
                Debug.LogWarning(string.Format("Unable to start {0}: {1}", shellExecutable, ex.Message));
                return false;
            }
        }

        static string GetPackageRoot()
        {
            return Path.GetFullPath(Path.Combine(Application.dataPath, "..", PackageAssetRoot));
        }

        static string GetFullPathFromAssetPath(string assetPath)
        {
            return Path.GetFullPath(Path.Combine(Application.dataPath, "..", assetPath));
        }

        static void RecreateDirectory(string path)
        {
            if (Directory.Exists(path))
            {
                DirectoryInfo directory = new DirectoryInfo(path);
                foreach (FileInfo file in directory.GetFiles("*", SearchOption.AllDirectories))
                    file.IsReadOnly = false;

                foreach (DirectoryInfo childDirectory in directory.GetDirectories("*", SearchOption.AllDirectories))
                    childDirectory.Attributes &= ~FileAttributes.ReadOnly;

                directory.Attributes &= ~FileAttributes.ReadOnly;
                Directory.Delete(path, true);
            }

            Directory.CreateDirectory(path);
        }

        static string Slug(string text)
        {
            if (string.IsNullOrWhiteSpace(text))
                return "index";

            string value = Regex.Replace(text.ToLowerInvariant(), "[^a-z0-9]+", "-").Trim('-');
            return string.IsNullOrWhiteSpace(value) ? "index" : value;
        }
    }
}

#if false

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
#endif
