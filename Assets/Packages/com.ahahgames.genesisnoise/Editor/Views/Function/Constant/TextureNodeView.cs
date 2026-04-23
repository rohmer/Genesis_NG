using AhahGames.GenesisNoise.Views;

using GraphProcessor;

using UnityEditor.UIElements;

using UnityEngine;
using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Nodes
{
    [NodeCustomEditor(typeof(TextureNode))]
    public class TextureNodeView : GenesisNodeView
    {
        TextureNode textureNode => nodeTarget as TextureNode;

        public override void Enable(bool fromInspector)
        {
            base.Enable(fromInspector);
            var textureField = this.Q(className: "unity-object-field") as ObjectField;

            var potConversionSettings = this.Q(nameof(TextureNode.POTMode));
            UpdatePOTSettingsVisibility(textureNode.textureAsset);

            // TODO: watch for texture asset changes (need the scripted importer thing)

            textureField.RegisterValueChangedCallback(e =>
            {
                if (e.newValue is Texture t && t != null)
                    UpdatePOTSettingsVisibility(t);
                ForceUpdatePorts();
            });

            void UpdatePOTSettingsVisibility(Texture t)
            {
                bool isPOT = true;

                if (t != null)
                    isPOT = textureNode.IsPowerOf2(t);

                potConversionSettings.style.display = isPOT ? DisplayStyle.None : DisplayStyle.Flex;
            }
        }
    }
}