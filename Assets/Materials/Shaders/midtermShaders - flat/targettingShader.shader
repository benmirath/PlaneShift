Shader "Unlit/targettingShader"
{
	SubShader {
        Pass {
			GLSLPROGRAM // here begins the part in Unity's GLSL

				#ifdef VERTEX // here begins the vertex shader

				void main() // all vertex shaders define a main() function
				{
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
				// this line transforms the predefined attribute 
				// gl_Vertex of type vec4 with the predefined
				// uniform gl_ModelViewProjectionMatrix of type mat4
				// and stores the result in the predefined output 
				// variable gl_Position of type vec4.
				}

				#endif // here ends the definition of the vertex shader


				#ifdef FRAGMENT // here begins the fragment shader
				uniform vec4 _Time;
				
				//				uniform vec2 u_resolution;
				uniform vec4 _ScreenParams;
				//				uniform vec2 u_mouse;
				//				uniform float u_time;
				// Author @patriciogv - 2015
				// http://patriciogonzalezvivo.com

//				#ifdef GL_ES
//				precision mediump float;
//				#endif
//
				#define PI 3.14159265359

//				uniform vec2 u_resolution;
//				uniform vec2 u_mouse;
//				uniform float u_time;

				float _box(in vec2 st, in vec2 size){

				    // size = vec2(0.5) - size*0.5;
				    // size = size;
				    st += 0.5;      //draw in center
				    vec2 uv = smoothstep(size,
				                        size+vec2(0.001),
				                        st);
				    uv *= smoothstep(size,
				                    size+vec2(0.001),
				                    vec2(1.0)-st);
				    return uv.x*uv.y;
				}
				float box2(in vec2 st, in vec2 size){

				    // size = vec2(0.5) - size*0.5;
				    // size = size;
				    size = size * 0.25;
				    st += 0.5;      //draw in center
				    vec2 uv = smoothstep(size,
				                        size+vec2(0.001),
				                        st);
				    uv *= smoothstep(size,
				                    size+vec2(0.001),
				                    vec2(1.0)-st);
				    return uv.x*uv.y;
				}


				float cross(in vec2 st, float size) {
				    return  _box(st, vec2(size,size/4.)) + 
				            _box(st, vec2(size/4.,size));
				}
				// float box(in vec2 st, float size) {
				//     return  _box(st, vec2(size,size/4.));;
				// }
				float box(in vec2 st, vec2 size) {
				    return  _box(st, vec2(size));;
				}


				//HARDCORE VERSION
				//f == factor
				mat3 scaleMatrix (vec2 f) {
				    return mat3 (
				        vec3 (f.x, 0.0, 0.0), 
				        vec3 (0.0, f.y, 0.0), 
				        vec3 (0.0, 0.0, 1.0)
				    );
				}
				mat3 translationMatrix (vec2 f) {
				    return mat3 (
				        vec3 (1.0, 0.0, 0.0), 
				        vec3 (0.0, 1.0, 0.0), 
				        vec3 (f.x, f.y, 1.0)
				    );
				}
				//a == angle
				mat3 rotationMatrix (float a) {
				    return mat3 (
				        vec3 (cos(a), -sin(a), 0.0), 
				        vec3 (sin (a), cos(a), 0.0), 
				        vec3 (0.0, 0.0, 1.0)
				    );
				}


				mat3 matrix = mat3 ( vec3 (1.0, 0.0, 0.0), vec3 (0.0, 1.0, 0.0), vec3 (0.0, 0.0, 1.0));

				//USER FRIENDLY VERSION
				// vec3 scale (vec2 f, vec3 pos) {
				//     return scaleMatrix (f) * pos;
				// }
				// void scale (in vec2 f, inout vec3 pos) {
				//     pos = scaleMatrix (f) * pos;
				// }
				void scale (in vec2 f) {
				    matrix = scaleMatrix (f) * matrix;
				}
				// vec3 translate (vec2 f, vec3 pos) {
				//     return translationMatrix (f) * pos;
				// }
				// void translate (in vec2 f, inout vec3 pos) {
				//     pos = translationMatrix (f) * pos;
				// }
				void translate (in vec2 f) {
				    matrix = translationMatrix (f) * matrix;
				}
				// vec3 rotate (float a, vec3 pos) {
				//     return rotationMatrix (a) * pos;
				// }
				void rotate (float a) {
				    matrix = rotationMatrix (a) * matrix;
				}

				void resetMatrix () {
				    matrix = mat3 ( vec3 (1.0, 0.0, 0.0), vec3 (0.0, 1.0, 0.0), vec3 (0.0, 0.0, 1.0));
				}

				vec4 DrawSquare (vec2 st, vec2 pos1, vec2 pos2) {
				    vec2 bl = floor(st + 1.0 - pos1);    // bottom-left
				    vec2 tr = floor(1.0 - st + pos2);   // top-right     
				    vec3 color = vec3(bl.x * bl.y * tr.x * tr.y);
				    return vec4(color,1.0);
				}


				void main(){
				    vec2 st = gl_FragCoord.xy/_ScreenParams.xy;
				    vec3 col = vec3 (0.0);
				    vec3 pos = vec3 (st, 1.0);
				    vec3 translationPos = vec3 (st, 1.0);

				    float offset_center = smoothstep (.3, .7, _ScreenParams.z / _ScreenParams.x);
				    float offset_centerV = smoothstep (.3, .7, _ScreenParams.w / _ScreenParams.y);
				    float offset_left = offset_center;
				    float offset_right = offset_center;

				    offset_center -= 0.5;
				    offset_center *= 0.25;
				    offset_centerV -= 0.5;
				    offset_centerV *= 0.25;

				    offset_left *= 0.025;

				    offset_right *= -1.0;
				    offset_right *= 0.025;

				    float extremeOffset_center = smoothstep (.15, .85, _ScreenParams.z / _ScreenParams.x);
				    float extremeOffset_centerV = smoothstep (.15, .85, _ScreenParams.w / _ScreenParams.y);
				    extremeOffset_center -= 1.5;
				    extremeOffset_center *= 0.25;
				    extremeOffset_centerV -= 0.5;
				    extremeOffset_centerV *= 0.5;

				    //align offset to follow mouse
				    offset_center *= -1.0;
				    offset_centerV *= -1.0;

				    //reticle
				    translate (vec2(offset_center + -0.5, offset_centerV + -0.5));
				    scale (vec2 (15.0));
				    rotate (_Time.y);
				    translationPos = matrix * pos;

				    vec3 hitCol = vec3 (1.0, 1.0, 1.0);
				    if (distance (_ScreenParams.zw, _ScreenParams.xy * vec2 (0.5)) < _ScreenParams.x * 0.05) { hitCol = vec3 (1.0, 0.0, 0.0);   }    //locked on!
				    col += (cross (translationPos.xy, 0.45) * hitCol);
				    
				    //left bracket
				    resetMatrix ();
				    scale (vec2 (4.0));
				    translate (vec2 (offset_center + -1.5 ,offset_centerV + -2.0));
				    translationPos = matrix * pos;
				    col += box (translationPos.xy, vec2 (0.49, -0.025));

				    translate (vec2 (-0.14 , -0.53));
				    rotate (PI * 0.5);
				    scale (vec2 (4.0));
				    translationPos = matrix * pos;
				    col += box (translationPos.xy, vec2 (0.46, -0.1));

				    translate (vec2 (4.15 , 0.0));
				    translationPos = matrix * pos;
				    col += box (translationPos.xy, vec2 (0.46, -0.1));

				    //right bracket
				    resetMatrix ();
				    scale (vec2 (4.0));
				    translate (vec2 (offset_center + -2.5 ,offset_centerV + -2.0));
				    translationPos = matrix * pos;
				    col += box (translationPos.xy, vec2 (0.49, -0.025));

				    translate (vec2 (0.14 , -0.53));
				    rotate (PI * 0.5);
				    scale (vec2 (4.0));
				    translationPos = matrix * pos;
				    col += box (translationPos.xy, vec2 (0.46, -0.1));

				    translate (vec2 (4.15 , 0.0));
				    translationPos = matrix * pos;
				    col += box (translationPos.xy, vec2 (0.46, -0.1));

				    //left lines
				    resetMatrix ();
				    scale (vec2 (4.0));
				    translate (vec2 (extremeOffset_center + -.75 ,extremeOffset_centerV + -2.));
				    translationPos = matrix * pos;
				    col += box (translationPos.xy, vec2 (0.485, -0.4));

				    resetMatrix ();
				    scale (vec2 (3.0));
				    translate (vec2 ((extremeOffset_center * 1.1) + -.3 ,(extremeOffset_centerV * 1.65) + -1.5));
				    translationPos = matrix * pos;
				    col += box (translationPos.xy, vec2 (0.49, -0.4));

				    resetMatrix ();
				    scale (vec2 (2.5));
				    translate (vec2 ((extremeOffset_center * 1.2) + -.03 ,(extremeOffset_centerV * 1.99) + -1.25));
				    translationPos = matrix * pos;
				    col += box (translationPos.xy, vec2 (0.49, -0.4));

				    //right lines
				    resetMatrix ();
				    scale (vec2 (4.0));
				    translate (vec2 (extremeOffset_center + -2.75 ,extremeOffset_centerV + -2.));
				    translationPos = matrix * pos;
				    col += box (translationPos.xy, vec2 (0.485, -0.4));

				    resetMatrix ();
				    scale (vec2 (3.0));
				    translate (vec2 ((extremeOffset_center * 1.1) + -2.15 ,(extremeOffset_centerV * 1.65) + -1.5));
				    translationPos = matrix * pos;
				    col += box (translationPos.xy, vec2 (0.49, -0.4));

				    resetMatrix ();
				    scale (vec2 (2.5));
				    translate (vec2 ((extremeOffset_center * 1.2) + -1.87 ,(extremeOffset_centerV * 1.99) + -1.25));
				    translationPos = matrix * pos;
				    col += box (translationPos.xy, vec2 (0.49, -0.4));

				    gl_FragColor = vec4( col ,1.0);
				}

				#endif // here ends the definition of the fragment shader

			ENDGLSL // here ends the part in GLSL 
        }
    }
}
