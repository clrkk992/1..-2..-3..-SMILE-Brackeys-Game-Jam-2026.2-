shader_type spatial;
render_mode unshaded; // Removes 3D lighting calculations so it behaves like a flat overlay screen

// Grabs the 3D screen texture beneath the MeshInstance3D
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float vignette_intensity : hint_range(0.0, 3.0) = 0.4;
uniform float scanline_count : hint_range(0.0, 1000.0) = 300.0;
uniform float scanline_opacity : hint_range(0.0, 1.0) = 0.15;
uniform float rgb_split : hint_range(0.0, 0.05) = 0.003;
uniform float distortion_amount : hint_range(0.0, 0.2) = 0.03;

uniform vec4 ui_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // White UI elements
uniform bool show_crosshair = true;
uniform float crosshair_size : hint_range(0.0, 0.5) = 0.05;
uniform float line_thickness : hint_range(0.001, 0.01) = 0.002;
uniform bool show_borders = true;
uniform float border_margin : hint_range(0.01, 0.1) = 0.05;
uniform float border_length : hint_range(0.01, 0.2) = 0.08;

// Simulated camera screen curvature math
vec2 curve_screen(vec2 uv) {
	uv = uv * 2.0 - 1.0;
	vec2 offset = abs(uv.yx) * distortion_amount;
	uv = uv + uv * offset * offset;
	uv = uv * 0.5 + 0.5;
	return uv;
}

void fragment() {
	// Apply screen warp/distortion using the 3D screen buffer coordinates
	vec2 uv = curve_screen(SCREEN_UV);

	// Boundary check to clip edges turned inside out by the distortion warp
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		ALBEDO = vec3(0.0, 0.0, 0.0); // Draw solid black borders
		ALPHA = 1.0;
	} else {
		// Chromatic Aberration: sample Red, Green, Blue channels from 3D screen texture
		float r = texture(screen_texture, vec2(uv.x + rgb_split, uv.y)).r;
		float g = texture(screen_texture, uv).g;
		float b = texture(screen_texture, vec2(uv.x - rgb_split, uv.y)).b;
		vec3 base_color = vec3(r, g, b);

		// Scanline Overlay
		float scanline = sin(uv.y * scanline_count + (TIME * 5.0));
		scanline = (scanline + 1.0) * 0.5;
		base_color -= scanline * scanline_opacity;

		// Vignette
		vec2 vignette_uv = uv * (1.0 - uv.yx);
		float vignette = vignette_uv.x * vignette_uv.y * 15.0;
		vignette = clamp(pow(vignette, vignette_intensity), 0.0, 1.0);
		base_color *= vignette;

		// --- MATHEMATICAL UI GENERATION ---
		float ui_mask = 0.0;

		// 1. Center Crosshairs + Dot
		if (show_crosshair) {
			vec2 center_dist = abs(uv - 0.5);

			// Center indicator dot
			if (center_dist.x < 0.004 && center_dist.y < 0.004) {
				ui_mask = 1.0;
			}

			// Horizontal line segments
			if (center_dist.y < line_thickness && center_dist.x > 0.01 && center_dist.x < crosshair_size) {
				ui_mask = 1.0;
			}
			// Vertical line segments
			if (center_dist.x < line_thickness && center_dist.y > 0.01 && center_dist.y < crosshair_size) {
				ui_mask = 1.0;
			}
		}

		// 2. Camera Corner Recording Brackets (Borders)
		if (show_borders) {
			// Find absolute distances from the active canvas edge margins
			float left_edge   = abs(uv.x - border_margin);
			float right_edge  = abs(uv.x - (1.0 - border_margin));
			float top_edge    = abs(uv.y - border_margin);
			float bottom_edge = abs(uv.y - (1.0 - border_margin));

			// Check if we are physically sitting within the boundary bounds
			bool in_x_range = (uv.x >= border_margin && uv.x <= border_margin + border_length) || (uv.x >= 1.0 - border_margin - border_length && uv.x <= 1.0 - border_margin);
			bool in_y_range = (uv.y >= border_margin && uv.y <= border_margin + border_length) || (uv.y >= 1.0 - border_margin - border_length && uv.y <= 1.0 - border_margin);

			// Horizontal lines of the corners
			if ((top_edge < line_thickness || bottom_edge < line_thickness) && in_x_range) {
				ui_mask = 1.0;
			}
			// Vertical lines of the corners
			if ((left_edge < line_thickness || right_edge < line_thickness) && in_y_range) {
				ui_mask = 1.0;
			}
		}

		// Mix the generated overlay color with our background 3D game world color
		vec3 final_color = mix(base_color, ui_color.rgb, ui_mask * ui_color.a);

		// Output to 3D Material Channels
		ALBEDO = final_color;
		ALPHA = 1.0;
	}
}