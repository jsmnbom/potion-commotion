shader_type canvas_item;

uniform sampler2D mask_texture;

vec2 rotateUV(vec2 uv, vec2 pivot, float rotation) {
    float cosa = cos(rotation);
    float sina = sin(rotation);
    uv -= pivot;
    return vec2(
        cosa * uv.x - sina * uv.y,
        cosa * uv.y + sina * uv.x 
    ) + pivot;
}

void fragment() {
	vec4 c = texture(TEXTURE, rotateUV(UV, vec2(0.5), -mod(TIME, 6.283185)));
	c.a *= texture(mask_texture, UV).a;
	
	COLOR.rgba=c;
}
