(** 重构的代码生成器模块 - 这是一个临时文件用于重构工作 *)

(* 这个文件包含了重构后的函数，完成后将替换原文件中的相应部分 *)

(** 生成基本字面量和变量表达式代码 *)
let rec gen_literal_and_vars ctx expr =
  match expr with
  | LitExpr (IntLit i) -> Printf.sprintf "luoyan_int(%dL)" i
  | LitExpr (FloatLit f) -> Printf.sprintf "luoyan_float(%g)" f
  | LitExpr (StringLit s) ->
      (* 对于C代码生成，我们需要保持UTF-8字符串原样，只转义必要的字符 *)
      let escape_for_c str =
        let buf = Buffer.create (String.length str * 2) in
        String.iter
          (function
            | '"' -> Buffer.add_string buf "\\\""
            | '\\' -> Buffer.add_string buf "\\\\"
            | '\n' -> Buffer.add_string buf "\\n"
            | '\r' -> Buffer.add_string buf "\\r"
            | '\t' -> Buffer.add_string buf "\\t"
            | c -> Buffer.add_char buf c)
          str;
        Buffer.contents buf
      in
      Printf.sprintf "luoyan_string(\"%s\")" (escape_for_c s)
  | LitExpr (BoolLit b) -> Printf.sprintf "luoyan_bool(%s)" (if b then "true" else "false")
  | LitExpr UnitLit -> "luoyan_unit()"
  | VarExpr name ->
      let escaped_name = escape_identifier name in
      Printf.sprintf "luoyan_env_lookup(env, \"%s\")" escaped_name
  | _ -> failwith "gen_literal_and_vars: 不支持的表达式类型"

(** 生成算术和逻辑运算表达式代码 *)
and gen_operations ctx expr =
  match expr with
  | BinaryOpExpr (e1, op, e2) -> gen_binary_op ctx op e1 e2
  | UnaryOpExpr (op, e) -> gen_unary_op ctx op e
  | _ -> failwith "gen_operations: 不支持的表达式类型"

(** 生成内存和引用操作表达式代码 *)
and gen_memory_operations ctx expr =
  match expr with
  | RefExpr expr -> gen_ref_expr ctx expr
  | DerefExpr expr -> gen_deref_expr ctx expr
  | AssignExpr (ref_expr, value_expr) -> gen_assign_expr ctx ref_expr value_expr
  | _ -> failwith "gen_memory_operations: 不支持的表达式类型"

(** 生成集合和数组操作表达式代码 *)
and gen_collections ctx expr =
  match expr with
  | ListExpr exprs -> gen_list_expr ctx exprs
  | ArrayExpr exprs -> gen_array_expr ctx exprs
  | ArrayAccessExpr (array_expr, index_expr) -> gen_array_access_expr ctx array_expr index_expr
  | ArrayUpdateExpr (array_expr, index_expr, value_expr) ->
      gen_array_update_expr ctx array_expr index_expr value_expr
  | _ -> failwith "gen_collections: 不支持的表达式类型"

(** 生成记录操作表达式代码 *)
and gen_record_operations ctx expr =
  match expr with
  | RecordExpr fields -> gen_record_expr ctx fields
  | FieldAccessExpr (record_expr, field_name) -> gen_field_access_expr ctx record_expr field_name
  | RecordUpdateExpr (record_expr, updates) -> gen_record_update_expr ctx record_expr updates
  | _ -> failwith "gen_record_operations: 不支持的表达式类型"

(** 生成函数定义表达式代码 *)
and gen_function_definitions ctx expr =
  match expr with
  | FunExpr (params, body) -> gen_fun_expr ctx params body
  | FunExprWithType (param_list, _return_type, body) ->
      (* 带类型注解的函数表达式：忽略类型信息，按普通函数处理 *)
      let param_names = List.map fst param_list in
      gen_fun_expr ctx param_names body
  | LabeledFunExpr (label_params, body) -> (
      (* 标签函数表达式代码生成 - 暂时简化为普通函数 *)
      let param_names = List.map (fun label_param -> label_param.param_name) label_params in
      let func_name = gen_var_name ctx "labeled_func" in
      let param_count = List.length param_names in
      let func_code = Printf.sprintf "luoyan_function_t* %s = luoyan_function_create(%d, %s);" func_name param_count
                       (String.concat ", " (List.mapi (fun i name -> Printf.sprintf "\"%s\"" name) param_names)) in
      let body_code = gen_expr ctx body in
      Printf.sprintf "({ %s luoyan_function_set_body(%s, %s); %s; })" func_code func_name body_code func_name)
  | _ -> failwith "gen_function_definitions: 不支持的表达式类型"

