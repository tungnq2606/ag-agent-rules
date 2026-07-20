import React from "react";
import {
  Canvas,
  Fill,
  Shader,
  Skia,
  useClock,
  vec,
} from "@shopify/react-native-skia";
import { useDerivedValue } from "react-native-reanimated";

const WIDTH = 320;
const HEIGHT = 220;

const source = Skia.RuntimeEffect.Make(`
uniform float2 resolution;
uniform float t;

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
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

vec4 main(vec2 xy) {
  vec2 uv = xy / resolution;
  float n = noise(uv * 5.0 + vec2(t * 0.08, -t * 0.05));
  float glow = 0.55 + 0.45 * sin((uv.x * 6.0) + t * 0.8);
  vec3 base = mix(vec3(0.03, 0.07, 0.16), vec3(0.15, 0.39, 0.95), uv.y);
  vec3 accent = mix(vec3(0.13, 0.82, 0.93), vec3(0.58, 0.36, 0.95), glow);
  vec3 color = mix(base, accent, 0.22 + n * 0.25);
  return vec4(color, 1.0);
}
`);

if (!source) {
  throw new Error("Failed to compile shader source.");
}

export function ShaderNoiseBackground() {
  const clock = useClock();
  const uniforms = useDerivedValue(() => ({
    resolution: vec(WIDTH, HEIGHT),
    t: clock.value / 1000,
  }));

  return (
    <Canvas style={{ width: WIDTH, height: HEIGHT }}>
      <Fill>
        <Shader source={source} uniforms={uniforms} />
      </Fill>
    </Canvas>
  );
}
