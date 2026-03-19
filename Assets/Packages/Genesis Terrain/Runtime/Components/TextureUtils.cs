using System;
using System.Collections.Generic;
using System.Text;

using UnityEngine;

namespace ahahgames.genesisnoise
{
    public static class TextureConverter
    {

        public enum Channel
        {
            R,
            G,
            B,
            A,
            Luminance
        }

        /// <summary>
        /// Convert a Texture2D (RGBAFloat) to a float[,] array.
        /// The returned array is [height, width] where index [y,x] corresponds to pixel (x,y).
        /// If the source texture is not readable, this will create a temporary RT and read it back.
        /// </summary>
        public static float[,] ToFloatArray(Texture2D source, Channel channel = Channel.R)
        {
            if (source == null) throw new System.ArgumentNullException(nameof(source));

            int w = source.width;
            int h = source.height;

            Texture2D readable = source;
            bool createdTempTexture = false;

            // If texture is not readable, blit to a temporary RenderTexture and read back into a new Texture2D
            if (!source.isReadable)
            {
                var rt = RenderTexture.GetTemporary(w, h, 0, RenderTextureFormat.ARGBFloat);
                var prev = RenderTexture.active;
                Graphics.Blit(source, rt);

                RenderTexture.active = rt;
                readable = new Texture2D(w, h, TextureFormat.RGBAFloat, false, true);
                readable.ReadPixels(new Rect(0, 0, w, h), 0, 0);
                readable.Apply();

                RenderTexture.active = prev;
                RenderTexture.ReleaseTemporary(rt);

                createdTempTexture = true;
            }

            // Read pixels (Color uses float components for RGBAFloat textures)
            Color[] pixels = readable.GetPixels();

            float[,] result = new float[h, w];

            for (int y = 0; y < h; y++)
            {
                for (int x = 0; x < w; x++)
                {
                    int idx = y * w + x;
                    Color c = pixels[idx];
                    float value;

                    switch (channel)
                    {
                        case Channel.R: value = c.r; break;
                        case Channel.G: value = c.g; break;
                        case Channel.B: value = c.b; break;
                        case Channel.A: value = c.a; break;
                        case Channel.Luminance:
                            // standard Rec. 601 luma
                            value = 0.299f * c.r + 0.587f * c.g + 0.114f * c.b;
                            break;
                        default: value = c.r; break;
                    }

                    result[y, x] = value;
                }
            }

            if (createdTempTexture)
            {
                UnityEngine.Object.DestroyImmediate(readable);
            }

            return result;
        }

    }
}