Shader "Custom/distanceHighlight4" {
	Properties {
		_Color ("Color", Color) = (1.0, 0.0, 0.0, 1.0)
		_Cutoff ("Distance Cutoff", Float) = 15
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_WaveHeight ("Wave Height", Float) = 1.0
		_WaveFreq ("Wave Frequency", Float) = 5.0
		_AnimationRange ("Animation Range", Float) = 50
		_AnimationSpeed ("Animation Spedd", Float) = .1

	}	
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// #pragma surface surf Standard fullforwardshadows vertex:vert
        // #pragma surface surf Standard vertex:vert addshadow
		#pragma surface surf Standard fullforwardshadows vertex:vert addshadow
		// #pragma surface surf Lambert vertex:vert addshadow
 
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
		
		uniform sampler2D _MainTex;
		// float4 MainTex_ST;
		// float4 _MainTex2_ST;
		uniform fixed4 _Color;
		uniform fixed _Cutoff;
		uniform fixed _Timer;
        uniform float _WaveHeight;
		uniform float _WaveFreq;
		uniform float _AnimationRange;
		uniform float _AnimationSpeed;
        
        struct Input {
			float2 uv_MainTex : TEXCOORD0;
			float2 uv;
		};
		void vert (inout appdata_full v, out Input o) {
				float dist = _AnimationRange - distance(_WorldSpaceCameraPos, mul(_Object2World, v.vertex));
				dist = max (dist, 0);
				// dist = clamp (dist, 0, -15);

				fixed4 newVerts = mul(UNITY_MATRIX_MV, v.vertex);				
				v.vertex += float4 (0, (noise (float2 (newVerts.x, newVerts.z) * (_Time.y * _AnimationSpeed)) * _WaveHeight) * dist, 0, 0);

				o.uv = TRANSFORM_UV(0);
			
      	}
		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed2 st = IN.uv_MainTex;
			o.Albedo = tex2D(_MainTex, st);
			o.Metallic = 0;
			o.Smoothness = 0;
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "VertexLit"
}