shader_type canvas_item;

// Controls the eye opening (0.0 = completely closed, 1.0 = wide open)
uniform float blink_progress : hint_range(0.0, 1.0) = 1.0;
// Controls how curved/round the eyelids look (0.0 = flat bar, higher = rounder eye)
uniform float eye_roundness : hint_range(0.0, 2.0) = 0.5;
// Smoothness of the eyelid edges
uniform float smoothness : hint_range(0.0, 0.1) = 0.005;
// Color of the eyelids/outer screen
uniform vec4 blink_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    // 1. Center the UV coordinates vertically and horizontally (-0.5 to 0.5)
    vec2 uv = UV - vec2(0.5);
    
    // 2. Calculate the shape of the eye opening using a parabolic curve
    // The curve dips further down/up as it moves away from the horizontal center (uv.x)
    float horizontal_taper = 1.0 - (uv.x * uv.x * eye_roundness);
    
    // 3. Define the current opening threshold based on progress and taper shape
    float eye_opening = blink_progress * 0.5 * horizontal_taper;
    
    // 4. Measure the vertical distance from the center line
    float vertical_dist = abs(uv.y);
    
    // 5. Create a sharp or smooth mask boundary for the upper/lower eyelids
    float mask = smoothstep(eye_opening - smoothness, eye_opening, vertical_dist);
    
    // 6. Output the blink color outside the eye shape, keeping the inside clear
    COLOR = vec4(blink_color.rgb, mask * blink_color.a);
}