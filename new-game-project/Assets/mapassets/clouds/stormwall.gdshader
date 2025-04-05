shader_type spatial;
render_mode unshaded, cull_back;

uniform float xrot;
uniform float yrot;
uniform float zrot;

uniform sampler2D StormNoise;
uniform float StormSpeed;

uniform sampler2D Clouds;
uniform sampler2D DarkClouds;
uniform float CloudsScale;
uniform float DarkCloudsScale;

uniform float cut_factor;
uniform float border;

void fragment() {
	vec2 uv1 = UV*CloudsScale;
	vec2 uv2 = UV*DarkCloudsScale;
	uv1.y=uv1.y/4.0;
	uv2.y=uv2.y/4.0;

	vec2 funnyuv = UV;
	funnyuv.y=funnyuv.y/4.0;
	float noise = texture(StormNoise,funnyuv+ (TIME * StormSpeed * vec2(1.1,1))).r;
	noise = smoothstep(cut_factor,cut_factor+border,noise);

	vec3 albedo = mix(texture(Clouds,uv1+ (TIME * StormSpeed * vec2(1.1,1))).rgb,texture(DarkClouds,uv2+ (TIME * StormSpeed * vec2(1.0,0.0))).rgb,noise);

	float alphaamount = 1.0;
	if(UV.y<0.1){
		alphaamount=(0.1-pow(((0.1-UV.y)/0.1),2))/0.1;
	}
	if(UV.y>0.9){
		alphaamount=1.0-pow((0.9-UV.y)/0.1,2);
	}

	float alphascale = ((2.0*pow(UV.y-0.5,4))*-8.0)+1.0;
	vec3 colorscale = alphascale*vec3(noise);

	alphaamount-=(1.0-alphascale)*noise;
	alphaamount = clamp(alphaamount,0.0,1.0);

	float lightscale = 1.0*(1.0-UV.y);
	lightscale = clamp(lightscale,0.0,1.0);
	albedo += (1.0-alphascale)*vec3(lightscale,lightscale,lightscale);
	albedo.r = clamp(albedo.r,0.0,1.0);
	albedo.g = clamp(albedo.g,0.0,1.0);
	albedo.b = clamp(albedo.b,0.0,1.0);

	ALPHA = alphaamount;
	ALBEDO = vec3(albedo);
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