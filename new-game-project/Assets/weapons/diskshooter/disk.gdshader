shader_type spatial;

uniform float xrot;
uniform float yrot;
uniform float zrot;

uniform sampler2D noise_tex;

void fragment() {
	vec2 uv = UV;
	float noise = texture(noise_tex,UV+ (TIME * 2.5 * vec2(1.1,1))).r;
	
	ALBEDO = vec3(0.0,0.0,1.0);
	ALBEDO+= vec3(noise*1.0,0.0,0.0);
}

mat3 ProcessRotation(vec3 rot) {
    float phi = rot.x;
    float theta = rot.y;
    float psi = rot.z;
    mat3 PositionalMatrix;

    PositionalMatrix[0][0] = cos(theta)*cos(psi);
    PositionalMatrix[1][0] = cos(phi)*sin(psi) + sin(phi) * sin(theta) * cos(psi);
    PositionalMatrix[2][0] = sin(phi) * sin(psi) - cos(phi)*sin(theta)*cos(psi);
    PositionalMatrix[0][1] = -cos(theta)*sin(psi);
    PositionalMatrix[1][1] = cos(phi)*cos(psi) - sin(phi) * sin(theta) * sin(psi);
    PositionalMatrix[2][1] = sin(phi) * cos(psi) + cos(phi)*sin(theta)*sin(psi);
    PositionalMatrix[0][2] = sin(theta);
    PositionalMatrix[1][2] = -sin(phi)*cos(theta);
    PositionalMatrix[2][2] = cos(phi)*cos(theta);
    return PositionalMatrix;
}
void vertex() {
    VERTEX = VERTEX * ProcessRotation(vec3(2.3 * xrot, 3.1 * TIME * yrot, 1.3 *zrot));
    NORMAL = NORMAL * ProcessRotation(vec3(2.3 * xrot, 3.1 * TIME * yrot, 1.3 *zrot));
}