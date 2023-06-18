shader_type canvas_item;

float v2min(vec2 vec) { return min(vec.x, vec.y); }
float v2max(vec2 vec) { return max(vec.x, vec.y); }

void vertex() {
	if (UV.y > 0.5) {
		mat4 to_screen = SCREEN_MATRIX * CANVAS_MATRIX * MODEL_MATRIX;
		// Vertex position in screen coordinates
		vec2 vertex = (to_screen * vec4(VERTEX, 0.0, 1.0)).xy;
		vec2 org_pos = (to_screen * vec4(vec3(0.0), 1.0)).xy;
		// Extend direction
		vec2 direction = (to_screen * vec4(0.0, 1.0 / TEXTURE_PIXEL_SIZE.y, 0.0, 1.0)).xy - org_pos;
		vec2 x_direction = (to_screen * vec4(1.0 / TEXTURE_PIXEL_SIZE.x, 0.0, 0.0, 1.0)).xy - org_pos;
		// Image size in screen coordinates
		vec2 image_size = vec2(length(x_direction), length(direction));
		direction = normalize(direction);
		
		vec2 target_edges = sign(direction);
		vec2 lens = (vertex - target_edges) / -direction;
//		float len = v2min(lens) - image_size.x;
		float len = v2min(lens) > 0.0 ? v2min(lens) : v2max(lens);
		len = max(len, 0.0) + image_size.x * 0.5;
		vec2 target = vertex + direction * len;
		VERTEX = (inverse(to_screen) * vec4(target, 0.0, 1.0)).xy;
		UV = UV + vec2(0.0, len) / image_size.y;
	}
//	mat4 trans = CANVAS_MATRIX * MODEL_MATRIX;
//	UV = (trans * vec4(VERTEX, 0.0, 1.0)).xy / 100.0;
//	UV = VERTEX;
}
