Shader "Unlit/glslShader_redFade"
{
	Properties {
		_Color ("Color", Color) = (1.0, 0.0, 0.0, 1.0)
	}
	
	SubShader {
        Pass {
      GLSLPROGRAM // here begins the part in Unity's GLSL
				uniform vec4 _Time;
				uniform vec4 _Color;
				
				//The vert and frag shader both run off of a main () function wrapped with preprocessor if directives. Anything in these #ifdef blocks are ignored in the other one.
				#ifdef VERTEX // here begins the vertex shader
				void main() {
					gl_TexCoord[0] = gl_MultiTexCoord0;
					vec4 pos = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;
					gl_Position = pos;
					gl_FrontColor =  gl_Color;
				}
				#endif // here ends the definition of the vertex shader


				#ifdef FRAGMENT // here begins the fragment shader
				vec3 col1 = vec3 (0.07, 0.68, 0.6);
				vec3 col2 = vec3 (0.67, 0.13, 0.45);
				void main() {
					vec2 st = gl_TexCoord[0].st;
					st.x *= sin (_Time.y);
				    gl_FragColor = vec4 (st.x, 0.0, 0.0, 1.0);     //single color at time
				}
				#endif // here ends the definition of the fragment shader

			ENDGLSL // here ends the part in GLSL 
        }
    }
}
