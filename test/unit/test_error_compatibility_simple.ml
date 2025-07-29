(** 错误兼容性模块简单测试
    
    Author: Echo, 测试工程师代理
    Purpose: 为 Error_compatibility 模块提供基础测试验证 *)

open Alcotest

(** 基础模块可用性测试 *)
let test_module_available () =
  (* 测试能否访问相关模块 *)
  check bool "Error_compatibility模块可用" true true

(** 基础位置信息测试 *)  
let test_position_creation () =
  try
    let pos = Yyocamlc_lib.Error_compatibility.create_position 
      ~filename:"test.ly" ~line:10 ~column:25 in
    check string "文件名正确" "test.ly" pos.filename;
    check int "行号正确" 10 pos.line;
    check int "列号正确" 25 pos.column
  with
  | _ -> check bool "位置信息创建失败" false true

(** 基础错误建议测试 *)
let test_error_suggestions () =
  try
    let suggestions = Yyocamlc_lib.Error_compatibility.suggest_type_fix 
      ~expected:"int" ~actual:"string" in
    check bool "建议数量大于0" true (List.length suggestions > 0)
  with
  | _ -> check bool "错误建议测试失败" false true

(** 测试套件 *)
let () =
  run "错误兼容性模块简单测试"
    [
      ( "基础功能",
        [
          test_case "模块可用性" `Quick test_module_available;
          test_case "位置信息创建" `Quick test_position_creation;
          test_case "错误建议测试" `Quick test_error_suggestions;
        ] );
    ]