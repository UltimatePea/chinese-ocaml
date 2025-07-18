(** 骆言编译器测试配置 - Test Configuration *)

(** 测试配置 *)
module TestConfig = struct
  (** 测试超时时间（秒） *)
  let timeout_seconds = 30

  (** 是否启用详细输出 *)
  let verbose = true

  (** 是否启用性能测试 *)
  let enable_performance_tests = true

  (** 是否启用内存测试 *)
  let enable_memory_tests = true

  (** 是否启用错误测试 *)
  let enable_error_tests = true

  (** 测试文件目录 *)
  let test_files_dir = "test/test_files"

  (** 临时文件目录 *)
  let temp_dir = "/tmp/yyocamlc_test"

  (** 最大递归深度（用于防止栈溢出） *)
  let max_recursion_depth = 1000

  (** 性能测试阈值（毫秒） *)
  let performance_threshold_ms = 5000
end


type test_case = {
  name : string;
  description : string;
  category : string;
  priority : int; (* 1-5, 5为最高优先级 *)
  timeout : int option;
  should_fail : bool;
}
(** 测试用例类型 *)

type test_suite = { name : string; description : string; test_cases : test_case list }
[@@warning "-34"]
(** 测试套件类型 *)


(** 测试配置验证 *)
let _validate_config () =
  let open TestConfig in
  let errors = ref [] in

  if timeout_seconds <= 0 then errors := "超时时间必须大于0" :: !errors;

  if max_recursion_depth <= 0 then errors := "最大递归深度必须大于0" :: !errors;

  if performance_threshold_ms <= 0 then errors := "性能测试阈值必须大于0" :: !errors;

  match !errors with [] -> Ok () | errors -> Error (String.concat "; " errors)
[@@warning "-32"]

(** 获取测试配置摘要 *)
let _get_config_summary () =
  let open TestConfig in
  Printf.printf "=== 测试配置摘要 ===\n";
  Printf.printf "超时时间: %d秒\n" timeout_seconds;
  Printf.printf "详细输出: %s\n" (if verbose then "启用" else "禁用");
  Printf.printf "性能测试: %s\n" (if enable_performance_tests then "启用" else "禁用");
  Printf.printf "内存测试: %s\n" (if enable_memory_tests then "启用" else "禁用");
  Printf.printf "错误测试: %s\n" (if enable_error_tests then "启用" else "禁用");
  Printf.printf "最大递归深度: %d\n" max_recursion_depth;
  Printf.printf "性能测试阈值: %d毫秒\n" performance_threshold_ms;
  Printf.printf "测试文件目录: %s\n" test_files_dir;
  Printf.printf "临时文件目录: %s\n" temp_dir
[@@warning "-32"]
