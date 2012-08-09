#ifdef GL_ES
precision highp float;
#endif

varying vec2 vTexCoord1;

uniform sampler2D sampler1;
uniform sampler2D sampler2;
uniform sampler2D sampler3;
uniform sampler2D sampler4;
uniform sampler2D sampler5;
uniform sampler2D sampler6;
uniform sampler2D sampler7;
uniform sampler2D sampler8;

uniform float width;
uniform float height;
uniform float vWidth;
uniform float vHeight;
uniform float vmax;
uniform float lmax;
uniform float maxDim;

// Packing a [0-1] float value into a 4D vector where each component will be a 8-bits integer
vec4 packFloatToVec4i(const float value) {
   const vec4 bitSh = vec4(256.0 * 256.0 * 256.0, 256.0 * 256.0, 256.0, 1.0);
   const vec4 bitMsk = vec4(0.0, 1.0 / 256.0, 1.0 / 256.0, 1.0 / 256.0);
   vec4 res = fract(value * bitSh);
   res -= res.xxyz * bitMsk;
   return res;
}

// Unpacking a [0-1] float value from a 4D vector where each component was a 8-bits integer
float unpackFloatFromVec4i(const vec4 value){
   const vec4 bitSh = vec4(1.0 / (256.0 * 256.0 * 256.0), 1.0 / (256.0 * 256.0), 1.0 / 256.0, 1.0);
   return(dot(value, bitSh));
}

void main(void) {
  float x = gl_FragCoord.x;
  float y = gl_FragCoord.y;
  float b = lmax;

  float rw = (width - 1.) / width;
  float rh = (height - 1.) / height;

  vec2 coord = vTexCoord1;
  float cx = texture2D(sampler1, coord).x;
  float cy = texture2D(sampler2, coord).x;

  float cpx = cx / width * rw;
  float cpy = cy / height * rh;
  vec2 pixel = vec2(cpx, cpy);

  float vx = texture2D(sampler7, pixel).x;
  float vy = texture2D(sampler8, pixel).x;
  vec2 field = vec2(vx, vy);

  vec4 texel;
  //4.5 Edge Treatment
  if (cx > width || cx < 0.
   || cy > height || cy < 0.) {
    //out of bounds. inject random white noise.
    texel = texture2D(sampler5, pixel);
  } else {
    texel = texture2D(sampler3, pixel);
  }

  //4.7 Noise Injection
  if (texture2D(sampler6, pixel).r > 0.5) {
    texel = 1. - texel;
  }

  //4.10.2 Velocity Mask
  const float m = 5.;
  const float n = 1.;
  float ratio = min(length(field) / vmax, 1.);
  vec4 alpha = (1. - pow(1. - ratio, m)) * (1. - pow(1. - texel, vec4(n)));
  texel = alpha;

  //4.9 Noise Blending
  vec4 blendValue = texture2D(sampler4, vTexCoord1);

  gl_FragColor = mix(texel, blendValue, 0.96);
}

