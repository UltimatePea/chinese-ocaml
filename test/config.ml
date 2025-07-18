(** 骆言编译器测试配置 - Test Configuration *)

(** 测试配置 *)
module TestConfig = struct
  (** 测试超时时间（秒） *)
  let timeout_seconds = 30

  (** 是否启用详细输出 *)
  let verbose = true
end

(** 简单配置测试 - 验证配置值正确性 *)
let () =
  let open TestConfig in
  assert (timeout_seconds > 0);
  assert (verbose = true);
  Printf.printf "测试配置验证通过: 超时%d秒, 详细输出%s\n" 
    timeout_seconds (if verbose then "启用" else "禁用")