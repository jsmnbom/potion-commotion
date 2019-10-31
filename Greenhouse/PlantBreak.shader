shader_type particles;

uniform sampler2D plant_texture;

float fake_random(vec2 p){
	return fract(sin(dot(p.xy, vec2(12.9898,78.233))) * 43758.5453);
}

void vertex() {
  if (RESTART) {
	vec2 plant_uv = vec2(float(INDEX % 16)*8.0+4.0, float(int(INDEX/16))*8.0+4.0);
	vec2 pos = vec2(-64.0+4.0, -192.0+4.0) + plant_uv;
	vec2 atlas_uv = plant_uv + vec2(128.0*4.0, 0.0);
	if (texture(plant_texture, atlas_uv / vec2(640.0, 512.0)).a > 0.1) {
		ACTIVE = true;
		COLOR = texture(plant_texture, atlas_uv / vec2(640.0, 512.0));
		TRANSFORM[3] = EMISSION_TRANSFORM[3] + vec4(pos.x, pos.y, 0.0, 0.0);
		VELOCITY.y = (fake_random(vec2(float(INDEX), 0.0))) * -50.0;
		VELOCITY.x = (fake_random(vec2(float(INDEX), 1.0)) - 0.5) * 50.0;
	} else {
		ACTIVE = false;
	}
  } else {
	vec2 pos = TRANSFORM[3].xy; 
	if (pos.y > 80.0) {
		ACTIVE = false;
	} else if (pos.y > 48.0) {
		COLOR.a = 1.0 - (pos.y - 48.0) / 32.0
	} else {
    	VELOCITY.y += 4.0
	}
  }
}
