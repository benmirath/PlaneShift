Shader "Custom/_fragDefault" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Pass {
			CGPROGRAM
	 		#pragma vertex vert
	        #pragma fragment frag
	        #include "UnityCG.cginc"
			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0


			uniform sampler2D _MainTex;
			float4 _MainTex_ST;	//dunno why this is important, but it needs to be here...
			uniform fixed4 _Color;
			
		 	struct v2f {
	            float4 pos : SV_POSITION;
	            fixed3 color : COLOR0;
	            float2 uv : TEXCOORD0;
	        };

			
			v2f vert (appdata_base v) {
		 		v2f o;
		        o.pos = mul (UNITY_MATRIX_MVP, v.vertex);		//set to proper viewpoint in the world
            	o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
            	o.uv *= -1.;
            	return o;
			}
			
			fixed pixel_w = 15.;
			fixed pixel_h = 10.;
			
			fixed4 frag (v2f i) : SV_Target {
				fixed2 st = i.uv;				
 				fixed4 texcol = tex2D (_MainTex, st);
            	return texcol;
			}
			ENDCG
		}
		
		
	} 
	FallBack "Diffuse"
}