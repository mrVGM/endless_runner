@group(0) @binding(0) var<uniform> camera : mat4x4<f32>;
@group(0) @binding(1) var<uniform> object_transf : mat4x4<f32>;

const max_bones = 100;
struct Pose {
  pose: array<mat4x4<f32>, max_bones>
};
@group(0) @binding(2) var<uniform> is_skeletal : u32;
@group(0) @binding(3) var<uniform> pose : Pose;

struct VOut {
  @builtin(position) clip_position: vec4<f32>,
  @location(0) normal: vec3<f32>,
  @location(1) uv: vec2<f32>,
};

fn transf_point(
  point: vec3<f32>,

  i1: vec4<u32>,
  i2: vec4<u32>,
  w1: vec4<f32>,
  w2: vec4<f32>
) -> vec3<f32> {
  let tr = object_transf;

  if (is_skeletal == 0) {
    let res: vec4f = tr * vec4f(point, 1.0);
    return res.xyz; 
  }

  var res: vec4f = vec4(0, 0, 0, 0);
  for (var i = 0; i < 4; i += 1) {
    if (i1[i] >= 0) {
      res += w1[i] * pose.pose[i1[i]] * vec4f(point, 1.0);
    }
  }
  for (var i = 0; i < 4; i += 1) {
    if (i2[i] >= 0) {
      res += w2[i] * pose.pose[i2[i]] * vec4f(point, 1.0);
    }
  }

  res[3] = 1;
  res = tr * res;
  return res.xyz;
}

@vertex
fn main(
    @location(0) pos: vec3f,
    @location(1) norm: vec3f,
    @location(2) uv: vec2f,

    @location(10) i1: vec4<u32>,
    @location(11) i2: vec4<u32>,
    @location(12) w1: vec4<f32>,
    @location(13) w2: vec4<f32>
) -> VOut {

  var out: VOut;
  out.uv = uv;

  let posTr = transf_point(pos, i1, i2, w1, w2);
  let posNormEndTr = transf_point(pos + norm, i1, i2, w1, w2);

  let normal = normalize(posNormEndTr - posTr);
  out.normal = normal;

  out.clip_position = camera * vec4f(posTr, 1);
  return out;
}
