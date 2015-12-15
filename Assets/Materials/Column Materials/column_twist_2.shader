Shader "Custom/Column/column_twist_2" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_TwistAmount ("Rotation", Float) = 5
		_AnimSpeed ("Animation Speed", Float) = 0
		_Subdivide ("Sub Divide", Int) = 20	 
	}
	SubShader {
		// Tags { "RenderType"="Opaque" }
		Tags { "Queue"="Transparent" "RenderType"="Transparent" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows vertex:vert alpha
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
		int _Subdivide;

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
			bool isTransparent = fmod (floor (st.x * _Subdivide), 2) == 0;
			o.Albedo = (isTransparent) ? fixed3(1,1,1) : c.rgb;
			o.Emission = o.Albedo;
			o.Metallic = 0;
			o.Smoothness = 0;
			o.Alpha = (isTransparent) ? 0 : c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
