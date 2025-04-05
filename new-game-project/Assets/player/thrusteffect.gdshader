shader_type spatial;
render_mode cull_disabled, unshaded;

uniform vec3 thrustcolor;

uniform sampler2D sprite;
uniform sampler2D noise_tex;

uniform float intensity;
uniform float cut_factor;
uniform float border;

void fragment() {
	vec2 mainuv = UV;
	vec2 noiseuv = UV;
	
	float noise = texture(noise_tex,noiseuv+ (TIME * intensity * vec2(0,1))).r;
	noise = smoothstep(cut_factor,cut_factor+border,noise);
	
	vec3 albedo =  texture(sprite,mainuv).rgb;
	ALPHA = texture(sprite,mainuv).a;
	
	if (ALPHA!=0.0){
		albedo = mix(texture(sprite,mainuv).rgb,texture(noise_tex,noiseuv).rgb,noise);
	}
	
	albedo+=thrustcolor;
	albedo.r = clamp(albedo.r,0.0,1.0);
	albedo.g = clamp(albedo.g,0.0,1.0);
	albedo.b = clamp(albedo.b,0.0,1.0);
	
	ALBEDO = albedo;
}

void vertex() {
	VERTEX.y+=intensity*sin(TIME*15.0*intensity)*0.05*VERTEX.y;
}
