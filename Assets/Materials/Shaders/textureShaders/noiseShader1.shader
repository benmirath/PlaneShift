Shader "Custom/noiseShader1" {
	Properties {
		_Color1 ("Color 1", Color) = (1,0,0,1)
		_Color2 ("Color 2", Color) = (0,0.5,5,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_DeformRange ("Deform Range", Float) = 15
		_DeformSpeed ("Deform Speed", Float) = 0.2
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
			#define TWO_PI 6.28318530718

	        //MATRIX TRANSFORMATION
	        fixed2x2 scale (fixed2 f) { return fixed2x2 ( fixed2 (f.x, 0.0), fixed2 (0.0, f.y)); }
			fixed2x2 translate (fixed2 f) { return fixed2x2 ( fixed2 (0.0, 1.0), fixed2 (f.x, f.y) ); }
			fixed2x2 scale (fixed f) { return fixed2x2 ( fixed2 (f, 0.0), fixed2 (0.0, f)); }
			fixed2x2 translate (fixed f) { return fixed2x2 ( fixed2 (0.0, 1.0), fixed2 (f, f) ); }
			fixed2x2 rotate (fixed a) { return fixed2x2 ( fixed2 (cos(a), -sin(a)), fixed2 (sin (a), cos(a))); }
			fixed2x2 identityMatrix () { return fixed2x2 ( fixed2 (1.0, 0.0), fixed2 (0.0, 1.0)); }
			fixed3 hsb2rgb( in fixed3 c ){
			    fixed3 rgb = clamp(abs(fmod(c.x*6.0+fixed3(0.0,4.0,2.0), 6.0)-3.0)-1.0, 0.0, 1.0 );		//color converting black magic, truly terrifying
			    rgb = rgb*rgb*(3.0-2.0*rgb);
			    return c.z * lerp( fixed3(1,1,1), rgb, c.y);
			}
			
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

			//SHAPE FUNCTIONS
			fixed box(fixed2 _st, fixed2 _size){
			    _size = fixed2(0.5)-_size*0.5;
			    fixed2 uv = smoothstep(_size, _size + fixed2(1e-4, 1e-4),_st); //1e-4 == 0.00004;
			    uv *= smoothstep(_size, _size + fixed2 (1e-4, 1e-4), fixed2(1,1) - _st);
			    return uv.x * uv.y;
			}
			fixed2 polygon (fixed2 st, int sides, fixed2 size, fixed2 blur) {
			  st = st *2.0 - 1.0; // Remap the space to -1. to 1.
			  fixed2 angle = atan2(st.x,st.y)+PI;   // Angle and radius from the current pixel
			  fixed2 radius = TWO_PI/fixed(sides);
			  fixed2 d = cos( floor ( 0.5 + angle / radius) * radius - angle) * length( st );      // Shaping function that modulate the distance
			  return 1.0 - smoothstep( size, size + blur ,d);
			}
			fixed circle(fixed2 st, fixed radius){
			    fixed2 pos = fixed2(0.5)-st;
			    radius *= 0.75;
			    return 1.-smoothstep(radius-(radius*0.05),radius+(radius*0.05),dot(pos,pos)*3.14);
			}
			fixed circleDeformed(fixed2 st, fixed radius){
			    fixed2 pos = fixed2(0.5)-st;
			    fixed adjust = smoothstep (0.5, 0.1, st.y);
			    st.x *= (0.5* adjust);
			    radius *= (0.75 + (noise (st * (_Time.y + 50.))) * adjust);
			    fixed returnVal = 1.-smoothstep(radius-(radius*0.05),radius+(radius*0.05),dot(pos,pos)*3.14);
			    return returnVal;
			}
//			float circleDeformed(vec2 st, float radius){
//			    vec2 pos = vec2(0.5)-st;
//			    float adjust = smoothstep (0.5, 0.1, st.y);
//			    st.x *= (0.5* adjust);
//			    // st.y *= (5. * noise (st.y) * adjust);
//			    // float radAdjust = smoothstep (0.6, 0.2, st.y);
//			    radius *= (0.75 + (noise (st * (u_time + 50.))) * adjust);
//			    float returnVal = 1.-smoothstep(radius-(radius*0.05),radius+(radius*0.05),dot(pos,pos)*3.14);
//
//			    // returnVal *- radAdjust;
//
//			    return returnVal;
//			}
			
			fixed addBlur (fixed2 _st, fixed intensity) {
			    return noise (random (_st) * intensity);
			}
			fixed addSmudge (fixed2 _st, fixed intensity, fixed freq) {
			    return noise (sin (dot (_st.x, _st.y)) * freq);
			}
			fixed addStroke (fixed2 _st, fixed intensity, fixed freq) {
			    return addBlur (_st, intensity) * addSmudge (_st, intensity, freq);
			}
			fixed addGyration (fixed2 _st, fixed _intensity, fixed _freq, fixed _speed, fixed _range) {
			    // return noise (sin (u_time * dot (_st.x, _st.y)) * 5.) * noise (random (_st) * intensity);
			    return noise (sin (noise (_Time.y * _speed) * _range * dot (_st.x, _st.y)) * _freq) * noise (random (_st) * _intensity);
			}
			
			void addColor (inout fixed3 curColor, fixed3 newColor, fixed intensity) {
			    fixed3 col = curColor;
			    col = mul (col, step (intensity, 0.0));
			    col += newColor * (1. - step (intensity, 0.));
			    curColor = col;
			}
			fixed3 addColorF (fixed3 curColor, fixed3 newColor, fixed intensity) {
			    fixed3 col = curColor;
			    col *= step (intensity, 0.0);
//			    col = mul (col, step (intensity, 0.0));
			    col += newColor * (1. - step (intensity, 0.));
			    return col;
			}
			half4 addColorF (fixed4 curColor, fixed4 newColor, fixed intensity) {
			    fixed4 col = curColor;
//			    col *= step (intensity, 0.0);
			    col = mul (col, step (intensity, 0.0));
			    col += newColor * (1. - step (intensity, 0.));
			    return col;
			}
			
			
			//MAIN FUNCTIONS
			struct v2f {
	            float4 pos : SV_POSITION;
	            fixed3 color : COLOR0;
	            float2 uv : TEXCOORD0;
	        };
	        
			uniform sampler2D _MainTex;
			float4 _MainTex_ST;	//dunno why this is important, but it needs to be here...
			uniform fixed4 _Color1;
			uniform fixed4 _Color2;
			uniform fixed _DeformRange;
			uniform fixed _DeformSpeed;
			
			v2f vert (appdata_base v) {
		 		v2f o;
		        o.pos = mul (UNITY_MATRIX_MVP, v.vertex);		//set to proper viewpoint in the world
            	o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
            	o.uv.y *= -1.;
            	o.uv.y += .95;
            	return o;
			}
			fixed4 frag (v2f i) : SV_Target {
				fixed2 st = i.uv;
				
//				st += fixed2 (0.5, 0.5);
//				st = mul (st, rotate (distance (st, fixed2 (0.5, 0.5)) * (sin (_Time.y * _DeformSpeed) * _DeformRange))) ;
//				st -= fixed2 (0.5, 0.5);
// 				fixed4 texcol = tex2D (_MainTex, st);
//            	return texcol;
            	
//            	fixed2 st = i.pos;
//            	fixed red = 1.0f * st.x;
////            	if (st.x < -.5) red = 0.0;
//            	return fixed4 (red, 0,0,1);
            	
////            	fixed2 st = gl_FragCoord.xy/u_resolution.xy;
				float pct = circleDeformed (st, 0.5);

				fixed4 col = fixed4 (0,0,0,0);
				// st.y += 0.375;
				// vec3 colAdjust1 = mix (vec3 (0., 0., 0.5), vec3 (0., 0.5, 0.75), noise (st * u_time * 0.5) * 0.4);
				// col = addColorF (col,  colAdjust1, box (st, vec2 (1., 0.7)));
				// st.y -= 0.375;

				half4 colAdjust2 = lerp (_Color1, _Color2, (distance (st, fixed2 (0.5)) * 0.4));
				col = addColorF (col, colAdjust2, pct);
				return col;
				
				
//				return fixed4(col, 1.0);
			}
			ENDCG
		}
		
		
	} 
	FallBack "Diffuse"
}




