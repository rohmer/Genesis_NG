using GraphProcessor;

using System;
using System.Collections.Generic;

using UnityEditor.Experimental.GraphView;

using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Graph
{
    public class GenesisParameterView : ExposedParameterView
    {
        static readonly string mixtureParameterStyleSheet = "MixtureParameterView";

        public GenesisParameterView()
        {
            var style = Resources.Load<StyleSheet>(mixtureParameterStyleSheet);
            if (style != null)
                styleSheets.Add(style);
        }

        protected override IEnumerable<Type> GetExposedParameterTypes()
        {
            // We only accept these types:
            yield return typeof(TextureParameter);
            yield return typeof(Texture3DParameter);
            yield return typeof(CubemapParameter);
            yield return typeof(GradientParameter);

            yield return typeof(MeshParameter);
            yield return typeof(StringParameter);

        }

        protected override void UpdateParameterList()
        {
            content.Clear();

            foreach (var param in graphView.graph.exposedParameters)
            {
                var row = new BlackboardRow(new ExposedParameterFieldView(graphView, param), new GenesisExposedParameterPropertyView(graphView, param));
                row.expanded = param.settings.expanded;
                row.RegisterCallback<GeometryChangedEvent>(e =>
                {
                    param.settings.expanded = row.expanded;
                });

                content.Add(row);
            }
        }
    }
}