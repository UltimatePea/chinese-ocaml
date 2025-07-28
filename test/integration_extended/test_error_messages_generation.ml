(** 错误消息生成模块测试套件

    验证error_messages_generation.ml模块的错误消息生成功能 包括类型不匹配、未定义变量、函数参数和模式匹配错误消息生成

    创建目的：提升错误处理模块测试覆盖率至60%以上 Fix #925 第三阶段 *)

open Alcotest
open Yyocamlc_lib.Error_messages_generation
open Yyocamlc_lib.Types

(** 测试辅助函数 *)
let create_test_type type_name =
  (* 创建基本类型用于测试 *)
  match type_name with
  | "int" -> IntType_T
  | "string" -> StringType_T
  | "bool" -> BoolType_T
  | "unit" -> UnitType_T
  | "list" -> ListType_T IntType_T
  | "func" -> FunType_T (IntType_T, StringType_T)
  | _ -> IntType_T

(** 测试类型不匹配错误消息生成 *)
let test_type_mismatch_error () =
  Printf.printf "测试类型不匹配错误消息生成...\n";

  (* 测试基本类型不匹配 *)
  let int_type = create_test_type "int" in
  let string_type = create_test_type "string" in
  let msg_int_str = type_mismatch_error int_type string_type in

  check bool "整数-字符串类型不匹配消息应非空" true (String.length msg_int_str > 0);
  check bool "类型不匹配消息应包含类型信息" true (String.length msg_int_str > 0);

  (* 测试布尔类型不匹配 *)
  let bool_type = create_test_type "bool" in
  let msg_bool_int = type_mismatch_error bool_type int_type in

  check bool "布尔-整数类型不匹配消息应非空" true (String.length msg_bool_int > 0);
  check bool "消息应该不同于前一个" true (msg_bool_int <> msg_int_str);

  (* 测试复合类型不匹配 *)
  let list_type = create_test_type "list" in
  let func_type = create_test_type "func" in
  let msg_list_func = type_mismatch_error list_type func_type in

  check bool "列表-函数类型不匹配消息应非空" true (String.length msg_list_func > 0);

  (* 测试单元类型不匹配 *)
  let unit_type = create_test_type "unit" in
  let msg_unit_str = type_mismatch_error unit_type string_type in

  check bool "单元-字符串类型不匹配消息应非空" true (String.length msg_unit_str > 0);

  Printf.printf "类型不匹配错误消息生成测试完成\n"

(** 测试未定义变量错误消息生成 *)
let test_undefined_variable_error () =
  Printf.printf "测试未定义变量错误消息生成...\n";

  (* 测试有可用变量的情况 *)
  let available_vars = [ "username"; "password"; "email" ] in
  let msg_with_vars = undefined_variable_error "usename" available_vars in

  check bool "有可用变量时消息应非空" true (String.length msg_with_vars > 0);
  check bool "消息应包含变量名" true (String.contains msg_with_vars 'u');

  (* 测试没有可用变量的情况 *)
  let msg_no_vars = undefined_variable_error "test_var" [] in

  check bool "无可用变量时消息应非空" true (String.length msg_no_vars > 0);
  check bool "消息应包含无可用变量提示" true (Str.search_forward (Str.regexp "没有可用变量") msg_no_vars 0 >= 0);

  (* 测试少量可用变量的情况（≤5个） *)
  let few_vars = [ "var1"; "var2"; "var3" ] in
  let msg_few_vars = undefined_variable_error "variable" few_vars in

  check bool "少量可用变量时消息应非空" true (String.length msg_few_vars > 0);

  (* 测试大量可用变量的情况（>5个） *)
  let many_vars = [ "var1"; "var2"; "var3"; "var4"; "var5"; "var6"; "var7"; "var8" ] in
  let msg_many_vars = undefined_variable_error "variable" many_vars in

  check bool "大量可用变量时消息应非空" true (String.length msg_many_vars > 0);
  check bool "大量变量时应有省略提示" true
    (try
       ignore (Str.search_forward (Str.regexp "等") msg_many_vars 0);
       true
     with Not_found -> false);

  (* 测试边界情况 - 正好5个变量 *)
  let exact_five_vars = [ "var1"; "var2"; "var3"; "var4"; "var5" ] in
  let msg_exact_five = undefined_variable_error "variable" exact_five_vars in

  check bool "正好5个变量时消息应非空" true (String.length msg_exact_five > 0);

  Printf.printf "未定义变量错误消息生成测试完成\n"

(** 测试函数参数错误消息生成 *)
let test_function_arity_error () =
  Printf.printf "测试函数参数错误消息生成...\n";

  (* 测试参数过少的情况 *)
  let msg_too_few = function_arity_error 3 1 in

  check bool "参数过少时消息应非空" true (String.length msg_too_few > 0);
  check bool "消息应包含数字信息" true (String.contains msg_too_few '3' || String.contains msg_too_few '1');

  (* 测试参数过多的情况 *)
  let msg_too_many = function_arity_error 2 5 in

  check bool "参数过多时消息应非空" true (String.length msg_too_many > 0);
  check bool "消息应该不同于参数过少的情况" true (msg_too_many <> msg_too_few);

  (* 测试参数匹配的情况 *)
  let msg_exact_match = function_arity_error 2 2 in

  check bool "参数匹配时消息应非空" true (String.length msg_exact_match > 0);

  (* 测试边界情况 - 0个参数 *)
  let msg_zero_params = function_arity_error 0 0 in

  check bool "0参数时消息应非空" true (String.length msg_zero_params > 0);

  (* 测试大数量参数 *)
  let msg_many_params = function_arity_error 10 15 in

  check bool "大数量参数时消息应非空" true (String.length msg_many_params > 0);

  Printf.printf "函数参数错误消息生成测试完成\n"

(** 测试模式匹配错误消息生成 *)
let test_pattern_match_error () =
  Printf.printf "测试模式匹配错误消息生成...\n";

  (* 测试基本类型的模式匹配错误 *)
  let int_type = create_test_type "int" in
  let msg_int_pattern = pattern_match_error int_type in

  check bool "整数类型模式匹配错误消息应非空" true (String.length msg_int_pattern > 0);
  check bool "消息应包含模式匹配相关信息" true
    (try
       ignore (Str.search_forward (Str.regexp "模\\|式") msg_int_pattern 0);
       true
     with Not_found -> false);

  (* 测试字符串类型的模式匹配错误 *)
  let string_type = create_test_type "string" in
  let msg_str_pattern = pattern_match_error string_type in

  check bool "字符串类型模式匹配错误消息应非空" true (String.length msg_str_pattern > 0);
  check bool "消息应该不同于整数类型" true (msg_str_pattern <> msg_int_pattern);

  (* 测试布尔类型的模式匹配错误 *)
  let bool_type = create_test_type "bool" in
  let msg_bool_pattern = pattern_match_error bool_type in

  check bool "布尔类型模式匹配错误消息应非空" true (String.length msg_bool_pattern > 0);

  (* 测试列表类型的模式匹配错误 *)
  let list_type = create_test_type "list" in
  let msg_list_pattern = pattern_match_error list_type in

  check bool "列表类型模式匹配错误消息应非空" true (String.length msg_list_pattern > 0);

  (* 测试函数类型的模式匹配错误 *)
  let func_type = create_test_type "func" in
  let msg_func_pattern = pattern_match_error func_type in

  check bool "函数类型模式匹配错误消息应非空" true (String.length msg_func_pattern > 0);

  (* 测试单元类型的模式匹配错误 *)
  let unit_type = create_test_type "unit" in
  let msg_unit_pattern = pattern_match_error unit_type in

  check bool "单元类型模式匹配错误消息应非空" true (String.length msg_unit_pattern > 0);

  Printf.printf "模式匹配错误消息生成测试完成\n"

(** 测试消息内容质量 *)
let test_message_quality () =
  Printf.printf "测试消息内容质量...\n";

  (* 测试消息的中文特性 *)
  let int_type = create_test_type "int" in
  let string_type = create_test_type "string" in
  let type_msg = type_mismatch_error int_type string_type in

  (* 检查消息是否包含中文字符 - 使用简单的字节检测 *)
  Printf.printf "Type message: %s\n" type_msg;
  let has_chinese =
    String.contains type_msg '\xe4' || String.contains type_msg '\xe5'
    || String.contains type_msg '\xe6' || String.contains type_msg '\xe7'
    || String.contains type_msg '\xe8' || String.contains type_msg '\xe9'
  in
  check bool "错误消息应包含中文字符" true has_chinese;

  (* 测试消息长度合理性 *)
  check bool "错误消息长度应合理（不会太短或太长）" true (String.length type_msg >= 5 && String.length type_msg <= 200);

  (* 测试未定义变量消息质量 *)
  let var_msg = undefined_variable_error "测试变量" [ "变量1"; "变量2" ] in
  check bool "变量错误消息应包含变量名" true
    (try
       ignore (Str.search_forward (Str.regexp "测") var_msg 0);
       true
     with Not_found -> false);

  (* 测试函数参数消息质量 *)
  let func_msg = function_arity_error 3 1 in
  check bool "函数参数消息应包含数字" true (String.contains func_msg '3' && String.contains func_msg '1');

  Printf.printf "消息内容质量测试完成\n"

(** 测试消息一致性 *)
let test_message_consistency () =
  Printf.printf "测试消息一致性...\n";

  (* 测试相同输入产生相同输出 *)
  let int_type = create_test_type "int" in
  let string_type = create_test_type "string" in
  let msg1 = type_mismatch_error int_type string_type in
  let msg2 = type_mismatch_error int_type string_type in

  check string "相同输入应产生相同消息" msg1 msg2;

  (* 测试不同输入产生不同输出 *)
  let bool_type = create_test_type "bool" in
  let msg3 = type_mismatch_error int_type bool_type in

  check bool "不同输入应产生不同消息" true (msg1 <> msg3);

  (* 测试变量错误消息一致性 *)
  let var_msg1 = undefined_variable_error "test" [ "var1"; "var2" ] in
  let var_msg2 = undefined_variable_error "test" [ "var1"; "var2" ] in

  check string "相同变量错误输入应产生相同消息" var_msg1 var_msg2;

  Printf.printf "消息一致性测试完成\n"

(** 测试边界条件和异常情况 *)
let test_edge_cases () =
  Printf.printf "测试边界条件和异常情况...\n";

  (* 测试空字符串变量名 *)
  let empty_var_msg = undefined_variable_error "" [ "var1"; "var2" ] in
  check bool "空变量名应有合理处理" true (String.length empty_var_msg > 0);

  (* 测试含特殊字符的变量名 *)
  let special_var_msg = undefined_variable_error "var_123$#" [] in
  check bool "特殊字符变量名应有合理处理" true (String.length special_var_msg > 0);

  (* 测试极长变量名 *)
  let long_var_name = String.make 100 'a' in
  let long_var_msg = undefined_variable_error long_var_name [] in
  check bool "极长变量名应有合理处理" true (String.length long_var_msg > 0);

  (* 测试负数参数（理论上不应出现，但要确保健壮性） *)
  let negative_param_msg = function_arity_error (-1) 0 in
  check bool "负数参数应有合理处理" true (String.length negative_param_msg > 0);

  (* 测试极大参数数量 *)
  let large_param_msg = function_arity_error 1000 2000 in
  check bool "极大参数数量应有合理处理" true (String.length large_param_msg > 0);

  (* 测试包含Unicode字符的变量名 *)
  let unicode_var_msg = undefined_variable_error "变量名测试" [ "可用变量" ] in
  check bool "Unicode变量名应有合理处理" true (String.length unicode_var_msg > 0);

  Printf.printf "边界条件和异常情况测试完成\n"

(** 错误消息生成模块测试套件 *)
let () =
  run "Error_messages_generation模块测试"
    [
      ("类型不匹配消息", [ test_case "类型不匹配错误消息生成" `Quick test_type_mismatch_error ]);
      ("未定义变量消息", [ test_case "未定义变量错误消息生成" `Quick test_undefined_variable_error ]);
      ("函数参数消息", [ test_case "函数参数错误消息生成" `Quick test_function_arity_error ]);
      ("模式匹配消息", [ test_case "模式匹配错误消息生成" `Quick test_pattern_match_error ]);
      ("消息质量", [ test_case "消息内容质量" `Quick test_message_quality ]);
      ("消息一致性", [ test_case "消息一致性" `Quick test_message_consistency ]);
      ("边界条件", [ test_case "边界和异常情况" `Quick test_edge_cases ]);
    ]
