Shader "Hidden/Genesis/WaterEffect"
{
    Properties
    {
        [InlineTexture(HideInNodeInspector)]_Source_2D("InputTexture", 2D) = "white" {}
		[InlineTexture(HideInNodeInspector)]_Source_3D("InputTexture", 3D) = "white" {}
		[InlineTexture(HideInNodeInspector)]_Source_Cube("InputTexture", Cube) = "white" {}  
        [Tooltip(The influence of the waves on the effect)]
        _emboss("Emboss", Range(0.1,0.5)) = 0.4
        [Tooltip(Intensity simulates ripples on the waves)]
        _intensity("Intensity", Range(1.0,4.0))=2.2
        [Tooltip(More steps make the effect more complicated, as if it is coming from multiple directions)]
        _steps("Steps", Range(2,16))=8
        [Tooltip(Frequency of the waves)]
        _frequency("Frequency", Range(1.0,12.0))=6.0
        [Tooltip(Initial angle of the waves)]
        [GenesisPrime]_angle("Angle", float)=5
        [Tooltip(Seed value)]
        _Time("Seed", float)=52.0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Overlay" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #define BUILTIN_TARGET_API					
			#include "Assets/Packages/com.ahahgames.genesisnoise/Runtime/Shaders/GenesisFixed.hlsl"
            
            #pragma vertex CustomRenderTextureVertexShader
			#pragma fragment GenesisFragment
			#pragma shader_feature CRT_2D CRT_3D CRT_CUBE
			#pragma shader_feature _ USE_CUSTOM_UV

            TEXTURE_SAMPLER_X(_Source);
            float _emboss,_intensity,_frequency,_Time;
            int _steps,_angle;
            const float delta=60.0;
            const float gain=700.0;
            const float relectionCutOff = 0.012;
            const float reflectionIntensity = 200000.0;
            //speed
            const float speed = 0.2;
            const float speed_x = 0.3;
            const float speed_y = 0.3;

            float col(float2 coord, float time)
            {
                // Assumes 'angle', 'steps', 'speed', 'speed_x', 'speed_y', 'frequency', 'intensity'
                // are defined as uniforms/constant buffer variables elsewhere.
                float delta_theta = 2.0 * PI / (float)_angle;
                float colVal = 0.0;
                float theta = 0.0;

                [loop] // Optional: hint to compiler
                for (int i = 0; i < _steps; i++)
                {
                    float2 adjc = coord;
                    theta = delta_theta * (float)i;

                    adjc.x += cos(theta) * _Time * speed + time * speed_x;
                    adjc.y -= sin(theta) * _Time * speed - time * speed_y;

                    colVal += cos((adjc.x * cos(theta) - adjc.y * sin(theta)) * _frequency) * _intensity;
                }

                return cos(colVal);
            }

            float4 genesis(v2f_customrendertexture i)
            {               
                float2 p  = i.localTexcoord.xy/_ScreenParams.xy*1024;
                float2 c1 = p;
                float2 c2 = p;

                float cc1 = col(c1, _Time);

                // X offset
                c2.x += i.localTexcoord.x / delta*1024;
                float dx = _emboss * (cc1 - col(c2, _Time)) / delta*1024;

                // Y offset
                c2.x = p.x;
                c2.y += i.localTexcoord.y / delta;
                float dy = _emboss * (cc1 - col(c2, _Time)) / delta*1024;

                // Apply distortion
                c1.x += dx * 2.0;
                c1.y = -(c1.y + dy * 2.0);

                // Alpha computation
                float alpha = 1.0 + (dx * dy) * gain; // dot(dx,dy) in GLSL was scalar multiply

                float ddx = dx - relectionCutOff;
                float ddy = dy - relectionCutOff;
                if (ddx > 0.0 && ddy > 0.0)
                {
                    alpha = pow(alpha, ddx * ddy * reflectionIntensity);
                }

                // Sample texture
                float4 colVal=SAMPLE_X(_Source,float3(c1.xy,0),i.direction);//*alpha;
                return colVal;
            }
            ENDHLSL
        }
    }
}
