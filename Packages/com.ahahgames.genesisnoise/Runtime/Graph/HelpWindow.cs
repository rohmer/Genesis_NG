using AhahGames.GenesisNoise;
using AhahGames.GenesisNoise.Nodes;
using AhahGames.GenesisNoise.Views;

using GraphProcessor;

using UnityEditor.Experimental.GraphView;

using UnityEngine;
using UnityEngine.UIElements;

namespace AhahGames.Graph
{
    public class HelpWindow : Node
    {
        public string Name
        {
            get { return name; }
            set
            {
                if (HelpObject != null && ((helpObject as BaseNode) != null))
                {
                    name = string.Format("Help: {0}", (helpObject as BaseNode).name);
                    titleText.text = name;
                }
            }
        }

        private object helpObject = null;
        private Label helpText, titleText;
        private Button minMaxButton;
        private Image minIcon;
        private ScrollView scrollView;

        public object HelpObject
        {
            get { return helpObject; }
            set
            {
                if (helpObject != value)
                {
                    helpObject = value;
                    GenesisNode gn = helpObject as GenesisNode;
                    if (gn != null)
                    {
                        helpText.text += HelpTools.GenerateHelpText(gn);
                    }
                    this.expanded = true;
                    titleText.text = string.Format("Help: {0}", (helpObject as BaseNode).name);
                }

            }
        }

        public BaseGraphView owner { private set; get; }

        public HelpWindow()
        {
            var stylesheet = Resources.Load<StyleSheet>("GenesisCommon");
            if (!styleSheets.Contains(stylesheet))
                styleSheets.Add(stylesheet);
            style.width = 300;
            style.flexShrink = 1;
            helpText = new Label();
            helpText.style.whiteSpace = WhiteSpace.Normal;
            helpText.style.unityTextAlign = TextAnchor.UpperLeft;
            helpText.style.fontSize = 12;
            helpText.style.paddingLeft = 6;
            helpText.style.paddingRight = 6;
            helpText.style.paddingTop = 4;
            helpText.style.paddingBottom = 4;
            helpText.style.height = StyleKeyword.Auto;
            helpText.enableRichText = true;
            helpText.style.flexShrink = 0;


            scrollView = new ScrollView
            {
                name = "scrollview",
                verticalScrollerVisibility = ScrollerVisibility.Auto,
                horizontalScrollerVisibility = ScrollerVisibility.Hidden
            };
            scrollView.style.height = 500;
            scrollView.style.flexGrow = 1;
            scrollView.Add(helpText);

            contentContainer.Add(scrollView);

            titleText = new Label();
            titleText.style.fontSize = 14;
            titleText.enableRichText = false;
            titleText.text = "Help";
            titleContainer.Add(titleText);

            capabilities -= Capabilities.Renamable;
            capabilities -= Capabilities.Copiable;
            capabilities -= Capabilities.Groupable;
            capabilities -= Capabilities.Renamable;

            minIcon = new Image { scaleMode = ScaleMode.ScaleToFit, name = "minmax" };

            if (expanded)
                minIcon.image = EditorUtilities.minimizeIcon;
            else
                minIcon.image = EditorUtilities.maximizeIcon;

            minMaxButton = new Button(() =>
            {
                minMax();
            });
            minMaxButton.Add(minIcon);
            minMaxButton.AddToClassList("MinimizeButton");
            titleContainer.Add(minMaxButton);
        }

        public HelpWindow(object helpObject)
        {
            var stylesheet = Resources.Load<StyleSheet>("GenesisCommon");
            if (!styleSheets.Contains(stylesheet))
                styleSheets.Add(stylesheet);
            style.width = 300;
            style.flexShrink = 1;
            helpText = new Label();
            helpText.style.whiteSpace = WhiteSpace.Normal;
            helpText.style.unityTextAlign = TextAnchor.UpperLeft;
            helpText.style.fontSize = 12;
            helpText.style.paddingLeft = 6;
            helpText.style.paddingRight = 6;
            helpText.style.paddingTop = 4;
            helpText.style.paddingBottom = 4;
            helpText.style.height = StyleKeyword.Auto;
            helpText.enableRichText = true;
            helpText.style.flexShrink = 0;

            scrollView = new ScrollView
            {
                name = "scrollview",
                verticalScrollerVisibility = ScrollerVisibility.Auto,
                horizontalScrollerVisibility = ScrollerVisibility.Hidden
            };
            scrollView.style.height = 500;
            scrollView.style.flexGrow = 1;
            scrollView.Add(helpText);

            contentContainer.Add(scrollView);
            titleText = new Label();
            titleText.style.fontSize = 14;
            titleText.enableRichText = false;
            titleText.text = "Help";
            titleContainer.Add(titleText);
            capabilities -= Capabilities.Renamable;
            capabilities -= Capabilities.Copiable;
            capabilities -= Capabilities.Groupable;
            capabilities -= Capabilities.Renamable;
            minIcon = new Image { scaleMode = ScaleMode.ScaleToFit, name = "minmax" };

            if (expanded)
                minIcon.image = EditorUtilities.minimizeIcon;
            else
                minIcon.image = EditorUtilities.maximizeIcon;

            minMaxButton = new Button(() =>
            {
                minMax();
            });
            minMaxButton.Add(minIcon);
            minMaxButton.AddToClassList("MinimizeButton");
            titleContainer.Add(minMaxButton);
        }

        public void minMax()
        {
            if (this.expanded)
            {
                this.ToggleCollapse();
                minIcon.image = EditorUtilities.maximizeIcon;
                minMaxButton.Add(minIcon);
                minIcon.MarkDirtyRepaint();
                scrollView.Remove(helpText);
                scrollView.style.height = 35;
            }
            else
            {
                ToggleCollapse();
                minIcon.image = EditorUtilities.minimizeIcon;
                minMaxButton.Add(minIcon);
                minIcon.MarkDirtyRepaint();
                scrollView.Add(helpText);
                scrollView.style.height = 500;

            }
        }
    }
}