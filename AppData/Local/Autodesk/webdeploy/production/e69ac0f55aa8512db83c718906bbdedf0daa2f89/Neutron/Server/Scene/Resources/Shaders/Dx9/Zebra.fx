//#define LOCAL_VIEWER
#define FLIP_BACKFACING_NORMALS

// Light structure.
struct Light
{
    // The light color.
    float3 Color;
    
    // The light ambient color.
    float3 AmbColor;
    
    // The light specular color.
    float3 SpecColor;

    // The light direction, in world space.
    // NOTE: Used by directional and spot lights.  This is the direction *toward* the light.
    float3 Dir;

    // The light position, in world space.
    // NOTE: Used by point and spot lights.
    float3 Pos;
    
    // The light range and attenuation factors.
    // NOTE: Used by point and spot lights.
    float4 Atten;
   
    // The cosine of the light hotspot and falloff half-angles.
    // NOTE: Used by spot lights.
    float2 Cone;
};

void ComputeLightingCoefficients(
    float3 Lw, float3 Nw, float3 Vw, float exp, out float diff, out float spec)
{
    // Compute the intermediate results for lighting.
    // > NdotL: The dot product of the world space normal and world space light direction.
    // > Hw   : The halfway vector between the light direction and the view direction, computed as
    //          the normalized sum of the vectors.
    // > NdotH: The dot product of the world space normal and world space halfway vector.
    float NdotL = dot(Nw, Lw);
    float3 Hw = normalize(Vw + Lw);
    float NdotH = dot(Nw, Hw);

    // Use the lit() intrinsic function to compute the diffuse and specular coefficients.
    float4 lighting = lit(NdotL, NdotH, exp);
    diff = lighting.y;
    spec = lighting.z;
}

// Computes lighting for a single directional light.
void ComputeDirectionalLight(
    Light light, float3 Nw, float3 Vw, float exp,
    out float3 amb, out float3 diff, out float3 spec)
{
    // Compute the lighting coefficients based on the incident light direction, surface normal, and
    // view direction.
    float diffCoeff = 0.0f, specCoeff = 0.0f;
    ComputeLightingCoefficients(light.Dir, Nw, Vw, exp, diffCoeff, specCoeff);
    
    // Multiply the light color by the coefficients.
    // NOTE: The ambient component is only affected by attenuation, and there is none here.
    amb  = light.AmbColor;
    diff = light.Color * diffCoeff;
    spec = light.SpecColor * specCoeff;
}

#define LIGHT_COUNT 2

// The array of lights if order of light type: directional lights, followed by point lights,
// followed by spot lights.
Light gLightList[LIGHT_COUNT] : LightArray;

// The number of directional lights.
int gNumDirectionalLights : DirLightCount
<
    string UIName = "# Directional Lights";
    string UIWidget = "Slider";
    int UIMin = 0;
    int UIMax = 8;
    int UIStep = 1;
>
= 1;

// Compute the lighting contribution from the lights in the light array.
void ComputeLighting(
    float3 Nw, float3 Vw, float3 Pw, float exp, out float3 amb, out float3 diff, out float3 spec)
{
    // Set the initial color components to black.
    amb = diff = spec = 0.0f;
    float3 ambFromLight = 0.0f, diffFromLight = 0.0f, specFromLight = 0.0f;

    // Loop over the directional lights, adding the ambient, diffuse, and specular contributions of
    // each one to the output values.
    for (int i = 0; i < gNumDirectionalLights; i++)
    {
        ComputeDirectionalLight(gLightList[i], Nw, Vw, exp,
            ambFromLight, diffFromLight, specFromLight);

        amb  += ambFromLight;
        diff += diffFromLight;
        spec += specFromLight;
    }
}


// World transformation.
float4x4 gWXf : World < string UIWidget = "None"; >;

// World transformation, inverse transpose.
float4x4 gWITXf : WorldInverseTranspose < string UIWidget = "None"; >;

// World-view-projection transformation.
float4x4 gWVPXf : WorldViewProjection < string UIWidget = "None"; >;

// World-view transformation
float4x4 gWV : WorldView < string UIWidget = "None"; >;

