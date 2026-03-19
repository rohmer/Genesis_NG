using SharpVoronoiLib;

using System;
using System.Collections.Generic;
using System.Linq;

namespace AhahGames.GenesisNoise.GNTerrain
{
    //TODO: This may all end up internal

    public class TerrainGeometry
    {
        public PointGenerationData pointGenerationData;

        public VoronoiPlane plane;

        public bool UseCoasts;

        int Size;

        public TerrainGeometry(PointGenerationData data)
        {
            pointGenerationData = data;
            Size=pointGenerationData.GetSize();
            plane = new VoronoiPlane(
                0,
                0,
                data.GetSize(),
                data.GetSize());
            List<VoronoiSite> sites = new List<VoronoiSite>(data.Points.Count);
            foreach (var pt in data.Points)
            {
                sites.Add(new VoronoiSite(pt.x, pt.y));
            }
            plane.SetSites(sites);
        }

        public void Compute(bool relax, int iterations, float strength)
        {
            plane.Tessellate();
            if (relax)
            {
                plane.Relax(iterations, strength);
            }            
        }

        public List<VoronoiEdge> GetEdges()
        {
            return plane.Edges;
        }
    }
}