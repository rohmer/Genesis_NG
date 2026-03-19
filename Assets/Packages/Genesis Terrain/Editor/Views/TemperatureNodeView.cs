using global::AhahGames.GenesisNoise.GNTerrain.Nodes;
using global::AhahGames.GenesisNoise.Views;

using GraphProcessor;

using System;

using UnityEditor.UIElements;

using UnityEngine;
using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.GNTerrain.Views
{
    namespace AhahGames.GenesisNoise.GNTerrain.Views
    {
        [NodeCustomEditor(typeof(TemperatureNode))]
        public class TemperatureNodeView : GenesisNodeView
        {
            TemperatureNode node => nodeTarget as TemperatureNode;

            Toggle mapHeight;
            CurveField tempCurve;

            public override void Enable(bool fromInspector)
            {
                base.Enable(fromInspector);

                mapHeight = new Toggle("Scale to map height");
                mapHeight.value = node.ScaleToMapHeight;
                mapHeight.RegisterCallback<ChangeEvent<bool>>
                    (
                    e =>
                    {
                        node.ScaleToMapHeight = mapHeight.value;
                        node.createTemp();
                    }
                    );
                controlsContainer.Add(mapHeight);

                tempCurve = new CurveField("Temperature Curve");
                tempCurve.value = node.TemperatureCurve;
                tempCurve.RegisterCallback<ChangeEvent<AnimationCurve>>(
                    e =>
                    {
                        node.TemperatureCurve = tempCurve.value;
                        node.createTemp();
                    });
                controlsContainer.Add(tempCurve);
            }
        }
    }
}