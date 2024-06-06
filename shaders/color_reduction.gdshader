shader_type canvas_item;

uniform int color_count : hint_range(0, 256, 1) = 4;
uniform int color_offset : hint_range(1, 256, 1) = 4;

uniform float luminosity_threshhold : hint_range(.0, 100.0, .001) = .2;
uniform vec4 dark_color : source_color = vec4(.2);

void fragment()
{
	float luminosity = dot(COLOR.rgb, vec3(0.21, 0.72, 0.07));
	
	vec3 color = COLOR.rgb;
	
	color = round(color * float(color_count - 1)) / float(color_count - 1);
	
	vec3 second_color = COLOR.rgb;
	
	second_color = round(second_color * float(color_count - 1 + color_offset)) / float(color_count - 1 + color_offset);
	
	vec3 test_color = second_color - color;
	
	if (test_color.r + test_color.g + test_color.b > .1)
	{
		//COLOR.rgb = vec3(.0);
	}
	
	if (luminosity < (luminosity_threshhold / 100.0))
	{
		//COLOR.rgb = dark_color.rgb;
	}
	
	
	luminosity = dot(COLOR.rgb, vec3(0.21, 0.72, 0.07));
	
	float second_luminosity = luminosity;
	
	luminosity = round(luminosity * float(color_count - 1)) / float(color_count - 1);
	second_luminosity = round(second_luminosity * float(color_count - 1 + color_offset)) / float(color_count - 1 + color_offset);
	
	if (abs(luminosity - second_luminosity) > (luminosity_threshhold / 100.0))
	{
		COLOR.rgb = dark_color.rgb;
	}
}