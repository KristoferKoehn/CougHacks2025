shader_type spatial;


uniform sampler2D heightmap : filter_linear;
uniform float PLANE_SIZE = 4000.0;

varying float cull_test;

uniform float _intensity = 1.5;
uniform float _amount = 3.0;

float get_height(vec3 pos, vec3 node_pos) {
	vec2 vec_uv = (pos.xz + vec2((PLANE_SIZE)/2.0)) / (PLANE_SIZE);
	return texture(heightmap, vec_uv).r;
}

vec3 computePlaneNormal(vec3 p1, vec3 p2, vec3 p3) {
    vec3 v1 = p2 - p1;
    vec3 v2 = p3 - p1;
    // Cross product to get the normal
    vec3 normal = normalize(cross(v2, v1));
    return normal;
}

void vertex() {
	VERTEX.y = get_height(VERTEX, NODE_POSITION_WORLD) * 1.0;
	vec3 v2 = VERTEX + vec3(PLANE_SIZE/1024.0, 0, 0);
	vec3 v3 = VERTEX + vec3(0, 0, PLANE_SIZE/1024.0);
	v2.y = get_height(v2, NODE_POSITION_WORLD);
	v3.y = get_height(v3, NODE_POSITION_WORLD);
	NORMAL = computePlaneNormal(VERTEX, v2, v3);
	COLOR = vec4(VERTEX.y);
	cull_test = PLANE_SIZE/2.0 - length(VERTEX);
}

vec3 fresnel_glow(float amount, float intensity, vec3 color, vec3 normal, vec3 view)
{
	return pow((1.0 - dot(normalize(normal), normalize(view))), amount) * color * intensity;
}

void fragment()
{
	vec3 base_color = NORMAL * VIEW * 2.01;
	vec3 fresnel_color = vec3(0.0, 0.7, 0.9);
	//vec3 fresnel = fresnel_glow(4.0, 4.5, fresnel_color, NORMAL, VIEW); <- OG shit
	vec3 fresnel = fresnel_glow(_amount, _intensity, fresnel_color, NORMAL, VIEW);
	ALBEDO = base_color + fresnel;
	ALPHA = clamp(length(fresnel) * clamp(cull_test, 0, 1.0), 0.0, 0.8); //
}