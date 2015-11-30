
Shader "Unlit/newTestShader1" { Fallback "Diffuse"}

//
//Shader "Unlit/newTestShader1"
//{
////	SubShader {
////        Pass {
////            CGPROGRAM
////            #pragma vertex vert
////            #pragma fragment frag
////            #pragma target 3.0
////
////            #include "UnityCG.cginc"
////
////            struct vertexInput {
////                float4 vertex : POSITION;
////                float4 texcoord0 : TEXCOORD0;
////            };
////
////            struct fragmentInput{
////                float4 position : SV_POSITION;
////                float4 texcoord0 : TEXCOORD0;
////            };
////
////            fragmentInput vert(vertexInput i){
////                fragmentInput o;
////                o.position = mul (UNITY_MATRIX_MVP, i.vertex);
////                o.texcoord0 = i.texcoord0;
////                return o;
////            }
////            fixed4 frag(fragmentInput i) : SV_Target {
////                return fixed4(1.0 - i.texcoord0.x, 0.0,0.0,1.0);
////            }
////            ENDCG
////        }
////    }
//	SubShader {
//        Pass {
//            CGPROGRAM
//            #pragma vertex vert
//            #pragma fragment frag
//            #pragma target 3.0
//
//            #include "UnityCG.cginc"
//
//            struct vertexInput {
//                float4 vertex : POSITION;
//                float4 texcoord0 : TEXCOORD0;
//            };
//
//            struct fragmentInput{
//                float4 position : SV_POSITION;
//                float4 texcoord0 : TEXCOORD0;
//            };
//
//            fragmentInput vert(vertexInput i){
//                fragmentInput o;
//                o.position = mul (UNITY_MATRIX_MVP, i.vertex);
//                o.texcoord0 = i.texcoord0;
//                return o;
//            }
//            
////            uniform float4 _Time;
//				
////				uniform vec2 u_resolution;
////			uniform float4 _ScreenParams;
////				uniform vec2 u_mouse;
////				uniform float u_time;
//
//			float4 DrawCircle (float2 st, float2 coord, float divisions, float dropShadow) {
//			    float pct = distance(st, coord) / divisions;
//			    float3 color = float3(1.0 - smoothstep (1.0 - dropShadow,1.0,pct));
//			    return float4 (color, 1.0);
//			}
//
//			// vec4 DrawCircle_Animdated (vec2 st, vec2 coord, float divisions, float dropShadow, float animMagnitude) {
//			//     float pct = (distance(st, coord) / divisions) + sin(u_time) * animMagnitude;
//			//     vec3 color = vec3(1.0 - smoothstep (1.0 - dropShadow,1.0,pct));
//			//     return vec4 (color, 1.0);
//			// }
//
//			float4 DrawCircle_Animdated (float2 st, float2 coord, float divisions, float dropShadow, float animMagnitude) {
//			    float pct = (distance(st, coord) / divisions) + animMagnitude;
//			    float3 color = float3(1.0 - smoothstep (1.0 - dropShadow,1.0,pct));
//			    return float4 (color, 1.0);
//			}
//
//			float4 DrawCircle_Manual (float2 st, float2 coord, float pct, float size, float dropShadow, float animMagnitude) {
//			    float newPct = (pct + animMagnitude) * size;
//			    float3 color = float3(1.0 - smoothstep (1.0 - dropShadow,1.0,newPct));
//			    return float4 (color, 1.0);
//			}
//
//			float Patricircle (in float2 _st, in float _radius){
//			    float2 l = _st-float2(0.5);
//			    return 1.-smoothstep(_radius-(_radius*0.01),
//			                         _radius+(_radius*0.01),
//			                         dot(l,l)*4.0);
//			}
//
//			float3 DistanceField_Circle (float2 st, float2 pos, float size, float shadowBuffer, float3 color, float sizeAnim, float2 posAnim) {
//			    float pct = 0.0;
//			    pct = distance(st,pos + posAnim);
//			    pct = smoothstep(pct, pct + shadowBuffer, size + sizeAnim);
//			    return color * pct;
//			}
//			float DistanceField_Circle (float2 st, float2 pos, float size, float shadowBuffer, float sizeAnim, float2 posAnim) {
//			    float pct = 0.0;
//			    pct = distance(st,pos + posAnim);
//			    // vec2( posAnim + 0.5 - sin (u_time) )
//			    // pct = smoothstep(pct, pct + shadowBuffer, size + sizeAnim);
//			    pct = smoothstep(pct, 1.0 - pct + shadowBuffer, size + sizeAnim);
//			    return pct;
//			}
//
//			float3x3 matr = float3x3 ( float3 (1.0, 0.0, 0.0), float3 (0.0, 1.0, 0.0), float3 (0.0, 0.0, 1.0));
//
//			float3x3 scaleMatrix (float2 f) {
//			    return float3x3 (
//			        float3 (f.x, 0.0, 0.0), 
//			        float3 (0.0, f.y, 0.0), 
//			        float3 (0.0, 0.0, 1.0)
//			    );
//			}
//			void scale (in float2 f) {
//			    matr = scaleMatrix (f) * matr;
//			}
//			float3x3 translationMatrix (float2 f) {
//			    return float3x3 (
//			        float3 (1.0, 0.0, 0.0), 
//			        float3 (0.0, 1.0, 0.0), 
//			        float3 (f.x, f.y, 1.0)
//			    );
//			}
//			void translate (in float2 f) {
//			    matr = translationMatrix (f) * matr;
//			}
//			float3x3 rotationMatrix (float a) {
//			    return float3x3 (
//			        float3 (cos(a), -sin(a), 0.0), 
//			        float3 (sin (a), cos(a), 0.0), 
//			        float3 (0.0, 0.0, 1.0)
//			    );
//			}
//			void rotate (float a) {
//			    matr = rotationMatrix (a) * matr;
//			}
//
//			// vec3 col1 = vec3 (0.0,0.0,1.0);
//			// vec3 col2 = vec3 (1.0,0.0,0.0);
//			fixed3 col1 = float3 (0.07, 0.68, 0.6);
//			fixed3 col2 = float3 (0.67, 0.13, 0.45);
////			fixed4 frag(fragmentInput i) : SV_Target {
//			fixed4 frag(fragmentInput i) : COLOR {
////				float2 st = gl_FragCoord.xy/_ScreenParams.xy;
////				float2 st = _ScreenParams.xy;
////				float2 st = i.texcoord0.xy / _ScreenParams.xy;
//				float2 st = i.texcoord0.xy;
//			    // st *= 4.0;
//			    // st -= 1.5;
//
//			    float3 pos = float3 (st, 1.0);
////			    pos = matr * pos;
//				pos = mul (matr, pos);
//
//			    float3 col = float3 (0.0);
//			    float pct = 0.0;
//			    // float posAnim = sin (u_time) * 0.25;
//			    float posAnim = sin (_Time.y);
//
//			    // STEP 1 - Draw same circle, animating across diffeent positions
//			    // pct = distance ( st, vec2(posAnim + 0.5 - sin (u_time) ) ); 
//			    // pct = distance ( st, vec2(posAnim + 0.5 + sin (u_time) ) );
//			    pct = DistanceField_Circle (st, float2 (0.5), 0.4, 0.05, 0.0, float2 (posAnim));
//			    pct = DistanceField_Circle (st, float2 (0.5), 0.4, 0.05, 0.0, -float2 (posAnim));
//
//
//			    // pct = min(
//			    //     distance (
//			    //         st,
//			    //         vec2(posAnim + 0.5 - sin (u_time))
//			    //     ), 
//			    //     distance (
//			    //         st,
//			    //         vec2(posAnim + 0.5 + sin (u_time))
//			    //     )
//			    // );
//
//			    // pct =  max (
//			    //     distance ( 
//			    //         st,
//			    //         vec2(posAnim + 0.4 + sin (u_time))
//			    //     ), 
//			    //     distance (
//			    //         st,
//			    //         vec2(posAnim + 0.6 + sin (u_time))
//			    //     )
//			    // );
//
//			    // pct = min(
//			    //     distance (
//			    //         st,
//			    //         vec2( 0.5 + posAnim - sin (u_time) )
//			    //     ), 
//			    //     distance (
//			    //         st,
//			    //         vec2( 0.5 + posAnim + sin (u_time) )
//			    //     )
//			    // );
//
//			    // pct = min (
//			    //     DistanceField_Circle (st, vec2 (0.5), 0.4, 0.0, abs (sin (u_time) * 0.075), vec2 (posAnim - sin (u_time) ) ),
//			    //     DistanceField_Circle (st, vec2 (0.5), 0.4, 0.0, abs (sin (u_time) * 0.075), vec2 (posAnim + sin (u_time) ) )
//			    // );
//
//			    
//			    translate (float2 (-0.5));
//			    scale (float2 (8.0));
//			    rotate (_Time.y);
//			    
////			    pos = matr * pos;
//				pos = mul (matr, pos);
//			    pct = min (
//			        DistanceField_Circle (pos.xy, float2 (0.0), 0.4, 0.0, abs (sin (_Time.y) * 0.05), float2 (posAnim - sin (_Time.y) ) ),
//			        DistanceField_Circle (pos.xy, float2 (0.0), 0.4, 0.0, abs (sin (_Time.y) * 0.05), float2 (posAnim + sin (_Time.y) ) )
//			    );
//
//			    pct += DistanceField_Circle (pos.xy, float2 (0.0), 0.4, 0.0, abs (cos (_Time.y) * 0.05), float2 (posAnim + cos (_Time.y) ) );
//
//
//			    // pct = mix ( 
//			    //     min(
//			    //         distance (
//			    //             st,
//			    //             vec2(posAnim + 0.4 - sin (u_time))
//			    //         ), 
//			    //         1.0 - distance (
//			    //             st,
//			    //             vec2(posAnim + 0.6 + sin (u_time))
//			    //         )
//			    //     ), 
//			    //     max (
//			    //         distance (
//			    //             st,
//			    //             vec2(posAnim + 0.4 + sin (u_time))
//			    //         ), 
//			    //         distance (
//			    //             st,
//			    //             vec2(posAnim + 0.6 + sin (u_time))
//			    //         )
//			    //     ), 
//			    //     (sin (u_time) * 0.5) + 0.5
//			    //     // abs (sin (u_time * 0.5)) + 0.5
//			    // );
//
//			    
//
//			    // pct = step (1.0 - pct, 0.5);
//			    // color = vec3 (pct);
//			    // color = mix (col1, col2, sin (u_time));
//			    col = lerp (col2, col1, pct + sin (_Time.y));
//			    // vec3 color2 = color;
//			    float3 color2 = lerp (col1, col2, pct + sin (_Time.y));
//			    col = lerp (col, color2, pct);
//
//			    
//			    
//			    // vec3 color = vec3 (1.0);
//			    // pct = 1.0 - step (pct, 0.1);
//
////			    gl_FragColor = vec4 (vec3 (pct), 1.0);      //BW
//			    // gl_FragColor = vec4 ((pct * color2 * 2.0) * color * 2.0, 1.0);     //single color at time
//			    // gl_FragColor = vec4 ((pct + color) * color, 1.0);   //weird oversaturation (pct is pushed over threshold by color addition?)
//			    // gl_FragColor = vec4 ((pct - color) * color, 1.0);   //ominous undersaturation (pct is pushed over threshold by color addition?)
//			    // gl_FragColor = vec4 ((pct / color2) * color, 1.0);  //weird tween for both shape and color
//
//			    // MAIN EXAMPLE
//			    // gl_FragColor = vec4 ((pct * (color2 + color) * 3.0) * color * 2.0, 1.0);     //single color at time
//
//			    // ROTATION ADDITIONS
////			    gl_FragColor = vec4 ((pos * (color2 + color) * 3.0) * color * 2.0, 1.0);     //single color at time
////			    gl_FragColor = vec4 ((pos * (color2 + color) * cos (_Time.y)) * color / sin(_Time.y), 1.0);     //single color at time
//			    return float4 ((pos * (color2 + col) * cos (_Time.y)) * col / sin(_Time.y), 1.0);
//
//			}
////            fixed4 frag(fragmentInput i) : SV_Target {
////                return fixed4(1.0 - i.texcoord0.x, 0.0,0.0,1.0);
////            }
//            ENDCG
//        }
//    }
//}
//
////#ifdef VERTEX // here begins the vertex shader
////
////				void main() // all vertex shaders define a main() function
////				{
////				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
////				// this line transforms the predefined attribute 
////				// gl_Vertex of type vec4 with the predefined
////				// uniform gl_ModelViewProjectionMatrix of type mat4
////				// and stores the result in the predefined output 
////				// variable gl_Position of type vec4.
////				}
////
////				#endif // here ends the definition of the vertex shader
////
////
////				#ifdef FRAGMENT // here begins the fragment shader
////				uniform vec4 _Time;
////				
//////				uniform vec2 u_resolution;
////				uniform vec4 _ScreenParams;
//////				uniform vec2 u_mouse;
//////				uniform float u_time;
////
////				vec4 DrawCircle (vec2 st, vec2 coord, float divisions, float dropShadow) {
////				    float pct = distance(st, coord) / divisions;
////				    vec3 color = vec3(1.0 - smoothstep (1.0 - dropShadow,1.0,pct));
////				    return vec4 (color, 1.0);
////				}
////
////				// vec4 DrawCircle_Animdated (vec2 st, vec2 coord, float divisions, float dropShadow, float animMagnitude) {
////				//     float pct = (distance(st, coord) / divisions) + sin(u_time) * animMagnitude;
////				//     vec3 color = vec3(1.0 - smoothstep (1.0 - dropShadow,1.0,pct));
////				//     return vec4 (color, 1.0);
////				// }
////
////				vec4 DrawCircle_Animdated (vec2 st, vec2 coord, float divisions, float dropShadow, float animMagnitude) {
////				    float pct = (distance(st, coord) / divisions) + animMagnitude;
////				    vec3 color = vec3(1.0 - smoothstep (1.0 - dropShadow,1.0,pct));
////				    return vec4 (color, 1.0);
////				}
////
////				vec4 DrawCircle_Manual (vec2 st, vec2 coord, float pct, float size, float dropShadow, float animMagnitude) {
////				    float newPct = (pct + animMagnitude) * size;
////				    vec3 color = vec3(1.0 - smoothstep (1.0 - dropShadow,1.0,newPct));
////				    return vec4 (color, 1.0);
////				}
////
////				float Patricircle (in vec2 _st, in float _radius){
////				    vec2 l = _st-vec2(0.5);
////				    return 1.-smoothstep(_radius-(_radius*0.01),
////				                         _radius+(_radius*0.01),
////				                         dot(l,l)*4.0);
////				}
////
////				vec3 DistanceField_Circle (vec2 st, vec2 pos, float size, float shadowBuffer, vec3 color, float sizeAnim, vec2 posAnim) {
////				    float pct = 0.0;
////				    pct = distance(st,pos + posAnim);
////				    pct = smoothstep(pct, pct + shadowBuffer, size + sizeAnim);
////				    return color * pct;
////				}
////				float DistanceField_Circle (vec2 st, vec2 pos, float size, float shadowBuffer, float sizeAnim, vec2 posAnim) {
////				    float pct = 0.0;
////				    pct = distance(st,pos + posAnim);
////				    // vec2( posAnim + 0.5 - sin (u_time) )
////				    // pct = smoothstep(pct, pct + shadowBuffer, size + sizeAnim);
////				    pct = smoothstep(pct, 1.0 - pct + shadowBuffer, size + sizeAnim);
////				    return pct;
////				}
////
////				mat3 matrix = mat3 ( vec3 (1.0, 0.0, 0.0), vec3 (0.0, 1.0, 0.0), vec3 (0.0, 0.0, 1.0));
////
////				mat3 scaleMatrix (vec2 f) {
////				    return mat3 (
////				        vec3 (f.x, 0.0, 0.0), 
////				        vec3 (0.0, f.y, 0.0), 
////				        vec3 (0.0, 0.0, 1.0)
////				    );
////				}
////				void scale (in vec2 f) {
////				    matrix = scaleMatrix (f) * matrix;
////				}
////				mat3 translationMatrix (vec2 f) {
////				    return mat3 (
////				        vec3 (1.0, 0.0, 0.0), 
////				        vec3 (0.0, 1.0, 0.0), 
////				        vec3 (f.x, f.y, 1.0)
////				    );
////				}
////				void translate (in vec2 f) {
////				    matrix = translationMatrix (f) * matrix;
////				}
////				mat3 rotationMatrix (float a) {
////				    return mat3 (
////				        vec3 (cos(a), -sin(a), 0.0), 
////				        vec3 (sin (a), cos(a), 0.0), 
////				        vec3 (0.0, 0.0, 1.0)
////				    );
////				}
////				void rotate (float a) {
////				    matrix = rotationMatrix (a) * matrix;
////				}
////
////				// vec3 col1 = vec3 (0.0,0.0,1.0);
////				// vec3 col2 = vec3 (1.0,0.0,0.0);
////				vec3 col1 = vec3 (0.07, 0.68, 0.6);
////				vec3 col2 = vec3 (0.67, 0.13, 0.45);
////				void main(){
////					vec2 st = gl_FragCoord.xy/_ScreenParams.xy;
////				    // st *= 4.0;
////				    // st -= 1.5;
////
////				    vec3 pos = vec3 (st, 1.0);
////				    pos = matrix * pos;
////
////				    vec3 color = vec3 (0.0);
////				    float pct = 0.0;
////				    // float posAnim = sin (u_time) * 0.25;
////				    float posAnim = sin (_Time.y);
////
////				    // STEP 1 - Draw same circle, animating across diffeent positions
////				    // pct = distance ( st, vec2(posAnim + 0.5 - sin (u_time) ) ); 
////				    // pct = distance ( st, vec2(posAnim + 0.5 + sin (u_time) ) );
////				    pct = DistanceField_Circle (st, vec2 (0.5), 0.4, 0.05, 0.0, vec2 (posAnim));
////				    pct = DistanceField_Circle (st, vec2 (0.5), 0.4, 0.05, 0.0, -vec2 (posAnim));
////
////
////				    // pct = min(
////				    //     distance (
////				    //         st,
////				    //         vec2(posAnim + 0.5 - sin (u_time))
////				    //     ), 
////				    //     distance (
////				    //         st,
////				    //         vec2(posAnim + 0.5 + sin (u_time))
////				    //     )
////				    // );
////
////				    // pct =  max (
////				    //     distance ( 
////				    //         st,
////				    //         vec2(posAnim + 0.4 + sin (u_time))
////				    //     ), 
////				    //     distance (
////				    //         st,
////				    //         vec2(posAnim + 0.6 + sin (u_time))
////				    //     )
////				    // );
////
////				    // pct = min(
////				    //     distance (
////				    //         st,
////				    //         vec2( 0.5 + posAnim - sin (u_time) )
////				    //     ), 
////				    //     distance (
////				    //         st,
////				    //         vec2( 0.5 + posAnim + sin (u_time) )
////				    //     )
////				    // );
////
////				    // pct = min (
////				    //     DistanceField_Circle (st, vec2 (0.5), 0.4, 0.0, abs (sin (u_time) * 0.075), vec2 (posAnim - sin (u_time) ) ),
////				    //     DistanceField_Circle (st, vec2 (0.5), 0.4, 0.0, abs (sin (u_time) * 0.075), vec2 (posAnim + sin (u_time) ) )
////				    // );
////
////				    
////				    translate (vec2 (-0.5));
////				    scale (vec2 (8.0));
////				    rotate (_Time.y);
////				    
////				    pos = matrix * pos;
////				    pct = min (
////				        DistanceField_Circle (pos.xy, vec2 (0.0), 0.4, 0.0, abs (sin (_Time.y) * 0.05), vec2 (posAnim - sin (_Time.y) ) ),
////				        DistanceField_Circle (pos.xy, vec2 (0.0), 0.4, 0.0, abs (sin (_Time.y) * 0.05), vec2 (posAnim + sin (_Time.y) ) )
////				    );
////
////				    pct += DistanceField_Circle (pos.xy, vec2 (0.0), 0.4, 0.0, abs (cos (_Time.y) * 0.05), vec2 (posAnim + cos (_Time.y) ) );
////
////
////				    // pct = mix ( 
////				    //     min(
////				    //         distance (
////				    //             st,
////				    //             vec2(posAnim + 0.4 - sin (u_time))
////				    //         ), 
////				    //         1.0 - distance (
////				    //             st,
////				    //             vec2(posAnim + 0.6 + sin (u_time))
////				    //         )
////				    //     ), 
////				    //     max (
////				    //         distance (
////				    //             st,
////				    //             vec2(posAnim + 0.4 + sin (u_time))
////				    //         ), 
////				    //         distance (
////				    //             st,
////				    //             vec2(posAnim + 0.6 + sin (u_time))
////				    //         )
////				    //     ), 
////				    //     (sin (u_time) * 0.5) + 0.5
////				    //     // abs (sin (u_time * 0.5)) + 0.5
////				    // );
////
////				    
////
////				    // pct = step (1.0 - pct, 0.5);
////				    // color = vec3 (pct);
////				    // color = mix (col1, col2, sin (u_time));
////				    color = mix (col2, col1, pct + sin (_Time.y));
////				    // vec3 color2 = color;
////				    vec3 color2 = mix (col1, col2, pct + sin (_Time.y));
////				    color = mix (color, color2, pct);
////
////				    
////				    
////				    // vec3 color = vec3 (1.0);
////				    // pct = 1.0 - step (pct, 0.1);
////
////				    gl_FragColor = vec4 (vec3 (pct), 1.0);      //BW
////				    // gl_FragColor = vec4 ((pct * color2 * 2.0) * color * 2.0, 1.0);     //single color at time
////				    // gl_FragColor = vec4 ((pct + color) * color, 1.0);   //weird oversaturation (pct is pushed over threshold by color addition?)
////				    // gl_FragColor = vec4 ((pct - color) * color, 1.0);   //ominous undersaturation (pct is pushed over threshold by color addition?)
////				    // gl_FragColor = vec4 ((pct / color2) * color, 1.0);  //weird tween for both shape and color
////
////				    // MAIN EXAMPLE
////				    // gl_FragColor = vec4 ((pct * (color2 + color) * 3.0) * color * 2.0, 1.0);     //single color at time
////
////				    // ROTATION ADDITIONS
////				    gl_FragColor = vec4 ((pos * (color2 + color) * 3.0) * color * 2.0, 1.0);     //single color at time
////				    gl_FragColor = vec4 ((pos * (color2 + color) * cos (_Time.y)) * color / sin(_Time.y), 1.0);     //single color at time
////
////				}
////
////
//////				void main() // all fragment shaders define a main() function
//////				{
//////				gl_FragColor = vec4(abs (sin (_Time.y)), 1.0, 0.0, 1.0); 
//////				// this fragment shader just sets the output color 
//////				// to opaque red (red = 1.0, green = 0.0, blue = 0.0, 
//////				// alpha = 1.0)
//////				}
////
////				#endif // here ends the definition of the fragment shader
