using System;
using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Graph
{
    [Serializable]
    public class VariableStorage
    {
        Dictionary<string, Variable> variables;
        public VariableStorage()
        {
            variables = new Dictionary<string, Variable>();
        }

        public Variable GetVariable(string name)
        {
            if (variables.TryGetValue(name, out var variable))
            {
                return variable;
            }
            return null;
        }

        public void SetVariable(string name, Variable variable)
        {
            if (variables.ContainsKey(name))
            {
                variables[name] = variable;
            }
            else
            {
                variables.Add(name, variable);
            }
        }

        public void RemoveVariable(string name)
        {
            if (variables.ContainsKey(name))
            {
                variables.Remove(name);
            }
        }

        public bool ContainsVariable(string name)
        {
            return variables.ContainsKey(name);
        }

        public bool AddIterator(string name, int value, int MaxValue)
        {
            if (!variables.ContainsKey(name))
            {
                variables[name] = new Variable(name, value, MaxValue);
                return true;
            }
            return false;
        }

        public bool SetIterator(string name, int value, int MaxValue)
        {
            if (variables.ContainsKey(name))
            {
                variables[name].IteratorMax = MaxValue;
                variables[name].Value = value;
                return true;
            }
            return false;
        }

        public bool IteratorGreaterThan(string name, int value)
        {
            if (variables.ContainsKey(name))
            {
                if (variables[name].VariableObjectType != Variable.eVariableType.Iterator)
                {
                    {
                        throw new Exception($"Variable {name} is not an iterator type.");
                    }
                }
                return (int)variables[name].IteratorMax < value;
            }
            return false;
        }

        public bool IteratorGreaterEqualTo(string name, int value)
        {
            if (variables.ContainsKey(name))
            {
                if (variables[name].VariableObjectType != Variable.eVariableType.Iterator)
                {
                    {
                        throw new Exception($"Variable {name} is not an iterator type.");
                    }
                }
                return (int)variables[name].IteratorMax <= value;
            }
            return false;
        }

        public bool IteratorLessThan(string name, int value)
        {
            if (variables.ContainsKey(name))
            {
                if (variables[name].VariableObjectType != Variable.eVariableType.Iterator)
                {
                    {
                        throw new Exception($"Variable {name} is not an iterator type.");
                    }
                }
                return (int)variables[name].IteratorMax > value;
            }
            return false;
        }

        public bool IteratorLessEqualTo(string name, int value)
        {
            if (variables.ContainsKey(name))
            {
                if (variables[name].VariableObjectType != Variable.eVariableType.Iterator)
                {
                    {
                        throw new Exception($"Variable {name} is not an iterator type.");
                    }
                }
                return (int)variables[name].IteratorMax >= value;
            }
            return false;
        }
    }
}