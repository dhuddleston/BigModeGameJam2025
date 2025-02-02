shader_type spatial;
render_mode unshaded;
uniform sampler2D TEXTURE: filter_nearest, repeat_enable;

void fragment() {
    ALBEDO = texture(TEXTURE, UV).rgb;
}