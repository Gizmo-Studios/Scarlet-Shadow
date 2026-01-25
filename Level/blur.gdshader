shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur_size : hint_range(0.0, 10.0) = 2.0;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 sum = vec4(0.0);

    // Define blur weights and offsets
    float offsets[5] = float[]( -2.0, -1.0, 0.0, 1.0, 2.0 );
    float weights[5] = float[]( 0.1, 0.2, 0.4, 0.2, 0.1 );

    // Apply horizontal and vertical blur
    for (int i = 0; i < 5; i++) {
        sum += texture(screen_texture, uv + vec2(offsets[i] * blur_size / 500.0, 0.0)) * weights[i];
        sum += texture(screen_texture, uv + vec2(0.0, offsets[i] * blur_size / 500.0)) * weights[i];
    }

    // Output blurred color
    COLOR = sum / 2.0;
}
