(** 骆言C代码生成器上下文模块全面测试套件 *)

open Alcotest
open Yyocamlc_lib
open Types
open C_codegen_context

(** 辅助函数：创建测试用的代码生成配置 *)
let create_test_config () = {
  c_output_file = "test_output.c";
  include_debug = true;
  optimize = false;
  runtime_path = "/usr/local/lib/luoyan";
}

(** 辅助函数：创建优化配置 *)
let create_optimized_config () = {
  c_output_file = "optimized_output.c";
  include_debug = false;
  optimize = true;
  runtime_path = "/opt/luoyan/runtime";
}

(** 代码生成上下文创建测试 *)
let test_create_context () =
  let config = create_test_config () in
  let ctx = create_context config in
  
  (* 验证配置是否正确设置 *)
  check string "输出文件名" "test_output.c" ctx.config.c_output_file;
  check bool "调试信息包含" true ctx.config.include_debug;
  check bool "优化标志" false ctx.config.optimize;
  check string "运行时路径" "/usr/local/lib/luoyan" ctx.config.runtime_path;
  
  (* 验证初始状态 *)
  check int "初始变量ID" 0 ctx.next_var_id;
  check int "初始标签ID" 0 ctx.next_label_id;
  check (list string) "初始includes列表" ["luoyan_runtime.h"] ctx.includes;
  check (list string) "初始全局变量列表" [] ctx.global_vars;
  check (list string) "初始函数列表" [] ctx.functions

(** 优化配置测试 *)
let test_optimized_config () =
  let config = create_optimized_config () in
  let ctx = create_context config in
  
  check string "优化输出文件名" "optimized_output.c" ctx.config.c_output_file;
  check bool "优化模式下不包含调试信息" false ctx.config.include_debug;
  check bool "优化标志开启" true ctx.config.optimize;
  check string "优化运行时路径" "/opt/luoyan/runtime" ctx.config.runtime_path

(** 变量名生成测试 *)
let test_gen_var_name () =
  let config = create_test_config () in
  let ctx = create_context config in
  
  (* 测试基础变量名生成 *)
  let var1 = gen_var_name ctx "测试变量" in
  check string "第一个变量名" "luoyan_var_测试变量_0" var1;
  check int "变量ID递增" 1 ctx.next_var_id;
  
  let var2 = gen_var_name ctx "另一个变量" in
  check string "第二个变量名" "luoyan_var_另一个变量_1" var2;
  check int "变量ID继续递增" 2 ctx.next_var_id;
  
  (* 测试相同基础名的变量生成 *)
  let var3 = gen_var_name ctx "测试变量" in
  check string "相同基础名的变量" "luoyan_var_测试变量_2" var3;
  check int "变量ID最终值" 3 ctx.next_var_id

(** 标签名生成测试 *)
let test_gen_label_name () =
  let config = create_test_config () in
  let ctx = create_context config in
  
  (* 测试基础标签名生成 *)
  let label1 = gen_label_name ctx "循环开始" in
  check string "第一个标签名" "luoyan_label_循环开始_0" label1;
  check int "标签ID递增" 1 ctx.next_label_id;
  
  let label2 = gen_label_name ctx "条件判断" in
  check string "第二个标签名" "luoyan_label_条件判断_1" label2;
  check int "标签ID继续递增" 2 ctx.next_label_id;
  
  (* 测试相同基础名的标签生成 *)
  let label3 = gen_label_name ctx "循环开始" in
  check string "相同基础名的标签" "luoyan_label_循环开始_2" label3;
  check int "标签ID最终值" 3 ctx.next_label_id

(** 标识符转义测试 *)
let test_escape_identifier () =
  (* 测试基础ASCII标识符 *)
  let basic_id = escape_identifier "simple_var" in
  check string "基础ASCII标识符" "simple_var" basic_id;
  
  (* 测试中文标识符 *)
  let chinese_id = escape_identifier "变量名" in
  check string "中文标识符转义" "\229\143\152\233\135\143\229\144\141" chinese_id;
  
  (* 测试混合标识符 *)
  let mixed_id = escape_identifier "变量_test_123" in
  check string "混合标识符转义" "\229\143\152\233\135\143_test_123" mixed_id;
  
  (* 测试特殊字符 *)
  let special_id = escape_identifier "特殊-字符.测试" in
  check string "特殊字符转义" "\231\137\185\230\174\138_dash_\229\173\151\231\172\166_dot_\230\181\139\232\175\149" special_id;
  
  (* 测试空字符串 *)
  let empty_id = escape_identifier "" in
  check string "空字符串转义" "" empty_id;
  
  (* 测试数字开头 *)
  let num_start_id = escape_identifier "123变量" in
  check string "数字开头标识符转义" "123\229\143\152\233\135\143" num_start_id

