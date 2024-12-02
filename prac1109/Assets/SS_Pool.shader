Shader "Custom/SS_Pool"
{
    Properties
    {
        _Color ("Color", Color) = (0.5,1,0,1)
        _MainTex ("Bubble", 2D) = "white" {}
		_StepSize("Step Size", Float) = 4

		_Amplitude("Amplitude", Range(0.1, 5)) = 1
		_Frequency("Frequency", Range(1, 6)) = 4
		_ColorLow("Color Low",Color) = (0.3,0.5,0,1)
		_ColorHigh("Color High", Color) = (0.7,0.9,0,1)

		_BubblePatternSpeed("Bubble Pattern Speed", Range(0.1, 10)) = 4 // 버블 패턴 이동 속도
		_BubbleMoveSpeed("Bubble Movement Speed", Range(0.1, 10)) = 1   // 버블 이동 속도
		_BubbleFrequency("Bubble Frequency", Range(0.1, 10)) = 6        // 버블 주파수
		_BubbleAmplitude("Bubble Amplitude", Range(0.1, 10)) = 1        // 버블 진폭
		_BubbleFlickSpeed("Bubble Flicker Speed", Range(0.1, 10)) = 1   // 버블 깜빡임 속도
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Nolight vertex:vert noshadow noambient

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

		sampler2D _MainTex;
		float _Amplitude;
		float _Frequency;
		fixed4 _ColorLow;
		fixed4 _ColorHigh;
		fixed4 _Color;

		struct Input
		{
			float2 uv_MainTex;
			float height; // 높이값을 추가
		};

		void vert(inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input, o); // o 초기화

			// 높이 변형 적용
			//v.vertex.xyz += v.normal * 3;
			v.vertex.y += sin((v.texcoord.x * 2 - 1) * _Frequency + _Time.y/2) * _Amplitude / 2;
			v.vertex.y += sin((v.texcoord.y * 2 - 1) * _Frequency/3 + _Time.y/2) * _Amplitude / 2;

			// 높이를 Input 구조체로 전달
			o.height = v.vertex.y;
		}
		float _StepSize;
		float _BubblePatternSpeed;
		float _BubbleMoveSpeed;
		float _BubbleFrequency;
		float _BubbleAmplitude;
		float _BubbleFlickSpeed;

		void surf(Input IN, inout SurfaceOutput o)
		{
			fixed4 c = tex2D(_MainTex, fixed2(IN.uv_MainTex.x-_Time.x/ _BubblePatternSpeed,IN.uv_MainTex.y - _Time.x/ _BubblePatternSpeed)); // pattern 변화 속도
			float heightVal = saturate((IN.height + 1.0) / 2.0);

			float sinVal = sin((_Time.x*_BubbleMoveSpeed + IN.uv_MainTex.x) *_BubbleFrequency)*_BubbleAmplitude 
				+ sin((_Time.x*_BubbleMoveSpeed + IN.uv_MainTex.y)*_BubbleFrequency)*_BubbleAmplitude;
			// Create Pattern 1. _Time * 시간텀-> 이동 속도 2. sin(_ * 주파수)-> 주파수 흰검 모양 3. sin(_)*진폭 -> 깜빡임 속도
			float fade = sinVal*((sin(_Time.y*_BubbleFlickSpeed))*0.5+0.5); // 한번 더 패턴을 주고 싶으면.
			
			float bubbleVal = saturate(c.r*fade );
			float step = floor((heightVal+ bubbleVal) * _StepSize) / _StepSize;
			o.Albedo = fade;// debugging
			o.Albedo = lerp(_ColorLow.rgb, _ColorHigh.rgb, step); // 높이에 따른 색상 변화
		}

		float4 LightingNolight(SurfaceOutput s, float3 lightDir, float3 viewDir, float atten) {
			// LightingNolight에서는 색상 조명 없이 Albedo 값을 그대로 반환
			return float4(s.Albedo, s.Alpha);
		}
        ENDCG
    }
    FallBack "Diffuse"
}
