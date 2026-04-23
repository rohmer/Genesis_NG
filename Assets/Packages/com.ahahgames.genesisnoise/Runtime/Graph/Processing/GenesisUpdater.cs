using AhahGames.GenesisNoise.Views;

using System;
using System.Collections.Generic;
using System.Linq;

using UnityEditor;

using UnityEditorInternal;

namespace AhahGames.GenesisNoise.Graph
{
    public class GenesisUpdater
    {
        public HashSet<GenesisGraphView> views = new();
        HashSet<GenesisGraph> needsProcessing = new();

        private static readonly Lazy<GenesisUpdater> instance = new(() => new GenesisUpdater());

        public static GenesisUpdater Instance
        {
            get { return instance.Value; }
        }

        private GenesisUpdater()
        {
            EditorApplication.update -= Update;
            EditorApplication.update += Update;
        }

        public void Update()
        {
            // When the editor is not focused we disable the realtime preview
            if (!InternalEditorUtility.isApplicationActive)
                return;
        }

        public void AddGraphToProcess(GenesisGraphView view)
        {
            views.Add(view);
        }

        public void RemoveGraphToProcess(GenesisGraph graph) => RemoveGraphToProcess(views.FirstOrDefault(v => v.graph == graph));
        public void RemoveGraphToProcess(GenesisGraphView view) => views.Remove(view);

        public void EnqueueGraphProcessing(GenesisGraph graph) => needsProcessing.Add(graph);
    }
}