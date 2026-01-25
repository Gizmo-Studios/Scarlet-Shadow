shader_type canvas_item;
render_mode unshaded;

uniform vec4 color: source_color;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 pixelColor = texture(screen_texture,SCREEN_UV);
	float brightness = (pixelColor.r+pixelColor.g+pixelColor.b)/3.0;
	vec4 grayScale = vec4(pixelColor.r,pixelColor.r,pixelColor.r,pixelColor.a);
	COLOR = grayScale * color;
	// Called for every pixel the material is visible on.
}