(** 骆言类型到C类型转换测试 *)
let test_c_type_of_luoyan_type () =
  (* 测试基础类型转换 *)
  check string "整数类型转换" "luoyan_int_t" (c_type_of_luoyan_type IntType_T);
  check string "字符串类型转换" "luoyan_string_t*" (c_type_of_luoyan_type StringType_T);
  check string "布尔类型转换" "luoyan_bool_t" (c_type_of_luoyan_type BoolType_T);
  
  (* 测试列表类型转换 *)
  let int_list_type = c_type_of_luoyan_type (ListType_T IntType_T) in
  check string "整数列表类型转换" "luoyan_list_t*" int_list_type;
  
  let string_list_type = c_type_of_luoyan_type (ListType_T StringType_T) in
  check string "字符串列表类型转换" "luoyan_list_t*" string_list_type;
  
  (* 测试函数类型转换 *)
  let func_type = c_type_of_luoyan_type (FunType_T (TupleType_T [IntType_T; StringType_T], BoolType_T)) in
  check string "函数类型转换" "luoyan_function_t*" func_type;
  
  (* 测试记录类型转换 *)
  let record_type = c_type_of_luoyan_type (RecordType_T [("字段1", IntType_T); ("字段2", StringType_T)]) in
  check string "记录类型转换" "luoyan_record_t*" record_type;
  
  (* 测试自定义类型转换 *)
  let custom_type = c_type_of_luoyan_type (ConstructType_T ("我的类型", [])) in
  check string "自定义类型转换" "luoyan_user_\230\136\145\231\154\132\231\177\187\229\158\139_t*" custom_type

(** 嵌套类型转换测试 *)
let test_nested_type_conversion () =
  (* 测试嵌套列表 *)
  let nested_list = c_type_of_luoyan_type (ListType_T (ListType_T IntType_T)) in
  check string "嵌套列表类型转换" "luoyan_list_t*" nested_list;
  
  (* 测试复杂函数类型 *)
  let complex_func = c_type_of_luoyan_type (FunType_T (ListType_T IntType_T, ListType_T StringType_T)) in
  check string "复杂函数类型转换" "luoyan_function_t*" complex_func;
  
  (* 测试复杂记录类型 *)
  let complex_record = c_type_of_luoyan_type (RecordType_T [
    ("整数", IntType_T);
    ("列表", ListType_T StringType_T);
    ("函数", FunType_T (IntType_T, BoolType_T))
  ]) in
  check string "复杂记录类型转换" "luoyan_record_t*" complex_record

(** 上下文状态修改测试 *)
let test_context_state_modification () =
  let config = create_test_config () in
  let ctx = create_context config in
  
  (* 测试变量和标签生成后的状态 *)
  let _var1 = gen_var_name ctx "变量A" in
  let _var2 = gen_var_name ctx "变量B" in
  let _label1 = gen_label_name ctx "标签A" in
  let _label2 = gen_label_name ctx "标签B" in
  
  check int "变量ID状态" 2 ctx.next_var_id;
  check int "标签ID状态" 2 ctx.next_label_id;
  
  (* 测试手动修改可变字段 *)
  ctx.includes <- ["stdio.h"; "stdlib.h"; "luoyan_runtime.h"];
  ctx.global_vars <- ["global_var1"; "global_var2"];
  ctx.functions <- ["main"; "helper_func"];
  
  check (list string) "includes列表修改" ["stdio.h"; "stdlib.h"; "luoyan_runtime.h"] ctx.includes;
  check (list string) "全局变量列表修改" ["global_var1"; "global_var2"] ctx.global_vars;
  check (list string) "函数列表修改" ["main"; "helper_func"] ctx.functions

(** 大量变量名生成性能测试 *)
let test_large_var_generation () =
  let config = create_test_config () in
  let ctx = create_context config in
  
  (* 生成大量变量名 *)
  let var_names = ref [] in
  for i = 0 to 999 do
    let var_name = gen_var_name ctx ("var_" ^ string_of_int i) in
    var_names := var_name :: !var_names
  done;
  
  check int "大量变量生成后的ID" 1000 ctx.next_var_id;
  check int "生成的变量名数量" 1000 (List.length !var_names);
  
  (* 验证变量名的唯一性 *)
  let unique_names = List.sort_uniq String.compare !var_names in
  check int "变量名唯一性" 1000 (List.length unique_names)

(** 大量标签名生成性能测试 *)
let test_large_label_generation () =
  let config = create_test_config () in
  let ctx = create_context config in
  
  (* 生成大量标签名 *)
  let label_names = ref [] in
  for i = 0 to 999 do
    let label_name = gen_label_name ctx ("label_" ^ string_of_int i) in
    label_names := label_name :: !label_names
  done;
  
  check int "大量标签生成后的ID" 1000 ctx.next_label_id;
  check int "生成的标签名数量" 1000 (List.length !label_names);
  
  (* 验证标签名的唯一性 *)
  let unique_names = List.sort_uniq String.compare !label_names in
  check int "标签名唯一性" 1000 (List.length unique_names)

