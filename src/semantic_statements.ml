(** 骆言语义分析语句 - Chinese Programming Language Semantic Statements *)

open Ast
open Types
open Semantic_context
open Semantic_types
open Semantic_expressions
open Error_utils


exception SemanticError of string
(** 语义错误异常 *)

(** 分析表达式语句 *)
let analyze_expr_statement context expr =
  analyze_expression context expr

(** 分析let语句 *)
let analyze_let_statement context var_name expr =
  let context1, expr_type = analyze_expression context expr in
  match expr_type with
  | Some typ -> (add_symbol context1 var_name typ false, Some typ)
  | None -> (context1, None)

(** 分析递归let语句 *)
let analyze_rec_let_statement context func_name expr =
  (* 递归函数需要先在环境中声明自己 *)
  let func_type = new_type_var () in
  let context1 = add_symbol context func_name func_type false in
  let context2, inferred_type = analyze_expression context1 expr in

  (* 检查推断出的类型是否与预期一致 *)
  match inferred_type with
  | Some typ -> (
      try
        let _ = unify func_type typ in
        (context2, Some typ)
      with TypeError msg ->
        let error_msg = "递归函数类型不一致: " ^ msg in
        ({ context2 with error_list = error_msg :: context2.error_list }, None))
  | None -> (context2, None)

(** 分析类型别名定义 *)
let analyze_alias_type_def context type_name type_expr =
  let resolved_type = resolve_type_expr context type_expr in
  let context1 = add_type_definition context type_name resolved_type in
  (context1, Some UnitType_T)

(** 分析私有类型定义 *)
let analyze_private_type_def context type_name type_expr =
  let resolved_type = resolve_type_expr context type_expr in
  let private_type = PrivateType_T (type_name, resolved_type) in
  let context1 = add_type_definition context type_name private_type in
  (context1, Some UnitType_T)

(** 分析代数数据类型定义 *)
let analyze_algebraic_type_def context type_name constructors =
  let context1 = add_algebraic_type context type_name constructors in
  (context1, Some UnitType_T)

(** 分析记录类型定义 *)
let analyze_record_type_def context type_name fields =
  let resolved_fields =
    List.map (fun (name, type_expr) -> (name, resolve_type_expr context type_expr)) fields
  in
  let record_type = RecordType_T resolved_fields in
  let context1 = add_type_definition context type_name record_type in
  (context1, Some UnitType_T)

(** 分析多态变体类型定义 *)
let analyze_polymorphic_variant_type_def context type_name variants =
  let resolved_variants =
    List.map
      (fun (tag, type_opt) ->
        match type_opt with
        | Some type_expr -> (tag, Some (resolve_type_expr context type_expr))
        | None -> (tag, None))
      variants
  in
  let variant_type = PolymorphicVariantType_T resolved_variants in
  let context1 = add_type_definition context type_name variant_type in
  (context1, Some UnitType_T)

(** 分析类型定义语句 *)
let analyze_type_def_statement context type_name type_def =
  match type_def with
  | AliasType type_expr -> analyze_alias_type_def context type_name type_expr
  | PrivateType type_expr -> analyze_private_type_def context type_name type_expr
  | AlgebraicType constructors -> analyze_algebraic_type_def context type_name constructors
  | RecordType fields -> analyze_record_type_def context type_name fields
  | PolymorphicVariantTypeDef variants -> analyze_polymorphic_variant_type_def context type_name variants

(** 分析语句 - 重构后的主函数 *)
let analyze_statement context stmt =
  match stmt with
  | ExprStmt expr -> analyze_expr_statement context expr
  | LetStmt (var_name, expr) -> analyze_let_statement context var_name expr
  | RecLetStmt (func_name, expr) -> analyze_rec_let_statement context func_name expr
  | TypeDefStmt (type_name, type_def) -> analyze_type_def_statement context type_name type_def
  | _ -> fail_unsupported_statement GeneralStatement

(** 分析多个语句 *)
let analyze_statements context stmt_list =
  List.fold_left
    (fun (acc_context, acc_types) stmt ->
      let context1, stmt_type = analyze_statement acc_context stmt in
      (context1, stmt_type :: acc_types))
    (context, []) stmt_list

(** 分析程序 *)
let analyze_program context stmt_list =
  let context1, _ = analyze_statements context stmt_list in
  context1
