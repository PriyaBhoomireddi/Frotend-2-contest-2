//**************************************************************************/
// Copyright (c) 2014 Autodesk, Inc.
// All rights reserved.
// 
// These coded instructions, statements, and computer programs contain
// unpublished proprietary information written by Autodesk, Inc., and are
// protected by Federal copyright law. They may not be disclosed to third
// parties or copied or duplicated in any form, in whole or in part, without
// the prior written consent of Autodesk, Inc.
//**************************************************************************/
// DESCRIPTION: Apply inverse of Canon curve. 0.0 to 1.0 input, output is
//     linear color 0 to unlimited (so best to output to 16 bit float or larger)
//     Note: alpha of incoming assumed to be 1.0
// AUTHOR: Eric Haines
// CREATED: March 2014
//**************************************************************************/

#include "Common10.fxh"

// The exposure adjustment
float gExposureValue = 0.0f;

// run in color preserving mode or not. default is to not run in color preserving mode
bool gColorPreserving = false;

// The source image (background pass) texture and sampler.
Texture2D gBackgroundTexture < string UIName = "Background Texture"; > = NULL;
SamplerState gBackgroundSampler;

float reverseSpectrumToneMappingLow(float x)
{
    const float a  =  0.244925773;
    const float t1 = -0.631960243;
    const float t2 = -4.251792105;
    const float t3 =  3.841721426;
    const float d0 = -0.005002772;
    const float d1 = -0.525010335;
    const float d2 = -0.885018509;
    const float d3 =  1.153153531;

    const float x2 = x * x;
    const float x3 = x2 * x;
    return a*(t1*x + t2*x2 + t3*x3)/(d0 + d1*x + d2*x2 + d3*x3);
}

float reverseSpectrumToneMappingHigh(float x)
{
    const float a  =  0.514397858;
    const float t1 = -0.553266341;
    const float t2 = -2.677674970;
    const float t3 =  2.903543727;
    const float d0 = -0.005057344;
    const float d1 = -0.804910686;
    const float d2 = -1.427186761;
    const float d3 =  2.068910419;

    const float x2 = x * x;
    const float x3 = x2 * x;
    return a*(t1*x + t2*x2 + t3*x3)/(d0 + d1*x + d2*x2 + d3*x3);
}

float Tinv(float y)
{
    y = saturate(y);
    const float a = 1.0592f;
    const float b = 1.0631f;
    const float c = 4.5805f;
    const float d = 1.5823f;
    float tmp = (b / (a - y) - 1.0f) / c;
    return pow(tmp, (1.0f / d));
}

// Pixel shader.
// incoming is 0 to 1.0, output is linear space color
float4 PS_CanonInverseCurve(VS_TO_PS_ScreenQuad In) : SV_Target
{
    float4 color = gBackgroundTexture.Sample(gBackgroundSampler, In.UV);
    float3 reverseColor;

    if (gColorPreserving) {
      // Undo gamma
      reverseColor = pow(color.rgb, float3(2.2f, 2.2f, 2.2f));

      // get luminance
      float inLum = dot(float3(0.2126f, 0.7152f, 0.0722f), reverseColor);

      if (inLum > 0.001f) {
        // Inverse of measured Canon sigmoid
        float outLum = Tinv(inLum);

        // scale the color, preserving channel ratios
        reverseColor = reverseColor * (outLum / inLum);
      }

      reverseColor /= exp2(gExposureValue);
    } else {
      const float spectrumTonemapMin = -2.152529302052785809;
      const float spectrumTonemapMax = 1.163792197947214113;

      const float lowHighBreak = 0.9932;

      const float shift = 0.18;

      if (color.r < lowHighBreak) {
        color.r = reverseSpectrumToneMappingLow(color.r);
      } else {
        color.r = reverseSpectrumToneMappingHigh(color.r);
      }

      if (color.g < lowHighBreak) {
        color.g = reverseSpectrumToneMappingLow(color.g);
      } else {
        color.g = reverseSpectrumToneMappingHigh(color.g);
      }

      if (color.b < lowHighBreak) {
        color.b = reverseSpectrumToneMappingLow(color.b);
      } else {
        color.b = reverseSpectrumToneMappingHigh(color.b);
      }

      // alpha assumed to be 1.0 - we'll pass in color.a, but it'd better be 1.0!
      reverseColor = clamp(color.rgb, 0.0, 1.0);
      reverseColor = reverseColor.rgb * (spectrumTonemapMax - spectrumTonemapMin) + spectrumTonemapMin;
      reverseColor = pow(float3(10.0,10.0,10.0), reverseColor);
      reverseColor /= exp2(gExposureValue);
      reverseColor *= shift;
    }

    return float4( reverseColor, color.a );
}

// Technique.
technique10 Main
{
    pass p0
    {
        SetVertexShader(CompileShader(vs_4_0,VS_ScreenQuad()));
        SetGeometryShader(NULL);
        SetPixelShader(CompileShader(ps_4_0,PS_CanonInverseCurve()));
    }
}
