shader_type canvas_item;

uniform int color_count : hint_range(0, 256, 1);

uniform float rotation : hint_range(-1.0, 1.0, .001);
uniform float thickness : hint_range(0.0, 1.0, .0001);
uniform float frequency : hint_range(0.0, 20.0, .0001);
uniform float max_blacknesss : hint_range(0.0, 1.0, .0001);

uniform float luminosity_factor : hint_range(0.0, 1.0, .0001);

uniform int kuwahara_sample_count : hint_range(0, 100, 1);
uniform float kuwahara_sample_size : hint_range(0.0, 1.0, .0001);

uniform sampler2D noise_texture;
uniform sampler2D original_texture;

void fragment() {
	vec2 texture_multiplier = 1.0 / TEXTURE_PIXEL_SIZE;
	texture_multiplier = normalize(texture_multiplier);
	
	float luminosity = dot(COLOR.rgb, vec3(0.21, 0.72, 0.07));
	
	luminosity = round(luminosity * float(color_count - 1)) / float(color_count - 1);
	
	int color_id = int(luminosity * float(color_count - 1) + .5);
	luminosity = 1.0;
	
	vec2 uv = UV;
	uv *= texture_multiplier;
	
	for (int i = color_id; i < color_count - 1; i++)
	{
		float rot = rotation + sin(float(i * 4)); 
		
		float x = uv.x * rot + uv.y * (1.0 - abs(rot));
		
		float multiplier = 1.0;
		
		if (abs(rot) < .5)
		{
			float temp_rotation = abs(rot) * 2.0;
			
			multiplier = 1.0 * (1.0 - temp_rotation) + sqrt(2.0) * temp_rotation;
		}
		else
		{
			float temp_rotation = abs(rot) * 2.0 - 1.0;
			
			multiplier = sqrt(2.0) * (1.0 - temp_rotation) + 1.0 * temp_rotation;
		}
		
		float freq = frequency;
		freq *= multiplier;
		
		float _frequency = 200.0 * freq;
		
		//make the line thinner for extra lines (the lower the i the darker the area)
		//float _thickness = thickness * ((float(i) / float(color_count)) / 2.0 + .5);
		float _thickness = thickness;
		
		float greyness = sin(x * _frequency) - 1.0 + _thickness * 3.0;
		
		if (greyness > .0)
		{
			luminosity *= 1.0 - greyness;
			if (luminosity < max_blacknesss) {
				luminosity = max_blacknesss;
				break;
			}
		}
	}
	
	vec3[4] colors;
	int[4] total_counts;
	float[4] differences;
	
	for (int x = -kuwahara_sample_count; x < kuwahara_sample_count; x++)
	{
		for (int y = -kuwahara_sample_count; y < kuwahara_sample_count; y++)
		{
			vec2 position = UV;
			
			position.x += float(x) * kuwahara_sample_size / float(kuwahara_sample_count);
			position.y += float(y) * kuwahara_sample_size / float(kuwahara_sample_count);
			
			if ((position.x < .0 || position.x > 1.0) || (position.y < .0 || position.y > 1.0))
			{
				continue;
			}
			
			vec3 color = texture(original_texture, position).rgb;
			
			int index = 0;
			
			if (x > 0)
			{
				index += 1;
			}
			if (y > 0)
			{
				index += 2;
			}
			
			colors[index] += color;
			total_counts[index] += 1;
		}
	}
	
	float lowest_difference = 3.0;
	int lowest_index = 0;
	
	for (int index = 0; index < 4; index++)
	{
		colors[index] /= float(total_counts[index]);
		
		vec3 color_difference = COLOR.rgb - colors[index];
		differences[index] = abs(color_difference.r) + abs(color_difference.g) + abs(color_difference.b);
		
		if (differences[index] < lowest_difference){
			lowest_difference = differences[index];
			lowest_index = index;
		}
	}
	
	if (total_counts[lowest_index] > 0)
	{
		COLOR.rgb = colors[lowest_index];
	}
	
	
	if (total_counts[lowest_index] == 0)
	{
		COLOR.rgb = vec3(.2, .4, .6);
	}
	
	/*
	COLOR.r = luminosity * luminosity_factor + COLOR.r * (1.0 - luminosity_factor);
	COLOR.g = luminosity * luminosity_factor + COLOR.g * (1.0 - luminosity_factor);
	COLOR.b = luminosity * luminosity_factor + COLOR.b * (1.0 - luminosity_factor);
	
	COLOR.rgb *= vec3(luminosity);*/
	
	//COLOR *= texture(noise_texture, UV);
}

vec3 srgb_to_oklab(vec3 color)
{
	return vec3(1.0);
}

float srgb_to_lightness(vec3 color)
{
	float maxRGB = .0;
	float minRGB = 1.0;
	
	for (int i = 0; i < 3; i++)
	{
		if (color[i] > maxRGB)
		{
			maxRGB = color[i];
		}
		
		if (color[i] < minRGB)
		{
			minRGB = color[i];
		}
	}
	
	float lightness = (maxRGB + minRGB) / 2.0;
	
	return lightness;
}