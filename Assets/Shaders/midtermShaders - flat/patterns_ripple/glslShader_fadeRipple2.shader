Shader "Unlit/glslShader_fadeRipple2"
{
	Properties {
		_Color ("Color", Color) = (1.0, 0.0, 0.0, 1.0)
		_AnimTime ("Animation Speed", Float) = 0.
		_PulseScale ("Pulse Scale", Float) = 5.
//		_ColorOptions ("Color Options", Color[7]) = (1.0, 1.0, 1.0, 1.0)
	}
	
	SubShader {
        Pass {
      GLSLPROGRAM // here begins the part in Unity's GLSL
				uniform vec4 _Time;
				varying vec2 position;
				uniform vec4 _Color;
				uniform float _AnimTime;
				uniform float _PulseScale;

				#ifdef VERTEX // here begins the vertex shader
				void main() // all vertex shaders define a main() function
				{
					gl_TexCoord[0] = gl_MultiTexCoord0;
					vec4 pos = gl_ModelViewProjectionMatrix * gl_Vertex;
//					vec2 st = pos.xy;
					
					gl_FrontColor =  gl_Color;
					position = gl_MultiTexCoord0.xy;
					
					vec2 st = position;
//					float d = distance (gl_Vertex.xy, vec2 (100.) );
//					d *= 1000.;
//					float d = distance(gl_Vertex.xyz, vec4(.5));
//					pos.y -= 1000. * d;
					
					
					gl_Position = pos;

//					position = st;
				}

				#endif // here ends the definition of the vertex shader


				#ifdef FRAGMENT // here begins the fragment shader
				float circle(vec2 st, float radius) {
				    st -= .5;
				    return 1.0-step(radius*.5,dot(st,st)*2.);
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
				float random (vec2 st) { 
				    return fract(sin(dot(st.xy,
				                         vec2(12.9898,78.233)))* 
				        43758.5453123);
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
					vec2 st = position;
				    vec3 col = vec3(0.);
				    
				    float d = distance(st,vec2(.5));
					d = -5. + (-50. + sin(d * 3.14 * _PulseScale - (_Time.y * _AnimTime) ) * 57.);

				    //initial resize
				    st *= 2000.;
				    
				    //determine arrangement layer
				    vec2 st_i = floor(st);
				    if (mod(st_i.y,2.) == 1.) {	//create x offset every other row
				        st.x += .5;
				        st_i = floor(st);
				    }
				    
				    //determine pattern layer
				    vec2 st_f = fract(st);		//create pattern
					float pct = circle(st_f, d * .75);
					col =  returnColor (st_i) * pct;
					gl_FragColor = vec4(col,1.0);
				}
				#endif // here ends the definition of the fragment shader

			ENDGLSL // here ends the part in GLSL 
        }
    }
}
