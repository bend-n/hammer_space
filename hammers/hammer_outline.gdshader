/* 
Rainbow outline by @Farfalk and @ThePadDev, July 2021

Apply to canvas items with transparent backgrounds.
Check that there is sufficient transparent background space for the outline!

CC0 License (but citation is welcome <3)
*/

shader_type canvas_item;

uniform float line_width : hint_range(0, 20) = 1.0;    // thickness of the line
uniform float sin_frequency : hint_range(0.1, 2.0) = 0.25;  // frequency of the rainbow
uniform float light_offset : hint_range(0.0, 1.0) = 1.0;   // this offsets all color channels; if set to 0 only red green and blue colors will be shown.

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * line_width;
	
	float outline = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
	outline = min(outline, 1.0);
	
	vec4 animated_line_color = vec4(light_offset + sin(2.0*3.14*sin_frequency*TIME),
							   light_offset + sin(2.0*3.14*sin_frequency*TIME + radians(120.0)),
							   light_offset + sin(2.0*3.14*sin_frequency*TIME + radians(240.0)),
							   1.0);
	
	vec4 color = texture(TEXTURE, UV);
	COLOR = mix(color, animated_line_color, outline - color.a);
}