shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float saturation : hint_range(0.0, 2.0) = 1.0;

void fragment() {
    vec4 tex_color = texture(screen_texture, SCREEN_UV);
    float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
    COLOR.rgb = mix(vec3(gray), tex_color.rgb, saturation);
    COLOR.a = tex_color.a;
}
