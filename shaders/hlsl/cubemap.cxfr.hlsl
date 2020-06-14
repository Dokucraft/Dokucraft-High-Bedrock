//File modified by @CrisXolt.
#include "ShaderConstants.fxh"
#include "util.fxh"

struct PS_Input
{
    float4 position : SV_Position;
#ifndef BYPASS_PIXEL_SHADER
    float2 uv : TEXCOORD_0_FB_MSAA;
#endif
};

struct PS_Output
{
    float4 color : SV_Target;
};

ROOT_SIGNATURE
void main(in PS_Input PSInput, out PS_Output PSOutput)
{
#if !defined(TEXEL_AA) || !defined(TEXEL_AA_FEATURE) || (VERSION < 0xa000 /*D3D_FEATURE_LEVEL_10_0*/) 
	float4 diffuse = TEXTURE_0.Sample(TextureSampler0, PSInput.uv);
#else
	float4 diffuse = texture2D_AA(TEXTURE_0, TextureSampler0, PSInput.uv);
#endif

#ifdef ALPHA_TEST
    if( diffuse.a < 0.5 )
    {
        discard;
    }
#endif

#ifdef IGNORE_CURRENTCOLOR
    PSOutput.color = diffuse;
#else
    PSOutput.color = CURRENT_COLOR * diffuse;
#endif

#ifdef WINDOWSMR_MAGICALPHA
    // Set the magic MR value alpha value so that this content pops over layers
    PSOutput.color.a = 133.0f / 255.0f;
#endif

#ifdef CUBEMAP
float DST = lerp(1.0,0.0,pow(max(min(1.0-FOG_COLOR.r*1.5,1.0),0.0),1.2));

float TD = (DST);
float TN = (1.0-TD);
float WR = (1.0-clamp(3.34*(FOG_CONTROL.y-0.7),0.0,1.0));

float2 CMDT = float2(1.0,0.499);
float2 CMNT = float2(0.0,0.501);

float4 D = TEXTURE_0.Sample(TextureSampler0,PSInput.uv.xy*CMDT);
float4 N = TEXTURE_0.Sample(TextureSampler0,PSInput.uv.xy*CMDT+CMNT);

D = D * 1.0;
N = N * 1.125;

D = D * TD;
N = N * TN;

float4 CMC = (1.0-N.a)*D+N.a*N;
CMC -= CMC*WR;

PSOutput.color = CMC;

#endif
}
