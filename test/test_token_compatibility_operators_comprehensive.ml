(** Token兼容性运算符映射测试套件 - 全面覆盖所有运算符映射功能
    
    测试目标: token_compatibility_operators.ml
    覆盖范围: 
    - 算术运算符映射（+、-、*、/、%、**）
    - 比较运算符映射（=、<>、<、>、<=、>=）
    - 逻辑运算符映射（&&、||、not）
    - 赋值运算符映射（:=、<-）
    - 其他运算符映射（::、->、|>、<|）
    - 边界条件和错误情况
    
    @version 1.0
    @since 2025-07-23 *)

open Yyocamlc_lib
open Token_compatibility_operators
open Unified_token_core

(** 算术运算符测试组 *)
let test_arithmetic_operators () =
  (* 基础算术运算符 *)
  assert (map_legacy_operator_to_unified "PlusOp" = Some PlusOp);
  assert (map_legacy_operator_to_unified "MinusOp" = Some MinusOp);
  assert (map_legacy_operator_to_unified "MultOp" = Some MultiplyOp);
  assert (map_legacy_operator_to_unified "DivOp" = Some DivideOp);
  assert (map_legacy_operator_to_unified "ModOp" = Some ModOp);
  assert (map_legacy_operator_to_unified "PowerOp" = Some PowerOp);
  
  print_endline "✅ 算术运算符映射测试通过"

(** 比较运算符测试组 *)
let test_comparison_operators () =
  (* 基础比较运算符 *)
  assert (map_legacy_operator_to_unified "EqualOp" = Some EqualOp);
  assert (map_legacy_operator_to_unified "NotEqualOp" = Some NotEqualOp);
  assert (map_legacy_operator_to_unified "LessOp" = Some LessOp);
  assert (map_legacy_operator_to_unified "GreaterOp" = Some GreaterOp);
  assert (map_legacy_operator_to_unified "LessEqualOp" = Some LessEqualOp);
  assert (map_legacy_operator_to_unified "GreaterEqualOp" = Some GreaterEqualOp);
  
  print_endline "✅ 比较运算符映射测试通过"

(** 逻辑运算符测试组 *)
let test_logical_operators () =
  (* 基础逻辑运算符 *)
  assert (map_legacy_operator_to_unified "AndOp" = Some LogicalAndOp);
  assert (map_legacy_operator_to_unified "OrOp" = Some LogicalOrOp);
  assert (map_legacy_operator_to_unified "NotOp" = Some LogicalNotOp);
  
  print_endline "✅ 逻辑运算符映射测试通过"

(** 赋值运算符测试组 *)
let test_assignment_operators () =
  (* 基础赋值运算符 *)
  assert (map_legacy_operator_to_unified "AssignOp" = Some AssignOp);
  
  (* 引用赋值运算符 - 应该映射到普通赋值 *)
  assert (map_legacy_operator_to_unified "RefAssignOp" = Some AssignOp);
  
  print_endline "✅ 赋值运算符映射测试通过"

(** 其他特殊运算符测试组 *)  
let test_special_operators () =
  (* 列表构造运算符 *)
  assert (map_legacy_operator_to_unified "ConsOp" = Some ConsOp);
  
  (* 函数箭头运算符 *)
  assert (map_legacy_operator_to_unified "ArrowOp" = Some ArrowOp);
  
  (* 管道运算符 *)
  assert (map_legacy_operator_to_unified "PipeRightOp" = Some PipeOp);
  assert (map_legacy_operator_to_unified "PipeLeftOp" = Some PipeBackOp);
  
  print_endline "✅ 特殊运算符映射测试通过"

(** 错误情况和边界条件测试组 *)
let test_invalid_operators () =
  (* 不支持的运算符应该返回None *)
  assert (map_legacy_operator_to_unified "InvalidOp" = None);
  assert (map_legacy_operator_to_unified "UnknownOperator" = None);
  assert (map_legacy_operator_to_unified "NotAnOperator" = None);
  
  (* 空字符串 *)
  assert (map_legacy_operator_to_unified "" = None);
  
  (* 大小写错误的运算符 *)
  assert (map_legacy_operator_to_unified "plusop" = None);
  assert (map_legacy_operator_to_unified "PLUSOP" = None);
  assert (map_legacy_operator_to_unified "Plus" = None);
  
  print_endline "✅ 无效运算符处理测试通过"

(** 边界条件测试 *)
let test_edge_cases () =
  (* 部分匹配的字符串 *)
  assert (map_legacy_operator_to_unified "Plus" = None);
  assert (map_legacy_operator_to_unified "OpPlus" = None);
  assert (map_legacy_operator_to_unified "PlusOperator" = None);
  
  (* 包含空格的字符串 *)
  assert (map_legacy_operator_to_unified " PlusOp" = None);
  assert (map_legacy_operator_to_unified "PlusOp " = None);
  assert (map_legacy_operator_to_unified " PlusOp " = None);
  
  (* 特殊字符 *)
  assert (map_legacy_operator_to_unified "+" = None);
  assert (map_legacy_operator_to_unified "-" = None);
  assert (map_legacy_operator_to_unified "*" = None);
  assert (map_legacy_operator_to_unified "/" = None);
  
  print_endline "✅ 边界条件测试通过"

