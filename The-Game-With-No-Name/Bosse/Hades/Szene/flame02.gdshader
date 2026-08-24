shader_type canvas_item;

uniform float speed = 2.5;
uniform float strength = 1.0;

void fragment() {
	vec2 uv = UV;

	float wave =
		sin(uv.y * 14.0 - TIME * speed * 5.0) * 0.6 +
		sin(uv.y * 7.0 + TIME * speed * 3.0) * 0.4;

	wave *= (1.0 - uv.y);

	uv.x += wave * strength * TEXTURE_PIXEL_SIZE.x;

	// Pixelperfektes Sampling
	uv = (floor(uv / TEXTURE_PIXEL_SIZE + 0.5)) * TEXTURE_PIXEL_SIZE;

	vec4 color = texture(TEXTURE, uv);

	float flicker =
		0.98 +
		0.02 * sin(TIME * 11.0) +
		0.015 * sin(TIME * 17.0);

	COLOR = color * flicker;
}
