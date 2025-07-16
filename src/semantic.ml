(** 骆言语义分析器 - Chinese Programming Language Semantic Analyzer *)

open Ast
open Types
open Compiler_errors

(** 初始化模块日志器 *)
let log_info, log_error = Logger_utils.init_info_error_loggers "Semantic"

exception SemanticError of string
(** 语义错误 *)

type symbol_entry = {
  symbol_name : string;
  symbol_type : typ;
  is_mutable : bool;
  definition_pos : int; (* 简化版位置信息 *)
}
(** 符号表条目 *)

module SymbolTable = Map.Make (String)
(** 符号表 *)

type symbol_table_t = symbol_entry SymbolTable.t

type scope_stack = symbol_table_t list
(** 作用域栈 *)

module TypeDefTable = Map.Make (String)
(** 类型定义表 *)

type type_def_table = typ TypeDefTable.t

(** 语义分析上下文 *)
type semantic_context = {
  scope_stack : scope_stack;
  current_function_return_type : typ option;
  error_list : string list;
  macros : (string * macro_def) list;
  type_definitions : type_def_table;
}
(** 语义分析上下文 *)

(** 创建初始上下文 *)
let create_initial_context () =
  {
    scope_stack = [ SymbolTable.empty ];
    current_function_return_type = None;
    error_list = [];
    macros = [];
    type_definitions = TypeDefTable.empty;
  }

