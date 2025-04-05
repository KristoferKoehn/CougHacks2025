shader_type spatial;

uniform sampler2D noise_rocks;
uniform sampler2D noise_tex;

uniform float cut_factor;
uniform float border;

uniform float cut_factor_rock;
uniform float border_rock;

uniform float texture1scale;
uniform float texture2scale;
uniform float texturerocksscale;
uniform float texture2height;

uniform sampler2D albedo1;
uniform sampler2D normal1;
uniform sampler2D rough1;

uniform sampler2D albedo2;
uniform sampler2D normal2;
uniform sampler2D rough2;

uniform sampler2D albedo3;
uniform sampler2D normal3;
uniform sampler2D rough3;

void fragment() {
	vec2 uv1 = UV*texture1scale;
	vec2 uv2 = UV*texture2scale;
	vec2 uvrocks = UV*texturerocksscale;

	float noise = texture(noise_tex,UV+NODE_POSITION_WORLD.xz).r;
	noise = smoothstep(cut_factor,cut_factor+border,noise);

	float rocknoise = texture(noise_rocks,UV+NODE_POSITION_WORLD.xz).r;
	rocknoise = smoothstep(cut_factor_rock,cut_factor_rock+border_rock,rocknoise);

	vec3 albedo = mix(texture(albedo1,uv1).rgb,texture(albedo2,uv2).rgb,noise);
	vec3 rough = mix(texture(rough1,uv1).rgb,texture(rough2,uv2).rgb,noise);
	vec3 normal = mix(texture(normal1,uv1).rgb,texture(normal2,uv2).rgb,noise);

	albedo = mix(albedo,texture(albedo3,uvrocks).rgb,rocknoise);

	ALBEDO = vec3(albedo);
	NORMAL = normal;
	ROUGHNESS = rough.r;
}

varying vec2 tex_position;

void vertex(){
	float height = texture(noise_tex,UV+NODE_POSITION_WORLD.xz).r;
	height = smoothstep(cut_factor,cut_factor+border,height);

	VERTEX.y += height*texture2height*100.0;
}
