#include "ShaderConstants.fxh"

struct PS_Input
{
    float4 position : SV_Position;
    float4 color : COLOR;
};

struct PS_Output
{
    float4 color : SV_Target;
};

ROOT_SIGNATURE
void main(in PS_Input PSInput, out PS_Output PSOutput)
{

float DST = lerp(1.0,0.0,pow(max(min(FOG_COLOR.r),0.0),1.2));
float SST = clamp((CURRENT_COLOR.b-0.15)*1.1764706,0.0,1.0);

float TD = (DST);
float TS = (0.5-abs(0.5-SST));
float TN = (1.0-TD);
float WR = (1.0-clamp(3.34*(FOG_CONTROL.y-0.7),0.0,1.0));

float4 D = float4(0.0625, 0.0625, 0.25, 1.5);
float4 N = float4(1.125, 1.125, 1.125, 1.125);
float4 S = float4(0.75, 0.875, 1.25, 4.0);

D = D * TD;
N = N * TN;
S = S * TS;

float4 DN = (1.0-N.a)*D+N.a*N;
float4 DS = (1.0-S.a)*DN+S.a*S;
float4 SC = lerp( DS, FOG_COLOR * 2.0, WR );

PSOutput.color = PSInput.color * SC;
if(bool(step(FOG_CONTROL.x,.0001)))PSOutput.color = FOG_COLOR;
}