(** 边界条件测试 *)
let test_edge_cases () =
  let config = create_test_config () in
  let ctx = create_context config in
  
  (* 测试极长的标识符名 *)
  let long_name = String.make 1000 'c' in
  let escaped_long = escape_identifier long_name in
  check bool "极长标识符转义不为空" true (String.length escaped_long > 0);
  
  (* 测试空配置字段 *)
  let empty_config = {
    c_output_file = "";
    include_debug = false;
    optimize = false;
    runtime_path = "";
  } in
  let empty_ctx = create_context empty_config in
  check string "空输出文件名" "" empty_ctx.config.c_output_file;
  check string "空运行时路径" "" empty_ctx.config.runtime_path;
  
  (* 测试空字符串变量名生成 *)
  let empty_var = gen_var_name ctx "" in
  check bool "空字符串变量名生成" true (String.length empty_var > 0);
  
  (* 测试空字符串标签名生成 *)
  let empty_label = gen_label_name ctx "" in
  check bool "空字符串标签名生成" true (String.length empty_label > 0)

(** 复杂标识符转义测试 *)
let test_complex_identifier_escaping () =
  (* 测试包含各种Unicode字符的标识符 *)
  let unicode_id = escape_identifier "变量_αβγ_测试_123" in
  check bool "Unicode字符转义" true (String.length unicode_id > 0);
  
  (* 测试包含emoji的标识符 *)
  let emoji_id = escape_identifier "变量_😀_测试" in
  check bool "Emoji字符转义" true (String.length emoji_id > 0);
  
  (* 测试包含空格和制表符的标识符 *)
  let whitespace_id = escape_identifier "变量 \t 测试" in
  check bool "空白字符转义" true (String.length whitespace_id > 0);
  
  (* 测试C关键字冲突 *)
  let keyword_id = escape_identifier "int" in
  check string "C关键字转义" "luoyan_int" keyword_id;
  
  let keyword_id2 = escape_identifier "return" in
  check string "C关键字return转义" "luoyan_return" keyword_id2

(** 类型转换边界条件测试 *)
let test_type_conversion_edge_cases () =
  (* 测试递归类型（这在实际中可能导致无限递归，需要谨慎处理） *)
  let recursive_custom = c_type_of_luoyan_type (ConstructType_T ("递归类型", [])) in
  check string "递归自定义类型转换" "luoyan_user_\233\128\146\229\189\146\231\177\187\229\158\139_t*" recursive_custom;
  
  (* 测试极深嵌套的列表类型 *)
  let deeply_nested = ListType_T (ListType_T (ListType_T (ListType_T IntType_T))) in
  let nested_c_type = c_type_of_luoyan_type deeply_nested in
  check string "深度嵌套列表类型转换" "luoyan_list_t*" nested_c_type;
  
  (* 测试空记录类型 *)
  let empty_record = c_type_of_luoyan_type (RecordType_T []) in
  check string "空记录类型转换" "luoyan_record_t*" empty_record;
  
  (* 测试无参数函数类型 *)
  let no_param_func = c_type_of_luoyan_type (FunType_T (UnitType_T, IntType_T)) in
  check string "无参数函数类型转换" "luoyan_function_t*" no_param_func

(** 测试套件定义 *)
let () =
  run "C_codegen_context 综合测试" [
    "上下文创建和配置", [
      test_case "基础上下文创建" `Quick test_create_context;
      test_case "优化配置测试" `Quick test_optimized_config;
    ];
    "名称生成", [
      test_case "变量名生成" `Quick test_gen_var_name;
      test_case "标签名生成" `Quick test_gen_label_name;
    ];
    "标识符处理", [
      test_case "标识符转义" `Quick test_escape_identifier;
      test_case "复杂标识符转义" `Quick test_complex_identifier_escaping;
    ];
    "类型转换", [
      test_case "基础类型转换" `Quick test_c_type_of_luoyan_type;
      test_case "嵌套类型转换" `Quick test_nested_type_conversion;
      test_case "类型转换边界条件" `Quick test_type_conversion_edge_cases;
    ];
    "状态管理", [
      test_case "上下文状态修改" `Quick test_context_state_modification;
    ];
    "性能测试", [
      test_case "大量变量名生成" `Slow test_large_var_generation;
      test_case "大量标签名生成" `Slow test_large_label_generation;
    ];
    "边界条件和错误处理", [
      test_case "边界条件测试" `Quick test_edge_cases;
    ];
  ]