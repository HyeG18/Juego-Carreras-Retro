shader_type canvas_item;

uniform vec2 pixel_size = vec2(4.0, 4.0); // Tamaño del píxel visual

void fragment() {
    vec2 resolution = vec2(textureSize(TEXTURE, 0));
    vec2 uv = floor(UV * resolution / pixel_size) * pixel_size / resolution;
    COLOR = texture(TEXTURE, uv);
}
