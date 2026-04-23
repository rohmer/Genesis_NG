using AhahGames.GenesisNoise.Views;

using GraphProcessor;

using UnityEngine.UIElements;
namespace AhahGames.GenesisNoise.Graph
{
    public class GenesisExposedParameterPropertyView : VisualElement
    {
        protected GenesisGraphView genesisGraphView;

        public ExposedParameter parameter { get; private set; }

        public Toggle hideInInspector { get; private set; }

        public GenesisExposedParameterPropertyView(BaseGraphView graphView, ExposedParameter param)
        {
            genesisGraphView = graphView as GenesisGraphView;
            parameter = param;

            var valueField = graphView.exposedParameterFactory.GetParameterValueField(param, (newValue) =>
            {
                graphView.RegisterCompleteObjectUndo("Updated Parameter Value");
                param.value = newValue;
                graphView.graph.NotifyExposedParameterValueChanged(param);
                genesisGraphView.ProcessGraph();
            });

            var field = graphView.exposedParameterFactory.GetParameterSettingsField(param, (newValue) =>
            {
                param.settings = newValue as ExposedParameter.Settings;
            });

            Add(valueField);

            Add(field);
        }
    }
}