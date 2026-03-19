using System;
using System.Collections.Generic;
using System.Text;

using UnityEngine;

namespace AhahGames.GenesisNoise.GNTerrain.Nodes
{
    public static class MaxDistance
    {
        static ComputeShader maxCompute;

        public static float GetMaxLandDistance(RenderTexture inputTexture)
        {
            if(maxCompute == null)
            {
                maxCompute = Resources.Load<ComputeShader>("Shaders/MaxDistance");
            }

            // 1. Setup Buffers
            // Bounds: MinX, MaxX, MinY, MaxY
            ComputeBuffer boundsBuffer = new ComputeBuffer(4, sizeof(int));
            ComputeBuffer resultBuffer = new ComputeBuffer(1, sizeof(float));

            // 2. Initialize Bounds (Crucial for Interlocked operations)
            int[] initialBounds = { inputTexture.width, 0, inputTexture.height, 0 };
            boundsBuffer.SetData(initialBounds);

            // 3. Dispatch FindBounds
            int kernelFind = maxCompute.FindKernel("FindBounds");
            maxCompute.SetTexture(kernelFind, "InputTexture", inputTexture);
            maxCompute.SetBuffer(kernelFind, "BoundsBuffer", boundsBuffer);
            maxCompute.SetVector("TextureDimensions", new Vector2(inputTexture.width, inputTexture.height));

            int groupsX = Mathf.CeilToInt(inputTexture.width / 8f);
            int groupsY = Mathf.CeilToInt(inputTexture.height / 8f);
            maxCompute.Dispatch(kernelFind, groupsX, groupsY, 1);

            // 4. Dispatch Calculation
            int kernelCalc = maxCompute.FindKernel("CalculateDistance");
            maxCompute.SetBuffer(kernelCalc, "BoundsBuffer", boundsBuffer);
            maxCompute.SetBuffer(kernelCalc, "ResultBuffer", resultBuffer);
            maxCompute.Dispatch(kernelCalc, 1, 1, 1);

            // 5. Get Result
            float[] result = new float[1];
            resultBuffer.GetData(result);
            return result[0]/2f;
        }
    }
}