(** 性能和压力测试 *)
let test_performance () =
  (* 测试大量映射操作的性能 *)
  let operators = [
    "PlusOp"; "MinusOp"; "MultOp"; "DivOp"; "ModOp"; "PowerOp";
    "EqualOp"; "NotEqualOp"; "LessOp"; "GreaterOp"; "LessEqualOp"; "GreaterEqualOp";
    "AndOp"; "OrOp"; "NotOp"; "AssignOp"; "RefAssignOp";
    "ConsOp"; "ArrowOp"; "PipeRightOp"; "PipeLeftOp"
  ] in
  
  (* 执行多次映射操作测试性能 *)
  for _ = 1 to 1000 do
    List.iter (fun op ->
      ignore (map_legacy_operator_to_unified op)
    ) operators
  done;
  
  (* 测试无效运算符的性能 *)
  let invalid_operators = Array.init 100 (fun i -> "InvalidOp" ^ string_of_int i) in
  Array.iter (fun op ->
    ignore (map_legacy_operator_to_unified op)
  ) invalid_operators;
  
  print_endline "✅ 性能压力测试通过"

(** 全面的运算符映射测试 *)
let test_comprehensive_operator_mapping () =
  let test_cases = [
    (* 算术运算符 *)
    ("PlusOp", Some PlusOp);
    ("MinusOp", Some MinusOp);
    ("MultOp", Some MultiplyOp);
    ("DivOp", Some DivideOp);
    ("ModOp", Some ModOp);
    ("PowerOp", Some PowerOp);
    
    (* 比较运算符 *)
    ("EqualOp", Some EqualOp);
    ("NotEqualOp", Some NotEqualOp);
    ("LessOp", Some LessOp);
    ("GreaterOp", Some GreaterOp);
    ("LessEqualOp", Some LessEqualOp);
    ("GreaterEqualOp", Some GreaterEqualOp);
    
    (* 逻辑运算符 *)
    ("AndOp", Some LogicalAndOp);
    ("OrOp", Some LogicalOrOp);
    ("NotOp", Some LogicalNotOp);
    
    (* 赋值运算符 *)
    ("AssignOp", Some AssignOp);
    ("RefAssignOp", Some AssignOp);
    
    (* 特殊运算符 *)
    ("ConsOp", Some ConsOp);
    ("ArrowOp", Some ArrowOp);
    ("PipeRightOp", Some PipeOp);
    ("PipeLeftOp", Some PipeBackOp);
    
    (* 无效运算符 *)
    ("InvalidOp", None);
    ("", None);
    ("Plus", None);
  ] in
  
  List.iter (fun (input, expected) ->
    let result = map_legacy_operator_to_unified input in
    assert (result = expected)
  ) test_cases;
  
  print_endline "✅ 综合运算符映射测试通过"

(** 类型一致性测试 *)
let test_type_consistency () =
  (* 验证返回的token类型与预期一致 *)
  (match map_legacy_operator_to_unified "PlusOp" with
  | Some PlusOp -> ()
  | _ -> assert false);
  
  (match map_legacy_operator_to_unified "EqualOp" with  
  | Some EqualOp -> ()
  | _ -> assert false);
  
  (match map_legacy_operator_to_unified "AndOp" with
  | Some LogicalAndOp -> ()
  | _ -> assert false);
  
  print_endline "✅ 类型一致性测试通过"

(** 主测试运行器 *)
let run_all_tests () =
  print_endline "🧪 开始Token兼容性运算符映射全面测试...";
  print_endline "";
  
  (* 基础功能测试 *)
  test_arithmetic_operators ();
  test_comparison_operators ();
  test_logical_operators ();
  test_assignment_operators ();
  test_special_operators ();
  
  (* 错误处理测试 *)
  test_invalid_operators ();
  test_edge_cases ();
  
  (* 性能测试 *)
  test_performance ();
  
  (* 综合测试 *)
  test_comprehensive_operator_mapping ();
  test_type_consistency ();
  
  print_endline "";
  print_endline "🎉 所有Token兼容性运算符映射测试完成！";
  print_endline "📊 测试覆盖范围：";
  print_endline "   - 算术运算符映射: ✅";
  print_endline "   - 比较运算符映射: ✅";
  print_endline "   - 逻辑运算符映射: ✅";
  print_endline "   - 赋值运算符映射: ✅";
  print_endline "   - 特殊运算符映射: ✅";
  print_endline "   - 无效运算符处理: ✅";
  print_endline "   - 边界条件处理: ✅";
  print_endline "   - 性能压力测试: ✅";
  print_endline "   - 类型一致性验证: ✅"

(* 如果直接运行此文件，执行所有测试 *)
let () = run_all_tests ()