@fragment
fn main(
  @location(0) normal: vec3<f32>,
  @location(1) uv: vec2<f32>
) -> @location(0) vec4f {

  var dark = vec3f(0.7, 0.0, 0.0);
  var light = vec3f(1.0, 0.0, 0.0);

  let uvInt = floor(10 * uv);
  if ((uvInt.x + uvInt.y) % 2 == 1) {
    dark = vec3f(0.7, 0.5, 0.0);
    light = vec3f(1.0, 0.5, 0.0);
  }

  let lightDir = normalize(vec3f(-1, -1, 1));

  let coef = clamp(dot(-normal, lightDir), 0, 1);
  let combined = (1 - coef) * dark + coef * light;

  return vec4f(combined, 1.0);
}