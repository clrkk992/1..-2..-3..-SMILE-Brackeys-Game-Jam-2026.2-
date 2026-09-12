shader_type canvas_item;

uniform float opacity : hint_range(0.0, 1.0) = 0.15;
uniform float speed : hint_range(1.0, 20.0) = 10.0;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    // Generate noise based on UV and time
    float noise = random(UV * (TIME * speed));
    // Apply noise to color alpha
    COLOR = vec4(vec3(noise), opacity);
}