(** 添加内置函数到上下文 *)
let add_builtin_functions context =
  let builtin_symbols = SymbolTable.empty in
  (* 基础IO函数 *)
  let builtin_symbols =
    SymbolTable.add "打印"
      {
        symbol_name = "打印";
        symbol_type = FunType_T (TypeVar_T "'a", UnitType_T);
        is_mutable = false;
        definition_pos = 0;
      }
      builtin_symbols
  in
  let builtin_symbols =
    SymbolTable.add "读取"
      {
        symbol_name = "读取";
        symbol_type = FunType_T (UnitType_T, StringType_T);
        is_mutable = false;
        definition_pos = 0;
      }
      builtin_symbols
  in
  (* 列表函数 *)
  let builtin_symbols =
    SymbolTable.add "长度"
      {
        symbol_name = "长度";
        symbol_type = FunType_T (ListType_T (TypeVar_T "'a"), IntType_T);
        is_mutable = false;
        definition_pos = 0;
      }
      builtin_symbols
  in
  let builtin_symbols =
    SymbolTable.add "连接"
      {
        symbol_name = "连接";
        symbol_type =
          FunType_T
            ( ListType_T (TypeVar_T "'a"),
              FunType_T (ListType_T (TypeVar_T "'a"), ListType_T (TypeVar_T "'a")) );
        is_mutable = false;
        definition_pos = 0;
      }
      builtin_symbols
  in
  let builtin_symbols =
    SymbolTable.add "过滤"
      {
        symbol_name = "过滤";
        symbol_type =
          FunType_T
            ( FunType_T (TypeVar_T "'a", BoolType_T),
              FunType_T (ListType_T (TypeVar_T "'a"), ListType_T (TypeVar_T "'a")) );
        is_mutable = false;
        definition_pos = 0;
      }
      builtin_symbols
  in
  let builtin_symbols =
    SymbolTable.add "映射"
      {
        symbol_name = "映射";
        symbol_type =
          FunType_T
            ( FunType_T (TypeVar_T "'a", TypeVar_T "'b"),
              FunType_T (ListType_T (TypeVar_T "'a"), ListType_T (TypeVar_T "'b")) );
        is_mutable = false;
        definition_pos = 0;
      }
      builtin_symbols
  in
  let builtin_symbols =
    SymbolTable.add "折叠"
      {
        symbol_name = "折叠";
        symbol_type =
          FunType_T
            ( FunType_T (TypeVar_T "'a", FunType_T (TypeVar_T "'b", TypeVar_T "'b")),
              FunType_T (TypeVar_T "'b", FunType_T (ListType_T (TypeVar_T "'a"), TypeVar_T "'b")) );
        is_mutable = false;
        definition_pos = 0;
      }
      builtin_symbols
  in
  (* 数组函数 *)
  let builtin_symbols =
    SymbolTable.add "数组长度"
      {
        symbol_name = "数组长度";
        symbol_type = FunType_T (ArrayType_T (TypeVar_T "'a"), IntType_T);
        is_mutable = false;
        definition_pos = 0;
      }
      builtin_symbols
  in
  let builtin_symbols =
    SymbolTable.add "创建数组"
      {
        symbol_name = "创建数组";
        symbol_type = FunType_T (IntType_T, FunType_T (TypeVar_T "'a", ArrayType_T (TypeVar_T "'a")));
        is_mutable = false;
        definition_pos = 0;
      }
      builtin_symbols
  in
  let builtin_symbols =
    SymbolTable.add "复制数组"
      {
        symbol_name = "复制数组";
        symbol_type = FunType_T (ArrayType_T (TypeVar_T "'a"), ArrayType_T (TypeVar_T "'a"));
        is_mutable = false;
        definition_pos = 0;
      }
      builtin_symbols
  in
  (* 数学函数 *)
  let builtin_symbols =
    SymbolTable.add "绝对值"
      {
        symbol_name = "绝对值";
        symbol_type = FunType_T (IntType_T, IntType_T);
        is_mutable = false;
        definition_pos = 0;
      }
      builtin_symbols
  in
  let builtin_symbols =
    SymbolTable.add "平方"
      {
        symbol_name = "平方";
        symbol_type = FunType_T (IntType_T, IntType_T);
        is_mutable = false;
        definition_pos = 0;
      }
      builtin_symbols
  in
  let builtin_symbols =
    SymbolTable.add "平方根"
      {
        symbol_name = "平方根";
        symbol_type = FunType_T (FloatType_T, FloatType_T);
        is_mutable = false;
        definition_pos = 0;
      }
      builtin_symbols
  in
  (* 字符串函数 *)
  let builtin_symbols =
    SymbolTable.add "字符串长度"
      {
        symbol_name = "字符串长度";
        symbol_type = FunType_T (StringType_T, IntType_T);
        is_mutable = false;
        definition_pos = 0;
      }
      builtin_symbols
  in
  let builtin_symbols =
    SymbolTable.add "字符串连接"
      {
        symbol_name = "字符串连接";
        symbol_type = FunType_T (StringType_T, FunType_T (StringType_T, StringType_T));
        is_mutable = false;
        definition_pos = 0;
      }
      builtin_symbols
  in
  (* 文件操作函数 *)
  let builtin_symbols =
    SymbolTable.add "读取文件"
      {
        symbol_name = "读取文件";
        symbol_type = FunType_T (StringType_T, StringType_T);
        is_mutable = false;
        definition_pos = 0;
      }
      builtin_symbols
  in
  let builtin_symbols =
    SymbolTable.add "写入文件"
      {
        symbol_name = "写入文件";
        symbol_type = FunType_T (StringType_T, FunType_T (StringType_T, UnitType_T));
        is_mutable = false;
        definition_pos = 0;
      }
      builtin_symbols
  in
  let builtin_symbols =
    SymbolTable.add "文件存在"
      {
        symbol_name = "文件存在";
        symbol_type = FunType_T (StringType_T, BoolType_T);
        is_mutable = false;
        definition_pos = 0;
      }
      builtin_symbols
  in
  { context with scope_stack = builtin_symbols :: context.scope_stack }

(** 进入新作用域 *)
let enter_scope context = { context with scope_stack = SymbolTable.empty :: context.scope_stack }

(** 退出作用域 *)
let exit_scope context =
  match context.scope_stack with
  | [] -> (
      let pos = { filename = "<semantic>"; line = 262; column = 0 } in
      match semantic_error "尝试退出空作用域栈" (Some pos) with
      | Error error_info -> raise (CompilerError error_info)
      | Ok _ -> failwith "不应该到达此处")
  | _ :: rest_scopes -> { context with scope_stack = rest_scopes }

