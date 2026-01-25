shader_type canvas_item;
uniform vec4 blink_color : source_color;
uniform float blink_intesity = 0;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 color = texture(TEXTURE,UV);
	color = mix(color,blink_color,blink_intesity*color.a);
	COLOR = color;
	// Called for every pixel the material is visible on.
}
