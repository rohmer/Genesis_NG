using AhahGames.GenesisNoise.Graph;

using System;
using System.Collections;
using System.Collections.Generic;

using UnityEditor;

using UnityEngine;

namespace AhahGames.GenesisNoise.Tests
{
    public class TestGraph
    {
        public static GenesisGraph CreateTestGraph(ref string filename)
        {
            string tmp = "Temp/TestFiles";
            if (!System.IO.Directory.Exists(tmp))
            {
                System.IO.Directory.CreateDirectory(tmp);
            }
            if (string.IsNullOrEmpty(filename))
            {
                // Our default initialization case
                Guid guid = Guid.NewGuid();
                filename = guid.ToString()+".asset";
            }
            else
            {
                filename = System.IO.Path.Combine(tmp, filename + ".asset");                
            }

            var graph = ScriptableObject.CreateInstance<GenesisGraph>();
            ProjectWindowUtil.CreateAsset(graph, filename);
            Selection.activeObject = graph;
            graph.Filename = filename;

            return graph;
        }

        public static bool DeleteTestGraph(GenesisGraph graph)
        {
            bool finished = false;
            int i = 0;
            string filename = graph.Filename;
            Exception exception = null;
            while (!finished && i < 10)
            {
                try
                {
                    ScriptableObject.DestroyImmediate(graph);
                }
                catch (Exception e)
                {
                    exception = e;  
                }                
                i++;
                if(graph==null)
                    { finished = true; break; }
            }
            if(i>=10 && exception!=null)
            {
                Debug.LogException(exception);
                return false;
            }

            // Try to delete the file
            bool succeeded = false;
            try
            {
                if(!string.IsNullOrEmpty(filename))
                {
                    System.IO.File.Delete(filename);
                }
                succeeded = true;
            } catch(Exception e)
            {
                Debug.LogException(e);                
                succeeded = false;
            }

            return succeeded;
        }
    }

}