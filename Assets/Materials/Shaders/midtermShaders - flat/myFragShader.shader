Shader "Custom/myFragShader" {
	Properties {
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}
	SubShader {
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"

            struct vertexInput {
                float4 vertex : POSITION;
                float4 texcoord0 : TEXCOORD0;
            };

            struct fragmentInput{
                float4 position : SV_POSITION;
                float4 texcoord0 : TEXCOORD0;
            };

            fragmentInput vert(vertexInput i){
                fragmentInput o;
                o.position = mul (UNITY_MATRIX_MVP, i.vertex);
                o.texcoord0 = i.texcoord0;
                return o;
            }
            fixed4 frag(fragmentInput i) : SV_Target {
                return fixed4(1.0 - i.texcoord0.x, 0.0,0.0,1.0);
            }
            ENDCG
        }
    }
	SubShader {
		Pass {
			CGPROGRAM
			
			//pragmas - instructions / declarations
			#pragma vertex vert
			#pragma fragment frag
			
			//user defined variables
			uniform float4 _Color;
//			uniform float4 _Time;
			
			//base input structs
			struct vertexInput {
				float4 vertx : POSITION;	//vertext == name, POSITION == semantic
			};
			struct vertexOutput {
				float4 pos : SV_POSITION;
			};
			
			//vertex function
			vertexOutput vert (vertexInput v) {
				vertexOutput o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertx);
//				float4 p = UNITY_MATRIX_MVP[3];
//				p.xy /= p.w;
//				o.pos = p;
				return o;
			}
			
			//fragment function - return type of float4 (since it won't be used elsewhere), the vert functions return type, and a semantic of COLOR
			float4 frag(vertexOutput i) : COLOR {	
				float2 pos = _ScreenParams.xy;
//				float4 col = float4(sin (_Time.y), 0.0, 0.0, 1.0);	//pulsing red
				float4 col = float4(pos.x, 0.0, 0.0, 1.0);	
				return col;
//				return _Color;
			}
			ENDCG
		}
	}
	//fallback commented out during development
	Fallback "Diffuse"
}
