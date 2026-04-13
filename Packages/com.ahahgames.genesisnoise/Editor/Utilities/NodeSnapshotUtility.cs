using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Nodes;
using AhahGames.GenesisNoise.Views;

using GraphProcessor;

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

using UnityEditor;

using UnityEngine;
using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise
{
    /// <summary>
    /// Displays a node inside a Genesis graph window, frames it, and saves a PNG snapshot.
    /// </summary>
    public static class NodeSnapshotUtility
    {
        const float defaultPadding = 20.0f;
        const float minViewportSize = 64.0f;
        const float minZoom = 0.05f;
        const float maxZoom = 2.0f;

        sealed class SnapshotRequest
        {
            public GenesisGraph graph;
            public GenesisNode node;
            public GenesisGraphWindow window;
            public BaseNodeView nodeView;
            public IMGUIContainer captureOverlay;
            public string outputPath;
            public Action<string> onCompleted;
            public Action<string> onFailed;
            public float padding;
            public bool shouldAddNode;
            public bool removeNodeAfterCapture;
            public bool destroyGraphAfterCapture;
            public bool closeWindowAfterCapture;
            public bool windowCreatedForRequest;
            public bool hasFramedNode;
            public bool captureQueued;
            public bool hasStoredViewState;
            public bool restoreViewAfterCapture;
            public Vector3 originalViewPosition;
            public Vector3 originalViewScale;
            public int waitFrames;
            public bool isFinished;
        }

        static readonly List<SnapshotRequest> pendingRequests = new();

        /// <summary>
        /// Opens the supplied graph, frames an existing node, captures it, and writes the result to a PNG file.
        /// </summary>
        public static void DisplayNodeAndCapturePng(
            GenesisGraph graph,
            GenesisNode node,
            string outputPath,
            Action<string> onCompleted = null,
            Action<string> onFailed = null,
            float padding = defaultPadding)
        {
            if (graph == null)
                throw new ArgumentNullException(nameof(graph));

            if (node == null)
                throw new ArgumentNullException(nameof(node));

            if (string.IsNullOrWhiteSpace(outputPath))
                throw new ArgumentException("Output path is required.", nameof(outputPath));

            if (!graph.nodes.Contains(node))
                throw new ArgumentException("The node must already belong to the supplied graph. Use DisplayStandaloneNodeAndCapturePng for temporary captures.", nameof(node));

            QueueRequest(new SnapshotRequest
            {
                graph = graph,
                node = node,
                outputPath = Path.GetFullPath(outputPath),
                onCompleted = onCompleted,
                onFailed = onFailed,
                padding = Mathf.Max(0.0f, padding),
                shouldAddNode = false,
                removeNodeAfterCapture = false,
                destroyGraphAfterCapture = false,
                closeWindowAfterCapture = false,
                restoreViewAfterCapture = true,
            });
        }

        /// <summary>
        /// Creates a temporary graph, displays a cloned copy of the node, captures it, and writes the result to a PNG file.
        /// </summary>
        public static void DisplayStandaloneNodeAndCapturePng(
            GenesisNode node,
            string outputPath,
            Action<string> onCompleted = null,
            Action<string> onFailed = null,
            float padding = defaultPadding)
        {
            if (node == null)
                throw new ArgumentNullException(nameof(node));

            if (string.IsNullOrWhiteSpace(outputPath))
                throw new ArgumentException("Output path is required.", nameof(outputPath));

            var graph = ScriptableObject.CreateInstance<GenesisGraph>();
            graph.name = $"{node.name} Snapshot";
            graph.ClearObjectReferences();
            var snapshotNode = CloneNodeForSnapshot(node);

            QueueRequest(new SnapshotRequest
            {
                graph = graph,
                node = snapshotNode,
                outputPath = Path.GetFullPath(outputPath),
                onCompleted = onCompleted,
                onFailed = onFailed,
                padding = Mathf.Max(0.0f, padding),
                shouldAddNode = true,
                removeNodeAfterCapture = true,
                destroyGraphAfterCapture = true,
                closeWindowAfterCapture = true,
                restoreViewAfterCapture = false,
            });
        }

        static GenesisNode CloneNodeForSnapshot(GenesisNode node)
        {
            var clonedNode = JsonSerializer.DeserializeNode(JsonSerializer.SerializeNode(node)) as GenesisNode;
            if (clonedNode == null)
                throw new InvalidOperationException($"Unable to clone node '{node.name}' for snapshot capture.");

            clonedNode.position = node.position;
            return clonedNode;
        }

        static void QueueRequest(SnapshotRequest request)
        {
            var directory = Path.GetDirectoryName(request.outputPath);
            if (!string.IsNullOrEmpty(directory))
                Directory.CreateDirectory(directory);

            pendingRequests.Add(request);

            EditorApplication.update -= ProcessPendingRequests;
            EditorApplication.update += ProcessPendingRequests;
        }

        static void ProcessPendingRequests()
        {
            for (int i = pendingRequests.Count - 1; i >= 0; i--)
            {
                var request = pendingRequests[i];

                if (request.isFinished)
                {
                    pendingRequests.RemoveAt(i);
                    continue;
                }

                try
                {
                    ProcessRequest(request);
                }
                catch (Exception ex)
                {
                    FailRequest(request, ex.Message);
                }

                if (request.isFinished)
                    pendingRequests.RemoveAt(i);
            }

            if (pendingRequests.Count == 0)
                EditorApplication.update -= ProcessPendingRequests;
        }

        static void ProcessRequest(SnapshotRequest request)
        {
            if (request.window == null)
            {
                request.windowCreatedForRequest = FindExistingWindow(request.graph) == null;
                request.window = GenesisGraphWindow.Open(request.graph);

                if (request.windowCreatedForRequest)
                {
                    var rect = request.window.position;
                    rect.width = Mathf.Max(rect.width, 960.0f);
                    rect.height = Mathf.Max(rect.height, 720.0f);
                    request.window.position = rect;
                }

                request.window.Repaint();
                return;
            }

            if (request.window.view == null || request.window.rootVisualElement.panel == null)
                return;

            request.window.Show();
            request.window.Focus();

            if (request.shouldAddNode && !request.graph.nodes.Contains(request.node))
            {
                request.node.OnNodeCreated();
                request.window.view.AddNode(request.node);
                EditorUtility.SetDirty(request.graph);
                request.window.Repaint();
                return;
            }

            if (!request.graph.nodes.Contains(request.node))
            {
                FailRequest(request, "The node is no longer present on the graph.");
                return;
            }

            if (!request.window.view.nodeViewsPerNode.TryGetValue(request.node, out request.nodeView) || request.nodeView == null)
            {
                request.window.Repaint();
                return;
            }

            if (!IsNodeViewReady(request.nodeView, request.window.view))
            {
                request.window.Repaint();
                return;
            }

            if (!request.hasStoredViewState)
            {
                request.originalViewPosition = request.graph.position;
                request.originalViewScale = request.graph.scale;
                request.hasStoredViewState = true;
            }

            if (!request.hasFramedNode)
            {
                FrameNode(request.window.view, request.node, request.nodeView, request.padding);
                request.hasFramedNode = true;
                request.waitFrames = 2;
                request.window.Repaint();
                return;
            }

            if (request.waitFrames > 0)
            {
                request.waitFrames--;
                request.window.Repaint();
                return;
            }

            if (!request.captureQueued)
            {
                QueueCapture(request);
                request.captureQueued = true;
                request.window.Repaint();
            }
        }

        static GenesisGraphWindow FindExistingWindow(GenesisGraph graph)
        {
            return Resources.FindObjectsOfTypeAll<GenesisGraphWindow>()
                .FirstOrDefault(w => w.GetCurrentGraph() == graph);
        }

        static bool IsNodeViewReady(BaseNodeView nodeView, GenesisGraphView view)
        {
            return nodeView.panel != null
                && view.layout.width > minViewportSize
                && view.layout.height > minViewportSize
                && nodeView.layout.width > 1.0f
                && nodeView.layout.height > 1.0f;
        }

        static void FrameNode(GenesisGraphView view, GenesisNode node, BaseNodeView nodeView, float padding)
        {
            float viewportWidth = Mathf.Max(view.layout.width, minViewportSize);
            float viewportHeight = Mathf.Max(view.layout.height, minViewportSize);

            float availableWidth = Mathf.Max(viewportWidth - (padding * 2.0f), minViewportSize);
            float availableHeight = Mathf.Max(viewportHeight - (padding * 2.0f), minViewportSize);

            var nodeRect = new Rect(node.position.position, nodeView.layout.size);

            float zoomX = availableWidth / Mathf.Max(nodeRect.width, 1.0f);
            float zoomY = availableHeight / Mathf.Max(nodeRect.height, 1.0f);
            float zoom = Mathf.Clamp(Mathf.Min(zoomX, zoomY, 1.0f), minZoom, maxZoom);

            var scale = new Vector3(zoom, zoom, 1.0f);
            var position = new Vector3(
                padding + ((availableWidth - (nodeRect.width * zoom)) * 0.5f) - (nodeRect.x * zoom),
                padding + ((availableHeight - (nodeRect.height * zoom)) * 0.5f) - (nodeRect.y * zoom),
                0.0f);

            view.UpdateViewTransform(position, scale);
        }

        static void QueueCapture(SnapshotRequest request)
        {
            if (request.captureOverlay != null)
                request.captureOverlay.RemoveFromHierarchy();

            request.captureOverlay = new IMGUIContainer(() => CaptureOnGui(request));
            request.captureOverlay.pickingMode = PickingMode.Ignore;
            request.captureOverlay.style.position = Position.Absolute;
            request.captureOverlay.style.left = 0;
            request.captureOverlay.style.top = 0;
            request.captureOverlay.style.right = 0;
            request.captureOverlay.style.bottom = 0;

            request.window.rootVisualElement.Add(request.captureOverlay);
        }

        static void CaptureOnGui(SnapshotRequest request)
        {
            if (request.isFinished || request.captureOverlay == null || request.nodeView == null)
                return;

            if (Event.current == null || Event.current.type != EventType.Repaint)
                return;

            var localRect = request.nodeView.ChangeCoordinatesTo(
                request.captureOverlay,
                new Rect(Vector2.zero, request.nodeView.layout.size));

            localRect.xMin -= request.padding;
            localRect.yMin -= request.padding;
            localRect.xMax += request.padding;
            localRect.yMax += request.padding;

            if (localRect.width <= 0.0f || localRect.height <= 0.0f)
            {
                FailRequest(request, "Node view has an invalid capture size.");
                return;
            }

            Vector2 screenTopLeft = GUIUtility.GUIToScreenPoint(localRect.position);
            SaveScreenRectToPng(screenTopLeft, localRect.size, request.outputPath);
            CompleteRequest(request);
        }

        static void SaveScreenRectToPng(Vector2 screenTopLeft, Vector2 sizeInPoints, string outputPath)
        {
            float pixelsPerPoint = EditorGUIUtility.pixelsPerPoint;

            int width = Mathf.Max(1, Mathf.RoundToInt(sizeInPoints.x * pixelsPerPoint));
            int height = Mathf.Max(1, Mathf.RoundToInt(sizeInPoints.y * pixelsPerPoint));
            Vector2 pixelPosition = new Vector2(
                Mathf.Round(screenTopLeft.x * pixelsPerPoint),
                Mathf.Round(screenTopLeft.y * pixelsPerPoint));

            Color[] pixels = UnityEditorInternal.InternalEditorUtility.ReadScreenPixel(pixelPosition, width, height);
            if (pixels == null || pixels.Length != width * height)
                throw new InvalidOperationException("Unable to read pixels from the editor window.");

            var texture = new Texture2D(width, height, TextureFormat.RGBA32, false);
            texture.SetPixels(pixels);
            texture.Apply(false, false);

            byte[] bytes = ImageConversion.EncodeToPNG(texture);
            UnityEngine.Object.DestroyImmediate(texture);

            File.WriteAllBytes(outputPath, bytes);

            string projectRoot = Path.GetFullPath(Directory.GetCurrentDirectory());
            string fullOutputPath = Path.GetFullPath(outputPath);
            if (fullOutputPath.StartsWith(projectRoot, StringComparison.OrdinalIgnoreCase))
                AssetDatabase.Refresh();
        }

        static void CompleteRequest(SnapshotRequest request)
        {
            CleanupRequest(request);

            request.isFinished = true;
            request.onCompleted?.Invoke(request.outputPath);
            Debug.Log($"Saved node snapshot to {request.outputPath}");
        }

        static void FailRequest(SnapshotRequest request, string error)
        {
            CleanupRequest(request);

            request.isFinished = true;
            request.onFailed?.Invoke(error);
            Debug.LogError($"Failed to capture node snapshot: {error}");
        }

        static void CleanupRequest(SnapshotRequest request)
        {
            if (request.captureOverlay != null)
            {
                request.captureOverlay.RemoveFromHierarchy();
                request.captureOverlay = null;
            }

            if (request.restoreViewAfterCapture && request.hasStoredViewState && request.window?.view != null)
                request.window.view.UpdateViewTransform(request.originalViewPosition, request.originalViewScale);

            if (request.removeNodeAfterCapture && request.graph != null && request.graph.nodes.Contains(request.node))
            {
                if (request.window?.view != null && request.window.view.nodeViewsPerNode.ContainsKey(request.node))
                    request.window.view.RemoveNode(request.node);
                else
                    request.graph.RemoveNode(request.node);
            }

            if (request.closeWindowAfterCapture && request.window != null && request.windowCreatedForRequest)
                request.window.Close();

            if (request.destroyGraphAfterCapture && request.graph != null)
                ScriptableObject.DestroyImmediate(request.graph);
        }
    }
}
