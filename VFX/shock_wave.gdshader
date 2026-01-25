shader_type canvas_item;
render_mode unshaded;

uniform vec2 center;
uniform float force;
uniform float size;
uniform float opacity;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float unique_id;

void fragment() {
    // Unique mask based on the instance ID
    float instance_mask = fract(unique_id * 0.61803398875); // Golden ratio for uniqueness

    // Use the unique mask to create a blend factor
    float blend = step(0.5, instance_mask); // Toggle between 0 and 1

    // Adjust UVs based on the unique blend
    float ratio = 1.0;
    vec2 scaledUV = (UV - vec2(0.5, 0.0)) / vec2(ratio, 1.0) + vec2(0.5, 0.0);
    float mask2 = (1.0 - smoothstep(0.5 - 0.3, 0.5, length(scaledUV - center)));
    float mask = (1.0 - smoothstep(size - 0.05, size, length(scaledUV - center))) *
                 smoothstep(size - 0.05, size - 0.025, length(scaledUV - center)) * mask2;

    // Apply displacement based on the blend
    vec2 disp = normalize(scaledUV - center) * force * mask * blend;

    // Sample screen texture with displacement
    COLOR = texture(screen_texture, SCREEN_UV - disp) * vec4(1.0, 1.0, 1.0, opacity);
}
