int numSeeds;
float scale;
int genType;


struct Triangles
{
    float3 vertices[3];
};

StructuredBuffer<float3> SeedPoints : register(t0); // Input seed points
RWStructuredBuffer<Triangles> points : register(u0); // Output triangles