(** 在当前作用域中添加符号 *)
let add_symbol context symbol_name symbol_type is_mutable =
  match context.scope_stack with
  | [] -> (
      let pos = { filename = "<semantic>"; line = 268; column = 0 } in
      match semantic_error "空作用域栈" (Some pos) with
      | Error error_info -> raise (CompilerError error_info)
      | Ok _ -> failwith "不应该到达此处")
  | current_scope :: rest_scopes ->
      if SymbolTable.mem symbol_name current_scope then
        { context with error_list = ("符号重复定义: " ^ symbol_name) :: context.error_list }
      else
        let new_entry = { symbol_name; symbol_type; is_mutable; definition_pos = 0 (* 简化版 *) } in
        let new_current_scope = SymbolTable.add symbol_name new_entry current_scope in
        { context with scope_stack = new_current_scope :: rest_scopes }

(** 添加类型定义 *)
let add_type_definition context type_name typ =
  let new_type_definitions = TypeDefTable.add type_name typ context.type_definitions in
  { context with type_definitions = new_type_definitions }

(** 查找类型定义 *)
let lookup_type_definition context type_name =
  TypeDefTable.find_opt type_name context.type_definitions

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

(** 查找符号 *)
let rec lookup_symbol scope_stack symbol_name =
  match scope_stack with
  | [] -> None
  | current_scope :: rest_scopes -> (
      try Some (SymbolTable.find symbol_name current_scope)
      with Not_found -> lookup_symbol rest_scopes symbol_name)

(** 将符号表转换为类型环境 *)
let symbol_table_to_env symbol_table =
  SymbolTable.fold
    (fun symbol_name entry env ->
      TypeEnv.add symbol_name (Types.TypeScheme ([], entry.symbol_type)) env)
    symbol_table TypeEnv.empty

(** 分析表达式 *)
let rec analyze_expression context expr =
  let env =
    match context.scope_stack with
    | [] -> TypeEnv.empty
    | scope_list ->
        List.fold_left
          (fun acc_env scope ->
            let current_env = symbol_table_to_env scope in
            TypeEnv.fold TypeEnv.add current_env acc_env)
          TypeEnv.empty scope_list
  in

  try
    let _, inferred_type = infer_type env expr in

    (* 额外的语义检查 *)
    let context1 = check_expression_semantics context expr in
    (context1, Some inferred_type)
  with
  | TypeError msg ->
      let error_msg = "类型错误: " ^ msg in
      ({ context with error_list = error_msg :: context.error_list }, None)
  | SemanticError msg -> ({ context with error_list = msg :: context.error_list }, None)

