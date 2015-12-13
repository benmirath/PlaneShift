Shader "Custom/distanceSpotlight3"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_WaveHeight ("Wave Height", Float) = 1.0
		_WaveFreq ("Wave Frequency", Float) = 5.0
		_AnimationRange ("AnimationRange", Float) = 50
		_AnimationSpeed ("AnimationRange", Float) = .1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			float _WaveHeight;
			float _WaveFreq;
			float _AnimationRange;
			float _AnimationSpeed;
			
			fixed remap(fixed value, fixed low1, fixed high1, fixed low2, fixed high2){
			    return(low2 + (high2 - low2) * (value - low1) / (high1 - low1));
			}


			//RANDOM & NOISE
			half random (fixed _x) { return frac(sin(_x)*100000.0); }
			half random (in fixed2 _st) { return frac(sin(dot(_st.xy, fixed2(12.9898,78.233))) * 43758.5453123); }
			half2 random2(fixed2 st){
			    st = fixed2( dot(st,fixed2(127.1,311.7)), dot(st,fixed2(269.5,183.3)) );
			    return -1.0 + 2.0*frac(sin(st)*43758.5453123);
			}

			fixed noise (fixed _x) {
			    fixed i = floor(_x);  // integer
				fixed f = frac(_x);  // fraction
				fixed y = lerp(random(i), random(i + 1.0), smoothstep(0.,1.,f));
				return y;
			}
			fixed noise (in fixed2 st) {
			    fixed2 i = floor(st);
			    fixed2 f = frac(st);
			    fixed a = random(i);
			    fixed b = random(i + fixed2(1.0, 0.0));
			    fixed c = random(i + fixed2(0.0, 1.0));
			    fixed d = random(i + fixed2(1.0, 1.0));
			    fixed2 u = f*f*(3.0-2.0*f);
			    return lerp(a, b, u.x) + 
			            (c - a)* u.y * (1.0 - u.x) + 
			            (d - b) * u.x * u.y;
			}
			fixed gradientNoise(fixed2 st) {
			    fixed2 i = floor(st);
			    fixed2 f = frac(st);

			    fixed2 u = f*f*(3.0-2.0*f);

			    return lerp( lerp( dot( random2(i + fixed2(0.0,0.0) ), f - fixed2(0.0,0.0) ), 
			                       dot( random2(i + fixed2(1.0,0.0) ), f - fixed2(1.0,0.0) ), u.x),
			                 lerp( dot( random2(i + fixed2(0.0,1.0) ), f - fixed2(0.0,1.0) ), 
			                       dot( random2(i + fixed2(1.0,1.0) ), f - fixed2(1.0,1.0) ), u.x), u.y);
			}

			
			v2f vert (appdata v) {
				v2f o;
				
				float dist = _AnimationRange - distance(_WorldSpaceCameraPos, mul(_Object2World, v.vertex));
				dist = max (dist, 0);
				
				
				
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				
				fixed4 newVerts = mul(UNITY_MATRIX_MV, v.vertex);
				o.vertex += float4 (0, (noise (float2 (newVerts.x, newVerts.z) *(_Time.y * _AnimationSpeed)) * _WaveHeight) * dist, 0, 0);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				UNITY_APPLY_FOG(i.fogCoord, col);				
				return col;
			}
			ENDCG
		}
	}
}