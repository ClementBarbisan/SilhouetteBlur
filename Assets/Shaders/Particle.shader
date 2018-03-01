// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Particle"
{
	Properties
	{
		_Color ("Color", Color) = (0.75, 0.75, 0.75, 1.0)
	}

	SubShader 
	{
		Pass 
		{
			Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }
			LOD 100
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Lighting Off
			CGPROGRAM
			#pragma target 5.0
			
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			// Particle's data
			struct Particle
			{
				float3 position;
				float3 velocity;
			};
			
			// Pixel shader input
			struct PS_INPUT
			{
				float4 position : SV_POSITION;
				//float4 color : COLOR;
				int instance : SV_InstanceID;
			};
			
			// Particle's data, shared with the compute shader
			StructuredBuffer<Particle> particleBuffer;
			
			// Properties variables
			uniform float4 _Color;
			uniform int _Width;
			uniform int _Height;
			
			// Vertex shader
			PS_INPUT vert(uint vertex_id : SV_VertexID, uint instance_id : SV_InstanceID)
			{
				PS_INPUT o = (PS_INPUT)0;

				// Color
				//o.color = _ColorHigh;

				// Position
				o.position = UnityObjectToClipPos(float4(particleBuffer[instance_id].position, 1.0f));
				o.instance = int(instance_id);
				return o;
			}

			[maxvertexcount(24)]
			void geom(point PS_INPUT p[1], inout TriangleStream<PS_INPUT> triStream)
			{
				float4 p1 = p[0].position;
				
				float size = 0.3f;
				PS_INPUT pIN;
				pIN.position = p1;
				//pIN.color = p[0].color;
				pIN.instance = 0;
				/*if (p[0].instance + 1 < _Width * _Height && (p[0].instance + 1) % _Width != 0)
				{
					float4 p2 = UnityObjectToClipPos(float4(particleBuffer[p[0].instance + 1].position, 1.0f));
					float4 ab = p2 - p1;
					float4 height = float4(ab.y, -ab.x, 0, 0);
					height = normalize(height);

					height.x /= (_ScreenParams.x / _ScreenParams.y);
					
					pIN.position = p1 - height * size;
					triStream.Append(pIN);
					pIN.position = p1 + height * size;
					triStream.Append(pIN);
					
					pIN.position = p2 - height * size;
					triStream.Append(pIN);
					pIN.position = p2 + height * size;
					triStream.Append(pIN);

					triStream.RestartStrip();
				}
				if (p[0].instance + _Width < _Width * _Height)
				{
					float4 p3 = UnityObjectToClipPos(float4(particleBuffer[p[0].instance + _Width].position, 1.0f));
					float4 ab = p3 - p1;
					float4 width = float4(ab.y, ab.x, 0, 0);
					width = normalize(width);

					width.x /= (_ScreenParams.x / _ScreenParams.y);
					
					pIN.position = p1 - width * size;
					triStream.Append(pIN);
					pIN.position = p1 + width * size;
					triStream.Append(pIN);
					
					pIN.position = p3 - width * size;
					triStream.Append(pIN);
					pIN.position = p3 + width * size;
					triStream.Append(pIN);
				
					triStream.RestartStrip();				
				}*/
				if (p[0].instance + 1 < _Width * _Height && uint(p[0].instance + 1) % uint(_Width) != 0)
				{
					float4 p2 = UnityObjectToClipPos(float4(particleBuffer[p[0].instance + 1].position, 1.0f));
					float4 ab = p2 - p1;
					float4 height = float4(0, 0, 0, 0);
					height = normalize(float4(ab.y, -ab.x, 0, 0));

					height.x /= (_ScreenParams.x / _ScreenParams.y);
					pIN.position = p1 - height * size;
					triStream.Append(pIN);
					pIN.position = p1 + height * size;
					triStream.Append(pIN);
					if (p[0].instance - 1 > 0 && uint(p[0].instance) % uint(_Width) != 0)
					{
						float4 p4 = UnityObjectToClipPos(float4(particleBuffer[p[0].instance - 1].position, 1.0f));
						float4 pc = p4 * 0.125f + p1 * 0.75f + p2 * 0.125f;
						float4 tmpP1 = 2 * pc - p4 / 2 - p2 / 2;

						float4 tmpPos = p2 * (0.6 * 0.6) + tmpP1 * 2 * 0.6 *(1 - 0.6) + p4 * (1 - 0.6) * (1 - 0.6);
						//pIN.color = _ColorHigh * (-tmpPos.z + 0.1f);
						pIN.position = tmpPos - height * size;
						triStream.Append(pIN);
						pIN.position = tmpPos + height * size;
						triStream.Append(pIN);
						tmpPos = p2 * (0.7 * 0.7) + tmpP1 * 2 * 0.7 *(1 - 0.7) + p4 * (1 - 0.7) * (1 - 0.7);
						//pIN.color = _ColorHigh * (-tmpPos.z + 0.1f);
						pIN.position = tmpPos - height * size;
						triStream.Append(pIN);
						pIN.position = tmpPos + height * size;
						triStream.Append(pIN);
						tmpPos = p2 * (0.8 * 0.8) + tmpP1 * 2 * 0.8 *(1 - 0.8) + p4 * (1 - 0.8) * (1 - 0.8);
						//pIN.color = _ColorHigh * (-tmpPos.z + 0.1f);
						pIN.position = tmpPos - height * size;
						triStream.Append(pIN);
						pIN.position = tmpPos + height * size;
						triStream.Append(pIN);
						tmpPos = p2 * (0.9 * 0.9) + tmpP1 * 2 * 0.9 *(1 - 0.9) + p4 * (1 - 0.9) * (1 - 0.9);
						//pIN.color = _ColorHigh * (-tmpPos.z + 0.1f);
						pIN.position =  tmpPos - height * size;
						triStream.Append(pIN);
						pIN.position = tmpPos + height * size;
						triStream.Append(pIN);
					}
					//pIN.color = _ColorHigh * (-p2.z / p2.w + 0.1f);
					pIN.position = p2 - height * size;
					triStream.Append(pIN);
					pIN.position = p2 + height * size;
					triStream.Append(pIN);
					triStream.RestartStrip();
				}
				if (p[0].instance + _Width < _Width * _Height)
				{
					float4 p3 = UnityObjectToClipPos(float4(particleBuffer[p[0].instance + _Width].position, 1.0f));
					float4 ab = p3 - p1;
					float4 width = float4(0, 0, 0, 0);
					width = normalize(float4(ab.y, ab.x, 0, 0));

					width.x /= (_ScreenParams.x / _ScreenParams.y);
					//pIN.color = p[0].color;
					pIN.position = p1 - width * size;
					triStream.Append(pIN);
					pIN.position = p1 + width * size;
					triStream.Append(pIN);
					if (p[0].instance - _Width > 0)
					{
						float4 p5 = UnityObjectToClipPos(float4(particleBuffer[p[0].instance - _Width].position, 1.0f));
						float4 pc = p5 * 0.125f + p1 * 0.75f + p3 * 0.125f;
						float4 tmpP1 = 2 * pc - p5 / 2 - p3 / 2;

						float4 tmpPos = p3 * (0.6 * 0.6) + tmpP1 * 2 * 0.6 *(1 - 0.6) + p5 * (1 - 0.6) * (1 - 0.6);
						//pIN.color = _ColorHigh * (-tmpPos.z + 0.1f);
						pIN.position = tmpPos - width * size;
						triStream.Append(pIN);
						pIN.position = tmpPos + width * size;
						triStream.Append(pIN);
						tmpPos = p3 * (0.7 * 0.7) + tmpP1 * 2 * 0.7 *(1 - 0.7) + p5 * (1 - 0.7) * (1 - 0.7);
						//pIN.color = _ColorHigh * (-tmpPos.z + 0.1f);
						pIN.position = tmpPos - width * size;
						triStream.Append(pIN);
						pIN.position = tmpPos + width * size;
						triStream.Append(pIN);
						tmpPos = p3 * (0.8 * 0.8) + tmpP1 * 2 * 0.8 *(1 - 0.8) + p5 * (1 - 0.8) * (1 - 0.8);
						//pIN.color = _ColorHigh * (-tmpPos.z + 0.1f);
						pIN.position = tmpPos - width * size;
						triStream.Append(pIN);
						pIN.position = tmpPos + width * size;
						triStream.Append(pIN);
						tmpPos = p3 * (0.9 * 0.9) + tmpP1 * 2 * 0.9 *(1 - 0.9) + p5 * (1 - 0.9) * (1 - 0.9);
						//pIN.color = _ColorHigh * (-tmpPos.z + 0.1f);
						pIN.position = tmpPos - width * size;
						triStream.Append(pIN);
						pIN.position = tmpPos + width * size;
						triStream.Append(pIN);
					}

					//pIN.color = _ColorHigh * (-p3.z / p3.w + 0.1f);
					pIN.position = p3 - width * size;
					triStream.Append(pIN);
					pIN.position = p3 + width * size;
					triStream.Append(pIN);
				
					triStream.RestartStrip();				
				}

			}

			// Pixel shader
			float4 frag(PS_INPUT i) : COLOR
			{
				float4 position = normalize(i.position);
				return (float4(_Color.xyz * (1.0f - (position.z * 2000.0f / position.w) + 0.1f), 1.0f));
			}
			
			ENDCG
		}
	}

	Fallback Off
}
