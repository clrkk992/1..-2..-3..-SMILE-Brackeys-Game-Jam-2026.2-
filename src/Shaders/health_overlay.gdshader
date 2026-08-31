shader_type canvas_item;

// Grabs the screen texture beneath the ColorRect
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// Controls how intense the red overlay is (Animate this via code/AnimationPlayer!)
uniform float damage_intensity : hint_range(0.0, 1.0) = 0.5;

uniform vec4 flash_color : source_color = vec4(0.8, 0.0, 0.0, 1.0); // Deep crimson red
uniform float vignette_softness : hint_range(0.1, 5.0) = 1.5;
uniform float pulse_speed : hint_range(0.0, 20.0) = 4.0;

void fragment() {
	// 1. Sample the clean game world color underneath
	vec3 base_color = texture(screen_texture, SCREEN_UV).rgb;

	// 2. Calculate a classic vignette mask (0.0 at center, 1.0 at screen corners)
	vec2 uv = SCREEN_UV * (1.0 - SCREEN_UV.yx);
	float vignette = uv.x * uv.y * 15.0;
	// Invert it so the edges are high strength (1.0) and center is low strength (0.0)
	float edge_mask = 1.0 - clamp(pow(vignette, 1.0 / vignette_softness), 0.0, 1.0);

	// 3. Add a slight heartbeat pulse effect to the edges over time
	float pulse = 1.0 + (sin(TIME * pulse_speed) * 0.15);
	float final_mask = clamp(edge_mask * pulse, 0.0, 1.0);

	// 4. Mix a low-intensity global tint with the heavy edge vignette
	float total_damage_factor = mix(0.15, 1.0, final_mask) * damage_intensity;

	// 5. Blend the background game with our damage color
	vec3 final_color = mix(base_color, flash_color.rgb, total_damage_factor);

	COLOR = vec4(final_color, 1.0);
}