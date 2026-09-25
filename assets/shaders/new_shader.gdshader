shader_type sky;

uniform sampler2D panorama_a : source_color, filter_linear;
uniform sampler2D panorama_b : source_color, filter_linear;
uniform float speed_a : hint_range(-1.0, 1.0) = 0.02;
uniform float speed_b : hint_range(-1.0, 1.0) = -0.02;
uniform float blend_b : hint_range(0.0, 1.0) = 0.5;

vec3 rotate_y(vec3 v, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return vec3(c * v.x + s * v.z, v.y, -s * v.x + c * v.z);
}

vec2 panorama_uv(vec3 dir) {
    float phi = atan(dir.z, dir.x);
    float theta = acos(dir.y);
    return vec2(phi / (2.0 * PI) + 0.5, theta / PI);
}

void sky() {
    vec3 dir_a = rotate_y(EYEDIR, TIME * speed_a);
    vec3 dir_b = rotate_y(EYEDIR, TIME * speed_b);

    vec3 col_a = texture(panorama_a, panorama_uv(dir_a)).rgb;
    vec3 col_b = texture(panorama_b, panorama_uv(dir_b)).rgb;

    COLOR = mix(col_a, col_b, blend_b);
}