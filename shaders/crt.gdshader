// This shader was created by Aeix, also known as "tqef".
// You are always free to use this shader, but please consider crediting me!
// Thanks for using my shader in your personal projects <3

shader_type canvas_item;
// === CRT PARAMETERS ===
uniform vec2 screen_size;
uniform vec2 viewport_size;
uniform float hardScan : hint_range(-20.0, 0.0, 1.0) = -8.0;
uniform float hardPix : hint_range(-20.0, 0.0, 1.0) = -3.0;
uniform float warpX : hint_range(0.0, 0.125, 0.001) = 0.031;
uniform float warpY : hint_range(0.0, 0.125, 0.001) = 0.041;
uniform float maskDark : hint_range(0.0, 2.0, 0.1) = 0.5;
uniform float maskLight : hint_range(0.0, 2.0, 0.1) = 1.5;
uniform bool scaleInLinearGamma = true;
uniform int shadowMask : hint_range(0, 4, 1) = 3;
uniform float brightBoost : hint_range(0.0, 2.0, 0.05) = 1.0;
uniform float hardBloomPix : hint_range(-2.0, -0.5, 0.1) = -1.5;
uniform float hardBloomScan : hint_range(-4.0, -1.0, 0.1) = -2.0;
uniform float bloomAmount : hint_range(0.0, 1.0, 0.05) = 0.15;
uniform float shape : hint_range(0.0, 10.0, 0.05) = 2.0;
uniform bool doBloom = true;

// === COMPRESSION BIBRATE ===
group_uniforms compression_artifacts;
uniform bool enable_compression = true;
uniform float compression_intensity : hint_range(0.0, 20.0, 0.1) = 8.0;
uniform float compression_quantization : hint_range(0.0, 64.0, 1.0) = 16.0;
uniform float compression_block_size : hint_range(4.0, 16.0, 4.0) = 8.0;
uniform float compression_blend : hint_range(0.0, 1.0, 0.05) = 0.7;

// === CHROMATIC ABERRATION ===
group_uniforms chromatic_aberration;
uniform bool enable_chromatic_aberration = true;
uniform vec2 red_shift = vec2(0.002, 0.0);
uniform vec2 green_shift = vec2(0.0, 0.0);
uniform vec2 blue_shift = vec2(-0.002, 0.0);
uniform float aberration_bias : hint_range(0.0, 2.0, 0.1) = 1.0;
uniform float aberration_blend : hint_range(0.0, 1.0, 0.05) = 0.8;

// === LENS DISTORTION PARAMETERS ===
group_uniforms lens_distortion;
uniform bool enable_lens_distortion = true;
uniform float distortion_intensity : hint_range(-2.0, 2.0, 0.01) = 0.15;
uniform float distortion_magnifier : hint_range(0.8, 1.2, 0.01) = 1.0;
uniform bool distortion_invert = false;

// === NOISE GRAIN ===
group_uniforms noise_grain;
uniform bool enable_noise = true;
uniform float noise_intensity : hint_range(0.0, 1.0, 0.01) = 0.08;
uniform float noise_scale : hint_range(1.0, 100.0, 1.0) = 50.0;
uniform float noise_framerate : hint_range(0.0, 60.0, 1.0) = 24.0;
uniform float noise_midtones : hint_range(0.0, 2.0, 0.1) = 1.0;
uniform float noise_shadows : hint_range(0.0, 2.0, 0.1) = 1.2;
uniform float noise_highlights : hint_range(0.0, 2.0, 0.1) = 0.8;

// === HALATION (FILM BLOOM) ===
group_uniforms halation;
uniform bool enable_halation = false;
uniform float halation_amount : hint_range(0.0, 2.0, 0.05) = 0.3;
uniform float halation_threshold : hint_range(0.0, 1.0, 0.01) = 0.8;
uniform float halation_size : hint_range(0.0, 10.0, 0.1) = 2.0;
uniform vec3 halation_color_filter = vec3(1.0, 0.9, 0.8);

