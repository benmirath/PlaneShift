Shader "Custom/pixellation2" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
//		_DeformRange ("Deform Range", Float) = 15
		_DeformSpeed ("Deform Speed", Float) = 0.2
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
//
//
//			uniform sampler2D _MainTex;
//			float4 _MainTex_ST;	//dunno why this is important, but it needs to be here...
//			uniform fixed4 _Color;
////			uniform fixed _DeformRange;
//			uniform fixed _DeformSpeed;
//			uniform fixed _Timer;
////			uniform float4 _Time;
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
//				
//				st += fixed2 (0.5, 0.5);
//				st = mul (st, rotate (distance (st, fixed2 (0.5, 0.5)) * (_Timer * _DeformSpeed))) ;
//				st -= fixed2 (0.5, 0.5);
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
        #pragma surface surf Standard fullforwardshadows
		
		#define PI 3.14159265358979323846


		uniform sampler2D _MainTex;
		uniform fixed4 _Color;
		uniform fixed _DeformRange;
		uniform fixed _DeformSpeed;
		uniform fixed _Timer;
        
        struct Input {
			float2 uv_MainTex;
		};

        
        fixed2x2 scale (fixed2 f) { return fixed2x2 ( fixed2 (f.x, 0.0), fixed2 (0.0, f.y)); }
		fixed2x2 translate (fixed2 f) { return fixed2x2 ( fixed2 (0.0, 1.0), fixed2 (f.x, f.y) ); }

		//float version
		fixed2x2 scale (fixed f) { return fixed2x2 ( fixed2 (f, 0.0), fixed2 (0.0, f)); }
		fixed2x2 translate (fixed f) { return fixed2x2 ( fixed2 (0.0, 1.0), fixed2 (f, f) ); }

		fixed2x2 rotate (fixed a) { return fixed2x2 ( fixed2 (cos(a), -sin(a)), fixed2 (sin (a), cos(a))); }
		fixed2x2 identityMatrix () { return fixed2x2 ( fixed2 (1.0, 0.0), fixed2 (0.0, 1.0)); }
		
		
		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed2 st = IN.uv_MainTex;
			
//			st += fixed2 (0.5, 0.5);
//			st = mul (st, rotate (distance (st, fixed2 (0.5, 0.5)) * (sin (_Timer * _DeformSpeed) * _DeformRange))) ;
//			st -= fixed2 (0.5, 0.5);
			st += fixed2 (0.5, 0.5);
//			st = mul (st, rotate (distance (st, fixed2 (0.5, 0.5)) * (sin (_Timer * _DeformSpeed) * _DeformRange))) ;
			st = mul (st, rotate (distance (st, fixed2 (0.5, 0.5)) * (_Timer * _DeformSpeed))) ;
			st -= fixed2 (0.5, 0.5);
//			fixed4 texcol = tex2D (_MainTex, st);

			fixed4 c = tex2D (_MainTex, st) * _Color;
			o.Albedo = c.rgb;
			
			// Metallic and smoothness come from slider variables
			o.Metallic = 0;
			o.Smoothness = 0;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "VertexLit"
}