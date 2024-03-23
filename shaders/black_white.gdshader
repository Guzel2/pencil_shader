shader_type canvas_item;

uniform int color_count : hint_range(0, 256, 1);

uniform float rotation : hint_range(-1.0, 1.0, .001);
uniform float thickness : hint_range(0.0, 1.0, .0001);
uniform float frequency : hint_range(0.0, 20.0, .0001);
uniform float max_blacknesss : hint_range(0.0, 1.0, .0001);
uniform float paper_stength : hint_range(0.0, 20.0, .0001);

uniform float line_strength : hint_range(0.0, 1.0, .0001);
uniform float brightness : hint_range(0.0, 20.0, .0001);
uniform float contrast : hint_range(0.0, 20.0, .0001);
uniform float saturation : hint_range(0.0, 20.0, .0001);

uniform sampler2D paper_texture;

float add_line_effect(vec3 color, vec2 uv)
{
	float luminosity = dot(color.rgb, vec3(0.21, 0.72, 0.07));
	
	luminosity = round(luminosity * float(color_count - 1)) / float(color_count - 1);
	
	int color_id = int(luminosity * float(color_count - 1) + .5);
	float pencil_color = 1.0;
	
	for (int i = color_id; i < color_count - 1; i++)
	{
		float rot = rotation + sin(float(i * 4)); 
		
		float x = uv.x * rot + uv.y * (1.0 - abs(rot));
		float y = uv.y * rot - uv.x * (1.0 - abs(rot));
		
		float frequency_multiplier = 1.0;
		
		if (abs(rot) < .5)
		{
			float temp_rotation = abs(rot) * 2.0;
			
			frequency_multiplier = 1.0 * (1.0 - temp_rotation) + sqrt(2.0) * temp_rotation;
		}
		else
		{
			float temp_rotation = abs(rot) * 2.0 - 1.0;
			
			frequency_multiplier = sqrt(2.0) * (1.0 - temp_rotation) + 1.0 * temp_rotation;
		}
		
		float _frequency = 200.0 * frequency * frequency_multiplier;
		
		float greyness = sin(x * _frequency) - 1.0 + thickness * 3.0;
		
		
		if (greyness > .0)
		{
			pencil_color *= 1.0 - greyness;
			if (pencil_color < max_blacknesss) {
				pencil_color = max_blacknesss;
				break;
			}
		}
	}
	
	return pencil_color;
}

vec3 srgb_to_oklab(vec3 color)
{
	return vec3(1.0);
}

void fragment() {
	vec2 texture_multiplier = 1.0 / TEXTURE_PIXEL_SIZE;
	texture_multiplier = normalize(texture_multiplier);
	
	vec2 uv = UV;
	uv *= texture_multiplier;
	
	vec4 paper_color = texture(paper_texture, UV);
	float pencil_color = add_line_effect(COLOR.rgb, uv);
	
	
	paper_color.r = pow(paper_color.r, paper_stength);
	paper_color.g = pow(paper_color.g, paper_stength);
	paper_color.b = pow(paper_color.b, paper_stength);
	
	COLOR.rgb = mix(vec3(0.0), COLOR.rgb, brightness);
	COLOR.rgb = mix(vec3(0.5), COLOR.rgb, contrast);
	COLOR.rgb = mix(vec3(dot(vec3(1.0), COLOR.rgb) * 0.33333), COLOR.rgb, saturation);
	COLOR = vec4(pencil_color) * line_strength + COLOR * (1.0 - line_strength);
	COLOR *= paper_color;
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