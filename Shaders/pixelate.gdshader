shader_type canvas_item;

uniform vec2 size = vec2(128.0, 112.0);
uniform float subdivide;
// If you intend to read from mipmaps with `textureLod()` LOD values greater than `0.0`,
// use `filter_nearest_mipmap` instead. This shader doesn't require it.
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
		//vec2 resolution = textureSize(screen_texture);
        //vec2 norm_size = 1.0 / SCREEN_PIXEL_SIZE / subdivide;
		vec2 norm_size = SCREEN_PIXEL_SIZE * subdivide;
        vec2 uv = SCREEN_UV + vec2(norm_size.x, 0.0);
        vec2 center_uv = floor(uv / norm_size) * norm_size;
        COLOR = textureLod(screen_texture, center_uv, 0.0);
}