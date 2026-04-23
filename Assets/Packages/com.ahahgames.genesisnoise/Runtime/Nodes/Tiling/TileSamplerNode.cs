using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Purpose: tile-sample an atlas texture across UV space and pick/transform tiles per grid cell using seeded randomness, pattern modes (including Gaussian variants), optional pattern texture input, and per-instance jitter/rotation/scale/mirror.

Property	Type / Range	Description
_Atlas	2D texture	Atlas/tileset texture (row-major layout).
_UseAtlas	Int (0/1)	Enable/disable atlas sampling.
_Scale	Vector	Grid tiling across UVs (cells per unit).
_TilesCols	Int	Number of columns in the atlas.
_TilesRows	Int	Number of rows in the atlas.
_Density	Range(1,16)	Instances per cell (samples per cell).
_Jitter	Range(0,1)	Position jitter inside each cell.
_RotJitter	Range(0,6.283)	Rotation jitter in radians.
_ScaleMin / _ScaleMax	Range(0.01,2)	Per-instance scale range.
_MirrorChance	Range(0,1)	Probability of horizontal mirror per instance.
_Pattern	Enum	Pattern mode selector (see Pattern Types).
_PatternTex	2D texture	Optional pattern input to bias tile selection.
_UsePatternTex	Int (0/1)	Enable/disable pattern texture usage.
_GaussianSigma	Range(0.01,10)	Width of Gaussian for Gaussian pattern modes.
_BlendSoftness	Range(0.0,1.0)	Softening of tile mask edges.
_Contrast	Range(0.5,4)	Final contrast exponent applied to output.
_Seed	Int	Randomization seed for deterministic variation.

Pattern Types
How tile indices are chosen per cell. The shader maps a scalar in [0,1) to a tile index (0..TilesCols*TilesRows-1). The pattern scalar can be modulated by the optional _PatternTex.

Enum Value	Name	Behavior
0	Random	Per-instance random selection using seeded hash.
1	CellIndex	Deterministic hash of cell coordinates (unique per cell).
2	Rows	Varies by cell row (ip.y).
3	Columns	Varies by cell column (ip.x).
4	Diagonal	Varies by ip.x + ip.y (diagonal bands).
5	Radial	Varies by distance from origin (cell center).
6	Checker	Alternating pattern like a checkerboard.
7	GaussianRows	Gaussian weight across rows (centered by default).
8	GaussianColumns	Gaussian weight across columns.
9	GaussianRadial	Gaussian falloff with radial distance from origin.
")]

    [System.Serializable, NodeMenuItem("Operations/Tile Sampler")]
    public class TileSamplerNode : FixedShaderNode
    {
        public override string name => "Tile Sampler";

        public override string NodeGroup => "Operations";
        public override string ShaderName => "Hidden/Genesis/TileSampler";

        public override bool DisplayMaterialInspector => true;
    }
}