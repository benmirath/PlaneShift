Shader "Unlit/glslShader_pattern1"
{
	Properties {
		_Color ("Color", Color) = (1.0, 0.0, 0.0, 1.0)
	}
	
	SubShader {
        Pass {
      GLSLPROGRAM // here begins the part in Unity's GLSL
				uniform vec4 _Time;
				varying vec2 position;
				uniform vec4 _Color;

				#ifdef VERTEX // here begins the vertex shader
				void main() // all vertex shaders define a main() function
				{
					gl_TexCoord[0] = gl_MultiTexCoord0;
//					float newX = gl_Vertex.x + sin(gl_Vertex.y+(_Time.y * 1.5))*10.;
////					vec4 pos = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;
					vec4 pos = gl_ModelViewProjectionMatrix * gl_Vertex;
//					pos.x += newX;
					gl_Position = pos;
					gl_FrontColor =  gl_Color;
//					
					position = gl_MultiTexCoord0.xy;
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
				
				void main() {
//					vec2 st = gl_TexCoord[0].st;
					vec2 st = position;
				    vec3 col = vec3(0.);
				    
				    float d = distance(st,vec2(.5));
//				    
//				    vec2 toCenter = vec2(0.5)-st;
//				    float angle = atan(toCenter.y,toCenter.x);
//    				float radius = length(toCenter)*2.0;
//				    d = sin(d*3.14*5.-_Time.y*3.);
					d = sin(d*3.14*5. - _Time.y*3.);
//					d = d*3.14*5. - _Time.y*3.;
				    col += d;
				    
				    //initial resize
				    st *= 30.;
				    
				    //determine arrangement layer
				    vec2 st_i = floor(st);
				    if (mod(st_i.y,2.) == 1.) {	//create x offset every other row
				        st.x += .5;
				    }
				    
				    //determine pattern layer
				    vec2 st_f = fract(st);		//create pattern
				    st_f -= .5;
				    st_f = rotationMatrix(d*3.14)*st_f;
				    st_f += .5;
				    
				    //draw pattern
//				    float pct = stripes(st_f);
//				    col += pct;				    
				    
					gl_FragColor = vec4(col,1.0);
				}
				#endif // here ends the definition of the fragment shader

			ENDGLSL // here ends the part in GLSL 
        }
    }
}
