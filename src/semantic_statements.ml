(** 骆言语义分析语句 - Chinese Programming Language Semantic Statements *)

open Ast
open Types
open Semantic_context
open Semantic_types
open Semantic_expressions

(** 初始化模块日志器 *)
let log_info, log_error = Logger_utils.init_info_error_loggers "SemanticStatements"

(** 语义错误异常 *)
exception SemanticError of string

(** 分析语句 *)
let analyze_statement context stmt =
  match stmt with
  | ExprStmt expr -> analyze_expression context expr
  | LetStmt (var_name, expr) -> (
      let context1, expr_type = analyze_expression context expr in
      match expr_type with
      | Some typ -> (add_symbol context1 var_name typ false, Some typ)
      | None -> (context1, None))
  | RecLetStmt (func_name, expr) -> (
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
      | None -> (context2, None))
  | TypeDefStmt (type_name, type_def) -> (
      (* 处理类型定义 *)
      match type_def with
      | AliasType type_expr ->
          (* 类型别名 *)
          let resolved_type = resolve_type_expr context type_expr in
          let context1 = add_type_definition context type_name resolved_type in
          (context1, Some UnitType_T)
      | PrivateType type_expr ->
          (* 私有类型 *)
          let resolved_type = resolve_type_expr context type_expr in
          let private_type = PrivateType_T (type_name, resolved_type) in
          let context1 = add_type_definition context type_name private_type in
          (context1, Some UnitType_T)
      | AlgebraicType constructors ->
          (* 代数数据类型 *)
          let context1 = add_algebraic_type context type_name constructors in
          (context1, Some UnitType_T)
      | RecordType fields ->
          (* 记录类型 *)
          let resolved_fields =
            List.map (fun (name, type_expr) -> (name, resolve_type_expr context type_expr)) fields
          in
          let record_type = RecordType_T resolved_fields in
          let context1 = add_type_definition context type_name record_type in
          (context1, Some UnitType_T)
      | PolymorphicVariantTypeDef variants ->
          (* 多态变体类型定义 *)
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
          (context1, Some UnitType_T))
  | _ -> failwith "不支持的语句类型"

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