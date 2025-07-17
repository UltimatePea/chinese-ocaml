(** 骆言语义分析类型管理 - Chinese Programming Language Semantic Types *)

open Ast
open Types
open Semantic_context

(** 初始化模块日志器 *)
let log_info, log_error = Logger_utils.init_info_error_loggers "SemanticTypes"

(** 解析类型表达式为类型 *)
let rec resolve_type_expr context type_expr =
  match type_expr with
  | BaseTypeExpr IntType -> IntType_T
  | BaseTypeExpr FloatType -> FloatType_T
  | BaseTypeExpr StringType -> StringType_T
  | BaseTypeExpr BoolType -> BoolType_T
  | BaseTypeExpr UnitType -> UnitType_T
  | FunType (param_type, return_type) ->
      let param_typ = resolve_type_expr context param_type in
      let return_typ = resolve_type_expr context return_type in
      FunType_T (param_typ, return_typ)
  | TupleType type_list ->
      let typ_list = List.map (resolve_type_expr context) type_list in
      TupleType_T typ_list
  | ListType elem_type ->
      let elem_typ = resolve_type_expr context elem_type in
      ListType_T elem_typ
  | TypeVar var_name -> TypeVar_T var_name
  | ConstructType (type_name, type_args) ->
      let typ_args = List.map (resolve_type_expr context) type_args in
      ConstructType_T (type_name, typ_args)
  | RefType inner_type ->
      let inner_typ = resolve_type_expr context inner_type in
      RefType_T inner_typ
  | PolymorphicVariantType variants ->
      let resolved_variants =
        List.map
          (fun (tag, type_opt) ->
            match type_opt with
            | Some type_expr -> (tag, Some (resolve_type_expr context type_expr))
            | None -> (tag, None))
          variants
      in
      PolymorphicVariantType_T resolved_variants

(** 添加代数数据类型 *)
let add_algebraic_type context type_name constructors =
  (* 为每个构造器创建符号表条目 *)
  let add_constructor ctx (constructor_name, param_type_opt) =
    let constructor_type =
      match param_type_opt with
      | None -> ConstructType_T (type_name, [])
      | Some param_type ->
          let param_typ = resolve_type_expr ctx param_type in
          FunType_T (param_typ, ConstructType_T (type_name, []))
    in
    add_symbol ctx constructor_name constructor_type false
  in
  List.fold_left add_constructor context constructors

(** 将符号表转换为类型环境 *)
let symbol_table_to_env symbol_table =
  SymbolTable.fold
    (fun symbol_name entry env ->
      Types.TypeEnv.add symbol_name (Types.TypeScheme ([], entry.symbol_type)) env)
    symbol_table Types.TypeEnv.empty

(** 从作用域栈构建类型环境 *)
let build_type_env scope_stack =
  match scope_stack with
  | [] -> Types.TypeEnv.empty
  | scope_list ->
      List.fold_left
        (fun acc_env scope ->
          let current_env = symbol_table_to_env scope in
          Types.TypeEnv.fold Types.TypeEnv.add current_env acc_env)
        Types.TypeEnv.empty scope_list