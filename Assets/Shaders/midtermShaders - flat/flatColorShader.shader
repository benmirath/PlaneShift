Shader "Custom/flatColorShader" {
	Properties {
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}
	
	SubShader {
		Pass {
			CGPROGRAM
			
			//pragmas - instructions / declarations
			#pragma vertex vert
			#pragma fragment frag
			
			//user defined variables
			uniform float4 _Color;
			
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
				return o;
			}
			
			//fragment function - return type of float4 (since it won't be used elsewhere), the vert functions return type, and a semantic of COLOR
			float4 frag(vertexOutput i) : COLOR {	
				return _Color;
			}
			ENDCG
		}
	}
	//fallback commented out during development
	Fallback "Diffuse"
}
