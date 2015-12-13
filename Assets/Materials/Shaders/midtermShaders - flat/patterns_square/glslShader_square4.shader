Shader "Unlit/glslShader_square3"
{
	Properties {
		_Color1 ("Color1", Color) = (0.075,0.114,0.329, 1.0)
		_Color2 ("Color2", Color) = (0.973,0.843,0.675, 1.0)
		_Color2 ("Color3", Color) = (.761,0.247,0.102, 1.)
	}
	
	SubShader {
        Pass {
      GLSLPROGRAM // here begins the part in Unity's GLSL
				#define PI 3.14159265358979323846
				uniform vec4 _Time;

				#ifdef VERTEX // here begins the vertex shader
				void main() // all vertex shaders define a main() function
				{
					//from patricios
					gl_TexCoord[0] = gl_MultiTexCoord0;
					vec4 pos = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;
					gl_Position = pos;
					gl_FrontColor =  gl_Color;
				}

				#endif // here ends the definition of the vertex shader


				#ifdef FRAGMENT // here begins the fragment shader
				uniform vec4 _Color1;
				uniform vec4 _Color2;
				uniform vec4 _Color3;
				vec2 tile(vec2 st, float zoom){
				    st *= zoom;
				    return fract(st);
				}
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
				float DistanceField_Circle (vec2 st, vec2 pos, float size, float shadowBuffer, float sizeAnim, vec2 posAnim) {
				    float pct = 0.0;
				    pct = distance(st,pos + posAnim);
				    pct = 1.0 - pct;

				    pct = smoothstep(pct, pct + shadowBuffer, size + sizeAnim);         // creates dot
				    return pct;
				}
				
				float box(vec2 _st, vec2 _size){
				    _size = vec2(0.5)-_size*0.5;
				    vec2 uv = smoothstep(_size,_size+vec2(1e-4),_st); //1e-4 == 0.00004;
				    uv *= smoothstep(_size,_size+vec2(1e-4), vec2(1.0) - _st);
				    return uv.x*uv.y;
				}
				float boxPattern(vec2 st, vec2 size) {
				    return  box(st+vec2(0.,-.5), size)+
				            box(st+vec2(0.,.5), size)+
				            box(st+vec2(-.5,0.), size)+
				            box(st+vec2(.5,0.), size);
				}

				mat2 rotationMatrix(float a) {
				    return mat2(vec2(cos(a),-sin(a)),
				               	vec2(sin(a),cos(a)));
				}
				
				float curRotation = 0.0;
				float curRotationContra = 0.0;

				void main() {
					vec2 st = gl_TexCoord[0].st;
				   	vec4 col = vec4(0.0);
				 
				    float time = _Time.y * 0.25;
				    float timeFrag = fract (time);


				    // if (timeFrag > 0.5) {
				    curRotation += (_Time.y - curRotation);
				    curRotationContra -= (_Time.y + curRotationContra);
				    // } else {

				    // }


				    //LAYER 1
				    vec2 coordSys1 = st;
				    if (timeFrag > 0.5) {
				        coordSys1 -= .5;
				        coordSys1 *= rotationMatrix ((PI * 0.25) * curRotation);
				        coordSys1 += .5;

				    }
				    vec2 grid1 = tile(coordSys1, 5.);
				    if (timeFrag <= 0.5) {
				        grid1 -= .5;
				        grid1 *= rotationMatrix ((PI * 0.25) * curRotationContra);
				        grid1 += .5;
				    }
				    col = mix(_Color1, _Color2, box(grid1, vec2 (0.75)));

				    vec2 coordSys2 = st;
				    if (timeFrag <= 0.5) {
				        coordSys2 -= .5;
				        coordSys2 *= rotationMatrix ((PI * 0.25) * curRotationContra);
				        coordSys2 += .5;
				    }
				    vec2 grid2 = tile(coordSys1, 10.);
				    if (timeFrag > 0.5) {
				        grid2 -= .5;
				        grid2 *= rotationMatrix ((PI * 0.25) * curRotation);
				        grid2 += .5;

				    }
				    col = mix(col, _Color3, box(grid2, vec2 (0.75)));
				    gl_FragColor = vec4(col);
				}
				#endif // here ends the definition of the fragment shader

			ENDGLSL // here ends the part in GLSL 
        }
    }
}