#ifdef LOCAL_VIEWER
	float4x4 gVIXf : ViewInverse < string UIWidget = "None"; >;
#else
	float3 gViewDirection : ViewDirection < string UIWidget = "None"; >;
#endif

// Whether the projection matrix flips Z: -1.0 if so, otherwise 1.0.
float gProjZSense : ProjectionZSense < string UIWidget = "None"; >;

// 0.0 for horizontal, 0.5 for diagonal, 1.0 for vertical
float  gStripeDir : StripeDir
<
    string UIName = "Stripe Direction";
    string UIWidget = "Slider";
> = 0.5f;                   

// controls the density of the zebra striping
float  gStripeDensity : StripeDensity
<
    string UIName = "Stripe Density";
    string UIWidget = "Slider";
> = 20.0f;                  

// The first color of the stripe
float3 gStripeColor0 : StripeColor0
<
    string UIName = "Stripe Color 0";
> = float3( 0.0, 0.0, 0.5 );       

// The second color of the stripe
float3 gStripeColor1 : StripeColor1
<
    string UIName = "Stripe Color 1";
> = float3( 1.0, 0.8, 0.5 );    

// The stripe are generated in world space using normal: locked mode
bool gLocked : StripeLocked
<
    string UIName = "Stripe Locked";
> = false;

// Emissive color.
float3 gEmiColor : Emissive
<
    string UIName = "Emissive";
    string UIWidget = "Color";
> = float3(0.0f, 0.0f, 0.0f);

// Ambient color.
float3 gAmbColor : Ambient
<
    string UIName = "Ambient";
    string UIWidget = "Color";
> = float3(1.0f, 1.0f, 1.0f);

// Diffuse color.
float3 gDiffColor : Diffuse
<
    string UIName =  "Diffuse Color";
    string UIWidget = "Color";
> = float3(1.0f, 1.0f, 1.0f);

// Specular color.
float3 gSpecColor : Specular
<
    string UIName =  "Specular Color";
    string UIWidget = "Color";
> = float3(1.0f, 1.0f, 1.0f);

// Glossiness (specular power).
float gGlossiness : SpecularPower
<
    string UIName = "Glossiness";
    string UIWidget = "Slider";
    float UIMin = 1.0f;
    float UIMax = 128.0f;
    float UIStep = 10.0;
> = 32.0f;

// Opacity factor.
float gOpacity : Opacity
<
    string UIName = "Opacity";
    string UIWidget = "Slider";
    float UIMin = 0.0f;
    float UIMax = 1.0f;
    float UIStep = 0.1f;
> = 1.0f;

// Base texture.
texture gZebraTex : ZebraTexture
<
    string UIName = "Zebra Texture";
> = NULL;

// Base texture sampler.
sampler2D gZebraSamp : ZebraTextureSampler = sampler_state
{
    Texture = <gZebraTex>;
};

// Depth priority, which shifts the model a bit forward in the z-buffer
float gDepthPriority : DepthPriority
<
    string UIName =  "Depth Priority";
    string UIWidget = "Slider";
    float UIMin = -16/1048576.0f;    // divide by 2^24/16 by default
    float UIMax = 16/1048576.0f;
    float UIStep = 1/1048576.0f;
> = 0.0f;

struct VS_INPUT
{
    float3 Pos  : POSITION;
    float3 Normal  : NORMAL;
};

struct VS_TO_PS
{
    float4 HPos       : POSITION;
    float3 ViewVec    : TEXCOORD0;
    float3 EyeNormal  : TEXCOORD1;
    float3 Diff : COLOR0; 
    float3 Spec : COLOR1;
};

