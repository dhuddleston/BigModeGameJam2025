shader_type canvas_item;

uniform vec3[16] pallate : source_color;
uniform float subdivide;
uniform sampler2D dither_tex: filter_nearest, repeat_enable;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap_anisotropic;

vec3 ditherColor(vec3 c1, vec3 c2, float ratio, vec2 pixel)
{ 
	vec2 tex_size = vec2(textureSize(dither_tex, 0)) * subdivide;
	vec2 screen_size = vec2(textureSize(SCREEN_TEXTURE, 0));
   	float dith = texture(dither_tex, pixel*(screen_size/tex_size)).r;
   	float mixAmt = float(ratio > dith);
    
	return mix(c1,c2,mixAmt);
}

void fragment() {
	vec2 norm_size = SCREEN_PIXEL_SIZE * subdivide;
    vec2 uv = SCREEN_UV;
    vec2 center_uv = floor(uv / norm_size) * norm_size;
    vec4 avg = textureLod(SCREEN_TEXTURE, center_uv, 0.0);
	vec3 color_mix = avg.rgb;

	// Initialize the closest color and its distance to a very high value.
	vec3 closest_color = vec3(0.0);
	float closest_distance = 1000.0;
	vec3 second_color = vec3(0.0);
	float second_distance = 1000.0;
	// Loop through each color in the palette.
	for (int i = 0; i < pallate.length(); i++) {
		// Calculate the distance between the current color and the input color.
		float distance = distance(color_mix, pallate[i]);

		// If this color is closer than the current closest color, update the closest color and its distance.
		if (distance < closest_distance) {
			//Shift our current closest into second place
			second_color = closest_color;
			second_distance = closest_distance;
			//Update the closest
			closest_color = pallate[i];
			closest_distance = distance;
		}
		else if (distance < second_distance) {
			second_color = pallate[i];
			second_distance = distance;
		}
	}
	float lerpfrac = closest_distance / (closest_distance + second_distance);
	closest_color = ditherColor(closest_color, second_color, lerpfrac, SCREEN_UV);

	// Set the final color to the closest color in the palette.
	COLOR = vec4(closest_color.r, closest_color.g, closest_color.b, 1.0);
}