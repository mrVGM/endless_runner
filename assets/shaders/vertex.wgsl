@group(0) @binding(0) var<uniform> camera : mat4x4<f32>;
@group(0) @binding(1) var<uniform> object_transf : mat4x4<f32>;

const max_bones = 50;
struct Pose {
  pose: array<mat4x4<f32>, max_bones>
};
@group(0) @binding(2) var<uniform> is_skeletal : u32;
@group(0) @binding(3) var<uniform> pose : Pose;

@vertex
fn main(
    @location(0) pos: vec3f,
    @location(10) i1: vec4<u32>,
    @location(11) i2: vec4<u32>,
    @location(12) w1: vec4<f32>,
    @location(13) w2: vec4<f32>
) -> @builtin(position) vec4f {
//   var pos = array<vec2f, 3>(
//     vec2(0.0, 0.5),
//     vec2(-0.5, -0.5),
//     vec2(0.5, -0.5)
//   );

  if (is_skeletal == 0)
  {
    let res: vec4f = camera * object_transf * vec4f(pos, 1.0);
    return res;
  }

  var res: vec4f = vec4(0, 0, 0, 0);
  for (var i = 0; i < 4; i += 1) {
    if (i1[i] >= 0) {
      res += w1[i] * pose.pose[i1[i]] * vec4f(pos, 1.0);
    }
  }
  for (var i = 0; i < 4; i += 1) {
    if (i2[i] >= 0) {
      res += w2[i] * pose.pose[i2[i]] * vec4f(pos, 1.0);
    }
  }

  res[3] = 1;
  res = camera * object_transf * res;
  return res;
}
