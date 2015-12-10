Shader "Custom/proximityColor2" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Color ("Color", Color) = (1.0, 0.0, 0.0, 1.0)
		_Cutoff ("Distance Cutoff", Float) = 15
		_PatternTiling ("Pattern Tiling", Float) = 200
		_Radius ("Circle Radius", Float) = .75
	}	
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow 
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
		    return lerp( lerp( dot( random2(i + fixed2(0.0,0.0) ), f - fixed2(0.0,0.0) ), dot( random2(i + fixed2(1.0,0.0) ), f - fixed2(1.0,0.0) ), u.x),
		                 lerp( dot( random2(i + fixed2(0.0,1.0) ), f - fixed2(0.0,1.0) ), dot( random2(i + fixed2(1.0,1.0) ), f - fixed2(1.0,1.0) ), u.x), u.y);
		}
        fixed3 hsb2rgb( in fixed3 c ){
		    fixed3 rgb = clamp(abs(fmod(c.x*6.0+fixed3(0.0,4.0,2.0), 6.0)-3.0)-1.0, 0.0, 1.0 );		//color converting black magic, truly terrifying
		    rgb = rgb*rgb*(3.0-2.0*rgb);
		    return c.z * lerp( fixed3(1,1,1), rgb, c.y);
		}
		
        fixed2x2 scale (fixed2 f) { return fixed2x2 ( fixed2 (f.x, 0.0), fixed2 (0.0, f.y)); }
		fixed2x2 translate (fixed2 f) { return fixed2x2 ( fixed2 (0.0, 1.0), fixed2 (f.x, f.y) ); }

		//float version
		fixed2x2 scale (fixed f) { return fixed2x2 ( fixed2 (f, 0.0), fixed2 (0.0, f)); }
		fixed2x2 translate (fixed f) { return fixed2x2 ( fixed2 (0.0, 1.0), fixed2 (f, f) ); }
		fixed2x2 rotate (fixed a) { return fixed2x2 ( fixed2 (cos(a), -sin(a)), fixed2 (sin (a), cos(a))); }
		fixed2x2 identityMatrix () { return fixed2x2 ( fixed2 (1.0, 0.0), fixed2 (0.0, 1.0)); }
		
		fixed circle(fixed2 _st, fixed _radius) {
			_st -= .5;
			return 1.0 - step (_radius*.5,dot(_st,_st) * 2);
			// return step (_radius*.5,dot(_st,_st) * 2);
		}
		
		uniform sampler2D _MainTex;
		uniform fixed4 _Color;
		uniform fixed _Cutoff;
		uniform fixed _Timer;
		uniform fixed _PatternTiling;
		uniform fixed _Radius;
        
        struct Input {
			// float2 uv_MainTex;
			float2 uv_MainTex : TEXCOORD0;
			float2 uv;
			float dist;
		};
		void vert (inout appdata_full v, out Input o) {
			o.dist = distance(_WorldSpaceCameraPos, mul(_Object2World, v.vertex));
			o.uv_MainTex = v.texcoord;
			o.uv = TRANSFORM_UV(0);
			
      	}
		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed2 st = IN.uv_MainTex;
			// fixed2 st = IN.uv;
			
			// st *= _PatternTiling;
			st *= _PatternTiling;
			// IN.uv_MainTex = st;
			
				    
			//determine arrangement layer
			fixed2 st_i = floor(st);
			if (fmod(st_i.y, 2) == 1) {	//create x offset every other row
				st.x += .5;
				st_i = floor(st);
			}
			
			//determine pattern layer
			fixed2 st_f = frac(st);		//create pattern
			// float pct = circle(st_f, d * .75);

			fixed pct2 = max(1 - (IN.dist / _Cutoff), 0);
			// col =  returnColor (st_i) * pct;
			// fixed pct = circle(st_f, _Radius);
			fixed pct = circle(st_f, (_Radius + noise (st * _Time.y) * 0.5) * pct2);
			// fixed4 c = _Color * (1 - (IN.dist / _Cutoff));
			// fixed3 c = fixed4 (1,1,1,1);
			fixed3 c = hsb2rgb (fixed3 (noise (_WorldSpaceCameraPos.xz *= 0.1), 1,1)) * pct * pct2;
			// o.Albedo = c.rgb;
			o.Albedo = c;
			
			// Metallic and smoothness come from slider variables
			o.Metallic = 0;
			o.Smoothness = 0;
			o.Emission = c * 0.25 * IN.dist * pct;
			// o.EmissionColor = c;
			// o.Alpha = c.a;
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "VertexLit"
}