(** 检查表达式语义 *)
and check_expression_semantics context expr =
  match expr with
  | LitExpr _ -> context
  | VarExpr var_name -> (
      match lookup_symbol context.scope_stack var_name with
      | Some _ -> context
      | None -> { context with error_list = ("未定义的变量: " ^ var_name) :: context.error_list })
  | BinaryOpExpr (left_expr, _op, right_expr) ->
      let context1 = check_expression_semantics context left_expr in
      check_expression_semantics context1 right_expr
  | UnaryOpExpr (_op, expr) -> check_expression_semantics context expr
  | FunCallExpr (func_expr, arg_list) ->
      let context1 = check_expression_semantics context func_expr in
      List.fold_left check_expression_semantics context1 arg_list
  | CondExpr (cond, then_branch, else_branch) ->
      let context1 = check_expression_semantics context cond in
      let context2 = check_expression_semantics context1 then_branch in
      check_expression_semantics context2 else_branch
  | FunExpr (param_list, body) ->
      let context1 = enter_scope context in
      let context2 =
        List.fold_left
          (fun acc_context param_name -> add_symbol acc_context param_name (new_type_var ()) false)
          context1 param_list
      in
      let context3 = check_expression_semantics context2 body in
      exit_scope context3
  | LetExpr (var_name, val_expr, body_expr) ->
      let context1 = check_expression_semantics context val_expr in
      let context2 = enter_scope context1 in
      let context3 = add_symbol context2 var_name (new_type_var ()) false in
      let context4 = check_expression_semantics context3 body_expr in
      exit_scope context4
  | MatchExpr (expr, branch_list) ->
      let context1 = check_expression_semantics context expr in
      (* Process each branch independently from the same base context *)
      let _ =
        List.map
          (fun branch ->
            let context2 = enter_scope context1 in
            let context3 = check_pattern_semantics context2 branch.pattern in
            let context4 = check_expression_semantics context3 branch.expr in
            (* Check guard condition if present *)
            let context5 =
              match branch.guard with
              | None -> context4
              | Some guard_expr -> check_expression_semantics context4 guard_expr
            in
            exit_scope context5)
          branch_list
      in
      context1
  | ListExpr expr_list -> List.fold_left check_expression_semantics context expr_list
  | SemanticLetExpr (var_name, _semantic_label, val_expr, body_expr) ->
      (* Similar to LetExpr but with semantic label *)
      let context1 = check_expression_semantics context val_expr in
      let context2 = enter_scope context1 in
      let context3 = add_symbol context2 var_name (new_type_var ()) false in
      let context4 = check_expression_semantics context3 body_expr in
      exit_scope context4
  | CombineExpr expr_list ->
      (* Check each expression in the combination *)
      List.fold_left check_expression_semantics context expr_list
  | TupleExpr expr_list -> List.fold_left check_expression_semantics context expr_list
  | OrElseExpr (primary_expr, default_expr) ->
      (* 检查主表达式和默认表达式的语义 *)
      let context_after_primary = check_expression_semantics context primary_expr in
      check_expression_semantics context_after_primary default_expr
  | MacroCallExpr macro_call -> (
      (* 检查宏是否已定义 *)
      try
        let _ = List.assoc macro_call.macro_call_name context.macros in
        context
      with Not_found ->
        { context with error_list = ("未定义的宏: " ^ macro_call.macro_call_name) :: context.error_list }
      )
  | AsyncExpr _ -> context
  | RecordExpr fields ->
      (* 检查记录表达式中的所有字段值 *)
      List.fold_left (fun ctx (_name, expr) -> check_expression_semantics ctx expr) context fields
  | FieldAccessExpr (record_expr, _field_name) ->
      (* 检查记录表达式 *)
      check_expression_semantics context record_expr
  | RecordUpdateExpr (record_expr, updates) ->
      (* 检查记录表达式和更新字段的值 *)
      let context' = check_expression_semantics context record_expr in
      List.fold_left (fun ctx (_name, expr) -> check_expression_semantics ctx expr) context' updates
  | ArrayExpr elements ->
      (* 检查数组表达式中的所有元素 *)
      List.fold_left check_expression_semantics context elements
  | ArrayAccessExpr (array_expr, index_expr) ->
      (* 检查数组表达式和索引表达式 *)
      let context' = check_expression_semantics context array_expr in
      check_expression_semantics context' index_expr
  | ArrayUpdateExpr (array_expr, index_expr, value_expr) ->
      (* 检查数组表达式、索引和值表达式 *)
      let context' = check_expression_semantics context array_expr in
      let context'' = check_expression_semantics context' index_expr in
      check_expression_semantics context'' value_expr
  | TryExpr (try_expr, catch_branches, finally_opt) -> (
      (* 检查try表达式 *)
      let context' = check_expression_semantics context try_expr in
      (* 检查catch分支 *)
      let context'' =
        List.fold_left
          (fun ctx branch ->
            let ctx' = check_pattern_semantics ctx branch.pattern in
            let ctx'' = check_expression_semantics ctx' branch.expr in
            (* Check guard condition if present *)
            match branch.guard with
            | None -> ctx''
            | Some guard_expr -> check_expression_semantics ctx'' guard_expr)
          context' catch_branches
      in
      (* 检查finally块（如果有） *)
      match finally_opt with
      | Some finally_expr -> check_expression_semantics context'' finally_expr
      | None -> context'')
  | RaiseExpr expr ->
      (* 检查raise表达式 *)
      check_expression_semantics context expr
  | RefExpr expr ->
      (* 检查引用表达式 *)
      check_expression_semantics context expr
  | DerefExpr expr ->
      (* 检查解引用表达式 *)
      check_expression_semantics context expr
  | AssignExpr (target_expr, value_expr) ->
      (* 检查赋值表达式 *)
      let context' = check_expression_semantics context target_expr in
      check_expression_semantics context' value_expr
  | ConstructorExpr (_, arg_exprs) ->
      (* 检查构造器表达式 *)
      List.fold_left check_expression_semantics context arg_exprs
  (* 模块系统表达式的语义检查 *)
  | ModuleAccessExpr (module_expr, _member_name) ->
      (* 检查模块表达式 *)
      check_expression_semantics context module_expr
  | FunctorCallExpr (functor_expr, module_expr) ->
      (* 检查函子表达式和模块参数表达式 *)
      let context1 = check_expression_semantics context functor_expr in
      check_expression_semantics context1 module_expr
  | FunctorExpr (_param_name, _param_type, body) ->
      (* 检查函子体表达式 *)
      check_expression_semantics context body
  | ModuleExpr _statements ->
      (* 暂时不进行特殊检查 *)
      context
  | TypeAnnotationExpr (expr, _type_expr) ->
      (* 类型注解表达式：检查内部表达式 *)
      check_expression_semantics context expr
  | FunExprWithType (param_list, _return_type, body) ->
      (* 带类型注解的函数表达式：检查函数体 *)
      let param_names = List.map fst param_list in
      let context_with_params =
        List.fold_left
          (fun acc_context param_name -> add_symbol acc_context param_name (new_type_var ()) false)
          context param_names
      in
      check_expression_semantics context_with_params body
  | LetExprWithType (var_name, _type_expr, value_expr, body_expr) ->
      (* 带类型注解的let表达式：检查值表达式和体表达式 *)
      let context1 = check_expression_semantics context value_expr in
      let context2 = add_symbol context1 var_name (new_type_var ()) false in
      check_expression_semantics context2 body_expr
  | PolymorphicVariantExpr (_, value_expr_opt) -> (
      (* 多态变体表达式：检查值表达式（如果有的话） *)
      match value_expr_opt with
      | Some value_expr -> check_expression_semantics context value_expr
      | None -> context)
  | LabeledFunExpr (label_params, body) ->
      (* 标签函数表达式：检查函数体 *)
      let context1 = enter_scope context in
      let context2 =
        List.fold_left
          (fun acc_context label_param ->
            let param_context =
              add_symbol acc_context label_param.param_name (new_type_var ()) false
            in
            (* 检查默认值（如果有的话） *)
            match label_param.default_value with
            | Some default_expr -> check_expression_semantics param_context default_expr
            | None -> param_context)
          context1 label_params
      in
      let context3 = check_expression_semantics context2 body in
      exit_scope context3
  | LabeledFunCallExpr (func_expr, label_args) ->
      (* 标签函数调用表达式：检查函数表达式和参数 *)
      let context1 = check_expression_semantics context func_expr in
      List.fold_left
        (fun acc_context label_arg -> check_expression_semantics acc_context label_arg.arg_value)
        context1 label_args
  | PoetryAnnotatedExpr (expr, _poetry_form) ->
      (* 诗词注解表达式：检查内部表达式 *)
      check_expression_semantics context expr
  | ParallelStructureExpr (left_expr, right_expr) ->
      (* 对偶结构表达式：检查左右两个表达式 *)
      let context1 = check_expression_semantics context left_expr in
      check_expression_semantics context1 right_expr
  | RhymeAnnotatedExpr (expr, _rhyme_info) ->
      (* 押韵注解表达式：检查内部表达式 *)
      check_expression_semantics context expr
  | ToneAnnotatedExpr (expr, _tone_pattern) ->
      (* 平仄注解表达式：检查内部表达式 *)
      check_expression_semantics context expr
  | MeterValidatedExpr (expr, _meter_constraint) ->
      (* 韵律验证表达式：检查内部表达式 *)
      check_expression_semantics context expr

