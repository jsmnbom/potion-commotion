shader_type canvas_item;

uniform float luck = 0.0;

void fragment() {
	vec4 col = texture(TEXTURE,UV);
	if (UV.y < luck * (-0.85) + 0.85) {
		float grey = (col.r + col.g + col.b) / 3.0;
		COLOR = vec4(grey, grey, grey, col.a);
	} else {
		COLOR = col;
	}
}