VS_TO_PS zebraVS(VS_INPUT In)
{
    VS_TO_PS Out;

    float4 P = float4(In.Pos, 1.0);
    float4 eyeSpaceP  = mul(P, gWV); 

	if(gLocked)
 	{
 		Out.EyeNormal     = In.Normal;
		Out.ViewVec		= -(In.Pos.xyz + float3(0.1,0.0,0.0)) * float3( 1.0, 1.0, gProjZSense );
 	}
 	else
 	{
 		Out.EyeNormal  = mul(In.Normal, (float3x3)gWV);
 		Out.ViewVec       = -eyeSpaceP.xyz * float3( 1.0, 1.0, gProjZSense ); 
 	}
	  
    Out.HPos          = mul(P, gWVPXf); 

    // Transform the position and normal to world space for lighting, and normalize the normal.
    float4 HPw = mul(P, gWXf);
    float3 Nw = normalize(mul(In.Normal, (float3x3)gWITXf));

#ifdef LOCAL_VIEWER
    // Compute the view direction, using the eye position and vertex position.  The eye
    // position is the translation vector of the inverse view transformation matrix.  This
    // provides more accurate lighting highlights and environment-mapped reflections than
    // using a non-local viewer (below).
    float3 Vw = HPw - gVIXf[3];
    float3 VwNorm = normalize(Vw);    
#else
    // Use the fixed view direction, the same for the entire view.  Use of this vector is
    // similar to disabling D3DRS_LOCALVIEWER for lighting and reflection in D3D9 (the
    // default state).  This is appropriate for orthographic projections.
    float3 VwNorm = gViewDirection;
#endif

    // Flip the normal to face the view direction, allowing proper shading of back-facing surfaces.
    // NOTE: This will lead to artifacts on the silhouettes of coarsely-tessellated surfaces.  A
    // compensation of about nine degrees is performed here (cos(99deg) ~ 0.15), so this issue
    // should be limited to triangles with very divergent normals.
#ifdef FLIP_BACKFACING_NORMALS
    Nw = -Nw * sign(dot(VwNorm, Nw));
#endif
    
    // Compute the ambient, diffuse, and specular lighting components from the light array.
    float3 amb = 0.0f;
    float3 spec = 0.0f;
    
    // Use the glossiness value.
    ComputeLighting(Nw, -VwNorm, HPw, gGlossiness, amb, Out.Diff.rgb, spec);
    Out.Diff.rgb *= gDiffColor;
    Out.Diff.rgb += gAmbColor * amb + gEmiColor;
    Out.Spec = gSpecColor * spec;

    // Clamp the diffuse and specular components to [0.0, 1.0] to match the limitations of COLOR
    // registers in SM 2.0.  Otherwise the final color output will not match.
    Out.Diff = saturate(Out.Diff); 

    // modify the HPos a bit by biasing the Z a bit forward, based on depth priority
    Out.HPos.z -= Out.HPos.w*gDepthPriority;

    return Out; 
}

float4 zebraPS(VS_TO_PS In) : COLOR
{
    float3 nrefl = normalize(In.EyeNormal);
 	//if(!gLocked)
 	{
 		float3 nEyeNorm  = nrefl;
 		nrefl  = normalize( reflect( In.ViewVec, nEyeNorm ) );
 	} 	

     //stripe dir controls the strip direction from horizontal stripes to vertical
     float nReflAxis = lerp( nrefl.y, nrefl.x, gStripeDir );

     //striped spherical environment map using reflection vector
     float3 mVec = float3( nrefl.x, nrefl.y, ( nrefl.z + 1 ) );
     float m = 2.0 * sqrt( dot( mVec, mVec ) );
     float tube_angle = 0.5 + (nReflAxis / m);

    float zebra_frac = tube_angle * gStripeDensity;

    float2 UV = float2(0,0);
    UV.x = zebra_frac; //Use the zebra_frac as the texture coordinates

    float3 zebraColor = tex2D(gZebraSamp, UV).xyz;

    // Start the output color with the diffuse component.  The rest of the shader adds to it.
    float3 outputColor = In.Diff.rgb;
    outputColor *= zebraColor;  //Treat the zebra color as the diffuse texture
    // Add the specular component.
    outputColor += In.Spec; 
    // Final color and alpha.
    float4 final = float4(outputColor, gOpacity);
    return final;
}

technique Zebra
{
    pass P0
    {
        VertexShader = compile vs_2_0 zebraVS();
        PixelShader = compile ps_2_0 zebraPS();
    }
}
