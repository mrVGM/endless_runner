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
  offset: vec3<f32>,

  i1: vec4<u32>,
  i2: vec4<u32>,
  w1: vec4<f32>,
  w2: vec4<f32>
) -> vec3<f32> {
  let offset_m: mat4x4<f32> = mat4x4f(
    1,         0,         0,         0, 
    0,         1,         0,         0,
    0,         0,         1,         0,
    offset[0], offset[1], offset[2], 1
  );

  let tr = object_transf;

  if (is_skeletal == 0) {
    let res: vec4f = tr * vec4f(point, 1.0);
    return (offset_m * res).xyz; 
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
  return (offset_m * res).xyz;
}

const PI: f32 = 3.14159265359;

fn bend_horizontal(point: vec3<f32>, r: f32) -> vec3<f32> {
  let p = point;

  var a = p.z / r;
  a = 2 * a / PI;
  a = a * a;
  a = min(a, PI / 4);
  a = a * PI / 2;
  if (p.z < 0) {
    a = -a;
  }

  let angle = a;

  let x: vec3<f32> = vec3(cos(angle), 0, sin(angle));
  let y: vec3<f32> = vec3(0, 1, 0);
  let z: vec3<f32> = vec3(-sin(angle), 0, cos(angle));

  let origin = r * x + vec3<f32>(-r, 0, 0);

  let tr: mat4x4<f32> = mat4x4(
    x[0], x[1], x[2], 0,
    y[0], y[1], y[2], 0,
    z[0], z[1], z[2], 0,
    origin[0], origin[1], origin[2], 1
  );

  let tmp = tr * vec4(p, 1.0);
  return tmp.xyz;
}

fn bend_vertical(point: vec3<f32>) -> vec3<f32> {
  let tr = mat3x3(
    0, -1, 0,
    1,  0, 0,
    0,  0, 1,
  );
  let invTr = mat3x3(
    0, 1, 0,
    -1, 0, 0,
    0, 0, 1,
  );

  var tmp = tr * point;
  tmp = bend_horizontal(tmp, 1500);
  tmp = invTr * tmp;

  return tmp;
}

@vertex
fn main(
    @location(0) pos: vec3f,
    @location(1) norm: vec3f,
    @location(2) uv: vec2f,

    @location(10) i1: vec4<u32>,
    @location(11) i2: vec4<u32>,
    @location(12) w1: vec4<f32>,
    @location(13) w2: vec4<f32>,

    @location(15) inst_pos: vec3<f32>
) -> VOut {

  var out: VOut;
  out.uv = uv;

  let posTr = bend_vertical(
    bend_horizontal(
      transf_point(pos, inst_pos, i1, i2, w1, w2),
      1000
    )
  );
  let posNormEndTr = bend_vertical(
    bend_horizontal(
      transf_point(pos + norm, inst_pos + norm, i1, i2, w1, w2),
      1000
    )
  );

  let normal = normalize(posNormEndTr - posTr);
  out.normal = normal;

  out.clip_position = camera * vec4f(posTr, 1);
  return out;
}
