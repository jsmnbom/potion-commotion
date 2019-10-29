shader_type canvas_item;

uniform float frequency = 60;
uniform float depth = 0.005;
uniform sampler2D mask_texture;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 c;
	if (texture(mask_texture,UV).a > 0.0) {
		uv.x += sin(uv.y*frequency+TIME)*depth;
		uv.x = clamp(uv.x,0,1);
		c = textureLod(SCREEN_TEXTURE,uv,0.0).rgba;
	} else {
		c = textureLod(SCREEN_TEXTURE,uv,0.0).rgba;
	}
	
	COLOR.rgba=c;
}
