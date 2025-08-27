@group(0) @binding(4) var<uniform> diffuse : vec3<f32>;

@fragment
fn main(
  @location(0) normal: vec3<f32>,
  @location(1) uv: vec2<f32>
) -> @location(0) vec4f {

  var dark = 0.9 * diffuse;
  var light = diffuse;

  let lightDir = normalize(vec3f(-1, -1, 1));

  let coef = clamp(dot(-normal, lightDir), 0, 1);
  let combined = (1 - coef) * dark + coef * light;

  return vec4f(combined, 1.0);
}