Shader "Custom/column_twist_1" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_TwistAmount ("Rotation", Float) = 5
		_AnimSpeed ("Animation Speed", Float) = 0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows vertex:vert
		#pragma target 3.0
		
		fixed4 DoTwist( fixed4 pos, fixed t ) {
			fixed st = sin(t);
			fixed ct = cos(t);
			fixed4 new_pos;
			
			new_pos.x = pos.x*ct - pos.z*st;
			new_pos.z = pos.x*st + pos.z*ct;
			
			new_pos.y = pos.y;
			new_pos.w = pos.w;
		
			return new_pos;
		}

		sampler2D _MainTex;
		fixed _TwistAmount;
		fixed _AnimSpeed;

		struct Input {
			float2 uv_MainTex;
		};
		fixed4 _Color;

		void vert (inout appdata_full v, out Input o) {
			float adj = v.vertex.y * _TwistAmount;
			adj += (_Time.y * _AnimSpeed); 
			v.vertex = DoTwist (v.vertex, adj);
      	}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			fixed2 st = IN.uv_MainTex;
			o.Albedo = (fmod (floor (st.x * 100), 2) == 0) ? fixed3(1,1,1) : c.rgb;
			o.Metallic = 0;
			o.Smoothness = 0;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