(** 检查模式语义 *)
and check_pattern_semantics context pattern =
  match pattern with
  | VarPattern var_name -> add_symbol context var_name (new_type_var ()) false
  | ConstructorPattern (_constructor_name, sub_pattern_list) ->
      List.fold_left check_pattern_semantics context sub_pattern_list
  | TuplePattern pattern_list -> List.fold_left check_pattern_semantics context pattern_list
  | ListPattern pattern_list -> List.fold_left check_pattern_semantics context pattern_list
  | EmptyListPattern -> context
  | ConsPattern (head_pattern, tail_pattern) ->
      let context1 = check_pattern_semantics context head_pattern in
      check_pattern_semantics context1 tail_pattern
  | OrPattern (pattern1, pattern2) ->
      let context1 = check_pattern_semantics context pattern1 in
      check_pattern_semantics context1 pattern2
  | _ -> context

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
  | ModuleDefStmt _ ->
      (* 暂不支持模块定义的类型分析 *)
      (context, Some UnitType_T)
  | ModuleImportStmt _ ->
      (* 暂不支持模块导入的类型分析 *)
      (context, Some UnitType_T)
  | ModuleTypeDefStmt _ ->
      (* 暂不支持模块类型定义的类型分析 *)
      (context, Some UnitType_T)
  | MacroDefStmt macro_def ->
      (* 宏定义：将宏添加到环境中，但暂时不做深度类型检查 *)
      let context1 =
        { context with macros = (macro_def.macro_def_name, macro_def) :: context.macros }
      in
      (context1, Some UnitType_T)
  | SemanticLetStmt (var_name, _semantic_label, expr) -> (
      (* For now, semantic labels are just metadata - analyze normally *)
      let context1, expr_type = analyze_expression context expr in
      match expr_type with
      | Some typ -> (add_symbol context1 var_name typ false, Some typ)
      | None -> (context1, None))
  | ExceptionDefStmt (exc_name, type_opt) ->
      (* 异常定义创建一个构造器函数 *)
      let exc_type =
        match type_opt with
        | None -> new_type_var () (* 无参数异常 *)
        | Some _ -> new_type_var () (* 带参数异常 *)
      in
      (add_symbol context exc_name exc_type false, Some UnitType_T)
  | IncludeStmt module_expr ->
      (* 包含模块语句的语义检查 *)
      let context' = check_expression_semantics context module_expr in
      (context', Some UnitType_T)
  | LetStmtWithType (var_name, _type_expr, expr) ->
      (* 带类型注解的let语句：检查表达式，然后添加符号 *)
      let context1 = check_expression_semantics context expr in
      let context2 = add_symbol context1 var_name (new_type_var ()) false in
      (context2, Some UnitType_T)
  | RecLetStmtWithType (var_name, _type_expr, expr) ->
      (* 带类型注解的递归let语句：先添加符号，然后检查表达式 *)
      let context1 = add_symbol context var_name (new_type_var ()) false in
      let context2 = check_expression_semantics context1 expr in
      (context2, Some UnitType_T)

(** 分析程序 *)
let analyze_program program =
  let initial_context = add_builtin_functions (create_initial_context ()) in

  let rec analyze_statement_list context stmt_list =
    match stmt_list with
    | [] -> context
    | stmt :: rest_stmts ->
        let new_context, _ = analyze_statement context stmt in
        analyze_statement_list new_context rest_stmts
  in

  let final_context = analyze_statement_list initial_context program in

  (* 返回分析结果 *)
  if final_context.error_list = [] then Result.Ok "语义分析成功"
  else Result.Error (List.rev final_context.error_list)

(** 类型检查入口函数 *)
let type_check program =
  match analyze_program program with
  | Result.Ok msg ->
      log_info msg;
      flush_all ();
      true
  | Result.Error error_list ->
      log_error "语义分析错误:";
      List.iter (fun err -> log_error (Printf.sprintf "  - %s" err)) error_list;
      flush_all ();
      false

(** 安静模式类型检查 - 用于测试 *)
let type_check_quiet program =
  match analyze_program program with Result.Ok _msg -> true | Result.Error _error_list -> false

(** 获取表达式类型 *)
let get_expression_type context expr =
  let _, type_option = analyze_expression context expr in
  type_option
