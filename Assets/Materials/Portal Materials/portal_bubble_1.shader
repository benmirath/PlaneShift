Shader "Custom/VertexManipulation/portal_bubble_1" {
	Properties {
		_Color ("Color", Color) = (1.0, 0.0, 0.0, 1.0)
		_Emission ("Emission Mult", Float) = 1
		_EmissionCutoff ("Emission Cutoff", Float) = 0.5
		_Cutoff ("Distance Cutoff", Float) = 15
		_MainTex ("Main Tex", 2D) = "white" {}
		_WaveHeight ("Wave Height", Float) = 1.0
		_WaveMag ("Wave Magnitude", Float) = 5.0
		_AnimationRange ("Animation Range", Float) = 50
		_AnimationSpeed ("Animation Spedd", Float) = .1

	}
	
	SubShader {
		// Tags { "RenderType"="Opaque" }
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		// Cull Off
		// ZTest Always
		// ZWrite Off
		
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off
		// Lighting Off
		// Blend SrcAlpha OneMinusSrcAlpha
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows vertex:vert addshadow alpha
		#pragma target 3.0
		#define PI 3.14159265358979323846

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
		
		#define NOISE_SIMPLEX_1_DIV_289 0.00346020761245674740484429065744f
		float mod289(float x) { return x - floor(x * NOISE_SIMPLEX_1_DIV_289) * 289.0; }
		float2 mod289(float2 x) { return x - floor(x * NOISE_SIMPLEX_1_DIV_289) * 289.0; }
		float3 mod289(float3 x) { return x - floor(x * NOISE_SIMPLEX_1_DIV_289) * 289.0; }
		float4 mod289(float4 x) { return x - floor(x * NOISE_SIMPLEX_1_DIV_289) * 289.0; }
		
		float permute(float x) { return mod289(x*x*34.0 + x); }
		float3 permute(float3 x) { return mod289(x*x*34.0 + x); }
		float4 permute(float4 x) { return mod289(x*x*34.0 + x); }

		fixed snoise(fixed2 v) {
			// Precompute values for skewed triangular grid
			const float4 C = fixed4(0.211324865405187,
								// (3.0-sqrt(3.0))/6.0
								0.366025403784439,  
								// 0.5*(sqrt(3.0)-1.0)
								-0.577350269189626,  
								// -1.0 + 2.0 * C.x
								0.024390243902439); 
								// 1.0 / 41.0
		
			// First corner (x0)
			fixed2 i  = floor(v + dot(v, C.yy));
			fixed2 x0 = v - i + dot(i, C.xx);
		
			// Other two corners (x1, x2)
			fixed2 i1 = fixed2(0.0);
			i1 = (x0.x > x0.y) ? fixed2(1.0, 0.0) : fixed2(0.0, 1.0);
			fixed2 x1 = x0.xy + C.xx - i1;
			fixed2 x2 = x0.xy + C.zz;
		
			// Do some permutations to avoid
			// truncation effects in permutation
			i = mod289(i);
			fixed3 p = permute(
					permute( i.y + fixed3(0.0, i1.y, 1.0))
						+ i.x + fixed3(0.0, i1.x, 1.0 ));
		
			fixed3 m = max(0.5 - fixed3(
								dot(x0,x0), 
								dot(x1,x1), 
								dot(x2,x2)
								), 0.0);
			m = m*m ;
			m = m*m ;
		
			// Gradients: 
			//  41 pts uniformly over a line, mapped onto a diamond
			//  The ring size 17*17 = 289 is close to a multiple 
			//      of 41 (41*7 = 287)
		
			fixed3 x = 2.0 * frac(p * C.www) - 1.0;
			fixed3 h = abs(x) - 0.5;
			fixed3 ox = floor(x + 0.5);
			fixed3 a0 = x - ox;
		
			// Normalise gradients implicitly by scaling m
			// Approximation of: m *= inversesqrt(a0*a0 + h*h);
			m *= 1.79284291400159 - 0.85373472095314 * (a0*a0+h*h);
		
			// Compute final noise value at P
			fixed3 g = fixed3(0.0);
			g.x  = a0.x  * x0.x  + h.x  * x0.y;
			g.yz = a0.yz * fixed2(x1.x,x2.x) + h.yz * fixed2(x1.y,x2.y);
			return 130.0 * dot(m, g);
		}
        
        
        fixed2x2 scale (fixed2 f) { return fixed2x2 ( fixed2 (f.x, 0.0), fixed2 (0.0, f.y)); }
		fixed2x2 translate (fixed2 f) { return fixed2x2 ( fixed2 (0.0, 1.0), fixed2 (f.x, f.y) ); }

		//float version
		fixed2x2 scale (fixed f) { return fixed2x2 ( fixed2 (f, 0.0), fixed2 (0.0, f)); }
		fixed2x2 translate (fixed f) { return fixed2x2 ( fixed2 (0.0, 1.0), fixed2 (f, f) ); }

		fixed2x2 rotate (fixed a) { return fixed2x2 ( fixed2 (cos(a), -sin(a)), fixed2 (sin (a), cos(a))); }
		fixed2x2 identityMatrix () { return fixed2x2 ( fixed2 (1.0, 0.0), fixed2 (0.0, 1.0)); }
		
		fixed remap(fixed value, fixed low1, fixed high1, fixed low2, fixed high2){
		    return(low2 + (high2 - low2) * (value - low1) / (high1 - low1));
		}
		fixed3 hsb2rgb( in fixed3 c ){
		    fixed3 rgb = clamp(abs(fmod(c.x*6.0+fixed3(0.0,4.0,2.0), 6.0)-3.0)-1.0, 0.0, 1.0 );		//color converting black magic, truly terrifying
		    rgb = rgb*rgb*(3.0-2.0*rgb);
		    return c.z * lerp( fixed3(1,1,1), rgb, c.y);
		}
		fixed SpikeVert (fixed4 _verts, fixed _spikeBase, fixed _spikeMag, fixed _animSpeed) {
			return _spikeBase + ((.1 + snoise ((_Time.y * _animSpeed) + _verts.xz)) * _spikeMag);
		}
		fixed4 ExpandVert (fixed4 _verts, fixed _spikeMag, fixed _animSpeed) {
			fixed4 returnVerts = fixed4 (0,0,0,0);
			returnVerts.x = (.1 + snoise ((_Time.y * _animSpeed) + _verts.yz)) * _spikeMag;
			// returnVerts.y = (.1 + snoise ((_Time.y * _animSpeed) + _verts.xz)) * _spikeMag;
			returnVerts.z = (.1 + snoise ((_Time.y * _animSpeed) + _verts.xy)) * _spikeMag; 
			return returnVerts;
		}
		
		uniform sampler2D _MainTex;
		uniform fixed4 _Color;
		uniform fixed _Cutoff;
		uniform fixed _Timer;
        uniform float _WaveHeight;
		uniform float _WaveMag;
		uniform float _AnimationRange;
		uniform float _AnimationSpeed;
		
        struct Input {
			float2 uv_MainTex : TEXCOORD0;
		};
		void vert (inout appdata_full v, out Input o) {
			// float dist = _AnimationRange - distance(_WorldSpaceCameraPos, mul(_Object2World, v.vertex));
			// dist = clamp (dist, -35, 1);
			// fixed4 newVerts = mul(_Object2World, v.vertex);
			// fixed adj = SpikeVert (newVerts, _WaveHeight, _WaveMag, _AnimationSpeed) * dist;
			fixed4 newVerts = mul(_Object2World, v.vertex);
			// fixed adj = SpikeVert (newVerts, _WaveHeight, _WaveMag, _AnimationSpeed) * dist;
			// v.vertex += float4 (0, adj, 0, 0);
			v.vertex += ExpandVert (newVerts, _WaveMag, _AnimationSpeed);
			o.uv_MainTex = TRANSFORM_UV(0);
      	}
		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed2 st = IN.uv_MainTex;
			o.Albedo = tex2D(_MainTex, st);
			// o.Albedo = fixed3 (1,0,0);
			o.Metallic = 0;
			o.Smoothness = 0;
			o.Alpha = _Color.a;
			// o.Alpha = 1;
			// o.Alpha = 0;
		}
		ENDCG
	}
	FallBack "VertexLit"
}