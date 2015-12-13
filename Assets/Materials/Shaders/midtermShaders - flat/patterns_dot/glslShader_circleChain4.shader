Shader "Unlit/glslShader_circleChain4"
{
	Properties {
//		_MainTex ("RGBA Texture Image", 2D) = "white" {}
		_Color1 ("Color1", Color) = (1.0, 0.0, 0.0, 1.0)
		_Color2 ("Color2", Color) = (0.0, 1.0, 0.0, 1.0)
		_Cutoff ("Alpha Cutoff", Float) = 0.5
	}
	
	SubShader {
        Pass {
			Tags { "Queue"="Transparent" "RenderType"="Transparent" }
         
			Cull Off // since the front is partially transparent, we shouldn't cull the back
            AlphaTest Greater [_Cutoff] // specify alpha test: fragment passes if alpha is greater than _Cutoff

				GLSLPROGRAM // here begins the part in Unity's GLSL
				uniform vec4 _Time;
				uniform vec4 _Color1;
				uniform vec4 _Color2;
				uniform sampler2D _MainTex;	
				
				#ifdef VERTEX // here begins the vertex shader
//				varying vec4 position;
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
				
//				uniform vec4 _Time;

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

				mat2 rotationMatrix(float a) {
				    return mat2(vec2(cos(a),-sin(a)),
				               	vec2(sin(a),cos(a)));
				}
				
				vec2 movingTiles(vec2 _st, float _zoom, float _speed){
				    _st *= _zoom;
				    float time = _Time.y * _speed;
				    if( fract(time)>0.5 ){
				        if (fract( _st.y * 0.5) > 0.5){
				            _st.x += fract(time)*2.0;
				        } else {
				            _st.x -= fract(time)*2.0;
				        } 
				    } else {
				        if (fract( _st.x * 0.5) > 0.5){
				            _st.y += fract(time)*2.0;
				        } else {
				            _st.y -= fract(time)*2.0;
				        } 
				    }
				    return fract(_st);
				}


				void main() {
					vec2 st = gl_TexCoord[0].st;
//				    vec3 col = vec3(0.);
					vec4 col = _Color1;
					float pct = 0.0;
					float time = _Time.y;
					time *= 0.25;
				    
				    float fullSwing = distance(st,vec2(.5));
				    fullSwing += _Time.y; 
				    float d = distance(st,vec2(.5));
				    d = sin(d*3.14*5.-time*3.);
//				    color += d;
				    
//				    st *= 20.;	//repeat 10 times
				    st = movingTiles (st, 20., .15);
				    vec2 st_i = floor(st);
//				    st_i -= .5;
//				    st_i = rotationMatrix(d*3.14)*st_i;
//				    st_i += .5;
				    
				    if (mod(st_i.y,2.) == 1.) {	//create x offset every other row
				        st.x += .5;
				    }
				    
				    vec2 st_f = fract(st);		//create pattern
				    st_f -= .5;
//				    st_f = rotationMatrix(d*3.14)*st_f;
					st_f = rotationMatrix(_Time.y)*st_f;
				    st_f += .5;
				    
				    vec2 offset1 = vec2 (1., 1.);
				    vec2 offset2 = vec2 (-1., 1.);;
				    vec2 offset3 = vec2 (1., -1.);;
				    vec2 offset4 = vec2 (-1., -1.);;
				    
					float timer = _Time.y * .25;
					timer = abs ( sin (timer) * 0.5 );
					pct += circle (st_f + (offset1 * timer), 0.25);
					pct += circle (st_f + (offset2 * timer), 0.25);
					pct += circle (st_f + (offset3 * timer), 0.25);
					pct += circle (st_f + (offset4 * timer), 0.25);
					
				    col = mix (_Color1, _Color2, abs (_Time.y * .25));

				    
				    
//				    col += pct;		
					col *= pct;
//					col.a *= (pct * 100.);
//				    col += 		    
				    
					gl_FragColor = col;
//					gl_FragColor = vec4 (0.0,0.0,0.0,0.0);
//					gl_FragColor.a = 0.;
				}
				#endif // here ends the definition of the fragment shader

			ENDGLSL // here ends the part in GLSL 
        }
    }
}
