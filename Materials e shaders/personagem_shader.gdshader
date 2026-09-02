

// uniform sampler2D color_ramp_calca;        similar  ao color_ramp
// uniform vec3 cor_casaco : source_color;    seleciona uma cor diretamente
// float m_casaco = texture(mask_casaco, UV).r;    quando usava o cor_casaco

shader_type spatial;

uniform vec3 cor_pele : source_color;

// uniform sampler2D mask_expressao_facial : hint_default_black;
// uniform sampler2D textura_expressao_facial : source_color;
uniform sampler2D textura_olhos : source_color, hint_default_transparent, repeat_disable;
uniform sampler2D textura_nariz : source_color, hint_default_transparent, repeat_disable;
uniform sampler2D textura_boca : source_color, hint_default_transparent, repeat_disable;
uniform sampler2D textura_detalhe_rosto_1 : source_color, hint_default_transparent, repeat_disable;
uniform sampler2D textura_detalhe_rosto_2 : source_color, hint_default_transparent, repeat_disable;

uniform sampler2D mask_calca : hint_default_black;
uniform sampler2D textura_calca : source_color;

uniform sampler2D mask_camisa : hint_default_black;
uniform sampler2D textura_camisa : source_color;

uniform sampler2D mask_casaco : hint_default_black;
uniform sampler2D textura_casaco : source_color;

uniform sampler2D mask_bota : hint_default_black;
uniform sampler2D textura_bota : source_color;

uniform sampler2D mask_cabelo : hint_default_black;
//uniform sampler2D textura_cabelo : source_color;
uniform vec3 cor_do_cabelo : source_color;


// UV é o uv do Corpo
// UV2 é o uv do Rosto


void fragment() {
	vec3 cor_final = cor_pele;


	vec4 tex_olhos = texture(textura_olhos, UV2);
	cor_final = mix(cor_final, tex_olhos.rgb, tex_olhos.a);

	vec4 tex_nariz = texture(textura_nariz, UV2);
	cor_final = mix(cor_final, tex_nariz.rgb, tex_nariz.a);

	vec4 tex_boca = texture(textura_boca, UV2);
	cor_final = mix(cor_final, tex_boca.rgb, tex_boca.a);

	vec4 tex_detalhe_1 = texture(textura_detalhe_rosto_1, UV);
	cor_final = mix(cor_final, tex_detalhe_1.rgb, tex_detalhe_1.a);

	vec4 tex_detalhe_2 = texture(textura_detalhe_rosto_2, UV);
	cor_final = mix(cor_final, tex_detalhe_2.rgb, tex_detalhe_2.a);


	// float m_expressao = texture(mask_expressao_facial, UV).r;
	// vec3 cor_renderizada_expressao = texture(textura_expressao_facial, UV).rgb;
	// cor_final = mix(cor_final, cor_renderizada_expressao, m_expressao);

	float m_calca = texture(mask_calca, UV).r;
	vec4 cor_renderizada_calca = texture(textura_calca, UV);
	cor_final = mix(cor_final, cor_renderizada_calca.rgb, m_calca * cor_renderizada_calca.a);

	float m_camisa = texture(mask_camisa, UV).r;
	vec4 cor_renderizada_camisa = texture(textura_camisa, UV);
	cor_final = mix(cor_final, cor_renderizada_camisa.rgb, m_camisa * cor_renderizada_camisa.a);

	float m_casaco = texture(mask_casaco, UV).r;
	vec4 cor_renderizada_casaco = texture(textura_casaco, UV);
	cor_final = mix(cor_final, cor_renderizada_casaco.rgb, m_casaco * cor_renderizada_casaco.a);

	float m_bota = texture(mask_bota, UV).r;
	vec4 cor_renderizada_bota = texture(textura_bota, UV);
	cor_final = mix(cor_final, cor_renderizada_bota.rgb, m_bota * cor_renderizada_bota.a);

	float m_cabelo = texture(mask_cabelo, UV).r;
	// vec3 cor_renderizada_cabelo = texture(textura_cabelo, UV).rgb;
	// cor_final = mix(cor_final, cor_renderizada_casaco, m_cabelo);
	cor_final = mix(cor_final, cor_do_cabelo, m_cabelo);

	ALBEDO = cor_final;
}

