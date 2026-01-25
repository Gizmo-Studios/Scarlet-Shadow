shader_type canvas_item;
uniform float speed = 2.0;
uniform float dis = 20.0;

void vertex() {
	// Called for every vertex the material is visible on.
	 VERTEX.x +=sin(TIME*speed)* dis* (UV.y - 1.0);

}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
