shader_type canvas_item;

uniform float wind_strength = 10.0; // Maximum horizontal offset in pixels
uniform float frequency = 10.0;     // Controls the wave’s spatial frequency
uniform float time_scale = 1.0;     // Speed of the wind animation

varying vec2 v_uv;

void vertex() {
    // Pass along the original UV coordinates
    v_uv = UV;

    // Only modify the lower half (UV.y > 0.5)
    if (v_uv.y > 0.7) {
        // 'factor' increases linearly from 0 at the midline to 1 at the bottom
        float factor = (v_uv.y - 0.7) * 2.0;
        // Compute a sine-based horizontal offset.
        // The sine wave creates a natural oscillation and is modulated by time.
        float offset = sin(v_uv.x * frequency + TIME * time_scale) * wind_strength * factor;
        VERTEX.x += offset;
    }
}

void fragment() {
    // Sample the texture using the original UV coordinates for proper mapping
    COLOR = texture(TEXTURE, v_uv);
}