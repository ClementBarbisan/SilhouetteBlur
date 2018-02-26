Shader "Unlit/FromImageGridDeformation"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_GrayTex("TextureSilhouette", 2D) = "white" {}
		_DeformationTex("TextureDeformation", 2D) = "white" {}
		_VideoTex("VideoTexture", 2D) = "white" {}
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }
		LOD 100
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};
			
			sampler2D _MainTex;
			sampler2D _GrayTex;
			sampler2D _DeformationTex;
			sampler2D _VideoTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
#if !defined(SHADER_API_OPENGL)
				float value = tex2Dlod(_GrayTex, float4(o.uv, 0, 0)).x;
				if (value > 0.01)
				{
					float4 rgba = tex2Dlod(_VideoTex, float4(o.uv, 0, 0));
					v.vertex.y += (0.2126 * rgba.x + 0.7152 * rgba.y + 0.0722 * rgba.z) * (value / 2);
				}
#endif
				o.vertex = UnityObjectToClipPos(v.vertex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 greyImage = tex2D(_GrayTex, i.uv);
				fixed4 col = tex2D(_MainTex, i.uv);
				if (greyImage.x > 0.01)
				{
					fixed4 deform = tex2D(_DeformationTex, i.uv);
					float x = (sin(col.x * _Time.y) * sin(col.y * _Time.y)) / 1.2;
					float y = cos(col.z * _Time.y) / 1.2;
					i.uv += (greyImage.x / 1.2) * float2(deform.x * x, deform.y * y);
					col = tex2D(_MainTex, i.uv);
				}
				// sample the texture
				
				
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
