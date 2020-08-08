shader_type canvas_item;

uniform float alpha = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec4 screen = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
	if (tex.a > 0.9) {
		COLOR = mix(tex, screen, 1.0-alpha);
	} else {
		COLOR = vec4(0.0);
	}
}