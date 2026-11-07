shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform vec2 center;
uniform float force; 

void fragment() {
	float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec2 scaledUV = ( SCREEN_UV - vec2(0.5, 0.0) ) / vec2(ratio, 1.0) + vec2(0.5, 0.0);
	
	// Displacement. The direction from the center to the current UV coord 
	vec2 disp = normalize(scaledUV - center) * force;
		
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV - disp);
	
	
	
	// Sets color to that of UV. R/G = UV, B = 0.0, Opacity: 1.0
	//COLOR = vec4(UV, 0.0, 1.0);
	
	// texture returns a color. Change the color to that of the texture. 
	// Positions based on the UV. 
	//COLOR = texture(TEXTURE, UV - vec2(0.5, 0.0));
}