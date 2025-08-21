@group(0) @binding(0) var<uniform> camera : mat4x4<f32>;
@group(0) @binding(1) var<uniform> object_transf : mat4x4<f32>;

@vertex
fn main(
    @location(0) pos: vec3f
) -> @builtin(position) vec4f {
//   var pos = array<vec2f, 3>(
//     vec2(0.0, 0.5),
//     vec2(-0.5, -0.5),
//     vec2(0.5, -0.5)
//   );

  let res: vec4f = camera * object_transf * vec4f(pos, 1.0);
  
  return res;
}
