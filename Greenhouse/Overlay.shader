shader_type canvas_item;

uniform sampler2D noise;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (UV.y < 0.05 || UV.y > 0.95 || (FRAGCOORD.x < 200.0 && UV.x < 0.05) || (FRAGCOORD.x > 1150.0 && UV.x > 0.95)) {
		if (texture(noise, UV).r > 0.5) {
			COLOR.a = 0.0;
		}
	}
}