using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class GenesisNoiseValueReturnDrawer : GenesisPropertyDrawer
    {
        public enum NoiseValueReturn
        {
            [InspectorName("Distance")]
            Distance = 0,
            [InspectorName("Distance 2")]
            Distance2 = 1,
            [InspectorName("Distance 2 Add")]
            Distance2Add = 2,
            [InspectorName("Distance 2 Sub")]
            Distance2Sub = 3,
            [InspectorName("Distance 2 Mul")]
            Distance2Mul = 4,
            [InspectorName("Distance 2 Div")]
            Distance2Div = 5,
        }

        protected override void DrawerGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor, GenesisGraph graph, GenesisNodeView nodeView)
        {
            EditorGUI.BeginChangeCheck();
            int value = (int)(NoiseValueReturn)EditorGUI.EnumPopup(position, label, (NoiseValueReturn)(int)prop.floatValue);
            if (EditorGUI.EndChangeCheck())
                prop.floatValue = (float)value;
        }
    }
}