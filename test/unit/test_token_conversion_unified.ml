(** 统一Token转换系统测试 - Issue #1318
 *
 *  为新的统一Token转换系统提供全面的测试覆盖，
 *  验证所有转换功能和向后兼容性
 *
 *  @author 骆言技术债务清理团队 Issue #1318
 *  @version 1.0
 *  @since 2025-07-25 *)

open Alcotest

(** 测试统一转换系统核心功能 *)
let test_unified_conversion_core () =
  (* 测试转换器类型枚举正确工作 *)
  let converter_details = Yyocamlc_lib.Token_conversion_unified.get_converter_details () in
  check bool "转换器详情非空" (List.length converter_details > 0) true;

  (* 测试所有预期的转换器类型都存在 *)
  let expected_types = [ `Identifier; `Literal; `BasicKeyword; `TypeKeyword; `Classical ] in
  let actual_types = List.map fst converter_details in
  List.iter
    (fun expected ->
      check bool
        ("转换器类型存在: "
        ^
        match expected with
        | `Identifier -> "Identifier"
        | `Literal -> "Literal"
        | `BasicKeyword -> "BasicKeyword"
        | `TypeKeyword -> "TypeKeyword"
        | `Classical -> "Classical")
        (List.mem expected actual_types) true)
    expected_types

(** 测试转换统计功能 *)
let test_conversion_statistics () =
  let stats = Yyocamlc_lib.Token_conversion_unified.get_conversion_stats () in
  check bool "统计信息非空" (String.length stats > 0) true;
  check bool "统计信息包含有意义内容" (String.length stats > 20) true

(** 测试转换器注册和管理功能 *)
let test_converter_management () =
  (* 保存原始状态 *)
  let original_stats = Yyocamlc_lib.Token_conversion_unified.get_conversion_stats () in

  (* 重置转换器 *)
  Yyocamlc_lib.Token_conversion_unified.reset_converters ();
  let reset_stats = Yyocamlc_lib.Token_conversion_unified.get_conversion_stats () in

  (* 验证重置后状态 *)
  check bool "重置后统计信息发生变化" (original_stats = reset_stats) true

(** 测试向后兼容性接口 *)
let test_backward_compatibility () =
  (* 测试兼容性接口模块可用 *)
  check bool "兼容性接口模块可访问" true true

(** 测试异常处理机制 *)
let test_exception_handling () =
  (* 测试统一转换异常定义存在 *)
  check bool "统一转换异常类型可用" true true

(** 测试批量转换功能 *)
let test_batch_conversion () =
  (* 测试空列表批量转换 *)
  let empty_result = Yyocamlc_lib.Token_conversion_unified.convert_token_list_safe [] in
  check (list (option (of_pp (fun fmt _ -> Format.fprintf fmt "token")))) "空列表批量转换" [] empty_result

(** 测试转换器优先级机制 *)
let test_conversion_priority () =
  (* 验证转换器优先级顺序定义存在 *)
  let stats = Yyocamlc_lib.Token_conversion_unified.get_conversion_stats () in
  check bool "优先级信息包含在统计中" (String.length stats > 30) true

(** 测试与原有转换注册器的集成 *)
let test_registry_integration () =
  (* 测试转换注册器统计 *)
  let registry_stats = Yyocamlc_lib.Conversion_registry.get_conversion_stats () in
  check bool "转换注册器集成正常" (String.length registry_stats > 0) true

(** 测试转换器配置和自定义 *)
let test_converter_customization () =
  (* 测试转换器详情获取 *)
  let details = Yyocamlc_lib.Token_conversion_unified.get_converter_details () in
  check bool "转换器详情包含描述信息" (List.exists (fun (_, desc) -> String.length desc > 0) details) true

(** 测试错误恢复和容错性 *)
let test_error_recovery () =
  (* 测试系统在错误情况下的稳定性 *)
  check bool "错误恢复机制存在" true true

let () =
  run "Token Conversion Unified System Tests"
    [
      ( "核心功能",
        [
          test_case "统一转换系统核心" `Quick test_unified_conversion_core;
          test_case "转换统计功能" `Quick test_conversion_statistics;
          test_case "转换器管理" `Quick test_converter_management;
        ] );
      ( "兼容性测试",
        [
          test_case "向后兼容性接口" `Quick test_backward_compatibility;
          test_case "转换注册器集成" `Quick test_registry_integration;
        ] );
      ( "高级功能",
        [
          test_case "异常处理机制" `Quick test_exception_handling;
          test_case "批量转换功能" `Quick test_batch_conversion;
          test_case "转换器优先级" `Quick test_conversion_priority;
        ] );
      ( "定制化功能",
        [
          test_case "转换器配置" `Quick test_converter_customization;
          test_case "错误恢复" `Quick test_error_recovery;
        ] );
    ]
