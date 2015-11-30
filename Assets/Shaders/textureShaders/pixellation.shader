Shader "Custom/pixellation" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_DeformRange ("Deform Range", Float) = 15
		_DeformSpeed ("Deform Speed", Float) = 0.2
		_Timer ("Timer", Float) = 0
	}
//	SubShader {
//        Pass {
//         
//            // 1.) This will be the base forward rendering pass in which ambient, vertex, and
//            // main directional light will be applied. Additional lights will need additional passes
//            // using the "ForwardAdd" lightmode.
//            // see: http://docs.unity3d.com/Manual/SL-PassTags.html
//            Tags { "LightMode" = "ForwardBase" }
//            Blend One One
//         
//            CGPROGRAM
// 
//            #pragma vertex vert
//            #pragma fragment frag
//            #include "UnityCG.cginc"
// 
//            // 2.) This matches the "forward base" of the LightMode tag to ensure the shader compiles
//            // properly for the forward bass pass. As with the LightMode tag, for any additional lights
//            // this would be changed from _fwdbase to _fwdadd.
////            #pragma multi_compile_fwdbase
////			#pragma multi_compile_fwdadd_fullshadows
//			#pragma multi_compile_fwdadd
// 
//            // 3.) Reference the Unity library that includes all the lighting shadow macros
//            #include "AutoLight.cginc"
// 
// 
//            struct v2f
//            {
//                float4 pos : SV_POSITION;
//                 
//                // 4.) The LIGHTING_COORDS macro (defined in AutoLight.cginc) defines the parameters needed to sample 
//                // the shadow map. The (0,1) specifies which unused TEXCOORD semantics to hold the sampled values - 
//                // As I'm not using any texcoords in this shader, I can use TEXCOORD0 and TEXCOORD1 for the shadow 
//                // sampling. If I was already using TEXCOORD for UV coordinates, say, I could specify
//                // LIGHTING_COORDS(1,2) instead to use TEXCOORD1 and TEXCOORD2.
//                LIGHTING_COORDS(1,2)
//            };
// 
// 
//            v2f vert(appdata_base v) {
//                v2f o;
//                o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
//                 
//                // 5.) The TRANSFER_VERTEX_TO_FRAGMENT macro populates the chosen LIGHTING_COORDS in the v2f structure
//                // with appropriate values to sample from the shadow/lighting map
//                TRANSFER_VERTEX_TO_FRAGMENT(o);
//                 
//                return o;
//            }
// 
//            fixed4 frag(v2f i) : COLOR {
//             
//                // 6.) The LIGHT_ATTENUATION samples the shadowmap (using the coordinates calculated by TRANSFER_VERTEX_TO_FRAGMENT
//                // and stored in the structure defined by LIGHTING_COORDS), and returns the value as a float.
//                float attenuation = LIGHT_ATTENUATION(i);
////                return fixed4(1.0,0.0,0.0,1.0) * attenuation;
//				return fixed4(1.0,0.0,0.0,1.0) * attenuation;
//            }
// 
//            ENDCG
//        }
//        Pass 
//        {
//             Name "ShadowCaster"
//             Tags { "LightMode" = "ShadowCaster" }
//        
//             Fog {Mode Off}
//             ZWrite On ZTest Less Cull Off
//             Offset [_ShadowBias], [_ShadowBiasSlope]
// 
//             CGPROGRAM
//             #pragma vertex vert
//             #pragma fragment frag
//             #pragma multi_compile_shadowcaster
//             #pragma fragmentoption ARB_precision_hint_fastest
//             #include "UnityCG.cginc"
//             
//             uniform float _Scale;
// 
//             struct v2f 
//             {
//                 V2F_SHADOW_CASTER;
//             };
// 
//             v2f vert( appdata_base v )
//             {
//                 v2f o;
//                 v.vertex.xyz *= _Scale;
//                 TRANSFER_SHADOW_CASTER(o)
//                 return o;
//             }
// 
//             float4 frag( v2f i ) : COLOR
//             {
//                 SHADOW_CASTER_FRAGMENT(i)
//             }
//             ENDCG
// 
//         }
//         
//         // Pass to render object as a shadow collector
//         Pass 
//         {
//             Name "ShadowCollector"
//             Tags { "LightMode" = "ShadowCollector" }
//        
//             Fog {Mode Off}
//             ZWrite On ZTest Less
//             
//             CGPROGRAM
//             #pragma vertex vert
//             #pragma fragment frag
//             #pragma fragmentoption ARB_precision_hint_fastest
//             #pragma multi_compile_shadowcollector
// 
//             #define SHADOW_COLLECTOR_PASS
//             #include "UnityCG.cginc"
// 
//             uniform float _Scale;
//             
//             struct appdata 
//             {
//                 float4 vertex : POSITION;
//             };
// 
//             struct v2f 
//             {
//                 V2F_SHADOW_COLLECTOR;
//             };
// 
//             v2f vert (appdata v)
//             {
//                 v2f o;
//                 v.vertex.xyz *= _Scale;
//                 TRANSFER_SHADOW_COLLECTOR(o)
//                 return o;
//             }
// 
//             fixed4 frag (v2f i) : COLOR
//             {
//                 SHADOW_COLLECTOR_FRAGMENT(i)
//             }
//             ENDCG
// 
//         }
//    }
    // 7.) To receive or cast a shadow, shaders must implement the appropriate "Shadow Collector" or "Shadow Caster" pass.
    // Although we haven't explicitly done so in this shader, if these passes are missing they will be read from a fallback
    // shader instead, so specify one here to import the collector/caster passes used in that fallback.
