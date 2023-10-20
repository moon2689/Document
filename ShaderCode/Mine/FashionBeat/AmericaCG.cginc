// 应用纹身
fixed4 ApplyTattoo(float2 uv, sampler2D tattooTex, float4 tattooPos, fixed4 albedo)
{
	if (uv.x >= tattooPos.x && uv.x <= tattooPos.x+tattooPos.z && uv.y >= tattooPos.y && uv.y <= tattooPos.y + tattooPos.w)
	{
		fixed tattooU = (uv.x - tattooPos.x) / tattooPos.z;
		fixed tattooV = (uv.y - tattooPos.y) / tattooPos.w;
		fixed2 tattooUV = fixed2(tattooU, tattooV);
		fixed4 tattooCol = tex2D(tattooTex, tattooUV);
		albedo.rgb = lerp(albedo.rgb, tattooCol.rgb, tattooCol.a);
	}

	return albedo;
}

// Photoshop 中的图层叠加算法
float OverlaySingle(float main, float mask)
{
	if (main < 0.5)
	{
		return 2 * main * mask;
	}
	else
	{
		return 1 - 2 * (1 - main) * (1 - mask);
	}
}

// Photoshop 中的图层叠加算法
fixed3 Overlay(fixed4 col, fixed4 overlyCol)
{
	fixed r = OverlaySingle(col.r, overlyCol.r);
	fixed g = OverlaySingle(col.g, overlyCol.g);
	fixed b = OverlaySingle(col.b, overlyCol.b);
	return fixed3(r, g, b);
}

// diffuse 算法
fixed3 CalcDiffuse(fixed4 albedo, float3 worldLight, float3 worldNormal, sampler2D _Ramp, float _RampRate)
{
	float d = dot(worldLight, worldNormal) * 0.5 + 0.5;
	fixed4 rampCol = tex2D(_Ramp, float2(d, d));
	fixed3 temp = lerp(fixed3(0.5, 0.5, 0.5), rampCol.rgb, rampCol.a);
	if (rampCol.a > 0)
	{
		temp *= _RampRate;
	}
	fixed3 diffuse = albedo.rgb * _LightColor0.rgb * temp;
	return diffuse;
}

// specular 算法
fixed3 CalcSpecular(float3 worldView, float3 worldLight, float3 worldNormal, float _SpecularGloss, sampler2D _SpecularMask, float2 uv)
{
	fixed3 halfDir = normalize(worldView + worldLight);
	float specD = abs(dot(halfDir, worldNormal));
	fixed4 specMask = tex2D(_SpecularMask, uv);
	fixed3 specular = _LightColor0.rgb * pow(specD, _SpecularGloss) * specMask.rgb;
	return specular;
}

float3 RGBToHSV(float3 rgb)
{
   float R = rgb.x;
   float G = rgb.y;
   float B = rgb.z;
   float3 hsv;
   float max1 = max(R, max(G, B));
   float min1 = min(R, min(G, B));

   if (R == max1)
   {
       hsv.x = (G - B) / (max1 - min1);
   }
   if (G == max1)
   {
       hsv.x = 2.0 + (B - R) / (max1 - min1);
   }
   if (B == max1)
   {
       hsv.x = 4.0 + (R - G) / (max1 - min1);
   }

   hsv.x = hsv.x * 60.0;
   if (hsv.x  < 0.0)
   {
       hsv.x = hsv.x + 360.0;
   }
   hsv.z = max1;
   hsv.y = (max1 - min1) / max1;
   return hsv;
}

float3 HSVToRGB(float3 hsv)
{
   float R;
   float G;
   float B;
   if (hsv.y == 0.0)
   {
		R = G = B = hsv.z;
		return float3(R, G, B);
	}

	hsv.x = hsv.x / 60.0;
	int i = int(hsv.x);
	float f = hsv.x - float(i);
	float a = hsv.z * (1.0 - hsv.y);
	float b = hsv.z * (1.0 - hsv.y * f);
	float c = hsv.z * (1.0 - hsv.y * (1.0 - f));
	if (i == 0)
	{
		R = hsv.z;
		G = c;
		B = a;
	}
	else if (i == 1)
	{
		R = b;
		G = hsv.z;
		B = a;
	}
	else if (i == 2)
	{
		R = a;
		G = hsv.z;
		B = c;
	}
	else if (i == 3)
	{
		R = a;
		G = b;
		B = hsv.z;
	}
	else if (i == 4)
	{
		R = c;
		G = a;
		B = hsv.z;
	}
	else
	{
		R = hsv.z;
		G = a;
		B = b;
	}
	return float3(R, G, B);
}

// 根据色相，饱和度，明度，计算染色颜色
half3 ComputeDyeColor(half4 c, half4 dyeValue)
{
	float3 hsv = RGBToHSV(c.rgb);
	hsv.x += dyeValue.x;
	hsv.x = hsv.x % 360;
	hsv.y *= dyeValue.y;
	hsv.z *= dyeValue.z;
	return HSVToRGB(hsv);
}

// 根据色相，饱和度，明度，计算最终的染色颜色
fixed4 ComputeFinalDyeColor(fixed4 col, fixed4 dye, float4 _DyeValue1, float4 _DyeValue2, float4 _DyeValue3)
{
	half dyeFlag1 = dye.r * dye.a;
	half dyeFlag2 = dye.g * dye.a;
	half dyeFlag3 = dye.b * dye.a;
	half noChangeFlag = 1 - dye.a;

	half3 color1 = ComputeDyeColor(col, _DyeValue1);
	half3 color2 = ComputeDyeColor(col, _DyeValue2);
	half3 color3 = ComputeDyeColor(col, _DyeValue3);

	half3 dyeCol = saturate(dyeFlag1 * color1 + dyeFlag2 * color2 + dyeFlag3 * color3 + noChangeFlag * col.rgb);

	col = half4(dyeCol.r, dyeCol.g, dyeCol.b, col.a);
	return col;
}