(** 生成函数调用表达式代码 *)
and gen_function_calls ctx expr =
  match expr with
  | FunCallExpr (func_expr, arg_exprs) -> gen_call_expr ctx func_expr arg_exprs
  | LabeledFunCallExpr (func_expr, label_args) -> (
      (* 标签函数调用表达式代码生成 *)
      let func_code = gen_expr ctx func_expr in
      let arg_codes = List.map (fun label_arg -> gen_expr ctx label_arg.arg_expr) label_args in
      match arg_codes with
      | [] -> Printf.sprintf "luoyan_function_call(%s, 0)" func_code
      | _ -> Printf.sprintf "luoyan_function_call(%s, %d, %s)" func_code (List.length arg_codes) (String.concat ", " arg_codes))
  | _ -> failwith "gen_function_calls: 不支持的表达式类型"

(** 生成控制流表达式代码 *)
and gen_control_flow ctx expr =
  match expr with
  | CondExpr (cond, then_expr, else_expr) -> gen_if_expr ctx cond then_expr else_expr
  | MatchExpr (expr, patterns) -> gen_match_expr ctx expr patterns
  | LetExpr (var, value_expr, body_expr) -> gen_let_expr ctx var value_expr body_expr
  | LetExprWithType (var_name, _type_expr, value_expr, body_expr) ->
      (* 带类型注解的let表达式：忽略类型信息，按普通let处理 *)
      let value_code = gen_expr ctx value_expr in
      let var_code = Printf.sprintf "luoyan_value %s = %s;" var_name value_code in
      let body_code = gen_expr ctx body_expr in
      Printf.sprintf "({ %s %s; })" var_code body_code
  | SemanticLetExpr (var, _semantic, value_expr, body_expr) ->
      gen_let_expr ctx var value_expr body_expr
  | _ -> failwith "gen_control_flow: 不支持的表达式类型"

(** 生成模块系统表达式代码 *)
and gen_module_system ctx expr =
  match expr with
  | ConstructorExpr (constructor, args) -> gen_constructor_expr ctx constructor args
  | ModuleAccessExpr (module_expr, member_name) ->
      gen_module_access_expr ctx module_expr member_name
  | FunctorCallExpr (functor_expr, module_expr) ->
      gen_functor_call_expr ctx functor_expr module_expr
  | FunctorExpr (param_name, _param_type, body) -> gen_functor_expr ctx param_name body
  | ModuleExpr statements ->
      (* 生成模块表达式：暂时简化为空模块 *)
      (* 完整实现需要处理模块内的语句，但这里避免前向引用问题 *)
      let module_var = gen_var_name ctx "module" in
      Printf.sprintf "/* 模块表达式(包含%d个语句) */ luoyan_module_create(\"%s\")" (List.length statements)
        module_var
  | _ -> failwith "gen_module_system: 不支持的表达式类型"

(** 生成类型和元编程表达式代码 *)
and gen_type_and_meta ctx expr =
  match expr with
  | MacroCallExpr macro_call -> (
      (* 宏调用：先展开宏，然后生成展开后表达式的C代码 *)
      try
        let macro_def = Hashtbl.find Interpreter.macro_table macro_call.macro_call_name in
        let expanded_expr = Interpreter.expand_macro macro_def macro_call.args in
        gen_expr ctx expanded_expr
      with
      | Not_found ->
          (* 未找到宏定义时的错误处理 *)
          Printf.sprintf "/* 错误：未定义的宏 '%s' */ 0" macro_call.macro_call_name
      | exn ->
          (* 宏展开过程中出现其他错误 *)
          Printf.sprintf "/* 错误：宏展开失败 '%s': %s */ 0" macro_call.macro_call_name
            (Printexc.to_string exn))
  | TypeAnnotationExpr (expr, _type_expr) ->
      (* 类型注解表达式：忽略类型信息，只生成表达式代码 *)
      gen_expr ctx expr
  | PolymorphicVariantExpr (tag_name, value_expr_opt) -> (
      (* 多态变体表达式代码生成 *)
      match value_expr_opt with
      | None -> Printf.sprintf "luoyan_make_variant(\"%s\", NULL)" tag_name
      | Some value_expr ->
          let value_code = gen_expr ctx value_expr in
          Printf.sprintf "luoyan_make_variant(\"%s\", %s)" tag_name value_code)
  | _ -> failwith "gen_type_and_meta: 不支持的表达式类型"

(** 生成诗词特性表达式代码 *)
and gen_poetry_features ctx expr =
  match expr with
  | PoetryAnnotatedExpr (expr, _poetry_form) ->
      (* 诗词注解表达式：忽略诗词信息，只生成表达式代码 *)
      gen_expr ctx expr
  | ParallelStructureExpr (left_expr, right_expr) ->
      (* 并行结构表达式：生成左右表达式的组合 *)
      let left_code = gen_expr ctx left_expr in
      let right_code = gen_expr ctx right_expr in
      Printf.sprintf "luoyan_parallel_structure(%s, %s)" left_code right_code
  | RhymeAnnotatedExpr (expr, _rhyme_info) ->
      (* 韵律注解表达式：忽略韵律信息，只生成表达式代码 *)
      gen_expr ctx expr
  | ToneAnnotatedExpr (expr, _tone_pattern) ->
      (* 音调注解表达式：忽略音调信息，只生成表达式代码 *)
      gen_expr ctx expr
  | MeterValidatedExpr (expr, _meter_constraint) ->
      (* 格律校验表达式：忽略格律信息，只生成表达式代码 *)
      gen_expr ctx expr
  | _ -> failwith "gen_poetry_features: 不支持的表达式类型"

