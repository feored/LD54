shader_type canvas_item;

uniform bool active;
uniform float start_time = 0;
uniform float speed = 3;

void fragment() {
	vec4 base_color = texture(TEXTURE, UV);
	if (active && base_color.a > 0.0){
		float avg_color = (base_color.r + base_color.g + base_color.b) / 3.0;
		float time_add = sin((TIME - start_time)*speed);
		if (time_add > 0.0){
			COLOR = base_color + time_add;
		}
		
	}
	
}
