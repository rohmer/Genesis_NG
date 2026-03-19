namespace AhahGames.GenesisNoise.Graph
{
    [System.Serializable]
    public class Variable
    {
        public string Name { get; set; }
        public object Value
        {
            get
            {
                return Value;
            }
            set
            {
                Value = value;
            }
        }
        public int IteratorMax = 0;

        public enum eVariableType
        {
            Float,
            Int,
            Vector2,
            Vector3,
            Vector4,
            Color,
            Iterator,
            String
        }

        public eVariableType VariableObjectType
        {
            get
            {
                if (Value.GetType() == typeof(float)) return eVariableType.Float;
                if (Value.GetType() == typeof(int)) return eVariableType.Int;
                if (Value.GetType() == typeof(UnityEngine.Vector2)) return eVariableType.Vector2;
                if (Value.GetType() == typeof(UnityEngine.Vector3)) return eVariableType.Vector3;
                if (Value.GetType() == typeof(UnityEngine.Vector4)) return eVariableType.Vector4;
                if (Value.GetType() == typeof(UnityEngine.Color)) return eVariableType.Color;
                if (Value.GetType() == typeof(string)) return eVariableType.String;
                return eVariableType.Iterator;
            }
        }

        public Variable(string name, int value, int iteratorMax = 0)
        {
            Name = name;
            Value = (object)value; // Cast int to object
            IteratorMax = iteratorMax;
        }

        public Variable(string name, object value)
        {
            Name = name;
            Value = value;
        }

        public override string ToString()
        {
            return $"{Name}: {Value}";
        }

        public static Variable operator +(Variable variable, object value)
        {
            return new Variable(variable.Name, (dynamic)variable.Value + value);
        }

        public static Variable operator -(Variable variable, object value)
        {
            return new Variable(variable.Name, (dynamic)variable.Value - value);
        }

        public static Variable operator *(Variable variable, object value)
        {
            return new Variable(variable.Name, (dynamic)variable.Value * value);
        }

        public static Variable operator /(Variable variable, object value)
        {
            return new Variable(variable.Name, (dynamic)variable.Value / value);
        }

        public static Variable operator +(Variable variable1, Variable variable2)
        {
            return new Variable(variable1.Name + " + " + variable2.Name, (dynamic)variable1.Value + variable2.Value);
        }

        public static Variable operator -(Variable variable1, Variable variable2)
        {
            return new Variable(variable1.Name + " - " + variable2.Name, (dynamic)variable1.Value - variable2.Value);
        }

        public static Variable operator *(Variable variable1, Variable variable2)
        {
            return new Variable(variable1.Name + " * " + variable2.Name, (dynamic)variable1.Value * variable2.Value);
        }

        public static Variable operator /(Variable variable1, Variable variable2)
        {
            return new Variable(variable1.Name + " / " + variable2.Name, (dynamic)variable1.Value / variable2.Value);
        }


        public int ToInt()
        {
            switch (VariableObjectType)
            {
                case eVariableType.Float:
                    return (int)(object)Value;
                case eVariableType.Int:
                    return (int)(object)Value;
                case eVariableType.Vector2:
                    return (int)((UnityEngine.Vector2)(object)Value).magnitude;
                case eVariableType.Vector3:
                    return (int)((UnityEngine.Vector3)(object)Value).magnitude;
                case eVariableType.Vector4:
                    return (int)((UnityEngine.Vector4)(object)Value).magnitude;
                case eVariableType.Color:
                    return (int)((UnityEngine.Color)(object)Value).grayscale * 255; // Convert color to grayscale and scale
                case eVariableType.Iterator:
                    return (int)(object)Value; // Assuming Value is an int for Iterator 
                default:
                    return 0; // Default case for unsupported types
            }
        }

        float ToFloat()
        {
            switch (VariableObjectType)
            {
                case eVariableType.Float:
                    return (float)(object)Value;
                case eVariableType.Int:
                    return (int)(object)Value;
                case eVariableType.Vector2:
                    return ((UnityEngine.Vector2)(object)Value).magnitude;
                case eVariableType.Vector3:
                    return ((UnityEngine.Vector3)(object)Value).magnitude;
                case eVariableType.Vector4:
                    return ((UnityEngine.Vector4)(object)Value).magnitude;
                case eVariableType.Color:
                    return ((UnityEngine.Color)(object)Value).grayscale; // Convert color to grayscale
                case eVariableType.Iterator:
                    return (float)(object)Value; // Assuming Value is a float for Iterator
                default:
                    return 0f; // Default case for unsupported types
            }
        }

        public UnityEngine.Vector2 ToVector2()
        {
            if (VariableObjectType == eVariableType.Vector2)
                return (UnityEngine.Vector2)(object)Value;
            if (VariableObjectType == eVariableType.Vector3)
                return new UnityEngine.Vector2(((UnityEngine.Vector3)(object)Value).x, ((UnityEngine.Vector3)(object)Value).y);
            if (VariableObjectType == eVariableType.Vector4)
                return new UnityEngine.Vector2(((UnityEngine.Vector4)(object)Value).x, ((UnityEngine.Vector4)(object)Value).y);
            if (VariableObjectType == eVariableType.Float || VariableObjectType == eVariableType.Int)
                return new UnityEngine.Vector2(ToFloat(), ToFloat());
            if (VariableObjectType == eVariableType.Color)
                return new UnityEngine.Vector2(((UnityEngine.Color)(object)Value).r, ((UnityEngine.Color)(object)Value).g);
            if (VariableObjectType == eVariableType.Iterator)
                return new UnityEngine.Vector2((float)(object)Value, (float)(object)Value); // Assuming Value is a float for Iterator
            if (VariableObjectType == eVariableType.String)
            {
                // Attempt to parse string to Vector2, if applicable
                var parts = ((string)(object)Value).Split(',');
                if (parts.Length >= 2 && float.TryParse(parts[0], out float x) && float.TryParse(parts[1], out float y))
                {
                    return new UnityEngine.Vector2(x, y);
                }
            }
            return UnityEngine.Vector2.zero; // Default case for unsupported types
        }

        public UnityEngine.Vector3 ToVector3()
        {
            if (VariableObjectType == eVariableType.Vector3)
                return (UnityEngine.Vector3)(object)Value;
            if (VariableObjectType == eVariableType.Vector2)
                return new UnityEngine.Vector3(((UnityEngine.Vector2)(object)Value).x, ((UnityEngine.Vector2)(object)Value).y, 0f);
            if (VariableObjectType == eVariableType.Vector4)
                return new UnityEngine.Vector3(((UnityEngine.Vector4)(object)Value).x, ((UnityEngine.Vector4)(object)Value).y, ((UnityEngine.Vector4)(object)Value).z);
            if (VariableObjectType == eVariableType.Float || VariableObjectType == eVariableType.Int)
                return new UnityEngine.Vector3(ToFloat(), ToFloat(), 0f);
            if (VariableObjectType == eVariableType.Color)
                return new UnityEngine.Vector3(((UnityEngine.Color)(object)Value).r, ((UnityEngine.Color)(object)Value).g, ((UnityEngine.Color)(object)Value).b);
            if (VariableObjectType == eVariableType.Iterator)
                return new UnityEngine.Vector3((float)(object)Value, (float)(object)Value, 0f); // Assuming Value is a float for Iterator
            if (VariableObjectType == eVariableType.String)
            {
                // Attempt to parse string to Vector3, if applicable
                var parts = ((string)(object)Value).Split(',');
                if (parts.Length >= 3 && float.TryParse(parts[0], out float x) && float.TryParse(parts[1], out float y) && float.TryParse(parts[2], out float z))
                {
                    return new UnityEngine.Vector3(x, y, z);
                }
            }
            return UnityEngine.Vector3.zero; // Default case for unsupported types
        }

        public UnityEngine.Vector4 ToVector4()
        {
            if (VariableObjectType == eVariableType.Vector4)
                return (UnityEngine.Vector4)(object)Value;
            if (VariableObjectType == eVariableType.Vector2)
                return new UnityEngine.Vector4(((UnityEngine.Vector2)(object)Value).x, ((UnityEngine.Vector2)(object)Value).y, 0f, 0f);
            if (VariableObjectType == eVariableType.Vector3)
                return new UnityEngine.Vector4(((UnityEngine.Vector3)(object)Value).x, ((UnityEngine.Vector3)(object)Value).y, ((UnityEngine.Vector3)(object)Value).z, 0f);
            if (VariableObjectType == eVariableType.Float || VariableObjectType == eVariableType.Int)
                return new UnityEngine.Vector4(ToFloat(), ToFloat(), 0f, 0f);
            if (VariableObjectType == eVariableType.Color)
                return new UnityEngine.Vector4(((UnityEngine.Color)(object)Value).r, ((UnityEngine.Color)(object)Value).g, ((UnityEngine.Color)(object)Value).b, ((UnityEngine.Color)(object)Value).a);
            if (VariableObjectType == eVariableType.Iterator)
                return new UnityEngine.Vector4((float)(object)Value, (float)(object)Value, 0f, 0f); // Assuming Value is a float for Iterator
            if (VariableObjectType == eVariableType.String)
            {
                // Attempt to parse string to Vector4, if applicable
                var parts = ((string)(object)Value).Split(',');
                if (parts.Length >= 4 && float.TryParse(parts[0], out float x) && float.TryParse(parts[1], out float y) && float.TryParse(parts[2], out float z) && float.TryParse(parts[3], out float w))
                {
                    return new UnityEngine.Vector4(x, y, z, w);
                }
            }
            return UnityEngine.Vector4.zero; // Default case for unsupported types
        }
    }
}