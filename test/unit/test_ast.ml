open Alcotest
open Yyocamlc_lib.Ast

let test_ast_construction () =
  let int_expr = make_int 42 in
  let string_expr = make_string "hello" in
  let bool_expr = make_bool true in
  let var_expr = make_var "x" in
  
  check (testable (fun fmt expr ->
    match expr with
    | LitExpr (IntLit i) -> Format.fprintf fmt "IntLit(%d)" i
    | LitExpr (StringLit s) -> Format.fprintf fmt "StringLit(%s)" s
    | LitExpr (BoolLit b) -> Format.fprintf fmt "BoolLit(%b)" b
    | VarExpr v -> Format.fprintf fmt "VarExpr(%s)" v
    | _ -> Format.fprintf fmt "Other"
  ) (fun a b -> equal_expr a b)) "整数表达式构造" (LitExpr (IntLit 42)) int_expr;
  
  check (testable (fun fmt expr ->
    match expr with
    | LitExpr (StringLit s) -> Format.fprintf fmt "StringLit(%s)" s
    | _ -> Format.fprintf fmt "Other"
  ) (fun a b -> equal_expr a b)) "字符串表达式构造" (LitExpr (StringLit "hello")) string_expr;
  
  check (testable (fun fmt expr ->
    match expr with
    | LitExpr (BoolLit b) -> Format.fprintf fmt "BoolLit(%b)" b
    | _ -> Format.fprintf fmt "Other"
  ) (fun a b -> equal_expr a b)) "布尔表达式构造" (LitExpr (BoolLit true)) bool_expr;
  
  check (testable (fun fmt expr ->
    match expr with
    | VarExpr v -> Format.fprintf fmt "VarExpr(%s)" v
    | _ -> Format.fprintf fmt "Other"
  ) (fun a b -> equal_expr a b)) "变量表达式构造" (VarExpr "x") var_expr

let test_binary_operations () =
  let add_expr = make_binary_op (make_int 1) Add (make_int 2) in
  let sub_expr = make_binary_op (make_int 5) Sub (make_int 3) in
  
  check (testable (fun fmt expr ->
    match expr with
    | BinaryOpExpr (left, op, right) ->
        Format.fprintf fmt "BinaryOpExpr(%s, %s, %s)" 
          (match left with LitExpr (IntLit i) -> string_of_int i | _ -> "?")
          (show_binary_op op)
          (match right with LitExpr (IntLit i) -> string_of_int i | _ -> "?")
    | _ -> Format.fprintf fmt "Other"
  ) (fun a b -> equal_expr a b)) "加法表达式构造" 
    (BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2))) add_expr;
  
  check (testable (fun fmt expr ->
    match expr with
    | BinaryOpExpr (left, op, right) ->
        Format.fprintf fmt "BinaryOpExpr(%s, %s, %s)" 
          (match left with LitExpr (IntLit i) -> string_of_int i | _ -> "?")
          (show_binary_op op)
          (match right with LitExpr (IntLit i) -> string_of_int i | _ -> "?")
    | _ -> Format.fprintf fmt "Other"
  ) (fun a b -> equal_expr a b)) "减法表达式构造" 
    (BinaryOpExpr (LitExpr (IntLit 5), Sub, LitExpr (IntLit 3))) sub_expr

let test_function_call () =
  let func_expr = make_var "print" in
  let args = [make_string "hello"; make_int 42] in
  let call_expr = make_call func_expr args in
  
  check (testable (fun fmt expr ->
    match expr with
    | FunCallExpr (func, args) ->
        Format.fprintf fmt "FunCallExpr(%s, [%d args])" 
          (match func with VarExpr name -> name | _ -> "?") (List.length args)
    | _ -> Format.fprintf fmt "Other"
  ) (fun a b -> equal_expr a b)) "函数调用表达式构造" 
    (FunCallExpr (VarExpr "print", [LitExpr (StringLit "hello"); LitExpr (IntLit 42)])) call_expr


let test_complex_expressions () =
  let nested_expr = make_binary_op 
    (make_binary_op (make_int 1) Add (make_int 2))
    Mul
    (make_binary_op (make_int 3) Sub (make_int 4)) in
  
  check (testable (fun fmt expr ->
    match expr with
    | BinaryOpExpr (BinaryOpExpr (LitExpr (IntLit i1), op1, LitExpr (IntLit i2)), op_main, 
                    BinaryOpExpr (LitExpr (IntLit i3), op2, LitExpr (IntLit i4))) ->
        Format.fprintf fmt "BinaryOpExpr(BinaryOpExpr(%d, %s, %d), %s, BinaryOpExpr(%d, %s, %d))"
          i1 (show_binary_op op1) i2 (show_binary_op op_main) i3 (show_binary_op op2) i4
    | _ -> Format.fprintf fmt "Other"
  ) (fun a b -> equal_expr a b)) "复杂嵌套表达式" 
    (BinaryOpExpr (BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)), Mul, 
                   BinaryOpExpr (LitExpr (IntLit 3), Sub, LitExpr (IntLit 4)))) 
    nested_expr


let () = 
  run "AST模块单元测试" [
    "AST构造测试", [
      test_case "基本表达式构造" `Quick test_ast_construction;
      test_case "二元运算表达式" `Quick test_binary_operations;
      test_case "函数调用表达式" `Quick test_function_call;
      test_case "复杂嵌套表达式" `Quick test_complex_expressions;
    ];
  ]