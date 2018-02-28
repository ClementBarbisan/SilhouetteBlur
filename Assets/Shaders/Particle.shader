// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Particle"
{
	Properties
	{
		_ColorLow ("Color Slow Speed", Color) = (0, 0, 0.5, 0.3)
		_ColorHigh ("Color High Speed", Color) = (1, 0, 0, 0.3)
		_HighSpeedValue ("High speed Value", Range(0, 50)) = 25
	}

	SubShader 
	{
		Pass 
		{
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
				float4 color : COLOR;
				int instance : SV_InstanceID;
			};
			
			// Particle's data, shared with the compute shader
			StructuredBuffer<Particle> particleBuffer;
			
			// Properties variables
			uniform float4 _ColorLow;
			uniform float4 _ColorHigh;
			uniform float _HighSpeedValue;
			uniform int _Width;
			uniform int _Height;
			
			// Vertex shader
			PS_INPUT vert(uint vertex_id : SV_VertexID, uint instance_id : SV_InstanceID)
			{
				PS_INPUT o = (PS_INPUT)0;

				// Color
				float speed = length(particleBuffer[instance_id].velocity);
				float lerpValue = clamp(speed / _HighSpeedValue, 0.0f, 1.0f);
				o.color = lerp(_ColorLow, _ColorHigh, lerpValue);

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
				pIN.color = p[0].color;
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

						pIN.position = p2 * (0.6 * 0.6) + tmpP1 * 2 * 0.6 *(1 - 0.6) + p4 * (1 - 0.6) * (1 - 0.6) - height * size;
						triStream.Append(pIN);
						pIN.position = p2 * (0.6 * 0.6) + tmpP1 * 2 * 0.6 *(1 - 0.6) + p4 * (1 - 0.6) * (1 - 0.6) + height * size;
						triStream.Append(pIN);
						pIN.position = p2 * (0.7 * 0.7) + tmpP1 * 2 * 0.7 *(1 - 0.7) + p4 * (1 - 0.7) * (1 - 0.7) - height * size;
						triStream.Append(pIN);
						pIN.position = p2 * (0.7 * 0.7) + tmpP1 * 2 * 0.7 *(1 - 0.7) + p4 * (1 - 0.7) * (1 - 0.7) + height * size;
						triStream.Append(pIN);
						pIN.position = p2 * (0.8 * 0.8) + tmpP1 * 2 * 0.8 *(1 - 0.8) + p4 * (1 - 0.8) * (1 - 0.8) - height * size;
						triStream.Append(pIN);
						pIN.position = p2 * (0.8 * 0.8) + tmpP1 * 2 * 0.8 *(1 - 0.8) + p4 * (1 - 0.8) * (1 - 0.8) + height * size;
						triStream.Append(pIN);
						pIN.position = p2 * (0.9 * 0.9) + tmpP1 * 2 * 0.9 *(1 - 0.9) + p4 * (1 - 0.9) * (1 - 0.9) - height * size;
						triStream.Append(pIN);
						pIN.position = p2 * (0.9 * 0.9) + tmpP1 * 2 * 0.9 *(1 - 0.9) + p4 * (1 - 0.9) * (1 - 0.9) + height * size;
						triStream.Append(pIN);
					}
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
					pIN.position = p1 - width * size;
					triStream.Append(pIN);
					pIN.position = p1 + width * size;
					triStream.Append(pIN);
					if (p[0].instance - _Width > 0)
					{
						float4 p5 = UnityObjectToClipPos(float4(particleBuffer[p[0].instance - _Width].position, 1.0f));
						float4 pc = p5 * 0.125f + p1 * 0.75f + p3 * 0.125f;
						float4 tmpP1 = 2 * pc - p5 / 2 - p3 / 2;
						pIN.position = p3 * (0.6 * 0.6) + tmpP1 * 2 * 0.6 *(1 - 0.6) + p5 * (1 - 0.6) * (1 - 0.6) - width * size;
						triStream.Append(pIN);
						pIN.position = p3 * (0.6 * 0.6) + tmpP1 * 2 * 0.6 *(1 - 0.6) + p5 * (1 - 0.6) * (1 - 0.6) + width * size;
						triStream.Append(pIN);

						pIN.position = p3 * (0.7 * 0.7) + tmpP1 * 2 * 0.7 *(1 - 0.7) + p5 * (1 - 0.7) * (1 - 0.7) - width * size;
						triStream.Append(pIN);
						pIN.position = p3 * (0.7 * 0.7) + tmpP1 * 2 * 0.7 *(1 - 0.7) + p5 * (1 - 0.7) * (1 - 0.7) + width * size;
						triStream.Append(pIN);

						pIN.position = p3 * (0.8 * 0.8) + tmpP1 * 2 * 0.8 *(1 - 0.8) + p5 * (1 - 0.8) * (1 - 0.8) - width * size;
						triStream.Append(pIN);
						pIN.position = p3 * (0.8 * 0.8) + tmpP1 * 2 * 0.8 *(1 - 0.8) + p5 * (1 - 0.8) * (1 - 0.8) + width * size;
						triStream.Append(pIN);

						pIN.position = p3 * (0.9 * 0.9) + tmpP1 * 2 * 0.9 *(1 - 0.9) + p5 * (1 - 0.9) * (1 - 0.9) - width * size;
						triStream.Append(pIN);
						pIN.position = p3 * (0.9 * 0.9) + tmpP1 * 2 * 0.9 *(1 - 0.9) + p5 * (1 - 0.9) * (1 - 0.9) + width * size;
						triStream.Append(pIN);
					}
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
				return i.color;
			}
			
			ENDCG
		}
	}

	Fallback Off
}
