using System.Linq;

using UnityEditor;
using UnityEditor.UIElements;

using UnityEngine;
using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise
{
    public static class PropertyToElement
    {
        public static VisualElement GetElement(MaterialProperty property, Material material, int idx)
        {
            if (property.name.Contains("Vector2"))
                return vector2Property(property);
            if (property.name.Contains("Vector3"))
                return vector3Property(property);
            if (property.name.Contains("Vector4"))
                return vector4Property(property);
            if (property.propertyType == UnityEngine.Rendering.ShaderPropertyType.Range)
            {
                if (material.shader.GetPropertyAttributes(idx).Any(a => a.Contains("IntRange")))
                    return intRangeProperty(property);
                else
                    return floatRangeProperty(property);
            }
            if (property.propertyType == UnityEngine.Rendering.ShaderPropertyType.Color)
            {
                return colorProperty(property);
            }
            if (property.propertyType == UnityEngine.Rendering.ShaderPropertyType.Texture)
                return textureProperty(property);
            if (property.propertyType == UnityEngine.Rendering.ShaderPropertyType.Int)
                return intProperty(property);
            if (property.propertyType == UnityEngine.Rendering.ShaderPropertyType.Float)
                return floatProperty(property);
            return objectProperty(property);



        }
        private static VisualElement textureProperty(MaterialProperty property)
        {
            VisualElement propertyEditor = new ObjectField(property.displayName);
            (propertyEditor as ObjectField).value = property.textureValue;

            propertyEditor.RegisterCallback<ChangeEvent<Texture>>(e =>
            {
                property.textureValue = e.newValue;
            });
            return propertyEditor;
        }

        private static VisualElement floatRangeProperty(MaterialProperty property)
        {
            VisualElement propertyEditor = new Slider(property.displayName, property.rangeLimits.x, property.rangeLimits.y);
            (propertyEditor as Slider).value = property.floatValue;

            propertyEditor.RegisterCallback<ChangeEvent<float>>(e =>
            {
                property.floatValue = e.newValue;
            });
            return propertyEditor;
        }

        private static VisualElement intRangeProperty(MaterialProperty property)
        {
            VisualElement propertyEditor = new SliderInt(property.displayName, (int)property.rangeLimits.x, (int)property.rangeLimits.y);
            (propertyEditor as SliderInt).value = property.intValue;
            propertyEditor.RegisterCallback<ChangeEvent<int>>(e =>
            {
                property.intValue = e.newValue;
            });
            return propertyEditor;
        }

        private static VisualElement floatProperty(MaterialProperty property)
        {
            VisualElement propertyEditor = new FloatField(property.displayName);
            (propertyEditor as FloatField).value = property.floatValue;
            propertyEditor.RegisterCallback<ChangeEvent<float>>(e =>
            {
                property.floatValue = e.newValue;
            });
            return propertyEditor;
        }

        private static VisualElement intProperty(MaterialProperty property)
        {
            VisualElement propertyEditor = new IntegerField(property.displayName);
            (propertyEditor as IntegerField).value = property.intValue;
            propertyEditor.RegisterCallback<ChangeEvent<int>>(e =>
            {
                property.intValue = e.newValue;
            });
            return propertyEditor;
        }

        private static VisualElement colorProperty(MaterialProperty property)
        {
            VisualElement propertyEditor = new ColorField(property.displayName);
            (propertyEditor as ColorField).value = property.colorValue;
            propertyEditor.RegisterCallback<ChangeEvent<Color>>(e =>
            {
                property.colorValue = e.newValue;
            });
            return propertyEditor;
        }

        private static VisualElement vector2Property(MaterialProperty property)
        {
            VisualElement propertyEditor = new Vector2Field(property.displayName);
            (propertyEditor as ColorField).value = property.vectorValue;
            propertyEditor.RegisterCallback<ChangeEvent<Vector2>>(e =>
            {
                property.vectorValue = e.newValue;
            });
            return propertyEditor;
        }

        private static VisualElement vector3Property(MaterialProperty property)
        {
            VisualElement propertyEditor = new Vector3Field(property.displayName);
            (propertyEditor as ColorField).value = property.vectorValue;
            propertyEditor.RegisterCallback<ChangeEvent<Vector3>>(e =>
            {
                property.vectorValue = e.newValue;
            });
            return propertyEditor;
        }

        private static VisualElement vector4Property(MaterialProperty property)
        {
            VisualElement propertyEditor = new Vector4Field(property.displayName);
            (propertyEditor as ColorField).value = property.vectorValue;
            propertyEditor.RegisterCallback<ChangeEvent<Vector4>>(e =>
            {
                property.vectorValue = e.newValue;
            });
            return propertyEditor;
        }

        private static VisualElement objectProperty(MaterialProperty property)
        {
            return new VisualElement();
        }

    }
}
