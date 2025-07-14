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

(** 测试结果类型 *)
type test_result =
  | Pass
  | Fail of string
  | Timeout
  | Error of string
[@@warning "-37"]

(** 测试统计 *)
type test_stats = {
  total: int;
  passed: int;
  failed: int;
  timed_out: int;
  errors: int;
}

(** 测试用例类型 *)
type test_case = {
  name: string;
  description: string;
  category: string;
  priority: int; (* 1-5, 5为最高优先级 *)
  timeout: int option;
  should_fail: bool;
}

(** 测试套件类型 *)
type test_suite = {
  name: string;
  description: string;
  test_cases: test_case list;
}
[@@warning "-34"]

(** 默认测试统计 *)
let _empty_stats = {
  total = 0;
  passed = 0;
  failed = 0;
  timed_out = 0;
  errors = 0;
}
[@@warning "-32"]

(** 更新测试统计 *)
let _update_stats stats result =
  match result with
  | Pass -> { stats with passed = stats.passed + 1 }
  | Fail _ -> { stats with failed = stats.failed + 1 }
  | Timeout -> { stats with timed_out = stats.timed_out + 1 }
  | Error _ -> { stats with errors = stats.errors + 1 }
[@@warning "-32"]

(** 打印测试统计 *)
let _print_stats stats =
  Printf.printf "=== 测试统计 ===\n";
  Printf.printf "总测试数: %d\n" stats.total;
  Printf.printf "通过: %d\n" stats.passed;
  Printf.printf "失败: %d\n" stats.failed;
  Printf.printf "超时: %d\n" stats.timed_out;
  Printf.printf "错误: %d\n" stats.errors;
  Printf.printf "成功率: %.2f%%\n"
    (float_of_int stats.passed /. float_of_int stats.total *. 100.0)
[@@warning "-32"]

(** 测试优先级字符串 *)
let _priority_to_string priority =
  match priority with
  | 1 -> "低"
  | 2 -> "中低"
  | 3 -> "中"
  | 4 -> "中高"
  | 5 -> "高"
  | _ -> "未知"
[@@warning "-32"]

(** 测试结果字符串 *)
let _result_to_string result =
  match result with
  | Pass -> "通过"
  | Fail msg -> "失败: " ^ msg
  | Timeout -> "超时"
  | Error msg -> "错误: " ^ msg
[@@warning "-32"]

(** 测试配置验证 *)
let _validate_config () =
  let open TestConfig in
  let errors = ref [] in

  if timeout_seconds <= 0 then
    errors := "超时时间必须大于0" :: !errors;

  if max_recursion_depth <= 0 then
    errors := "最大递归深度必须大于0" :: !errors;

  if performance_threshold_ms <= 0 then
    errors := "性能测试阈值必须大于0" :: !errors;

  match !errors with
  | [] -> Ok ()
  | errors -> Error (String.concat "; " errors)
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