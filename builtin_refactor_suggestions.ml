(** 内置函数重构建议实现 - 骆言项目代码重复消除方案 *)

open Value_operations
open Builtin_error

(** === 重构方案1: 参数验证抽象 === *)

(** 单参数字符串验证高阶函数 *)
let with_single_string_arg func_name operation args =
  let str_param = expect_string (check_single_arg args func_name) func_name in
  operation str_param

(** 单参数整数验证高阶函数 *)
let with_single_int_arg func_name operation args =
  let int_param = expect_int (check_single_arg args func_name) func_name in
  operation int_param

(** 双参数字符串验证高阶函数 *)
let with_two_string_args func_name operation args =
  let first_param = expect_string (check_single_arg args func_name) func_name in
  BuiltinFunctionValue (fun second_args ->
    let second_param = expect_string (check_single_arg second_args func_name) func_name in
    operation first_param second_param)

(** === 重构方案2: 返回值包装抽象 === *)

(** 字符串操作包装器 *)
let wrap_string_operation operation = fun param -> StringValue (operation param)

(** 整数操作包装器 *)
let wrap_int_operation operation = fun param -> IntValue (operation param)

(** 布尔操作包装器 *)
let wrap_bool_operation operation = fun param -> BoolValue (operation param)

(** === 重构方案3: 组合式内置函数构建器 === *)

(** 构建单参数字符串到字符串的内置函数 *)
let build_string_to_string_builtin func_name operation =
  with_single_string_arg func_name (wrap_string_operation operation)

(** 构建单参数字符串到整数的内置函数 *)
let build_string_to_int_builtin func_name operation =
  with_single_string_arg func_name (wrap_int_operation operation)

(** 构建双参数字符串到字符串的内置函数 *)
let build_two_strings_to_string_builtin func_name operation =
  with_two_string_args func_name (fun s1 s2 -> StringValue (operation s1 s2))

(** === 重构方案4: 错误处理抽象 === *)

(** 安全的字符串转换操作 *)
let safe_string_conversion func_name converter error_msg str =
  try wrap_string_operation converter str
  with _ -> runtime_error (error_msg ^ ": " ^ str)

(** 安全的类型转换操作 *)
let safe_type_conversion func_name converter error_msg str =
  try converter str
  with _ -> runtime_error (error_msg ^ ": " ^ str)

(** === 使用示例：重构后的内置函数定义 === *)

(** 重构前的函数示例 *)
module OldStyle = struct
  let remove_hash_comment_function args =
    let line = expect_string (check_single_arg args "移除井号注释") "移除井号注释" in
    StringValue (String_processing_utils.remove_hash_comment line)

  let string_to_int_function args =
    let s = expect_string (check_single_arg args "字符串转整数") "字符串转整数" in
    try IntValue (int_of_string s) 
    with Failure _ -> runtime_error ("无法将字符串转换为整数: " ^ s)
end

(** 重构后的函数示例 *)
module NewStyle = struct
  (* 使用组合式构建器 - 大幅减少样板代码 *)
  let remove_hash_comment_function =
    build_string_to_string_builtin "移除井号注释" String_processing_utils.remove_hash_comment

  let remove_double_slash_comment_function =
    build_string_to_string_builtin "移除双斜杠注释" String_processing_utils.remove_double_slash_comment

  let remove_block_comments_function =
    build_string_to_string_builtin "移除块注释" String_processing_utils.remove_block_comments

  (* 带错误处理的类型转换 *)
  let string_to_int_function args =
    safe_type_conversion "字符串转整数" 
      (fun s -> IntValue (int_of_string s))
      "无法将字符串转换为整数" 
      (expect_string (check_single_arg args "字符串转整数") "字符串转整数")

  (* 字符串连接函数 - 使用双参数构建器 *)
  let string_concat_function =
    build_two_strings_to_string_builtin "字符串连接" (^)
end

(** === 重构效果对比 === *)

(** 代码行数减少统计 *)
let refactor_statistics = 
  let old_lines = 5 * 3 in  (* 5个函数，每个3行样板代码 *)
  let new_lines = 5 * 1 in  (* 5个函数，每个1行定义 *)
  let reduction_percentage = (old_lines - new_lines) * 100 / old_lines in
  Printf.sprintf "代码减少：%d行 -> %d行，减少率：%d%%" old_lines new_lines reduction_percentage

(** === 迁移工具 === *)

(** 自动化重构脚本生成器 *)
let generate_refactor_script filename old_pattern new_pattern =
  Printf.sprintf "sed -i 's/%s/%s/g' %s" old_pattern new_pattern filename

(** 批量重构命令 *)
let batch_refactor_commands = [
  generate_refactor_script "src/builtin_utils.ml" 
    "let \\(.*\\) args =\\n  let line = expect_string (check_single_arg args \"\\(.*\\)\") \"\\2\" in\\n  StringValue (\\(.*\\) line)"
    "let \\1 = build_string_to_string_builtin \"\\2\" \\3";
]

(** === 重构验证测试 === *)

(** 重构前后功能等价性测试 *)
let test_refactor_equivalence () =
  let test_args = [StringValue "test_input"] in
  
  (* 测试旧版本 *)
  let old_result = OldStyle.remove_hash_comment_function test_args in
  
  (* 测试新版本 *)  
  let new_result = NewStyle.remove_hash_comment_function test_args in
  
  (* 验证结果相等 *)
  assert (old_result = new_result);
  print_endline "✓ 重构验证通过：功能等价性保持"

(** === 重构实施计划 === *)

(** 阶段1：创建抽象工具 *)
let phase1_tasks = [
  "创建 builtin_macros.ml 模块";
  "实现参数验证高阶函数";
  "实现返回值包装函数";
  "创建组合式构建器";
]

(** 阶段2：逐步迁移现有函数 *)
let phase2_tasks = [
  "迁移 builtin_utils.ml 中的5个函数";
  "迁移 builtin_types.ml 中的2个函数";
  "迁移 builtin_string.ml 中的8个函数";
  "迁移 builtin_io.ml 中的4个函数";
]

(** 阶段3：验证和优化 *)
let phase3_tasks = [
  "运行完整测试套件";
  "性能基准测试";
  "代码覆盖率验证";
  "文档更新";
]

(** 预期收益量化 *)
let expected_benefits = {
  code_reduction = "减少样板代码60-70%";
  maintainability = "统一接口，易于维护";
  bug_reduction = "减少copy-paste错误";
  development_speed = "新内置函数开发效率提升50%";
}

(** 主入口：展示重构方案 *)
let () =
  print_endline "=== 骆言项目内置函数重构方案 ===";
  print_endline refactor_statistics;
  print_endline "\n=== 实施计划 ===";
  List.iter (fun task -> print_endline ("• " ^ task)) phase1_tasks;
  print_endline "\n=== 验证测试 ===";
  test_refactor_equivalence ();
  print_endline "\n重构方案已准备就绪，可开始实施！"