Shader "Custom/pixelStripDrip" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_YScale ("Scaling", Float) = 10
		_YSpeed ("Speed", Float) = .2
		_TilingScale ("Tiling Scale", Float) = 25
		
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Pass {
			CGPROGRAM
	 		#pragma vertex vert
	        #pragma fragment frag
	        #include "UnityCG.cginc"
			// Use shader model 3.0 target, to get nicer looking lighting
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


			uniform sampler2D _MainTex;
			float4 _MainTex_ST;	//dunno why this is important, but it needs to be here...
			uniform fixed _YScale;
			uniform fixed _YSpeed;
			uniform fixed _TilingScale;
			uniform fixed _Timer;
			
		 	struct v2f {
	            float4 pos : SV_POSITION;
	            fixed3 color : COLOR0;
	            float2 uv : TEXCOORD0;
	        };
	        
	        
	        
	        fixed2x2 scale (fixed2 f) { return fixed2x2 ( fixed2 (f.x, 0.0), fixed2 (0.0, f.y)); }
			fixed2x2 translate (fixed2 f) { return fixed2x2 ( fixed2 (0.0, 1.0), fixed2 (f.x, f.y) ); }

			//float version
			fixed2x2 scale (fixed f) { return fixed2x2 ( fixed2 (f, 0.0), fixed2 (0.0, f)); }
			fixed2x2 translate (fixed f) { return fixed2x2 ( fixed2 (0.0, 1.0), fixed2 (f, f) ); }

			fixed2x2 rotate (fixed a) { return fixed2x2 ( fixed2 (cos(a), -sin(a)), fixed2 (sin (a), cos(a))); }
			fixed2x2 identityMatrix () { return fixed2x2 ( fixed2 (1.0, 0.0), fixed2 (0.0, 1.0)); }
			
			v2f vert (appdata_base v) {
		 		v2f o;
		        o.pos = mul (UNITY_MATRIX_MVP, v.vertex);		//set to proper viewpoint in the world
            	o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
            	o.uv *= -1.;
            	return o;
			}
			fixed4 frag (v2f i) : SV_Target {
				fixed2 st = i.uv;
				
				st *= _TilingScale;
				fixed2 st_red = st;
				fixed2 st_blue = st;
//				st *= 30;
				
				fixed adjustX = _Timer * clamp (random (floor(st.x)), 0.1, 1.);
				fixed adjustY = _Timer * clamp (random (floor(st.y)), 0.1, 1.);
				st_red.y += adjustX;
				st_blue.x += adjustY;
				st.x -= adjustY;
				st.y -= adjustX;
//				st
				
				st /= _TilingScale;
				st_red /= _TilingScale;
				st_blue /= _TilingScale;
//				st.y += ((_Time.y * _YSpeed) * random (st.x * _YScale));

//				st *= .03;
 				
// 				fixed4 texcol = tex2D (_MainTex, st);
// 				fixed4 texcol_red = tex2D (_MainTex, st_red);
// 				fixed4 texcol_blue = tex2D (_MainTex, st_blue);
 							
 				fixed4 finalCol = fixed4(tex2D (_MainTex, st_red).r,tex2D (_MainTex, st).g,tex2D (_MainTex, st_blue).b,1);
            	return finalCol;
			}
			ENDCG
		}
		
		
	} 
	FallBack "Diffuse"
}