//**************************************************************************/
// Copyright 2014 Autodesk, Inc.
// All rights reserved.
//
// This computer source code and related instructions and comments are the
// unpublished confidential and proprietary information of Autodesk, Inc.
// and are protected under Federal copyright and state trade secret law.
// They may not be disclosed to, copied or used by any third party without
// the prior written consent of Autodesk, Inc.
//**************************************************************************/
// DESCRIPTION: Thickness map effect (D3D10).
// AUTHOR: Shubird
// CREATED: Oct 2014
//**************************************************************************/

// World transformation.
float4x4 gWXf : World < string UIWidget = "None"; >;

// World-view-projection transformation.
float4x4 gWVPXf : WorldViewProjection < string UIWidget = "None"; >;

// View inverse transformation.
float4x4 gVIXf : ViewInverse < string UIWidget = "None"; >;

// Vertex shader input structure.
struct VS_INPUT
{
    float3 Pos : POSITION;
};

// Vertex shader output structure.
struct VS_TO_PS
{
    float4 HPos : SV_Position;
    float3 ViewDir : TEXCOORD0;
};

// Vertex shader.
VS_TO_PS VS_ThicknessMap(VS_INPUT In)
{
    VS_TO_PS Out;
    
    // Transform the vertex from object space to clip space and world space.
    Out.HPos = mul(float4(In.Pos, 1.0f), gWVPXf);
    float4 HPw = mul(float4(In.Pos, 1.0f), gWXf);

    // Compute the view direction from the eye point(the last row of the inverse view matrix) 
    // to the world-space position.
    Out.ViewDir = HPw.xyz - gVIXf[3].xyz;

    return Out;
}

// Pixel shader.
float4 PS_ThicknessMap(VS_TO_PS In, bool IsFront : SV_IsFrontFace) : SV_Target
{
    // Get the fragment depth (distance from the view position).
    float depth = length(In.ViewDir);

    // ADD the depth from backfaces (larger values), and SUBTRACT the depth from front faces
    // (smaller values).  Using a one-one-add blend state with this will give the thickness.
    // NOTE: This assumes manifold (properly formed) geometry.
    depth = IsFront ? -depth : depth;

    // Return the depth in the first channel.
    return float4(depth, 0.0, 0.0, 1.0);
}

// The main technique.
technique10 Main
{
    pass p0
    {
        SetVertexShader(CompileShader(vs_4_0, VS_ThicknessMap()));
        SetGeometryShader(NULL);
        SetPixelShader(CompileShader(ps_4_0, PS_ThicknessMap()));
    }
}
