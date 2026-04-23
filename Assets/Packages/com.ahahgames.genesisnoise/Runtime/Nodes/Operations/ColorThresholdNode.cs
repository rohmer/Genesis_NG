using GraphProcessor;

using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Execute a flood fill operation on all pixels above the specified threshold.

Note that the computational cost of this node only depends on the texture resolution and not the distance parameter.

Smooth is only in alpha
")]

    [System.Serializable, NodeMenuItem("Operations/Fill")]
    public class Distance : ComputeShaderNode
    {
        public enum Mode
        {
            InputBlend,
            InputOnly,
            Mask,
            UV,
        }

        public enum DistanceMode
        {
            Euclidian,
            Manhattan,
            Chebyshev,
            // Minkovsky,
        }

        public enum ThresholdMode
        {
            Luminance,
            R, G, B, A,
            RGB,
            RGBA,
        }

        [Input]
        public Texture input;

        [Output]
        public CustomRenderTexture output;

        [Tooltip("Output mode of the distance, by default a blend with the distance is performed")]
        public Mode mode;

        [Tooltip("Threshold value to select pixels to dilate. Any value above this threshold will be selected")]
        public float threshold = 0.1f;

        [ShowInInspector, Tooltip("Select which value to compare against the threshold")]
        public ThresholdMode thresholdMode;

        [Tooltip("Distance value in percent of the texture size")]
        public float distance = 50;

        [ShowInInspector, Tooltip("How the distance is calculated")]
        public DistanceMode distanceMode;

        public override string name => "Distance";

        protected override string computeShaderResourcePath => "GenesisNoise/Distance";

        public override bool showDefaultInspector => true;
        public override string NodeGroup => "Operations";
        public override Texture previewTexture => output;

        public override List<OutputDimension> supportedDimensions => new() {
            OutputDimension.Texture2D,
            OutputDimension.Texture3D,
        };

        int fillUvKernel;
        int jumpFloodingKernel;
        int finalPassKernel;

        protected override void Enable()
        {
            base.Enable();

            settings.outputChannels = OutputChannel.RGBA;
            settings.outputPrecision = OutputPrecision.Half;
            settings.editFlags = EditFlags.Dimension | EditFlags.Size;

            UpdateTempRenderTexture(ref output);

            fillUvKernel = computeShader.FindKernel("FillUVMap");
            jumpFloodingKernel = computeShader.FindKernel("JumpFlooding");
            finalPassKernel = computeShader.FindKernel("FinalPass");
        }

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            // Force the double buffering for multi-pass flooding
            settings.doubleBuffered = true;

            if (!base.ProcessNode(cmd) || input == null)
                return false;

            UpdateTempRenderTexture(ref output);

            cmd.SetComputeFloatParam(computeShader, "_Threshold", threshold);
            cmd.SetComputeVectorParam(computeShader, "_Size", new Vector4(output.width, output.height, output.volumeDepth));
            cmd.SetComputeFloatParam(computeShader, "_Distance", distance / 100.0f);
            cmd.SetComputeIntParam(computeShader, "_ThresholdMode", (int)thresholdMode);
            cmd.SetComputeIntParam(computeShader, "_DistanceMode", (int)distanceMode);
            cmd.SetComputeIntParam(computeShader, "_Mode", (int)mode);

            output.doubleBuffered = true;
            output.EnsureDoubleBufferConsistency();
            var rt = output.GetDoubleBufferRenderTexture();
            if (!rt.enableRandomWrite)
            {
                rt.Release();
                rt.enableRandomWrite = true;
                rt.Create();
            }

            GenesisNoiseUtility.SetupComputeTextureDimension(cmd, computeShader, input.dimension);

            GenesisNoiseUtility.SetTextureWithDimension(cmd, computeShader, fillUvKernel, "_Input", input);
            GenesisNoiseUtility.SetTextureWithDimension(cmd, computeShader, fillUvKernel, "_Output", output);
            GenesisNoiseUtility.SetTextureWithDimension(cmd, computeShader, fillUvKernel, "_FinalOutput", rt);
            cmd.SetComputeIntParam(computeShader, "_DistanceMode", (int)distanceMode);
            cmd.SetComputeVectorParam(computeShader, "_InputScaleFactor", new Vector3(input.width / (float)output.width, input.height / (float)output.height, TextureUtils.GetSliceCount(input) / (float)TextureUtils.GetSliceCount(output)));
            DispatchCompute(cmd, fillUvKernel, output.width, output.height, output.volumeDepth);

            int maxLevels = (int)Mathf.Log(input.width, 2);
            for (int i = 0; i <= maxLevels; i++)
            {
                float offset = 1 << (maxLevels - i);
                cmd.SetComputeFloatParam(computeShader, "_InputScaleFactor", 1);
                cmd.SetComputeFloatParam(computeShader, "_Offset", offset);
                GenesisNoiseUtility.SetTextureWithDimension(cmd, computeShader, jumpFloodingKernel, "_Input", output);
                GenesisNoiseUtility.SetTextureWithDimension(cmd, computeShader, jumpFloodingKernel, "_Output", rt);
                cmd.SetComputeIntParam(computeShader, "_DistanceMode", (int)distanceMode);
                DispatchCompute(cmd, jumpFloodingKernel, output.width, output.height, output.volumeDepth);
                TextureUtils.CopyTexture(cmd, rt, output);
            }


            cmd.SetComputeVectorParam(computeShader, "_InputScaleFactor", new Vector3(input.width / (float)output.width, input.height / (float)output.height, TextureUtils.GetSliceCount(input) / (float)TextureUtils.GetSliceCount(output)));
            cmd.SetComputeIntParam(computeShader, "_DistanceMode", (int)distanceMode);
            GenesisNoiseUtility.SetTextureWithDimension(cmd, computeShader, finalPassKernel, "_Input", input);
            GenesisNoiseUtility.SetTextureWithDimension(cmd, computeShader, finalPassKernel, "_Output", rt);
            GenesisNoiseUtility.SetTextureWithDimension(cmd, computeShader, finalPassKernel, "_FinalOutput", output);
            DispatchCompute(cmd, finalPassKernel, output.width, output.height, output.volumeDepth);

            return true;
        }

        protected override void Disable()
        {
            base.Disable();
            CoreUtils.Destroy(output);
        }

        public CustomRenderTexture GetCustomRenderTexture() => output;
    }
}