Shader "Unlit/glslShader_fadePulse"
{
	Properties {
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_AnimTime ("Animation Speed", Float) = 1
		_TileX ("Tile X", Float) = 100
		_TileY ("Tile Y", Float) = 100
		
	}
	
	SubShader {
        Pass {
      GLSLPROGRAM // here begins the part in Unity's GLSL
			    #define PI 3.14159265358979323846
			    #define TWO_PI 6.28318530718


				uniform vec4 _Time;
				uniform float _AnimTime;
				

				#ifdef VERTEX // here begins the vertex shader
				void main() // all vertex shaders define a main() function
				{
					//from patricios
					gl_TexCoord[0] = gl_MultiTexCoord0;
					vec4 pos = gl_ProjectionMatrix 
								* gl_ModelViewMatrix 		
								* gl_Vertex;
					gl_Position = pos;
					gl_FrontColor =  gl_Color;
				}

				#endif // here ends the definition of the vertex shader


				#ifdef FRAGMENT // here begins the fragment shader
				uniform vec4 _Color;
				uniform float _TileX;
				uniform float _TileY;				
				
				float circle(vec2 st, float radius) {
				    st -= .5;
				    return 1.0-step(radius*.5,dot(st,st)*2.);
				}
				float polygon (vec2 st, int sides, float size, float blur) {
					st = st *2.0 - 1.0; // Remap the space to -1. to 1.
					float angle = atan(st.x,st.y)+PI;   // Angle and radius from the current pixel
					float radius = TWO_PI/float(sides);
					float d = cos( floor ( 0.5 + angle / radius) * radius - angle) * length( st );      // Shaping function that modulate the distance
					return 1.0 - smoothstep( size, size + blur ,d);
				}
				float stripes(vec2 st) {
				    return step(st.y,st.x);
				}
				vec2 tile(vec2 st) {
				    return floor(st);
				}
				vec2 brick(vec2 st){
				    vec2 st_i = floor(st);
				    if (mod(st_i.y,2.) == 1.) {
				        st.x += .5;
				    }
				    return st;
				}

				vec2 truchet(vec2 st){
				    vec2 st_i = floor(st);
				    if (mod(st_i.y,2.) == 1.) {
				        st.x = 1.-st.x;
				    }
				    if (mod(st_i.x,2.) == 1.) {
				        st.y = 1.-st.y;
				    }
				    return st;
				}

				mat2 rotationMatrix(float a) {
				    return mat2(vec2(cos(a),-sin(a)),
				               	vec2(sin(a),cos(a)));
				}
				float addBorder (vec2 _st, float _thickness) {
				    float col = 0.;
				    col += step (_st.x, _thickness);
				    col += 1. - step (_st.x, 1. - _thickness);
				    col += step (_st.y, _thickness);
				    col += 1. - step (_st.y, 1. - _thickness);
				    return col;
				}
				
				float random (vec2 st) { 
				    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
				}
				vec3 returnColor (vec2 _st) {
					vec3 colorOptions[8];
				    colorOptions[0] = vec3 (.7, .89, .81);
				    colorOptions[1] = vec3 (.99, .8, .67);
				    colorOptions[2] = vec3 (.8, .84, .91);
				    colorOptions[3] = vec3 (.96, .79, .89);
				    colorOptions[4] = vec3 (.9, .96, .79);
				    colorOptions[5] = vec3 (1., .95, .68);
				    colorOptions[6] = vec3 (.95, .88, .8);
				    colorOptions[7] = vec3 (.8, .8, .8);
				    
				    float targVal = random (_st) * 8.;					
					return colorOptions [int (floor (targVal))];
				}
				

				void main() {
					vec2 st = gl_TexCoord[0].st;
					vec4 col = vec4 (0., 0., 0., 1.);
					st *= vec2 (_TileX, _TileY);
				    
				    vec2 st_i = floor(st);
				    if (mod(st_i.y,2.) == 1.) {	//create x offset every other row
				        st.x += .5;
				        st_i = floor (st);
				    }
				    
				    vec2 st_f = fract(st);		//create pattern space and rotate it
				    
				    st_f -= .5;
				    st_f = rotationMatrix(_Time.y) * st_f;
				    st_f += .5;
				    
					float pct = polygon (st_f, 3, sin (_Time.y * _AnimTime) * 1.5, 0.);
//					col *= pct;
					col.rgb += returnColor (st_i) * pct;
					col += addBorder (gl_TexCoord[0].st, 0.01);
					
					gl_FragColor = col;
				}
				#endif // here ends the definition of the fragment shader

			ENDGLSL // here ends the part in GLSL 
        }
    }
}
