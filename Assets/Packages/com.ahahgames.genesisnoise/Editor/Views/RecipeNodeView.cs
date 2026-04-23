using AhahGames.GenesisNoise;
using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System.Collections.Generic;
using System.Linq;

using UnityEditor.Experimental.GraphView;

using UnityEngine;
using UnityEngine.UIElements;

public class RecipeNodeView : GroupView
{
    public RecipeNode recipe;

    Label titleLabel;
    Texture2D icon;

    readonly string groupStyle = "GenesisRecipeView";

    public RecipeNodeView()
    {
        styleSheets.Add(Resources.Load<StyleSheet>(groupStyle));
    }

    private static void BuildContextualMenu(ContextualMenuPopulateEvent evt) { }

    public void Initialize(BaseGraphView graphView, RecipeNode block)
    {
        group = block;
        recipe = block;
        owner = graphView;
        title = block.title;
        base.SetPosition(block.position);

        this.AddManipulator(new ContextualMenuManipulator(BuildContextualMenu));

        headerContainer.Q<TextField>().RegisterCallback<ChangeEvent<string>>(TitleChangedCallback);
        titleLabel = headerContainer.Q<Label>();

        VisualElement titleContainer = headerContainer.Q("titleContainer");
        icon = EditorUtilities.recipeIcon;
        titleContainer.style.backgroundImage = icon;

        InitializeInnerNodes();
    }

    void InitializeInnerNodes()
    {
        foreach (var nodeGUID in recipe.innerNodeGUIDs.ToList())
        {
            if (!owner.graph.nodesPerGUID.ContainsKey(nodeGUID))
            {
                Debug.LogWarning("Node GUID not found: " + nodeGUID);
                recipe.innerNodeGUIDs.Remove(nodeGUID);
                continue;
            }
            var node = owner.graph.nodesPerGUID[nodeGUID];
            var nodeView = owner.nodeViewsPerNode[node];

            AddElement(nodeView);
        }
    }

    protected override void OnElementsAdded(IEnumerable<GraphElement> elements)
    {
        foreach (var element in elements)
        {
            var node = element as BaseNodeView;

            // Adding an element that is not a node currently supported
            if (node == null)
                continue;

            if (!recipe.innerNodeGUIDs.Contains(node.nodeTarget.GUID))
                recipe.innerNodeGUIDs.Add(node.nodeTarget.GUID);
        }
        base.OnElementsAdded(elements);
    }

    protected override void OnElementsRemoved(IEnumerable<GraphElement> elements)
    {
        // Only remove the nodes when the group exists in the hierarchy
        if (parent != null)
        {
            foreach (var elem in elements)
            {
                if (elem is BaseNodeView nodeView)
                {
                    recipe.innerNodeGUIDs.Remove(nodeView.nodeTarget.GUID);
                }
            }
        }

        base.OnElementsRemoved(elements);
    }

    void TitleChangedCallback(ChangeEvent<string> e)
    {
        recipe.title = e.newValue;
    }
}
