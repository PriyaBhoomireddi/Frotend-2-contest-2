//**************************************************************************/
// Copyright (c) 2008 Autodesk, Inc.
// All rights reserved.
// 
// These coded instructions, statements, and computer programs contain
// unpublished proprietary information written by Autodesk, Inc., and are
// protected by Federal copyright law. They may not be disclosed to third
// parties or copied or duplicated in any form, in whole or in part, without
// the prior written consent of Autodesk, Inc.
//**************************************************************************/
// DESCRIPTION: Sky box effect.
// AUTHOR: Danny Chen
// CREATED: March 2009
//**************************************************************************/

#define PI 3.14159265358

//matrices
float4x4  gVXf : View;
float4x4  gWXf : World;
float4x4  gPXf : Projection;
float4x4  gTexXf;

//textures
texture g_CubeTex;
texture g_SphereTex;
texture g_LatLongTex;

// Gain, a color to scale the texture value.
float4  gGain;

//samplers
samplerCUBE g_samCube =
sampler_state
{
        Texture = <g_CubeTex>;
};
sampler2D g_samSphere =
sampler_state
{
        Texture = <g_SphereTex>;
};
sampler2D g_samLatLong = 
sampler_state
{
        Texture = <g_LatLongTex>;
};


void RenderSkyBoxVS( float3 Pos : POSITION,
                     float3 Tex : NORMAL,
                     out float4 oPos : POSITION,
                     out float3 oTex : TEXCOORD0 )
{
    //transform vertex
    float4 wpos = mul( float4(Pos,1.0f),gWXf );
    oPos = mul( wpos, gVXf );
    oPos = mul( oPos, gPXf);

    //transform sample direction using the texture matrix
    oTex = mul(Tex,float3x3(gTexXf[0].xyz,
                   gTexXf[1].xyz,
                   gTexXf[2].xyz));
}


void RenderSkyBoxPS_Cube( float3 Tex : TEXCOORD0,
                     out float4 oColor : COLOR0)
{
    //sample cubemap
   oColor = gGain * texCUBE( g_samCube, normalize(Tex) );
}
void RenderSkyBoxPS_Sphere( float3 Tex : TEXCOORD0,
                        out float4 oColor : COLOR0)
{
    //normalize direction
    float3 dir = normalize(Tex);
    
    //if the length of the x,y direction vector is 0, 
    // this is a special case. We test here to avoid division by zero in rsqrt
    if ((dir.x==0)&&(dir.y==0))
    {
        //make sure the sample coords is (0.5f,0.5f)
        dir.y = 1.0f;  
        dir.z = 1.0f;
    }
    
    //calculate reciprocal of the length of the arc projected on XY plane 
    float dist_r = rsqrt(dir.x*dir.x+dir.y*dir.y);
    
    //calculate sphere map texcoord
    float2 coord;
    
    coord.xy = dir.xy*dist_r*acos(dir.z)/PI;
    
    coord.xy = coord.xy*float2(0.5f,-0.5f)+float2(0.5f,0.5f);
    
    //sample color
    oColor = gGain * tex2D(g_samSphere,coord);
}

void RenderSkyBoxPS_LatLong( float3 Tex : TEXCOORD0,
                        out float4 oColor : COLOR0)
{
    //normalize direction
    float3 dir = normalize(Tex);    
    
    //calculate lat/long
    float latitude = -asin(dir.y)/PI + 0.5f;
    float longitude = atan2(dir.x, -dir.z)/PI*0.5f+0.5f;
    
    //sample color
    oColor = gGain * tex2D(g_samLatLong,float2(longitude,latitude));
}

//-----------------------------------------------------------------------------
// Technique: RenderSkyCube
// Desc: Renders using 3D texture coordinates to sample from a cube texture.
//-----------------------------------------------------------------------------
technique RenderSkyCube
{
    pass p0
    {
        VertexShader = compile vs_2_0 RenderSkyBoxVS();
        PixelShader = compile ps_2_0 RenderSkyBoxPS_Cube();
    }
}
//-----------------------------------------------------------------------------
// Technique: RenderSkySphere
// Desc: Renders using 3D texture coordinates to sample from a sphere texture.
//-----------------------------------------------------------------------------
technique RenderSkySphere
{
    pass p0
    {
        VertexShader = compile vs_2_0 RenderSkyBoxVS();
        PixelShader = compile ps_2_0 RenderSkyBoxPS_Sphere();
    }
}
//-----------------------------------------------------------------------------
// Technique: RenderSkyLatLong
// Desc: Renders using 3D texture coordinates to sample from a latitude-longitude texture.
//-----------------------------------------------------------------------------
technique RenderSkyLatLong
{
    pass p0
    {
        VertexShader = compile vs_2_0 RenderSkyBoxVS();
        PixelShader = compile ps_2_0 RenderSkyBoxPS_LatLong();
    }
}

