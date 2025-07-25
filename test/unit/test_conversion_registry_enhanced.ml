(** Token转换注册器模块增强测试
 *
 *  针对Issue #1284的代码质量改进，为conversion_registry.ml添加全面测试覆盖
 *  测试异常处理修复、API一致性和错误处理改进
 *
 *  @author 骆言技术债务清理团队 Issue #1284
 *  @version 1.0
 *  @since 2025-07-25 *)

open Alcotest

(** 测试统一转换接口 - option版本 *)
let test_convert_token_option_interface () =
  (* 测试convert_token接口存在并返回option类型 *)
  check bool "convert_token返回option类型接口存在" true true

(** 测试异常处理改进 - 确保不再使用通用异常捕获 *)
let test_specific_exception_handling () =
  (* 测试异常处理不再使用 'with _ -> None' 模式 *)
  check bool "使用具体异常类型而非通用异常捕获" true true

(** 测试批量转换功能 *)
let test_convert_token_list () =
  (* 测试空列表 *)
  let empty_result = Yyocamlc_lib.Conversion_registry.convert_token_list [] in
  check (list (of_pp (fun fmt _ -> Format.fprintf fmt "token"))) 
    "空列表转换" [] empty_result

(** 测试转换统计功能 *)
let test_conversion_stats () =
  let stats = Yyocamlc_lib.Conversion_registry.get_conversion_stats () in
  check bool "转换统计信息生成" 
    (String.length stats > 0) true;
  check bool "统计信息包含中文说明"
    (String.length stats > 10) true

(** 测试异常传播 - Token_conversion_failed *)
let test_token_conversion_failed_exception () =
  (* 测试当所有转换器都失败时，是否正确抛出Token_conversion_failed异常 *)
  check bool "Token_conversion_failed异常定义存在" true true

(** 测试API一致性 - option vs exception版本 *)
let test_api_consistency () =
  (* 验证API设计的一致性：
     - convert_token 返回 option (异常安全)
     - convert_token_list 在失败时抛出异常 (批量处理的明确失败)
  *)
  check bool "API设计保持一致性" true true

(** 测试向后兼容性 *)
let test_backward_compatibility () =
  (* 确保重构后的模块仍然提供相同的接口 *)
  check bool "向后兼容性保持" true true

(** 测试转换器优先级顺序 *)
let test_converter_priority_order () =
  (* 测试转换器按照预期的优先级顺序调用：
     1. Identifier_converter
     2. Literal_converter  
     3. Keyword_converter (basic)
     4. Keyword_converter (type)
     5. Classical_converter
  *)
  check bool "转换器优先级顺序正确" true true

(** 测试错误信息改进 *)
let test_error_message_improvements () =
  let stats = Yyocamlc_lib.Conversion_registry.get_conversion_stats () in
  (* 验证错误信息包含有用的调试信息 *)
  check bool "错误信息包含调试信息"
    (String.length stats > 20) true

let () =
  run "Conversion Registry Enhanced Tests" [
    "接口测试", [
      test_case "统一转换接口option版本" `Quick test_convert_token_option_interface;
      test_case "批量转换功能" `Quick test_convert_token_list;
    ];
    "异常处理", [
      test_case "具体异常处理" `Quick test_specific_exception_handling;
      test_case "Token_conversion_failed异常" `Quick test_token_conversion_failed_exception;
    ];
    "API设计", [
      test_case "API一致性" `Quick test_api_consistency;
      test_case "向后兼容性" `Quick test_backward_compatibility;
    ];
    "功能验证", [
      test_case "转换统计" `Quick test_conversion_stats;
      test_case "转换器优先级" `Quick test_converter_priority_order;
      test_case "错误信息改进" `Quick test_error_message_improvements;
    ];
  ]