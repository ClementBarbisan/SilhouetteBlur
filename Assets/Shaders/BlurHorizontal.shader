﻿Shader "Custom/BlurHorizontal" {
	Properties{
		_Size("Blur", Range(0, 50)) = 1
		_Resolution("Resolution", int) = 1024
		[HideInInspector] _MainTex("Tint Color (RGB)", 2D) = "white" {}
	}
		Category{
		// We must be transparent, so other objects are drawn before this one.
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Opaque" }
		SubShader
	{
		// Horizontal blur
	
		Pass
	{
		
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest
#include "UnityCG.cginc"

		struct appdata_t {
		float4 vertex : POSITION;
		float2 texcoord: TEXCOORD0;
	};

	struct v2f {
		float4 vertex : POSITION;
		float4 uvgrab : TEXCOORD0;
		float2 uvmain : TEXCOORD1;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

	v2f vert(appdata_t v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);

#if UNITY_UV_STARTS_AT_TOP
		float scale = -1.0;
#else
		float scale = 1.0;
#endif

		o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y * scale) + o.vertex.w) * 0.5;
		o.uvgrab.zw = o.vertex.zw;

		o.uvmain = TRANSFORM_TEX(v.texcoord, _MainTex);
		return o;
	}

	uint _Resolution;
	float _Size;

	half4 frag(v2f i) : COLOR
	{
		float alpha = tex2D(_MainTex, i.uvmain).a;
	half4 sum = half4(0,0,0,0);

#define GRABPIXEL(weight,kernelx) tex2Dproj( _MainTex, UNITY_PROJ_COORD(float4(i.uvgrab.x +  float(1.0f / _Resolution) * kernelx * _Size * alpha, i.uvgrab.y, i.uvgrab.z, i.uvgrab.w))) * weight

	sum += GRABPIXEL(0.05, -4.0);
	sum += GRABPIXEL(0.09, -3.0);
	sum += GRABPIXEL(0.12, -2.0);
	sum += GRABPIXEL(0.15, -1.0);
	sum += GRABPIXEL(0.18,  0.0);
	sum += GRABPIXEL(0.15, +1.0);
	sum += GRABPIXEL(0.12, +2.0);
	sum += GRABPIXEL(0.09, +3.0);
	sum += GRABPIXEL(0.05, +4.0);

	return sum;
	}
		ENDCG
	}
	}
	}
}