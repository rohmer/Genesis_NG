using AhahGames.GenesisNoise;

using System;
using System.Collections.Generic;
using System.IO;

using UnityEditor;

using UnityEngine;
using UnityEngine.UIElements;

public class RecipeBrowser : EditorWindow
{
    [SerializeField]
    private VisualTreeAsset m_VisualTreeAsset = default;
    private TreeView treeView;
    private Toggle builtinOnly;
    private Button select;
    private VisualElement blankSpace;
    private IList<TreeViewItemData<string>> treeViewItems;


    public void CreateGUI()
    {
        // Each editor window contains a root VisualElement object
        VisualElement root = rootVisualElement;
        VisualElement topBar = new();
        topBar.style.flexDirection = FlexDirection.Row;
        Label rbLabel = new("Recipe Browser");
        rbLabel.style.fontSize = 24;
        topBar.Add(rbLabel);
        blankSpace = new VisualElement();
        blankSpace.style.width = position.width - 100;
        topBar.Add(blankSpace);
        //rbLabel.style.flexDirection = FlexDirection.Row;
        //rbLabel.style.alignContent = Align.FlexStart;
        this.minSize = new Vector2(450, 200);
        this.maxSize = new Vector2(1920, 720);
        Button closeWindow = new();
        Texture2D i = EditorUtilities.closeIcon;
        closeWindow.style.backgroundImage = i;
        closeWindow.style.width = 32;
        closeWindow.style.height = 32;
        closeWindow.clicked += closeEditorWindow;

        //closeWindow.style.flexDirection = FlexDirection.RowReverse;
        topBar.Add(closeWindow);
        root.Add(topBar);
        treeView = new TreeView();
        root.Add(treeView);


        builtinOnly = new Toggle("Show built-in only");
        root.Add(builtinOnly);
        select = new Button();
        select.SetEnabled(false);
        select.Add(new Label("Add selected recipe"));
        select.clicked += loadRecipe;
        root.Add(select);
        treeView.selectionType = SelectionType.Single;
        OnBackingScaleFactorChanged();
        updateItems();
        Func<VisualElement> makeItem = () => new Label();
        Action<VisualElement, int> bindItem = (e, i) =>
        {
            var item = treeView.GetItemDataForIndex<string>(i);
            (e as Label).text = item;
        };
        treeView.makeItem = makeItem;
        treeView.bindItem = bindItem;
        treeView.itemsChosen += TreeView_onItemsChosen;
        treeView.selectionChanged += TreeView_onItemsChosen;
        updateItems();
    }

    private void TreeView_onItemsChosen(IEnumerable<object> obj)
    {
        string val = treeView.selectedItem.ToString();
        int i = treeView.GetParentIdForIndex(treeView.selectedIndex);
        if (i != -1)
        {
            // Not a base
            select.SetEnabled(true);
        }
    }

    private void closeEditorWindow()
    {
        this.Close();
    }

    protected override void OnBackingScaleFactorChanged()
    {
        blankSpace.style.width = position.width - 100;
        treeView.style.width = position.width - 10;
        //base.OnBackingScaleFactorChanged();
    }

    private void loadRecipe()
    {

    }

    public void Update()
    {
        OnBackingScaleFactorChanged();
    }

    private void updateItems()
    {
        treeView.Clear();
        treeViewItems = new List<TreeViewItemData<string>>();
        TreeViewItemData<string> builtins;
        int ctr = 2;


        List<TreeViewItemData<string>> builtinFiles = new();

        // Load the items for builtin
        if (!builtinOnly.value)
        {
            string builtinPath = "Packages/com.ahahgames.genesisnoise/Runtime/Resources/Recipes";
            if (!Directory.Exists(builtinPath))
                Directory.CreateDirectory(builtinPath);
            foreach (var file in Directory.GetFiles(builtinPath, "*.recipe"))
            {
                builtinFiles.Add(new TreeViewItemData<string>(ctr, System.IO.Path.GetFileNameWithoutExtension(file)));
                ctr++;
            }

        }
        if (builtinFiles.Count > 0)
        {
            builtins = new TreeViewItemData<string>(0, "Built In", builtinFiles);
        }
        else
        {
            builtins = new TreeViewItemData<string>(0, "Built In");
        }

        treeViewItems.Add(builtins);


        if (!builtinOnly.value)
        {
            string customPath = "Resources/Recipes";
            if (!Directory.Exists(customPath))
                Directory.CreateDirectory(customPath);
            List<TreeViewItemData<string>> customFiles = new();
            foreach (var file in Directory.GetFiles(customPath, "*.recipe"))
            {
                customFiles.Add(new TreeViewItemData<string>(ctr, System.IO.Path.GetFileNameWithoutExtension(file)));
                ctr++;
            }
            TreeViewItemData<string> custom;
            if (customFiles.Count > 0)
                custom = new TreeViewItemData<string>(ctr, "Custom", customFiles);
            else
                custom = new TreeViewItemData<string>(ctr, "Custom");
            treeViewItems.Add(custom);
        }


        treeView.SetRootItems(treeViewItems);
    }


}
