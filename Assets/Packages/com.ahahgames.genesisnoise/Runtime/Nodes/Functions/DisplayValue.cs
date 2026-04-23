using System;

using UnityEditor.UIElements;

using UnityEngine;
using UnityEngine.UIElements;

namespace AhahGames.GenesisNoise.Nodes
{
    public class DisplayValue
    {
        VisualElement controlsContainer;
        TextField tf;
        ColorField cf;
        CurveField curveField;
        ObjectField objField;

        string fieldLabel;

        public DisplayValue(VisualElement controlsContainer, Type objectType, string fieldLabel = "")
        {
            this.fieldLabel = fieldLabel;
            this.controlsContainer = controlsContainer;
            if (objectType == typeof(string) ||
                objectType == typeof(int) ||
                objectType == typeof(float) ||
                objectType == typeof(bool) ||
                objectType == typeof(Vector2) ||
                objectType == typeof(Vector3) ||
                objectType == typeof(Vector4) ||
                objectType == typeof(Vector2Int) ||
                objectType == typeof(Vector3Int))
            {
                tf = new TextField(fieldLabel);
                controlsContainer.Add(tf);
            }
            if (objectType == typeof(Color))
            {
                cf = new ColorField(fieldLabel);
                controlsContainer.Add(cf);
            }
            if (objectType == typeof(AnimationCurve))
            {
                curveField = new CurveField(fieldLabel);
                controlsContainer.Add(curveField);
            }
            if (objectType == typeof(Texture))
            {
                objField = new ObjectField(fieldLabel);
                controlsContainer.Add(objField);
            }
        }

        public void SetValue(object value)
        {
            if (value.GetType() == typeof(string) ||
                value.GetType() == typeof(int) ||
                value.GetType() == typeof(float) ||
                value.GetType() == typeof(bool) ||
                value.GetType() == typeof(Vector2) ||
                value.GetType() == typeof(Vector3) ||
                value.GetType() == typeof(Vector4) ||
                value.GetType() == typeof(Vector2Int) ||
                value.GetType() == typeof(Vector3Int) ||
                value.GetType() == typeof(Quaternion))
            {
                if (tf != null)
                {
                    tf.value = value.ToString();
                    tf.MarkDirtyRepaint();
                    return;
                }

                if (cf != null)
                {
                    controlsContainer.Remove(cf);
                    cf = null;
                }
                if (curveField != null)
                {
                    controlsContainer.Remove(curveField);
                    curveField = null;
                }
                tf = new TextField(fieldLabel);
                tf.value = value.ToString();
                tf.MarkDirtyRepaint();
                controlsContainer.Add(tf);
            }

            if (value.GetType() == typeof(Color))
            {
                if (cf != null)
                {
                    cf.value = (Color)value;
                    cf.MarkDirtyRepaint();
                    return;
                }
                if (tf != null)
                {
                    controlsContainer.Remove(tf);
                    tf = null;
                }
                if (curveField != null)
                {
                    controlsContainer.Remove(curveField);
                    curveField = null;
                }
                cf = new ColorField(fieldLabel);
                cf.value = (Color)value;
                controlsContainer.Add(cf);
                cf.MarkDirtyRepaint();
            }
            if (value.GetType() == typeof(AnimationCurve))
            {
                if (curveField != null)
                {
                    curveField.value = (AnimationCurve)value;
                    curveField.MarkDirtyRepaint();
                    return;
                }
                if (tf != null)
                {
                    controlsContainer.Remove(tf);
                    tf = null;
                }
                if (cf != null)
                {
                    controlsContainer.Remove(cf);
                    cf = null;
                }
                curveField = new CurveField(fieldLabel);
                curveField.value = (AnimationCurve)value;
                controlsContainer.Add(curveField);
                curveField.MarkDirtyRepaint();
            }
            if (value.GetType() == typeof(UnityEngine.Texture2D))
            {
                if (objField != null)
                {
                    objField.value = (UnityEngine.Object)value;
                    objField.MarkDirtyRepaint();
                    return;
                }
                if (curveField != null)
                {
                    controlsContainer.Remove(curveField); ;
                    curveField = null;
                }
                if (tf != null)
                {
                    controlsContainer.Remove(tf);
                    tf = null;
                }
                if (cf != null)
                {
                    controlsContainer.Remove(cf);
                    cf = null;
                }
                objField = new ObjectField(fieldLabel);
                objField.value = (Texture2D)value;
                controlsContainer.Add(objField);
                objField.MarkDirtyRepaint();
            }
        }
    }
}