(** 生成未实现功能的错误代码 *)
and gen_unimplemented_features ctx expr =
  match expr with
  | TupleExpr _ -> (
      let error_info = unimplemented_feature "元组表达式" ~context:"C代码生成" in
      match error_info with
      | Error info -> raise (Failure (format_error_info info))
      | Ok _ -> "/* 不可能到达这里 */")
  | AsyncExpr _ -> (
      let error_info = unimplemented_feature "异步表达式" ~context:"C代码生成" in
      match error_info with
      | Error info -> raise (Failure (format_error_info info))
      | Ok _ -> "/* 不可能到达这里 */")
  | CombineExpr _ -> (
      let error_info = unimplemented_feature "组合表达式" ~context:"C代码生成" in
      match error_info with
      | Error info -> raise (Failure (format_error_info info))
      | Ok _ -> "/* 不可能到达这里 */")
  | OrElseExpr (_, _) -> (
      let error_info = unimplemented_feature "OrElse表达式" ~context:"C代码生成" in
      match error_info with
      | Error info -> raise (Failure (format_error_info info))
      | Ok _ -> "/* 不可能到达这里 */")
  | TryExpr _ -> (
      let error_info = unimplemented_feature "Try表达式" ~context:"C代码生成" in
      match error_info with
      | Error info -> raise (Failure (format_error_info info))
      | Ok _ -> "/* 不可能到达这里 */")
  | RaiseExpr _ -> (
      let error_info = unimplemented_feature "Raise表达式" ~context:"C代码生成" in
      match error_info with
      | Error info -> raise (Failure (format_error_info info))
      | Ok _ -> "/* 不可能到达这里 */")
  | _ -> failwith "gen_unimplemented_features: 不支持的表达式类型"

(** 重构后的主要表达式生成函数 *)
and gen_expr ctx expr =
  match expr with
  (* 基本字面量和变量 *)
  | LitExpr _ | VarExpr _ -> gen_literal_and_vars ctx expr
  
  (* 算术和逻辑运算 *)
  | BinaryOpExpr (_, _, _) | UnaryOpExpr (_, _) -> gen_operations ctx expr
  
  (* 内存和引用操作 *)
  | RefExpr _ | DerefExpr _ | AssignExpr (_, _) -> gen_memory_operations ctx expr
  
  (* 集合和数组操作 *)
  | ListExpr _ | ArrayExpr _ | ArrayAccessExpr (_, _) | ArrayUpdateExpr (_, _, _) -> gen_collections ctx expr
  
  (* 记录操作 *)
  | RecordExpr _ | FieldAccessExpr (_, _) | RecordUpdateExpr (_, _) -> gen_record_operations ctx expr
  
  (* 函数定义 *)
  | FunExpr (_, _) | FunExprWithType (_, _, _) | LabeledFunExpr (_, _) -> gen_function_definitions ctx expr
  
  (* 函数调用 *)
  | FunCallExpr (_, _) | LabeledFunCallExpr (_, _) -> gen_function_calls ctx expr
  
  (* 控制流 *)
  | CondExpr (_, _, _) | MatchExpr (_, _) | LetExpr (_, _, _) | LetExprWithType (_, _, _, _) | SemanticLetExpr (_, _, _, _) -> gen_control_flow ctx expr
  
  (* 模块系统 *)
  | ConstructorExpr (_, _) | ModuleAccessExpr (_, _) | FunctorCallExpr (_, _) | FunctorExpr (_, _, _) | ModuleExpr _ -> gen_module_system ctx expr
  
  (* 类型和元编程 *)
  | MacroCallExpr _ | TypeAnnotationExpr (_, _) | PolymorphicVariantExpr (_, _) -> gen_type_and_meta ctx expr
  
  (* 诗词特性 *)
  | PoetryAnnotatedExpr (_, _) | ParallelStructureExpr (_, _) | RhymeAnnotatedExpr (_, _) | ToneAnnotatedExpr (_, _) | MeterValidatedExpr (_, _) -> gen_poetry_features ctx expr
  
  (* 未实现的功能 *)
  | TupleExpr _ | AsyncExpr _ | CombineExpr _ | OrElseExpr (_, _) | TryExpr _ | RaiseExpr _ -> gen_unimplemented_features ctx expr