// === SHARPEN ===
group_uniforms sharpen;
uniform bool enable_sharpen = false;
uniform float sharpen_intensity : hint_range(0.0, 5.0, 0.1) = 1.0;
uniform float sharpen_offset : hint_range(0.5, 3.0, 0.1) = 1.0;

// === SOFTEN ===
group_uniforms soften;
uniform bool enable_soften = false;
uniform float soften_strength : hint_range(0.0, 5.0, 0.1) = 1.0;
uniform float soften_blend : hint_range(0.0, 1.0, 0.05) = 0.5;

// === VIGNETTE OVERLAY ===
group_uniforms overlay;
uniform bool enable_vignette = true;
uniform float vignette_intensity : hint_range(0.0, 2.0, 0.05) = 0.4;
uniform float vignette_size : hint_range(0.0, 2.0, 0.05) = 0.8;
uniform vec3 vignette_color = vec3(0.0, 0.0, 0.0);

uniform sampler2D CRTBackBuffer : hint_screen_texture;
uniform sampler2D noise_texture : hint_default_white;

// === HELPER FUNCTIONS ===
float ToLinear1(float c) {
    if (!scaleInLinearGamma) return c;
    return (c <= 0.04045) ? c/12.92 : pow((c + 0.055)/1.055, 2.4);
}

vec3 ToLinear(vec3 c) {
    if (!scaleInLinearGamma) return c;
    return vec3(ToLinear1(c.r), ToLinear1(c.g), ToLinear1(c.b));
}

float ToSrgb1(float c) {
    if (!scaleInLinearGamma) return c;
    return (c < 0.0031308) ? c * 12.92 : 1.055 * pow(c, 0.41666) - 0.055;
}

vec3 ToSrgb(vec3 c) {
    if (!scaleInLinearGamma) return c;
    return vec3(ToSrgb1(c.r), ToSrgb1(c.g), ToSrgb1(c.b));
}

// === DCT COMPRESSION ARTIFACTS ===
float dct_coefficient(float x, float y, float u, float v, float N) {
    float cu = (u == 0.0) ? 1.0/sqrt(2.0) : 1.0;
    float cv = (v == 0.0) ? 1.0/sqrt(2.0) : 1.0;
    return cu * cv * cos(((2.0 * x + 1.0) * u * PI) / (2.0 * N)) *
                     cos(((2.0 * y + 1.0) * v * PI) / (2.0 * N));
}

vec3 apply_dct_compression(vec3 color, vec2 uv) {
    float block_size = compression_block_size;
    vec2 block_pos = floor(uv * screen_size / block_size) * block_size;
    vec2 local_pos = mod(uv * screen_size, block_size);

    vec3 compressed = vec3(0.0);
    float quantization = compression_intensity;

    // Simplified DCT for performance (8x8 blocks)
    for(float u = 0.0; u < 4.0; u++) {
        for(float v = 0.0; v < 4.0; v++) {
            float weight = 1.0 / (1.0 + u + v);
            vec2 sample_pos = (block_pos + vec2(u, v) * 2.0) / screen_size;
            vec3 sample = texture(CRTBackBuffer, sample_pos).rgb;

            // Quantize
            sample = floor(sample * quantization + 0.5) / quantization;
            compressed += sample * weight * dct_coefficient(local_pos.x, local_pos.y, u, v, block_size);
        }
    }

    // Additional color quantization
    compressed = floor(compressed * compression_quantization) / compression_quantization;

    return mix(color, compressed, compression_blend);
}

// === CHROMATIC ABERRATION ===
vec3 apply_chromatic_aberration(vec2 uv) {
    vec2 center = vec2(0.5, 0.5);
    vec2 dist = uv - center;
    float factor = pow(length(dist), aberration_bias);

    vec3 color;
    color.r = texture(CRTBackBuffer, uv + red_shift * factor).r;
    color.g = texture(CRTBackBuffer, uv + green_shift * factor).g;
    color.b = texture(CRTBackBuffer, uv + blue_shift * factor).b;

    return color;
}

