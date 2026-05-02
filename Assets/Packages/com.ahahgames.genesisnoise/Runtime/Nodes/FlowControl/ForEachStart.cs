using GraphProcessor;

using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Begins a for-each loop flow block over a collection input.

The loop carries an input value between iterations while also exposing the current item, item index, and collection count.
")]
    [System.Serializable, NodeMenuItem("Conditional/For Each Start"), NodeMenuItem("Conditional/For Each")]
    public class ForEachStart : GenesisNode, ILoopStart
    {
        [Input]
        public object input;

        [Input("Collection")]
        public object collection;

        [Output]
        public object output;

        [System.NonSerialized]
        [Output("Item")]
        public object item;

        [System.NonSerialized]
        [Output("Index")]
        public int index = 0;

        [Output("Count")]
        public int outputCount = 0;

        [HideInInspector, SerializeField]
        SerializableType inputType = new(typeof(object));

        [HideInInspector, SerializeField]
        SerializableType collectionType = new(typeof(object));

        [HideInInspector, SerializeField]
        SerializableType itemType = new(typeof(object));

        [NonSerialized]
        List<object> cachedItems = new();

        public override string name => "For Each Start";
        public override string NodeGroup => "Conditional";
        public override bool hasPreview => false;
        public override bool hasSettings => false;
        public override bool showDefaultInspector => true;
        public override float nodeWidth => GenesisNoiseUtility.smallNodeWidth;

        public object CurrentLoopValue
        {
            get => output;
            set => output = value;
        }

        [CustomPortBehavior(nameof(input))]
        public IEnumerable<PortData> InputPortType(List<SerializableEdge> edges)
        {
            yield return GenesisNoiseUtility.UpdateInputPortType(ref inputType, "Input", edges);
        }

        [CustomPortBehavior(nameof(collection))]
        public IEnumerable<PortData> CollectionInputPortType(List<SerializableEdge> edges)
        {
            collectionType.type = ResolveCollectionType(edges);
            itemType.type = GetCollectionElementType(collectionType.type);

            yield return new PortData
            {
                identifier = nameof(collection),
                displayName = "Collection",
                acceptMultipleEdges = false,
                displayType = collectionType.type,
            };
        }

        [CustomPortBehavior(nameof(output))]
        public IEnumerable<PortData> OutputPortType(List<SerializableEdge> edges)
        {
            yield return new PortData
            {
                identifier = nameof(output),
                displayName = "Output",
                acceptMultipleEdges = true,
                displayType = inputType.type,
            };
        }

        [CustomPortBehavior(nameof(item))]
        public IEnumerable<PortData> ItemOutputPortType(List<SerializableEdge> edges)
        {
            yield return new PortData
            {
                identifier = nameof(item),
                displayName = "Item",
                acceptMultipleEdges = true,
                displayType = itemType.type,
            };
        }

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (cachedItems != null && cachedItems.Count > 0)
            {
                int currentIndex = Mathf.Clamp(index, 0, cachedItems.Count - 1);
                item = cachedItems[currentIndex];
            }
            else
            {
                item = null;
            }

            index++;
            return true;
        }

        public void UpdateLoopState()
        {
            outputCount = cachedItems?.Count ?? 0;
        }

        public bool IsLastIteration() => index >= outputCount || outputCount <= 0;

        public bool CanEnterLoop() => outputCount > 0;

        public Type GetLoopValueType() => inputType.type;

        public void PrepareLoopStart()
        {
            if (inputPorts != null && inputPorts.Count > 0)
                inputPorts.PullDatas();

            cachedItems = ConvertCollectionToList(collection);
            outputCount = cachedItems.Count;
            output = input;
            item = null;
            index = 0;
        }

        Type ResolveCollectionType(List<SerializableEdge> edges)
        {
            if (TryGetConnectedPortType(edges, out var resolvedType))
                return resolvedType;

            if (inputPorts != null)
            {
                foreach (var port in inputPorts)
                {
                    if (port.fieldName != nameof(collection))
                        continue;

                    if (TryGetConnectedPortType(port.GetEdges(), out resolvedType))
                        return resolvedType;
                }
            }

            return typeof(object);
        }

        static bool TryGetConnectedPortType(List<SerializableEdge> edges, out Type resolvedType)
        {
            if (edges != null && edges.Count > 0)
            {
                var edge = edges[0];
                resolvedType = edge.outputPort.portData.displayType ?? edge.outputPort.fieldInfo.FieldType;
                return resolvedType != null;
            }

            resolvedType = null;
            return false;
        }

        static Type GetCollectionElementType(Type sourceType)
        {
            if (sourceType == null || sourceType == typeof(object) || sourceType == typeof(string))
                return sourceType ?? typeof(object);

            if (sourceType.IsArray)
                return sourceType.GetElementType() ?? typeof(object);

            var enumerableType = sourceType
                .GetInterfaces()
                .Concat(new[] { sourceType })
                .FirstOrDefault(t => t.IsGenericType && t.GetGenericTypeDefinition() == typeof(IEnumerable<>));

            return enumerableType?.GetGenericArguments()[0] ?? typeof(object);
        }

        static List<object> ConvertCollectionToList(object source)
        {
            List<object> values = new();

            if (source == null)
                return values;

            if (source is string)
            {
                values.Add(source);
                return values;
            }

            if (source is IEnumerable enumerable)
            {
                foreach (var value in enumerable)
                    values.Add(value);

                return values;
            }

            values.Add(source);
            return values;
        }
    }
}
