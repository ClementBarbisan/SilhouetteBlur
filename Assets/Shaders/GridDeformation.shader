Shader "Unlit/GridDeformation"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_GrayTex("TextureSilhouette", 2D) = "white" {}
		_StreamTex("TextureVideo", 2D) = "white" {}
		_Width("Width", Range(1, 1920)) = 640
		_Height("Height", Range(1, 1080)) = 480
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
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
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _GrayTex;
			sampler2D _StreamTex;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _GrayTex_ST;
			float4 _StreamTex_ST;
			uint _Width;
			uint _Height;
			uint _InstanceX;
			uint _InstanceY;
			
			v2f vert (appdata v)
			{

				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
#if !defined(SHADER_API_OPENGL)
				if (tex2Dlod(_GrayTex, float4(o.uv, 0, 0)).x > 0.1)
				{
					float4 rgba = tex2Dlod(_StreamTex, float4(o.uv, 0, 0));
					v.vertex.y += 0.2126 * rgba.x + 0.7152 * rgba.y + 0.0722 * rgba.z;
					v.vertex.y /= 2;
				}
#endif
				o.vertex = UnityObjectToClipPos(v.vertex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
