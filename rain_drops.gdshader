shader_type canvas_item;

uniform float drop_count: hint_range(1.0, 128.0, 1.0) = 16.0;
uniform float ripple_speed: hint_range(0.0, 2.0, 0.01) = 0.4;
uniform float ripple_max_radius: hint_range(0.01, 1.0, 0.01) = 0.35;
uniform float ripple_strength: hint_range(0.01, 1.0, 0.01) = 0.1;
uniform float ring_count: hint_range(1.0, 10.0, 1.0) = 3.0;
uniform float fade_power: hint_range(0.1, 5.0, 0.01) = 2.0;
uniform vec4 ripple_color: source_color = vec4(0.55, 0.78, 1.0, 0.18);
uniform float shimmer_intensity: hint_range(0.0, 1.0, 0.01) = 0.5;

// Gives us a reasonable distribution of falling drops.
float hash12(vec2 x) {
	return fract(sin(dot(x, vec2(127.1, 311.7))) * 43758.5453);
}


void eval_drop(float id, vec2 uv, vec2 resolution, float time, out vec2 disp, out float shimmer) {
	disp = vec2(0.0);
	shimmer = 0.0;
	vec2 seed = vec2(id * 0.37 + 1.3, id * 0.71 + 0.9);
	// Random period to avoid synchronocity with other droplets.
	float period = mix(2.2, 5.5, hash12(seed + vec2(0.1, 0.0)));
	// Random start offset of the animation.
	float phase = hash12(seed + vec2(0.0, 0.3)) * period;
	
	float age = fract((time + phase) / period);
	float radius = age * ripple_max_radius;
	vec2 center = vec2(0.5);
	vec2 delta = uv - center;
	delta.x *= resolution.x / resolution.y;
	float dist = length(delta);
	vec2 dir = dist > 0.0001 ? normalize(delta) : vec2(1.0, 0.0);
	float life = 1.0 - smoothstep(0.6, 1.0, age);
	float wave_arg = (dist / max(radius, 0.0001) - 1.0) * ring_count * TAU;
	float wave = sin(wave_arg);
	float env = exp(-pow(max(dist - radius * 0.15, 0.0) / (ripple_max_radius * 0.18), fade_power)) * exp(-pow(max(radius - dist, 0.0) / (ripple_max_radius * 0.25), fade_power));
	float mask = step(dist, radius + ripple_max_radius * 0.1);
	float contribution = wave * env * mask * life;
	disp = dir * contribution * ripple_strength;
	shimmer = contribution * shimmer_intensity;
}


void fragment() {
	vec2 uv = UV;
	vec2 resolution = 1.0 / TEXTURE_PIXEL_SIZE;
	float time = TIME * ripple_speed;
	// Handles displacement.
	vec2 total_disp = vec2(0.0);
	float total_shimmer = 0.0;
	
	for (float i = 0.0; i < drop_count; i++) {
		vec2 d;
		float s;
		eval_drop(i, uv, resolution, time, d, s);
		total_disp += d;
		total_shimmer += s;
	}
	
	vec2 sample_uv = clamp(uv + total_disp, vec2(0.0), vec2(1.0));
	vec4 base = texture(TEXTURE, sample_uv);
	float shimmer_clamped = clamp(total_shimmer, -1.0, 1.0);
	vec3 highlight = ripple_color.rgb * ripple_color.a * max(shimmer_clamped, 0.0);
	COLOR = vec4(base.rgb + highlight, base.a);
}
