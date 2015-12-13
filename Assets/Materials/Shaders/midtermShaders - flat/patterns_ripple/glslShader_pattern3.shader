Shader "Unlit/glslShader_pattern3"
{
	Properties {
		_Color ("Color", Color) = (1.0, 0.0, 0.0, 1.0)
	}
	
	SubShader {
        Pass {
      GLSLPROGRAM // here begins the part in Unity's GLSL

				#ifdef VERTEX // here begins the vertex shader
				uniform vec4 _Time;
//				varying vec4 position;
				void main() // all vertex shaders define a main() function
				{
					//from patricios
					gl_TexCoord[0] = gl_MultiTexCoord0;
//					gl_Vertex.x += sin (pos.y + _Time.y) * 10.;
					
//					vec4 pos = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;
//					vec4 pos = gl_ModelViewMatrix;
//					vec4 pos = gl_Vertex;
//					vec4 pos = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;
//					float newX = gl_Vertex.x + sin(gl_Vertex.y+(_Time.y * .5)) * 15.;
//					vec4 pos = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;
//					pos.x += sin(pos.y+_Time.y)*10.;
//					pos.x += newX;
					vec4 newVertex = gl_Vertex;
//					newVertex *= _Time.y;
					newVertex.x += (.5 - sin (_Time.y));
//					newVertex.x += _Time.y
					vec4 pos = gl_ProjectionMatrix 
//					vec4 pos = gl_ModelViewMatrix 
//								gl_ProjectionMatrix 
								* gl_ModelViewMatrix 		
								* newVertex;
					gl_Position = pos;
					gl_FrontColor =  gl_Color;
				}

				#endif // here ends the definition of the vertex shader


				#ifdef FRAGMENT // here begins the fragment shader
				uniform vec4 _Color;
				uniform vec4 _Time;

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
					vec2 st = gl_TexCoord[0].st;
//				    vec3 col = vec3(0.);
					vec4 col = _Color;
				    
				    float fullSwing = distance(st,vec2(.5));
				    fullSwing += _Time.y; 
				    float d = distance(st,vec2(.5));
				    d = sin(d*3.14*5.-_Time.y*3.);
//				    color += d;
				    
				    st *= 100.;	//repeat 10 times
				    vec2 st_i = floor(st);
//				    st_i -= .5;
//				    st_i = rotationMatrix(d*3.14)*st_i;
//				    st_i += .5;
				    
				    if (mod(st_i.y,2.) == 1.) {	//create x offset every other row
				        st.x += .5;
				    }
				    
				    vec2 st_f = fract(st);		//create pattern
				    
//				    st_f -= .5;
				    st_f = rotationMatrix(fullSwing) * st_f;
//				    st_f += .5;
				    
				    float pct = circle(st_f, 2.);
//				    col += pct;		
					col *= pct;
//				    col += 		    
				    
					gl_FragColor = col;
				}
				#endif // here ends the definition of the fragment shader

			ENDGLSL // here ends the part in GLSL 
        }
    }
}