//// Author: @diaBEETS (ben miller) - 2015
//// http://fabraz.com
//
//#ifdef GL_ES
//precision mediump float;
//#endif
//
//#define PI 3.14159265359
//#define TWO_PI 6.28318530718
//
////uniform vec2 u_resolution;
////uniform vec2 u_mouse;
////uniform float u_time;
//
//// mat3 scale (vec2 f) { return mat3 ( vec3 (f.x, 0.0, 0.0), vec3 (0.0, f.y, 0.0), vec3 (0.0, 0.0, 1.0) ); }
//// mat3 translate (vec2 f) { return mat3 ( vec3 (1.0, 0.0, 0.0), vec3 (0.0, 1.0, 0.0), vec3 (f.x, f.y, 1.0) ); }
//// mat3 rotate (float a) { return mat3 ( vec3 (cos(a), -sin(a), 0.0), vec3 (sin (a), cos(a), 0.0), vec3 (0.0, 0.0, 1.0) ); }
//// mat2 rotationMatrix(float a) { return mat2 ( vec2 (cos(a), -sin(a)), vec2(sin(a),cos(a))); }
//
//mat2 scale (vec2 f) { return mat2 ( vec2 (f.x, 0.0), vec2 (0.0, f.y)); }
//mat2 translate (vec2 f) { return mat2 ( vec2 (0.0, 1.0), vec2 (f.x, f.y) ); }
//mat2 rotate (float a) { return mat2 ( vec2 (cos(a), -sin(a)), vec2 (sin (a), cos(a))); }
//mat3 identityMatrix () { return mat3 ( vec3 (1.0, 0.0, 0.0), vec3 (0.0, 1.0, 0.0), vec3 (0.0, 0.0, 1.0) ); }
//
//vec3 hsb2rgb( in vec3 c ){
//    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
//                             6.0)-3.0)-1.0, 
//                     0.0, 
//                     1.0 );
//    rgb = rgb*rgb*(3.0-2.0*rgb);
//    return c.z * mix( vec3(1.0), rgb, c.y);
//}
//
//float random (float _x) {
//	return fract(sin(_x)*100000.0);
//}
//float random (in vec2 _st) { 
//    return fract(sin(dot(_st.xy, vec2(12.9898,78.233))) * 43758.5453123);
//}
//vec2 random2(vec2 st){
//    st = vec2( dot(st,vec2(127.1,311.7)),
//              dot(st,vec2(269.5,183.3)) );
//    return -1.0 + 2.0*fract(sin(st)*43758.5453123);
//}
//
//float noise (float _x) {
//    float i = floor(_x);  // integer
//	float f = fract(_x);  // fraction
//	float y = mix(random(i), random(i + 1.0), smoothstep(0.,1.,f));
//	return y;
//}
//float noise (in vec2 st) {
//    vec2 i = floor(st);
//    vec2 f = fract(st);
//
//    // Four corners in 2D of a tile
//    float a = random(i);
//    float b = random(i + vec2(1.0, 0.0));
//    float c = random(i + vec2(0.0, 1.0));
//    float d = random(i + vec2(1.0, 1.0));
//
//    // Smooth Interpolation
//
//    // Cubic Hermine Curve.  Same as SmoothStep()
//    vec2 u = f*f*(3.0-2.0*f);
//    u = smoothstep(0.,1.,f);
//
//    // Mix 4 coorners porcentages
//    return mix(a, b, u.x) + 
//            (c - a)* u.y * (1.0 - u.x) + 
//            (d - b) * u.x * u.y;
//}
//
//float gradientNoise(vec2 st) {
//    vec2 i = floor(st);
//    vec2 f = fract(st);
//
//    vec2 u = f*f*(3.0-2.0*f);
//
//    return mix( mix( dot( random2(i + vec2(0.0,0.0) ), f - vec2(0.0,0.0) ), 
//                     dot( random2(i + vec2(1.0,0.0) ), f - vec2(1.0,0.0) ), u.x),
//                mix( dot( random2(i + vec2(0.0,1.0) ), f - vec2(0.0,1.0) ), 
//                     dot( random2(i + vec2(1.0,1.0) ), f - vec2(1.0,1.0) ), u.x), u.y);
//}
//
//float box(vec2 _st, vec2 _size){
//    _size = vec2(0.5)-_size*0.5;
//    vec2 uv = smoothstep(_size,_size+vec2(1e-4),_st); //1e-4 == 0.00004;
//    uv *= smoothstep(_size,_size+vec2(1e-4), vec2(1.0) - _st);
//    return uv.x * uv.y;
//}
//
//float polygon (vec2 st, int sides, float size, float blur) {
//  st = st *2.0 - 1.0; // Remap the space to -1. to 1.
//  float angle = atan(st.x,st.y)+PI;   // Angle and radius from the current pixel
//  float radius = TWO_PI/float(sides);
//  float d = cos( floor ( 0.5 + angle / radius) * radius - angle) * length( st );      // Shaping function that modulate the distance
//  return 1.0 - smoothstep( size, size + blur ,d);
//}
//float circle(vec2 st, float radius){
//    vec2 pos = vec2(0.5)-st;
//    radius *= 0.75;
//    return 1.-smoothstep(radius-(radius*0.05),radius+(radius*0.05),dot(pos,pos)*3.14);
//}
//float circleDeformed(vec2 st, float radius){
//    vec2 pos = vec2(0.5)-st;
//    float adjust = smoothstep (0.5, 0.1, st.y);
//    st.x *= (0.5* adjust);
//    // st.y *= (5. * noise (st.y) * adjust);
//    // float radAdjust = smoothstep (0.6, 0.2, st.y);
//    radius *= (0.75 + (noise (st * (u_time + 50.))) * adjust);
//    float returnVal = 1.-smoothstep(radius-(radius*0.05),radius+(radius*0.05),dot(pos,pos)*3.14);
//
//    // returnVal *- radAdjust;
//
//    return returnVal;
//}
//
//
//float addBlur (vec2 _st, float intensity) {
//    return noise (random (_st) * intensity);
//}
//float addSmudge (vec2 _st, float intensity, float freq) {
//    return noise (sin (dot (_st.x, _st.y)) * freq);
//}
//float addStroke (vec2 _st, float intensity, float freq) {
//    return addBlur (_st, intensity) * addSmudge (_st, intensity, freq);
//}
//float addGyration (vec2 _st, float intensity, float freq, float speed, float range) {
//    // return noise (sin (u_time * dot (_st.x, _st.y)) * 5.) * noise (random (_st) * intensity);
//    return noise (sin (noise (u_time * speed) * range * dot (_st.x, _st.y)) * freq) * noise (random (_st) * intensity);
//}
//
//void addColor (inout vec3 curColor, vec3  newColor, float intensity) {
//    vec3 col = curColor;
//    col *= step (intensity, 0.0);
//    col += newColor * (1. - step (intensity, 0.));
//    curColor = col;
//}
//vec3 addColorF (vec3 curColor, vec3  newColor, float intensity) {
//    vec3 col = curColor;
//    col *= step (intensity, 0.0);
//    col += newColor * (1. - step (intensity, 0.));
//    return col;
//}
//
//vec3 col1 = vec3 (1., 0., 0.);
//vec3 col2 = vec3 (0.0, 0.5, 5.);
//
//void main () {
//     vec2 st = gl_FragCoord.xy/u_resolution.xy;
//    float pct = circleDeformed (st, 0.5);
//    
//    vec3 col = vec3 (0.);
//    // st.y += 0.375;
//    // vec3 colAdjust1 = mix (vec3 (0., 0., 0.5), vec3 (0., 0.5, 0.75), noise (st * u_time * 0.5) * 0.4);
//    // col = addColorF (col,  colAdjust1, box (st, vec2 (1., 0.7)));
//    // st.y -= 0.375;
//
//    vec3 colAdjust2 = mix (col1, col2, (distance (st, vec2 (0.5)) * 0.4));
//    col = addColorF (col, colAdjust2, pct);
//
//    gl_FragColor = vec4(col, 1.0);
//}





