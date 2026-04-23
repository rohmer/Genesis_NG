using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Views;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.PropertyDrawers
{
    public class GenesisMultiNoiseTypeDrawer : GenesisPropertyDrawer
    {
        public enum NoiseType
        {
            //[Enum(,4,BillowVoronoi,5,TurbulenceVoronoi,6,WarpingValue,7)]_Mode("Mode", int) = 0
            [InspectorName("FBM Value")]
            One = 0,
            [InspectorName("Ridge Value")]
            Two = 1,
            [InspectorName("Billow Value")]
            Three = 2,
            [InspectorName("Turbulence Value")]
            Four = 3,
            [InspectorName("FBM Vornoi")]
            Five = 4,
            [InspectorName("Billow Value")]
            Six = 6,
            [InspectorName("Turbulence Voronoi Value")]
            Seven= 7,
            [InspectorName("Warping Value")]
            Eight = 8
        }

        protected override void DrawerGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor, GenesisGraph graph, GenesisNodeView nodeView)
        {
            EditorGUI.BeginChangeCheck();
            int value = (int)(NoiseType)EditorGUI.EnumPopup(position, label, (NoiseType)(int)prop.floatValue);
            if (EditorGUI.EndChangeCheck())
                prop.floatValue = (float)value;
        }
    }

}