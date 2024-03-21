shader_type canvas_item;

uniform int color_count : hint_range(0, 256, 1);

uniform float rotation : hint_range(-1.0, 1.0, .001);
uniform float thickness : hint_range(0.0, 1.0, .0001);
uniform float frequency : hint_range(0.0, 20.0, .0001);
uniform float max_blacknesss : hint_range(0.0, 1.0, .0001);

uniform float luminosity_factor : hint_range(0.0, 1.0, .0001);

uniform sampler2D noise_texture;

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
	
	COLOR.r = luminosity * luminosity_factor + COLOR.r * (1.0 - luminosity_factor);
	COLOR.g = luminosity * luminosity_factor + COLOR.g * (1.0 - luminosity_factor);
	COLOR.b = luminosity * luminosity_factor + COLOR.b * (1.0 - luminosity_factor);
	
	COLOR.rgb *= vec3(luminosity);
	COLOR *= texture(noise_texture, UV);
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