using UnityEngine;

namespace AhahGames.GenesisNoise.Graph
{
    [System.Serializable]
    public class GenesisMesh
    {
        public Mesh mesh;
        public Matrix4x4 localToWorld = Matrix4x4.identity;

        public GenesisMesh(Mesh mesh = null) : this(mesh, Matrix4x4.identity) { }

        public GenesisMesh(Mesh mesh, Matrix4x4 localToWorld)
        {
            this.mesh = mesh;
            this.localToWorld = localToWorld;
        }

        public GenesisMesh Clone()
        {
            var clonedMesh = new Mesh { indexFormat = mesh.indexFormat };
            clonedMesh.vertices = mesh.vertices;
            clonedMesh.triangles = mesh.triangles;
            clonedMesh.normals = mesh.normals;
            clonedMesh.uv = mesh.uv;
            clonedMesh.bounds = mesh.bounds;
            clonedMesh.colors = mesh.colors;
            clonedMesh.colors32 = mesh.colors32;
            return new GenesisMesh(clonedMesh, localToWorld);
        }
    }
}