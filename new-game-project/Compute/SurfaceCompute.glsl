#[compute]
#version 450

layout(local_size_x = 32, local_size_y = 32, local_size_z = 1) in;

layout(r16f, set = 0, binding = 0) uniform image2D height_map;

float UV_POSITION_SCALE = 20.0;
//
layout(push_constant, std430) uniform Params {
    vec2 texture_size;
    float seed;
    float time;
	float scale;
} params;


// Fast Hash Function for Gradient Selection
vec2 hash2(vec2 p, float seed) {
    p = vec2(dot(p, vec2(127.13, 311.7)), dot(p, vec2(269.5, 183.3))) + seed;
    return fract(sin(p) * 43758.5453) * 2.0 - 1.0;
}

float mix_alt(float a, float b, float t) {
    return a + t * (b - a);
}


// Quintic Smootherstep
vec2 fade(vec2 t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

// Bilinear interpolation function without mix
float bilinearInterpolation(float p00, float p10, float p01, float p11, vec2 uv) {
    float i0 = p00 * (1.0 - uv.x) + p10 * uv.x;
    float i1 = p01 * (1.0 - uv.x) + p11 * uv.x;
    return i0 * (1.0 - uv.y) + i1 * uv.y;
}


// 2D Perlin Noise Function
float perlin(vec2 p, float seed) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    // Gradient vectors at the four corners
    vec2 g00 = hash2(i + vec2(0.0, 0.0), seed);
    vec2 g10 = hash2(i + vec2(1.0, 0.0), seed);
    vec2 g01 = hash2(i + vec2(0.0, 1.0), seed);
    vec2 g11 = hash2(i + vec2(1.0, 1.0), seed);

    // Distance vectors from grid points
    vec2 d00 = f - vec2(0.0, 0.0);
    vec2 d10 = f - vec2(1.0, 0.0);
    vec2 d01 = f - vec2(0.0, 1.0);
    vec2 d11 = f - vec2(1.0, 1.0);

    // Dot product of gradient and distance vectors
    float v00 = dot(g00, d00);
    float v10 = dot(g10, d10);
    float v01 = dot(g01, d01);
    float v11 = dot(g11, d11);

    // Smooth interpolation using quintic polynomial
    vec2 u = fade(f);
	//vec2 u = f;
    
    // Bilinear interpolation
    //return mix_alt(mix_alt(v00, v10, u.x), mix_alt(v01, v11, u.x), u.y);
	return bilinearInterpolation(v00, v01, v10, v11, u);
}

// 2D Domain Warped Perlin Noise
float perlinDomainWarp(vec2 p, float seed) {
    // Compute a base Perlin noise value to warp the domain
    vec2 warp = vec2(perlin(p * 0.5, seed + 12.3), perlin(p * 0.5, seed - 12.3)) * 5.05;
    
    // Strength of warping effect (adjustable)
    float warpStrength = 1.5;
    p += warp * warpStrength;

    // Compute final Perlin noise with warped coordinates
    return perlin(p, seed);
}


void main() {
    // Scale UV coordinates
    vec2 uv = (gl_GlobalInvocationID.xy / (params.texture_size)) * UV_POSITION_SCALE + vec2(params.time, 0.1113);
	
    // Generate height map using Perlin noise

    //float height = perlinDomainWarp(uv,  params.seed) * params.scale;
	float height = sin(uv.x * 10.0f) * params.scale * sin(params.time + uv.y * 3.0f);
    imageStore(height_map, ivec2(gl_GlobalInvocationID.xy), vec4(height, 0.0, 0.0, 1.0));
}
