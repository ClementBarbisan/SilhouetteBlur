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
			Blend SrcAlpha one

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
				int instance : ID;
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
				o.instance = instance_id;
				return o;
			}

			[maxvertexcount(10)]
			void geom(point PS_INPUT p[1], inout LineStream<PS_INPUT> triStream)
			{
				float4 p1 = p[0].position;
				float4 p2 = p[0].position;
				float4 p3 = p[0].position;
				float4 p4 = p[0].position;
				float4 p5 = p[0].position;
				if (p[0].instance + 1 < _Width * _Height && (p[0].instance + 1) % _Width != 0)
					p2 = UnityObjectToClipPos(float4(particleBuffer[p[0].instance + 1].position, 1.0f));
				if (p[0].instance + _Width < _Width * _Height)
					p3 = UnityObjectToClipPos(float4(particleBuffer[p[0].instance + _Width].position, 1.0f));
				if (p[0].instance - 1 >= 0)
					p4 = UnityObjectToClipPos(float4(particleBuffer[p[0].instance - 1].position, 1.0f));
				if (p[0].instance - _Width >= 0)
					p5 = UnityObjectToClipPos(float4(particleBuffer[p[0].instance - _Width].position, 1.0f));
				PS_INPUT pIN;
				float4 pc = p4 * 0.25f + p1 * 0.5f + p2 * 0.25f;
				float4 tmpP1 = 2 * pc - p4 / 2 - p2 / 2;

				pIN.position = p1;
				pIN.color = p[0].color;
				pIN.instance = p[0].instance;
				triStream.Append(pIN);

				pIN.position = p4 * (0.625 * 0.625) + tmpP1 * 2 * 0.125 *(1 - 0.625) + p2 * (1 - 0.625) * (1 - 0.625);
				pIN.color = p[0].color;
				pIN.instance = p[0].instance + 1;
				triStream.Append(pIN);

				pIN.position = p4 * (0.75 * 0.75) + tmpP1 * 2 * 0.75 *(1 - 0.75) + p2 * (1 - 0.75) * (1 - 0.75);
				pIN.color = p[0].color;
				pIN.instance = p[0].instance + 1;
				triStream.Append(pIN);

				pIN.position = p4 * (0.875 * 0.875) + tmpP1 * 2 * 0.875 *(1 - 0.875) + p2 * (1 - 0.875) * (1 - 0.875);
				pIN.color = p[0].color;
				pIN.instance = p[0].instance + 1;
				triStream.Append(pIN);

				pIN.position = p2;
				pIN.instance = p[0].instance + 1;
				triStream.Append(pIN);

				triStream.RestartStrip();

				pc = p5 * 0.25f + p1 * 0.5f + p3 * 0.25f;
				tmpP1 = 2 * pc - p5 / 2 - p3 / 2;

				pIN.position = p1;
				pIN.instance = p[0].instance;
				triStream.Append(pIN);

				pIN.position = p5 * (0.625 * 0.625) + tmpP1 * 2 * 0.125 *(1 - 0.625) + p3 * (1 - 0.625) * (1 - 0.625);
				pIN.color = p[0].color;
				pIN.instance = p[0].instance + 1;
				triStream.Append(pIN);

				pIN.position = p5 * (0.75 * 0.75) + tmpP1 * 2 * 0.75 *(1 - 0.75) + p3 * (1 - 0.75) * (1 - 0.75);
				pIN.color = p[0].color;
				pIN.instance = p[0].instance + 1;
				triStream.Append(pIN);

				pIN.position = p5 * (0.875 * 0.875) + tmpP1 * 2 * 0.875 *(1 - 0.875) + p3 * (1 - 0.875) * (1 - 0.875);
				pIN.color = p[0].color;
				pIN.instance = p[0].instance + 1;
				triStream.Append(pIN);

				pIN.position = p3;
				pIN.instance = p[0].instance + _Width;
				triStream.Append(pIN);
				
				triStream.RestartStrip();
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
