Shader "Custom/Column/column_twist_4" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_TwistAmount ("Rotation", Float) = 5
		_AnimSpeed ("Animation Speed", Float) = 0
		_Subdivide ("Sub Divide", Int) = 20	 
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		// Tags { "Queue"="Transparent" "RenderType"="Transparent" }
		LOD 500	//200
		
		CGPROGRAM
		// #pragma surface surf Standard fullforwardshadows vertex:vert alpha
		// #pragma surface surf Lambert vertex:vert alpha
		#pragma surface surf Lambert vertex:vert alpha
		#pragma target 3.0
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
		fixed4 Twist( fixed4 pos, fixed t ) {
			fixed st = sin(t);
			fixed ct = cos(t);
			fixed4 new_pos;
			
			new_pos.x = pos.x*ct - pos.z*st;
			new_pos.z = pos.x*st + pos.z*ct;
			
			new_pos.y = pos.y;
			new_pos.w = pos.w;
		
			return new_pos;
		}

		sampler2D _MainTex;
		fixed _TwistAmount;
		fixed _AnimSpeed;
		int _Subdivide;

		struct Input {
			float2 uv_MainTex;
		};
		fixed4 _Color;

		void vert (inout appdata_full v, out Input o) {
			float adj = v.vertex.y * _TwistAmount;
			adj += (_Time.y * _AnimSpeed); 
			v.vertex = Twist (v.vertex, adj);
			
			fixed4 objPos = mul(_World2Object, mul (_Object2World, v.vertex)); 

			// fixed3 adj = fixed3 (0,0,0);
			// adj.x = snoise (adj.y + (adj.x *  (_Time.y * _AnimSpeed))) * _TwistAmount;
			// adj.z = snoise (adj.y + (adj.z * (_Time.y * _AnimSpeed))) * _TwistAmount;
			
			fixed4 adj2 = fixed4 (
				snoise (v.vertex.y + (v.vertex.x *  (_Time.y * _AnimSpeed))) * _TwistAmount,
				0,
				snoise (v.vertex.y + (v.vertex.z * (_Time.y * _AnimSpeed))) * _TwistAmount,
				0
			);
			v.vertex += adj2;
			
			// v.vertex += fixed4 (0,0,5,0);
			
      	}

		// void surf (Input IN, inout SurfaceOutputStandard o) {
		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			fixed2 st = IN.uv_MainTex;
			// bool isTransparent = fmod (floor (st.x * 50), 2) == 0;
			
			o.Albedo = c.rgb;
			
			// o.Emission = o.Albedo;
			o.Emission = 0;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