// === LENS DISTORTION ===
vec2 apply_lens_distortion(vec2 uv) {
    vec2 center = vec2(0.5, 0.5);
    vec2 dist = uv - center;
    float r = length(dist);
    float factor = 1.0 + distortion_intensity * r * r;

    if (distortion_invert) {
        factor = 1.0 / factor;
    }

    vec2 distorted = center + dist * factor * distortion_magnifier;
    return distorted;
}

// === NOISE GENERATION ===
float hash(vec2 p) {
    p = fract(p * vec2(443.8975, 397.2973));
    p += dot(p.xy, p.yx + 19.19);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

vec3 apply_noise_grain(vec3 color, vec2 uv, float time) {
    float frame_time = (noise_framerate > 0.0) ? floor(time * noise_framerate) / noise_framerate : time;

    vec2 noise_uv = uv * noise_scale + vec2(frame_time * 12.9898, frame_time * 78.233);
    float n = noise(noise_uv) * 2.0 - 1.0;

    // Luminance-based intensity
    float lum = dot(color, vec3(0.299, 0.587, 0.114));
    float intensity = noise_intensity;

    if (lum < 0.33) {
        intensity *= noise_shadows;
    } else if (lum > 0.66) {
        intensity *= noise_highlights;
    } else {
        intensity *= noise_midtones;
    }

    // Soft light blend mode
    vec3 noise_color = vec3(n * intensity);
    return mix(color, color + noise_color, 0.5);
}

// === HALATION (FILM BLOOM) ===
vec3 apply_halation(vec3 color, vec2 uv) {
    vec3 bright = max(color - halation_threshold, 0.0);

    // Simple blur for halation
    vec3 blurred = vec3(0.0);
    float total = 0.0;
    float radius = halation_size / 1000.0;

    for(float i = -2.0; i <= 2.0; i++) {
        for(float j = -2.0; j <= 2.0; j++) {
            vec2 offset = vec2(i, j) * radius;
            float weight = exp(-length(offset) * 2.0);
            blurred += texture(CRTBackBuffer, uv + offset).rgb * weight;
            total += weight;
        }
    }

    blurred = (blurred / total) * halation_color_filter;
    return color + blurred * halation_amount;
}

// === SHARPEN ===
vec3 apply_sharpen(vec3 color, vec2 uv) {
    vec3 sum = vec3(0.0);
    float offset = sharpen_offset / 1000.0;

    // Unsharp mask technique
    sum -= texture(CRTBackBuffer, uv + vec2(-offset, 0.0)).rgb;
    sum -= texture(CRTBackBuffer, uv + vec2(offset, 0.0)).rgb;
    sum -= texture(CRTBackBuffer, uv + vec2(0.0, -offset)).rgb;
    sum -= texture(CRTBackBuffer, uv + vec2(0.0, offset)).rgb;
    sum += color * 5.0;

    return mix(color, sum, sharpen_intensity * 0.2);
}

// === SOFTEN ===
vec3 apply_soften(vec3 color, vec2 uv) {
    vec3 blurred = vec3(0.0);
    float total = 0.0;
    float radius = soften_strength / 500.0;

    for(float i = -2.0; i <= 2.0; i++) {
        for(float j = -2.0; j <= 2.0; j++) {
            vec2 offset = vec2(i, j) * radius;
            float weight = exp(-length(offset) * 2.0);
            blurred += texture(CRTBackBuffer, uv + offset).rgb * weight;
            total += weight;
        }
    }

    blurred /= total;
    return mix(color, blurred, soften_blend);
}

// === VIGNETTE ===
vec3 apply_vignette(vec3 color, vec2 uv) {
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(uv, center);
    float vignette = 1.0 - smoothstep(vignette_size * 0.5, vignette_size, dist);
    vignette = 1.0 - (1.0 - vignette) * vignette_intensity;

    return mix(vignette_color, color, vignette);
}

// === CRT FUNCTIONS ===
vec3 Fetch(vec2 pos, vec2 off) {
    vec2 res = screen_size;
    pos = (floor(pos * res.xy + off) + vec2(0.5, 0.5)) / res.xy;
    if(max(abs(pos.x - 0.5), abs(pos.y - 0.5)) > 0.5) return vec3(0.0, 0.0, 0.0);
    return ToLinear(brightBoost * texture(CRTBackBuffer, pos.xy).rgb);
}

vec2 Dist(vec2 pos) {
    vec2 res = screen_size;
    pos = pos * res;
    return -((pos - floor(pos)) - vec2(0.5, 0.5));
}

float Gaus(float pos, float scale) {
    return exp2(scale * pow(abs(pos), shape));
}

vec3 Horz3(vec2 pos, float off) {
    vec3 b = Fetch(pos, vec2(-1.0, off));
    vec3 c = Fetch(pos, vec2(0.0, off));
    vec3 d = Fetch(pos, vec2(1.0, off));
    float dst = Dist(pos).x;

    float scale = hardPix;
    float wb = Gaus(dst - 1.0, scale);
    float wc = Gaus(dst + 0.0, scale);
    float wd = Gaus(dst + 1.0, scale);

    return (b * wb + c * wc + d * wd) / (wb + wc + wd);
}

vec3 Horz5(vec2 pos, float off) {
    vec3 a = Fetch(pos, vec2(-2.0, off));
    vec3 b = Fetch(pos, vec2(-1.0, off));
    vec3 c = Fetch(pos, vec2(0.0, off));
    vec3 d = Fetch(pos, vec2(1.0, off));
    vec3 e = Fetch(pos, vec2(2.0, off));
    float dst = Dist(pos).x;

    float scale = hardPix;
    float wa = Gaus(dst - 2.0, scale);
    float wb = Gaus(dst - 1.0, scale);
    float wc = Gaus(dst + 0.0, scale);
    float wd = Gaus(dst + 1.0, scale);
    float we = Gaus(dst + 2.0, scale);

    return (a * wa + b * wb + c * wc + d * wd + e * we) / (wa + wb + wc + wd + we);
}

vec3 Horz7(vec2 pos, float off) {
    vec3 a = Fetch(pos, vec2(-3.0, off));
    vec3 b = Fetch(pos, vec2(-2.0, off));
    vec3 c = Fetch(pos, vec2(-1.0, off));
    vec3 d = Fetch(pos, vec2(0.0, off));
    vec3 e = Fetch(pos, vec2(1.0, off));
    vec3 f = Fetch(pos, vec2(2.0, off));
    vec3 g = Fetch(pos, vec2(3.0, off));
    float dst = Dist(pos).x;

    float scale = hardBloomPix;
    float wa = Gaus(dst - 3.0, scale);
    float wb = Gaus(dst - 2.0, scale);
    float wc = Gaus(dst - 1.0, scale);
    float wd = Gaus(dst + 0.0, scale);
    float we = Gaus(dst + 1.0, scale);
    float wf = Gaus(dst + 2.0, scale);
    float wg = Gaus(dst + 3.0, scale);

    return (a * wa + b * wb + c * wc + d * wd + e * we + f * wf + g * wg) / (wa + wb + wc + wd + we + wf + wg);
}

float Scan(vec2 pos, float off) {
    float dst = Dist(pos).y;
    return Gaus(dst + off, hardScan);
}

float BloomScan(vec2 pos, float off) {
    float dst = Dist(pos).y;
    return Gaus(dst + off, hardBloomScan);
}

vec3 Tri(vec2 pos) {
    vec3 a = Horz3(pos, -1.0);
    vec3 b = Horz5(pos, 0.0);
    vec3 c = Horz3(pos, 1.0);
    float wa = Scan(pos, -1.0);
    float wb = Scan(pos, 0.0);
    float wc = Scan(pos, 1.0);
    return a * wa + b * wb + c * wc;
}

vec3 Bloom(vec2 pos) {
    vec3 a = Horz5(pos, -2.0);
    vec3 b = Horz7(pos, -1.0);
    vec3 c = Horz7(pos, 0.0);
    vec3 d = Horz7(pos, 1.0);
    vec3 e = Horz5(pos, 2.0);
    float wa = BloomScan(pos, -2.0);
    float wb = BloomScan(pos, -1.0);
    float wc = BloomScan(pos, 0.0);
    float wd = BloomScan(pos, 1.0);
    float we = BloomScan(pos, 2.0);
    return a * wa + b * wb + c * wc + d * wd + e * we;
}

vec2 Warp(vec2 pos) {
    pos = pos * 2.0 - 1.0;
    pos *= vec2(1.0 + (pos.y * pos.y) * warpX, 1.0 + (pos.x * pos.x) * warpY);
    return pos * 0.5 + 0.5;
}

vec3 Mask(vec2 pos) {
    vec3 mask = vec3(maskDark, maskDark, maskDark);

    if (shadowMask == 1) {
        float sline = maskLight;
        float odd = 0.0;
        if(fract(pos.x / 6.0) < 0.5) odd = 1.0;
        if(fract((pos.y + odd) / 2.0) < 0.5) sline = maskDark;
        pos.x = fract(pos.x / 3.0);

        if(pos.x < 0.333) mask.r = maskLight;
        else if(pos.x < 0.666) mask.g = maskLight;
        else mask.b = maskLight;
        mask *= sline;
    }
    else if (shadowMask == 2) {
        pos.x = fract(pos.x / 3.0);

        if(pos.x < 0.333) mask.r = maskLight;
        else if(pos.x < 0.666) mask.g = maskLight;
        else mask.b = maskLight;
    }
    else if (shadowMask == 3) {
        pos.x += pos.y * 3.0;
        pos.x = fract(pos.x / 6.0);

        if(pos.x < 0.333) mask.r = maskLight;
        else if(pos.x < 0.666) mask.g = maskLight;
        else mask.b = maskLight;
    }
    else if (shadowMask == 4) {
        pos.xy = floor(pos.xy * vec2(1.0, 0.5));
        pos.x += pos.y * 3.0;
        pos.x = fract(pos.x / 6.0);

        if(pos.x < 0.333) mask.r = maskLight;
        else if(pos.x < 0.666) mask.g = maskLight;
        else mask.b = maskLight;
    }

    return mask;
}

// === MAIN SHADER ===
void fragment() {
    vec2 uv = UV;
    vec3 color;

    // Apply lens distortion first
    if (enable_lens_distortion) {
        uv = apply_lens_distortion(uv);
    }

    // Apply chromatic aberration
    if (enable_chromatic_aberration) {
        color = apply_chromatic_aberration(uv);
        vec3 original = texture(CRTBackBuffer, uv).rgb;
        color = mix(original, color, aberration_blend);
    } else {
        color = texture(CRTBackBuffer, uv).rgb;
    }

    // Apply compression artifacts (DCT)
    if (enable_compression) {
        color = apply_dct_compression(color, uv);
    }

    // Apply soften
    if (enable_soften) {
        color = apply_soften(color, uv);
    }

    // Apply CRT effects
    vec2 ppos = Warp(uv * (screen_size / viewport_size) * (viewport_size / screen_size));
    vec3 crt_color = Tri(ppos);

    if (doBloom) {
        crt_color.rgb += (Bloom(ppos) * bloomAmount);
    }

    if (shadowMask >= 0) {
        crt_color.rgb *= Mask(floor(uv * (screen_size / viewport_size) / SCREEN_PIXEL_SIZE) + vec2(0.5, 0.5));
    }

    // Mix CRT with processed color
    color = mix(color, crt_color, 0.5);

    // Apply halation
    if (enable_halation) {
        color = apply_halation(color, uv);
    }

    // Apply sharpen
    if (enable_sharpen) {
        color = apply_sharpen(color, uv);
    }

    // Apply noise grain
    if (enable_noise) {
        color = apply_noise_grain(color, uv, TIME);
    }

    // Apply vignette
    if (enable_vignette) {
        color = apply_vignette(color, uv);
    }

    // Final color space conversion
    color = ToSrgb(color);

    // Clamp to valid range
    color = clamp(color, 0.0, 1.0);

    COLOR = vec4(color, 1.0);
}