shader_type canvas_item;

render_mode unshaded;

uniform vec2 center;
uniform float force;
uniform float size;
uniform float opacity;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
void fragment() {
	float ratio = 1.0; //SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec2 scaledUV  = (UV - vec2(.5,.0))/vec2(ratio,1.0) + vec2(.5,.0);
	float mask2 =  (1.0- smoothstep(0.5 - 0.3, 0.5 , length(scaledUV - center)));
	float mask =  (1.0- smoothstep(size - 0.05, size , length(scaledUV - center))
	)*
	smoothstep(size - 0.05, size -0.025 , length(scaledUV - center)) * mask2;

	vec2 disp = normalize(scaledUV - center) * force * mask;
	COLOR = texture(screen_texture, SCREEN_UV - disp);

	//COLOR.rgb = vec3(mask2);
}