//    Fallback "VertexLit"


//	SubShader {
//		Tags { 
//			"RenderType"="Opaque" 
//			"LightMode" = "ForwardBase"
//		}
//		LOD 200
//		
//		Pass {
//			CGPROGRAM
//	 		#pragma vertex vert
//	        #pragma fragment frag
//	        #pragma surface surf Standard fullforwardshadows
////	        #pragma multi_compile_fwdbase
//			
//	        #include "UnityCG.cginc"
//			// Use shader model 3.0 target, to get nicer looking lighting
//			#pragma target 3.0
////			#pragma multi_compile_fwdbase_fullshadows
//			#pragma multi_compile_fwdbase
//			#include "AutoLight.cginc"
//			#include "Lighting.cginc"
//			
//			#define PI 3.14159265358979323846
//
//
//			uniform sampler2D _MainTex;
//			float4 _MainTex_ST;	//dunno why this is important, but it needs to be here...
//			uniform fixed4 _Color;
//			uniform fixed _DeformRange;
//			uniform fixed _DeformSpeed;
//			uniform fixed _Timer;
////			uniform float4 _Time;
//			
//		 	struct v2f {
//	            float4 pos : SV_POSITION;
//	            fixed3 color : COLOR0;
//	            float2 uv : TEXCOORD0;
//	            LIGHTING_COORDS(2,3)
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
//            	
//            	TRANSFER_VERTEX_TO_FRAGMENT(o);
//            	return o;
//			}
//			fixed4 frag (v2f i) : SV_Target {
//				fixed2 st = i.uv;
//				
//				st += fixed2 (0.5, 0.5);
//				st = mul (st, rotate (distance (st, fixed2 (0.5, 0.5)) * (sin (_Timer * _DeformSpeed) * _DeformRange))) ;
//				st -= fixed2 (0.5, 0.5);
//				
//				float  atten = LIGHT_ATTENUATION(i);
// 				fixed4 texcol = tex2D (_MainTex, st) * atten;
//// 				fixed4 texcol = tex2D (_MainTex, st);
//            	return texcol;
//			}
//			ENDCG
//		}
//		
//		
//	} 
//	FallBack "Diffuse"
//	FallBack "VertexLit"
//	FallBack Off
	SubShader {
		Tags { 
			"RenderType"="Opaque" 
//			"LightMode" = "ForwardBase"
		}
		LOD 200
		
		
//		Pass {
			CGPROGRAM
//	 		#pragma vertex vert
//	        #pragma fragment frag
	        #pragma surface surf Standard fullforwardshadows
//	        #pragma multi_compile_fwdbase
			
//	        #include "UnityCG.cginc"
//			// Use shader model 3.0 target, to get nicer looking lighting
//			#pragma target 3.0
////			#pragma multi_compile_fwdbase_fullshadows
////			#pragma multi_compile_fwdbase
//			#include "AutoLight.cginc"
//			#include "Lighting.cginc"
			
			#define PI 3.14159265358979323846


			uniform sampler2D _MainTex;
//			float4 _MainTex_ST;	//dunno why this is important, but it needs to be here...
			uniform fixed4 _Color;
			uniform fixed _DeformRange;
			uniform fixed _DeformSpeed;
			uniform fixed _Timer;
//			uniform float4 _Time;
			
//		 	struct v2f {
//	            float4 pos : SV_POSITION;
//	            fixed3 color : COLOR0;
//	            float2 uv : TEXCOORD0;
//	            LIGHTING_COORDS(2,3)
//	        };
	        
	        struct Input {
				float2 uv_MainTex;
			};

			half _Glossiness;
			half _Metallic;
//			fixed4 _Color;

	        
	        
	        fixed2x2 scale (fixed2 f) { return fixed2x2 ( fixed2 (f.x, 0.0), fixed2 (0.0, f.y)); }
			fixed2x2 translate (fixed2 f) { return fixed2x2 ( fixed2 (0.0, 1.0), fixed2 (f.x, f.y) ); }

			//float version
			fixed2x2 scale (fixed f) { return fixed2x2 ( fixed2 (f, 0.0), fixed2 (0.0, f)); }
			fixed2x2 translate (fixed f) { return fixed2x2 ( fixed2 (0.0, 1.0), fixed2 (f, f) ); }

			fixed2x2 rotate (fixed a) { return fixed2x2 ( fixed2 (cos(a), -sin(a)), fixed2 (sin (a), cos(a))); }
			fixed2x2 identityMatrix () { return fixed2x2 ( fixed2 (1.0, 0.0), fixed2 (0.0, 1.0)); }
			
			
			void surf (Input IN, inout SurfaceOutputStandard o) {
				// Albedo comes from a texture tinted by color
//				fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
//				fixed2 st = i.uv;
				fixed2 st = IN.uv_MainTex;
				
				st += fixed2 (0.5, 0.5);
				st = mul (st, rotate (distance (st, fixed2 (0.5, 0.5)) * (sin (_Timer * _DeformSpeed) * _DeformRange))) ;
				st -= fixed2 (0.5, 0.5);

				fixed4 c = tex2D (_MainTex, st) * _Color;
				o.Albedo = c.rgb;
				// Metallic and smoothness come from slider variables
				o.Metallic = _Metallic;
				o.Smoothness = _Glossiness;
				o.Alpha = c.a;
			}
//			void surf (Input IN, inout SurfaceOutputStandard o) {
//				// Albedo comes from a texture tinted by color
//				fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
//				o.Albedo = c.rgb;
//				// Metallic and smoothness come from slider variables
//				o.Metallic = _Metallic;
//				o.Smoothness = _Glossiness;
//				o.Alpha = c.a;
//			}
			
//			v2f vert (appdata_base v) {
//		 		v2f o;
//		        o.pos = mul (UNITY_MATRIX_MVP, v.vertex);		//set to proper viewpoint in the world
//            	o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
//            	o.uv *= -1.;
//            	
//            	TRANSFER_VERTEX_TO_FRAGMENT(o);
//            	return o;
//			}
//			fixed4 frag (v2f i) : SV_Target {
//				fixed2 st = i.uv;
//				
//				st += fixed2 (0.5, 0.5);
//				st = mul (st, rotate (distance (st, fixed2 (0.5, 0.5)) * (sin (_Timer * _DeformSpeed) * _DeformRange))) ;
//				st -= fixed2 (0.5, 0.5);
//				
//				float  atten = LIGHT_ATTENUATION(i);
// 				fixed4 texcol = tex2D (_MainTex, st) * atten;
//// 				fixed4 texcol = tex2D (_MainTex, st);
//            	return texcol;
//			}
			ENDCG
		}
		
		
//	} 
	FallBack "Diffuse"	
}