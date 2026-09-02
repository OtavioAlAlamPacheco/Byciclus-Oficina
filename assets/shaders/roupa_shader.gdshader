
shader_type spatial;
render_mode cull_disabled;

uniform sampler2D mask_roupa : hint_default_black;
uniform sampler2D textura_roupa : source_color;

void fragment() {
	vec4 cor_renderizada = texture(textura_roupa, UV);
	float m_roupa = texture(mask_roupa, UV).r;
		
	ALBEDO = cor_renderizada.rgb;
		
	ALPHA = m_roupa * cor_renderizada.a;
		
	ALPHA_SCISSOR_THRESHOLD = 0.5;
		
	ROUGHNESS = 0.9;
	SPECULAR = 0.1;
}
