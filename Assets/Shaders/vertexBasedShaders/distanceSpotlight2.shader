﻿Shader "Custom/distanceHighlight2" {
	Properties {
		_Color ("Color", Color) = (1.0, 0.0, 0.0, 1.0)
		_Cutoff ("Distance Cutoff", Float) = 15
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_WaveHeight ("Wave Height", Float) = 1.0
		_WaveFreq ("Wave Frequency", Float) = 5.0
		_AnimationRange ("AnimationRange", Float) = 50
		_AnimationSpeed ("AnimationRange", Float) = .1
//		_YScale ("Scaling", Float) = 10
//		_YSpeed ("Speed", Float) = .2		
	}
//	SubShader {
//		Tags { "RenderType"="Opaque" }
//		LOD 200
//		
//		Pass {
//			CGPROGRAM
//	 		#pragma vertex vert
//	        #pragma fragment frag
//	        #include "UnityCG.cginc"
//			// Use shader model 3.0 target, to get nicer looking lighting
//			#pragma target 3.0
//			
//			#define PI 3.14159265358979323846
//			//RANDOM & NOISE
//			half random (fixed _x) { return frac(sin(_x)*100000.0); }
//			half random (in fixed2 _st) { return frac(sin(dot(_st.xy, fixed2(12.9898,78.233))) * 43758.5453123); }
//			half2 random2(fixed2 st){
//			    st = fixed2( dot(st,fixed2(127.1,311.7)), dot(st,fixed2(269.5,183.3)) );
//			    return -1.0 + 2.0*frac(sin(st)*43758.5453123);
//			}
//
//			fixed noise (fixed _x) {
//			    fixed i = floor(_x);  // integer
//				fixed f = frac(_x);  // fraction
//				fixed y = lerp(random(i), random(i + 1.0), smoothstep(0.,1.,f));
//				return y;
//			}
//			fixed noise (in fixed2 st) {
//			    fixed2 i = floor(st);
//			    fixed2 f = frac(st);
//			    fixed a = random(i);
//			    fixed b = random(i + fixed2(1.0, 0.0));
//			    fixed c = random(i + fixed2(0.0, 1.0));
//			    fixed d = random(i + fixed2(1.0, 1.0));
//			    fixed2 u = f*f*(3.0-2.0*f);
//			    return lerp(a, b, u.x) + 
//			            (c - a)* u.y * (1.0 - u.x) + 
//			            (d - b) * u.x * u.y;
//			}
//			fixed gradientNoise(fixed2 st) {
//			    fixed2 i = floor(st);
//			    fixed2 f = frac(st);
//
//			    fixed2 u = f*f*(3.0-2.0*f);
//
//			    return lerp( lerp( dot( random2(i + fixed2(0.0,0.0) ), f - fixed2(0.0,0.0) ), 
//			                       dot( random2(i + fixed2(1.0,0.0) ), f - fixed2(1.0,0.0) ), u.x),
//			                 lerp( dot( random2(i + fixed2(0.0,1.0) ), f - fixed2(0.0,1.0) ), 
//			                       dot( random2(i + fixed2(1.0,1.0) ), f - fixed2(1.0,1.0) ), u.x), u.y);
//			}
//
//
//			uniform sampler2D _MainTex;
//			float4 _MainTex_ST;	//dunno why this is important, but it needs to be here...
//			uniform fixed _YScale;
//			uniform fixed _YSpeed;
//			uniform fixed _Timer;
//			
//		 	struct v2f {
//	            float4 pos : SV_POSITION;
//	            fixed3 color : COLOR0;
//	            float2 uv : TEXCOORD0;
//	        };
//	        
//	        
//	        
//	        fixed2x2 scale (fixed2 f) { return fixed2x2 ( fixed2 (f.x, 0.0), fixed2 (0.0, f.y)); }
//			fixed2x2 translate (fixed2 f) { return fixed2x2 ( fixed2 (0.0, 1.0), fixed2 (f.x, f.y) ); }
//
//			//float version
//			fixed2x2 scale (fixed f) { return fixed2x2 ( fixed2 (f, 0.0), fixed2 (0.0, f)); }
//			fixed2x2 translate (fixed f) { return fixed2x2 ( fixed2 (0.0, 1.0), fixed2 (f, f) ); }
//
//			fixed2x2 rotate (fixed a) { return fixed2x2 ( fixed2 (cos(a), -sin(a)), fixed2 (sin (a), cos(a))); }
//			fixed2x2 identityMatrix () { return fixed2x2 ( fixed2 (1.0, 0.0), fixed2 (0.0, 1.0)); }
//			
//			v2f vert (appdata_base v) {
//		 		v2f o;
//		        o.pos = mul (UNITY_MATRIX_MVP, v.vertex);		//set to proper viewpoint in the world
//            	o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
//            	o.uv *= -1.;
//            	return o;
//			}
//			fixed4 frag (v2f i) : SV_Target {
//				fixed2 st = i.uv;
//				st.y += ((_Timer * _YSpeed) * noise (st.x * _YScale));
// 				fixed4 texcol = tex2D (_MainTex, st);
//            	return texcol;
//			}
//			ENDCG
//		}
//		
//		
//	} 
//	FallBack "Diffuse"
	
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert
		
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
		float4 _MainTex_ST;
		uniform fixed4 _Color;
		uniform fixed _Cutoff;
		uniform fixed _Timer;
        uniform float _WaveHeight;
		uniform float _WaveFreq;
		uniform float _AnimationRange;
		uniform float _AnimationSpeed;
        
        struct Input {
			float2 uv_MainTex;
			float dist;
			float4 vertex;
		};
		void vert (inout appdata_full v, out Input o) {
//				float dist = max (_AnimationRange - distance(_WorldSpaceCameraPos, mul(_Object2World, v.vertex)), 0);
//				o.dist = dist;
//				fixed newVal = remap (o.dist, 0, 50, 0, 1);				
//				o.vertex += float4 (0, (noise (float2 (newVerts.x, newVerts.z) *(_Time.y * _AnimationSpeed)) * _WaveHeight) * dist, 0, 0);
//				fixed4 newVerts = mul(UNITY_MATRIX_MV, o.vertex);
				float dist = _AnimationRange - distance(_WorldSpaceCameraPos, mul(_Object2World, v.vertex));
				dist = max (dist, 0);
				
				
				
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				
				fixed4 newVerts = mul(UNITY_MATRIX_MV, v.vertex);
//				o.vertex += float4 (0, (abs (sin ((_Time.y * _WaveFreq + _Phase) + o.vertex.x + o.vertex.z) * _WaveHeight)) * dist, 0,0);
				o.vertex += float4 (0, (noise (float2 (newVerts.x, newVerts.z) *(_Time.y * _AnimationSpeed)) * _WaveHeight) * dist, 0, 0);
				
				o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
//				UNITY_TRANSFER_FOG(o,o.vertex);
//				return o;
			
      	}
		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed2 st = IN.uv_MainTex;
			
			
			
//			st += fixed2 (0.5, 0.5);
//			st = mul (st, rotate (distance (st, fixed2 (0.5, 0.5)) * (sin (_Timer * _DeformSpeed) * _DeformRange))) ;
//			st -= fixed2 (0.5, 0.5);
//			st.y += ((_Timer * _YSpeed) * noise (st.x * _YScale));

			

//			fixed4 c = tex2D (_MainTex, st) * IN.dist;
//			fixed4 c = _Color * (1 - (IN.dist / _Cutoff));
//			fixed4 c = _Color * IN.dist;
			fixed newVal = remap (IN.dist, 0, 25, 0, 1);
			
//			fixed3 c = hsb2rgb (fixed3 (noise (_Time.y * st) * 20, 1, 1 - newVal));
			fixed3 c = fixed3 (1,0,0);
//			fixed3 c = fixed3 (st.x, 0, 0);
			
//			fixed4 c = _Color;
			
			o.Albedo = c;
			
			// Metallic and smoothness come from slider variables
			o.Metallic = 0;
			o.Smoothness = 0;
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "VertexLit"
}