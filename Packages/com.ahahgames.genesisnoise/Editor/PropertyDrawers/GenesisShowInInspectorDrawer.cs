using UnityEditor;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class ShowInInspectorDecorator : GenesisPropertyDrawer
    {
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor) => 0;
    }
}