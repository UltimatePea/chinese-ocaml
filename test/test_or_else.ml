open Alcotest
open Ast
open Codegen

(** 测试"否则返回"语法 *)

let test_or_else_basic () =
  let options = { recovery_mode = true } in

  (* 测试正常值，不使用默认值 *)
  let expr1 = OrElseExpr (LitExpr (IntLit 42), LitExpr (IntLit 0)) in
  let result1 = eval_expr [] expr1 in
  check (module IntValue_testable) "正常值应该直接返回" (IntValue 42) result1;

  (* 测试单元值，使用默认值 *)
  let expr2 = OrElseExpr (LitExpr UnitLit, LitExpr (IntLit 99)) in
  let result2 = eval_expr [] expr2 in
  check (module IntValue_testable) "单元值应该使用默认值" (IntValue 99) result2

let test_or_else_with_errors () =
  let options = { recovery_mode = true } in

  (* 测试变量不存在的错误情况 *)
  let expr = OrElseExpr (VarExpr "undefined_var", LitExpr (StringLit "默认值")) in
  let result = eval_expr [] expr in
  check (module StringValue_testable) "错误时应该返回默认值" (StringValue "默认值") result

let test_or_else_nested () =
  let options = { recovery_mode = true } in

  (* 测试嵌套的否则返回 *)
  let expr =
    OrElseExpr (OrElseExpr (VarExpr "undefined", LitExpr UnitLit), LitExpr (StringLit "最终默认值"))
  in
  let result = eval_expr [] expr in
  check (module StringValue_testable) "嵌套否则返回应该工作" (StringValue "最终默认值") result

let test_or_else_with_computation () =
  let options = { recovery_mode = true } in

  (* 测试带计算的表达式 *)
  let good_expr = BinaryOpExpr (LitExpr (IntLit 10), Add, LitExpr (IntLit 5)) in
  let or_else_expr = OrElseExpr (good_expr, LitExpr (IntLit 0)) in
  let result = eval_expr [] or_else_expr in
  check (module IntValue_testable) "正常计算应该返回结果" (IntValue 15) result

(* 辅助模块用于测试 *)
module IntValue_testable = struct
  type t = runtime_value

  let pp fmt = function
    | IntValue i -> Format.fprintf fmt "IntValue %d" i
    | _ -> Format.fprintf fmt "Not IntValue"

  let equal v1 v2 = match (v1, v2) with IntValue i1, IntValue i2 -> i1 = i2 | _ -> false
end

module StringValue_testable = struct
  type t = runtime_value

  let pp fmt = function
    | StringValue s -> Format.fprintf fmt "StringValue %s" s
    | _ -> Format.fprintf fmt "Not StringValue"

  let equal v1 v2 = match (v1, v2) with StringValue s1, StringValue s2 -> s1 = s2 | _ -> false
end

(** 测试套件 *)
let () =
  run "OrElse语法测试"
    [
      ("基础否则返回", [ test_case "正常值和默认值" `Quick test_or_else_basic ]);
      ("错误处理", [ test_case "变量未定义时使用默认值" `Quick test_or_else_with_errors ]);
      ( "复杂用法",
        [
          test_case "嵌套否则返回" `Quick test_or_else_nested;
          test_case "带计算的表达式" `Quick test_or_else_with_computation;
        ] );
    ]
