shader_type canvas_item;

uniform vec3[16] pallate : source_color;
uniform float subdivide;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap_anisotropic;


void fragment() {
	vec2 norm_size = SCREEN_PIXEL_SIZE * subdivide;
    vec2 uv = SCREEN_UV + vec2(norm_size.x, 0.0);
    vec2 center_uv = floor(uv / norm_size) * norm_size;
    vec4 avg = textureLod(SCREEN_TEXTURE, center_uv, 0.0);
	vec3 color_mix = avg.rgb;

	// Initialize the closest color and its distance to a very high value.
	vec3 closest_color = vec3(0.0);
	float closest_distance = 1000.0;
	// Loop through each color in the palette.
	for (int i = 0; i < pallate.length(); i++) {
		// Calculate the distance between the current color and the input color.
		float distance = distance(color_mix, pallate[i]);

		// If this color is closer than the current closest color, update the closest color and its distance.
		if (distance < closest_distance) {
			closest_color = pallate[i];
			closest_distance = distance;
		}
	}

	// Set the final color to the closest color in the palette.
	COLOR = vec4(closest_color.r, closest_color.g, closest_color.b, 1.0);
}