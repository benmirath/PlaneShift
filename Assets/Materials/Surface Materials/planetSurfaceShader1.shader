Shader "Custom/planetSurfaceShader1" {
	Properties {
		_Color ("Color", Color) = (1.0, 0.0, 0.0, 1.0)
		// _Cutoff ("Distance Cutoff", Float) = 15
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_WaveHeight ("Wave Height", Float) = 1.0
		_WaveMag ("Wave Magnitude", Float) = 5.0
		_WaveSpeed ("Wave Speed", Float) = .1
		// _AnimationRange ("Animation Range", Float) = 50
		_AnimationSpeed ("Animation Spedd", Float) = .1
		// _ColorType ("Color Pallette", Int) = 0.0
		_Tile ("Tile Amount", Int) = 100
		_Smoothness ("Smoothness", Float) = 0
		_Metallic ("Metallic", Float) = 0
		_Emission ("Emission", Float) = 0

	}
	
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Upgrade NOTE: excluded shader from DX11, Xbox360, OpenGL ES 2.0 because it uses unsized arrays
		#pragma exclude_renderers d3d11 xbox360 gles
		#pragma surface surf Standard fullforwardshadows vertex:vert addshadow
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
		
		// fixed3 CalculateNormal (fixed2 _st, fixed2 _pix, sampler2D _tex) {
		// 	// fixed2 st = IN.uv_MainTex;
		// 	fixed2 st = _st;
		// 	// fixed2 pixel = 1./u_tex0Resolution;
		// 	// fixed2 pixel = _MainTex_TexelSize.xy;
		// 	fixed2 pixel = _pix;
			
		// 	fixed center     = tex2D(_tex, st).r;
		// 	fixed topLeft    = tex2D(_tex, st + fixed2(-pixel.x, -pixel.y) ).r;
		// 	fixed left       = tex2D(_tex, st + fixed2(-pixel.x, 0.0) ).r;
		// 	fixed bottomLeft = tex2D(_tex, st + fixed2(-pixel.x, pixel.y) ).r;
		// 	fixed top        = tex2D(_tex, st + fixed2(0.0, -pixel.y) ).r;
		// 	fixed bottom     = tex2D(_tex, st + fixed2(0.0, pixel.y) ).r;
		// 	fixed topRight   = tex2D(_tex, st + fixed2(pixel.x, -pixel.y) ).r;
		// 	fixed right      = tex2D(_tex, st + fixed2(pixel.x, 0.0) ).r;
		// 	fixed bottomRight= tex2D(_tex, st + fixed2(pixel.x, pixel.y) ).r;
			
		// 	fixed dX = topRight + 2.0 * right + bottomRight - topLeft - 2.0 * left - bottomLeft;
		// 	fixed dY = bottomLeft + 2.0 * bottom + bottomRight - topLeft - 2.0 * top - topRight;
			
		// 	fixed3 N = normalize( fixed3( dX, dY, 0.01) );
			
		// 	N *= 0.5;
		// 	N += 0.5;
		// 	return N;
		// }
		
		uniform sampler2D _MainTex;
		// uniform fixed4 _MainTex_TexelSize;
		uniform fixed4 _Color;
		// uniform fixed _Cutoff;
		uniform fixed _Timer;
        uniform fixed _WaveHeight;
		uniform fixed _WaveMag;
		uniform fixed _WaveSpeed;
		uniform fixed _Smoothness;
		uniform fixed _Metallic;
		uniform fixed _Emission;
		// uniform float _AnimationRange;
		uniform float _AnimationSpeed;
		
		// fixed _ColorType = 1;
		uniform int _Tile;
		
		fixed3 returnColor (fixed2 _st) {
			fixed3 colorOptions[8] = {
				fixed3 (.2,.2,.2),
				fixed3 (.3,.3,.3),
				fixed3 (.4,.4,.4),
				fixed3 (.5,.5,.5),
				fixed3 (.6,.6,.6),
				fixed3 (.7,.7,.7),
				fixed3 (.8,.8,.8),
				fixed3 (.9,.9,.9)
			};
			float targVal = random (_st) * 8.;					
			return colorOptions [int (floor (targVal))];
			// return fixed3(1,1,1);			
		}
		
		
		
        struct Input {
			float2 uv_MainTex : TEXCOORD0;
			// float4 verts;
		};
		void vert (inout appdata_full v, out Input o) {
			fixed4 newVerts = mul(_Object2World, v.vertex);
			fixed adj = SpikeVert (newVerts, _WaveHeight, _WaveMag, _AnimationSpeed);
			// fixed adj = 0;
			// adj += (sin (v.vertex.xy + (_Time.y * _WaveSpeed));
			adj += sin (_Time.y + v.vertex.x + v.vertex.z) * _WaveSpeed;
			// fixed adj2 = _Time.x * _WaveSpeed; 
			v.vertex += float4 (0, adj, 0, 0);
			// v.vertex += sin ()
			// v.vertex += adj2;
			// o.verts = v.vertex;
			
			o.uv_MainTex = TRANSFORM_UV(0);
      	}
		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed2 st = IN.uv_MainTex;
			
			fixed2 st_i = floor (st * _Tile);
			o.Albedo = returnColor (st_i) * _Color;			
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
			// o.Metallic = 0;
			// o.Smoothness = 0;
			// o.Emission = o.Albedo * (_Emission *  (1 - step (o.Albedo, 0.9 - (noise (_Time.y) * 0.2))));
			o.Emission = o.Albedo * noise (st *_Time.y);
			o.Emission *= noise (_Time.y * st);
			// o.Emission = 
			// o.Specularity = _Specularity;
			o.Alpha = 1;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
