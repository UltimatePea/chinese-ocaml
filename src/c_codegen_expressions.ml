(** 骆言C代码生成器表达式模块 - Chinese Programming Language C Code Generator Expression Module *)

open Ast
open C_codegen_context

(** 初始化模块日志器 *)
let log_info = Logger_utils.init_info_logger "CCodegenExpr"

(** 生成基本字面量和变量表达式代码 *)
let rec gen_literal_and_vars _ctx expr =
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

(** 生成二元运算表达式代码 *)
and gen_binary_op ctx op e1 e2 =
  let e1_code = gen_expr ctx e1 in
  let e2_code = gen_expr ctx e2 in
  match op with
  | Add -> Printf.sprintf "luoyan_add(%s, %s)" e1_code e2_code
  | Sub -> Printf.sprintf "luoyan_subtract(%s, %s)" e1_code e2_code
  | Mul -> Printf.sprintf "luoyan_multiply(%s, %s)" e1_code e2_code
  | Div -> Printf.sprintf "luoyan_divide(%s, %s)" e1_code e2_code
  | Mod -> Printf.sprintf "luoyan_modulo(%s, %s)" e1_code e2_code
  | Eq -> Printf.sprintf "luoyan_equal(%s, %s)" e1_code e2_code
  | Neq -> Printf.sprintf "luoyan_not_equal(%s, %s)" e1_code e2_code
  | Lt -> Printf.sprintf "luoyan_less_than(%s, %s)" e1_code e2_code
  | Gt -> Printf.sprintf "luoyan_greater_than(%s, %s)" e1_code e2_code
  | Le -> Printf.sprintf "luoyan_less_equal(%s, %s)" e1_code e2_code
  | Ge -> Printf.sprintf "luoyan_greater_equal(%s, %s)" e1_code e2_code
  | And -> Printf.sprintf "luoyan_logical_and(%s, %s)" e1_code e2_code
  | Or -> Printf.sprintf "luoyan_logical_or(%s, %s)" e1_code e2_code
  | Concat -> Printf.sprintf "luoyan_concat(%s, %s)" e1_code e2_code

(** 生成一元运算表达式代码 *)
and gen_unary_op ctx op e =
  let e_code = gen_expr ctx e in
  match op with
  | Neg -> Printf.sprintf "luoyan_subtract(luoyan_int(0), %s)" e_code
  | Not -> Printf.sprintf "luoyan_logical_not(%s)" e_code

(** 生成算术和逻辑运算表达式代码 *)
and gen_operations ctx expr =
  match expr with
  | BinaryOpExpr (e1, op, e2) -> gen_binary_op ctx op e1 e2
  | UnaryOpExpr (op, e) -> gen_unary_op ctx op e
  | _ -> failwith "gen_operations: 不支持的表达式类型"

(** 生成引用表达式代码 *)
and gen_ref_expr ctx expr =
  let expr_code = gen_expr ctx expr in
  Printf.sprintf "luoyan_ref(%s)" expr_code

(** 生成解引用表达式代码 *)
and gen_deref_expr ctx expr =
  let expr_code = gen_expr ctx expr in
  Printf.sprintf "luoyan_deref(%s)" expr_code

(** 生成赋值表达式代码 *)
and gen_assign_expr ctx ref_expr value_expr =
  let ref_code = gen_expr ctx ref_expr in
  let value_code = gen_expr ctx value_expr in
  Printf.sprintf "luoyan_assign(%s, %s)" ref_code value_code

(** 生成内存和引用操作表达式代码 *)
and gen_memory_operations ctx expr =
  match expr with
  | RefExpr expr -> gen_ref_expr ctx expr
  | DerefExpr expr -> gen_deref_expr ctx expr
  | AssignExpr (ref_expr, value_expr) -> gen_assign_expr ctx ref_expr value_expr
  | _ -> failwith "gen_memory_operations: 不支持的表达式类型"

(** 生成列表表达式代码 *)
and gen_list_expr ctx exprs =
  let rec build_list = function
    | [] -> "luoyan_list_empty()"
    | e :: rest ->
        let elem_code = gen_expr ctx e in
        let rest_code = build_list rest in
        Printf.sprintf "luoyan_list_cons(%s, %s)" elem_code rest_code
  in
  build_list exprs

(** 生成数组表达式代码 *)
and gen_array_expr ctx exprs =
  let expr_codes = List.map (gen_expr ctx) exprs in
  let array_size = List.length exprs in
  Printf.sprintf "luoyan_array(%d, %s)" array_size (String.concat ", " expr_codes)

(** 生成数组访问表达式代码 *)
and gen_array_access_expr ctx array_expr index_expr =
  let array_code = gen_expr ctx array_expr in
  let index_code = gen_expr ctx index_expr in
  Printf.sprintf "luoyan_array_get(%s, %s)" array_code index_code

(** 生成集合和数组操作表达式代码 *)
and gen_collections ctx expr =
  match expr with
  | ListExpr exprs -> gen_list_expr ctx exprs
  | ArrayExpr exprs -> gen_array_expr ctx exprs
  | ArrayAccessExpr (array_expr, index_expr) -> gen_array_access_expr ctx array_expr index_expr
  | _ -> failwith "gen_collections: 不支持的表达式类型"

(** 生成元组表达式代码 *)
and gen_tuple_expr ctx exprs =
  let expr_codes = List.map (gen_expr ctx) exprs in
  let tuple_size = List.length exprs in
  Printf.sprintf "luoyan_tuple(%d, %s)" tuple_size (String.concat ", " expr_codes)

(** 生成记录表达式代码 *)
and gen_record_expr ctx fields =
  let gen_field (name, expr) =
    let expr_code = gen_expr ctx expr in
    Printf.sprintf "{\"%s\", %s}" (escape_identifier name) expr_code
  in
  let field_codes = List.map gen_field fields in
  Printf.sprintf "luoyan_record(%d, (luoyan_field_t[]){%s})" (List.length fields) (String.concat ", " field_codes)

(** 生成记录字段访问表达式代码 *)
and gen_record_access_expr ctx record_expr field_name =
  let record_code = gen_expr ctx record_expr in
  let escaped_field = escape_identifier field_name in
  Printf.sprintf "luoyan_record_get(%s, \"%s\")" record_code escaped_field

(** 生成结构化数据表达式代码 *)
and gen_structured_data ctx expr =
  match expr with
  | TupleExpr exprs -> gen_tuple_expr ctx exprs
  | RecordExpr fields -> gen_record_expr ctx fields
  | FieldAccessExpr (record_expr, field_name) -> gen_record_access_expr ctx record_expr field_name
  | _ -> failwith "gen_structured_data: 不支持的表达式类型"

(** 生成函数调用表达式代码 *)
and gen_call_expr ctx func_expr args =
  let func_code = gen_expr ctx func_expr in
  let arg_codes = List.map (gen_expr ctx) args in
  let argc = List.length args in
  if argc = 0 then
    Printf.sprintf "luoyan_call(%s, 0, NULL)" func_code
  else
    Printf.sprintf "luoyan_call(%s, %d, (luoyan_value_t[]){%s})" func_code argc (String.concat ", " arg_codes)

(** 生成函数定义表达式代码 *)
and gen_fun_expr ctx params body =
  let func_name = gen_var_name ctx "func" in
  let body_code = gen_expr ctx body in

  (* 对于多参数函数，创建curry化的函数 *)
  let rec create_curried_func params_left body_code =
    match params_left with
    | [] -> body_code
    | param :: rest_params ->
        let escaped_param = escape_identifier param in
        let inner_body = create_curried_func rest_params body_code in
        if rest_params = [] then
          (* 最后一个参数，直接返回body *)
          Printf.sprintf
            "luoyan_value_t* %s_impl_%s(luoyan_env_t* env, luoyan_value_t* arg) {\n\
            \  luoyan_env_bind(env, \"%s\", arg);\n\
            \  return %s;\n\
             }"
            func_name param escaped_param inner_body
        else
          (* 还有更多参数，返回另一个函数 *)
          let next_func_name = gen_var_name ctx "func" in
          Printf.sprintf
            "luoyan_value_t* %s_impl_%s(luoyan_env_t* env, luoyan_value_t* arg) {\n\
            \  luoyan_env_bind(env, \"%s\", arg);\n\
            \  return luoyan_function_create(%s_impl_%s, env, \"%s\");\n\
             }"
            func_name param escaped_param next_func_name (List.hd rest_params) next_func_name
  in

  let func_impl = create_curried_func params body_code in
  ctx.functions <- func_impl :: ctx.functions;

  match params with
  | [] -> "luoyan_unit()"
  | first_param :: _ ->
      Printf.sprintf "luoyan_function_create(%s_impl_%s, env, \"%s\")" func_name first_param
        func_name

(** 生成条件表达式代码 *)
and gen_if_expr ctx cond_expr then_expr else_expr =
  let cond_var = gen_var_name ctx "cond" in
  let cond_code = gen_expr ctx cond_expr in
  let then_code = gen_expr ctx then_expr in
  let else_code = gen_expr ctx else_expr in
  Printf.sprintf
    "({ luoyan_value_t* %s = %s; ((%s->type == LUOYAN_BOOL && %s->data.bool_val)) ? (%s) : (%s); })"
    cond_var cond_code cond_var cond_var then_code else_code

(** 生成let表达式代码 *)
and gen_let_expr ctx var_name value_expr body_expr =
  let value_code = gen_expr ctx value_expr in
  let escaped_var = escape_identifier var_name in
  let body_code = gen_expr ctx body_expr in
  Printf.sprintf "luoyan_let(\"%s\", %s, %s)" escaped_var value_code body_code

(** 生成匹配表达式代码 *)
and gen_match_expr ctx expr patterns =
  let expr_var = gen_var_name ctx "match_expr" in
  let expr_code = gen_expr ctx expr in

  let rec gen_patterns = function
    | [] -> "luoyan_unit()" (* 应该不会到达这里 *)
    | branch :: rest ->
        let pattern_check = gen_pattern_check ctx expr_var branch.pattern in
        let guard_check =
          match branch.guard with
          | None -> "1" (* No guard, always true *)
          | Some guard_expr ->
              let guard_code = gen_expr ctx guard_expr in
              Printf.sprintf "luoyan_is_true(%s)" guard_code
        in
        let combined_check = Printf.sprintf "(%s && %s)" pattern_check guard_check in
        let expr_code = gen_expr ctx branch.expr in
        if rest = [] then Printf.sprintf "(%s) ? (%s) : (luoyan_unit())" combined_check expr_code
        else Printf.sprintf "(%s) ? (%s) : (%s)" combined_check expr_code (gen_patterns rest)
  in

  Printf.sprintf "({ luoyan_value_t* %s = %s; %s; })" expr_var expr_code (gen_patterns patterns)

(** 生成模式检查代码 *)
and gen_pattern_check ctx expr_var = function
  | LitPattern (IntLit i) -> Printf.sprintf "luoyan_equals(%s, luoyan_int(%d))" expr_var i
  | LitPattern (StringLit s) ->
      Printf.sprintf "luoyan_equals(%s, luoyan_string(\"%s\"))" expr_var (String.escaped s)
  | LitPattern (BoolLit b) ->
      Printf.sprintf "luoyan_equals(%s, luoyan_bool(%s))" expr_var (if b then "true" else "false")
  | LitPattern UnitLit -> Printf.sprintf "luoyan_equals(%s, luoyan_unit())" expr_var
  | LitPattern (FloatLit f) -> Printf.sprintf "luoyan_equals(%s, luoyan_float(%g))" expr_var f
  | VarPattern var ->
      let escaped_var = escape_identifier var in
      Printf.sprintf "(luoyan_env_bind(env, \"%s\", %s), true)" escaped_var expr_var
  | EmptyListPattern -> Printf.sprintf "luoyan_list_is_empty(%s)->data.bool_val" expr_var
  | ConsPattern (head_pat, tail_pat) ->
      let head_check =
        gen_pattern_check ctx (Printf.sprintf "luoyan_list_head(%s)" expr_var) head_pat
      in
      let tail_check =
        gen_pattern_check ctx (Printf.sprintf "luoyan_list_tail(%s)" expr_var) tail_pat
      in
      Printf.sprintf "(%s && %s)" head_check tail_check
  | WildcardPattern -> "true"
  | TuplePattern patterns -> 
      let gen_tuple_check i pattern =
        let tuple_elem = Printf.sprintf "luoyan_tuple_get(%s, %d)" expr_var i in
        gen_pattern_check ctx tuple_elem pattern
      in
      let checks = List.mapi gen_tuple_check patterns in
      String.concat " && " checks
  | ConstructorPattern (name, args) -> 
      let escaped_name = escape_identifier name in
      let constructor_check = Printf.sprintf "luoyan_constructor_matches(%s, \"%s\")" expr_var escaped_name in
      let gen_arg_check i pattern =
        let arg_access = Printf.sprintf "luoyan_constructor_get_arg(%s, %d)" expr_var i in
        gen_pattern_check ctx arg_access pattern
      in
      let arg_checks = List.mapi gen_arg_check args in
      String.concat " && " (constructor_check :: arg_checks)
  | ListPattern patterns ->
      let gen_list_check i pattern =
        let list_elem = Printf.sprintf "luoyan_list_get(%s, %d)" expr_var i in
        gen_pattern_check ctx list_elem pattern
      in
      let checks = List.mapi gen_list_check patterns in
      String.concat " && " checks
  | ExceptionPattern (name, pattern_opt) ->
      let name_check = Printf.sprintf "luoyan_exception_matches(%s, \"%s\")" expr_var (escape_identifier name) in
      let pattern_check = match pattern_opt with
        | Some pattern -> gen_pattern_check ctx (Printf.sprintf "luoyan_exception_get_payload(%s)" expr_var) pattern
        | None -> "true"
      in
      Printf.sprintf "(%s && %s)" name_check pattern_check
  | PolymorphicVariantPattern (name, pattern_opt) ->
      let name_check = Printf.sprintf "luoyan_variant_matches(%s, \"%s\")" expr_var (escape_identifier name) in
      let pattern_check = match pattern_opt with
        | Some pattern -> gen_pattern_check ctx (Printf.sprintf "luoyan_variant_get_payload(%s)" expr_var) pattern
        | None -> "true"
      in
      Printf.sprintf "(%s && %s)" name_check pattern_check
  | OrPattern (pattern1, pattern2) ->
      let check1 = gen_pattern_check ctx expr_var pattern1 in
      let check2 = gen_pattern_check ctx expr_var pattern2 in
      Printf.sprintf "(%s || %s)" check1 check2

(** 生成模式代码 *)
and gen_pattern ctx = function
  | VarPattern name -> Printf.sprintf "luoyan_var_pattern(\"%s\")" (escape_identifier name)
  | WildcardPattern -> "luoyan_wildcard_pattern()"
  | LitPattern lit -> Printf.sprintf "luoyan_lit_pattern(%s)" (gen_literal_and_vars ctx (LitExpr lit))
  | ConsPattern (head, tail) -> 
      let head_code = gen_pattern ctx head in
      let tail_code = gen_pattern ctx tail in
      Printf.sprintf "luoyan_cons_pattern(%s, %s)" head_code tail_code
  | ListPattern patterns ->
      let pattern_codes = List.map (gen_pattern ctx) patterns in
      Printf.sprintf "luoyan_list_pattern(%d, (luoyan_pattern_t[]){%s})" (List.length patterns) (String.concat ", " pattern_codes)
  | TuplePattern patterns ->
      let pattern_codes = List.map (gen_pattern ctx) patterns in
      Printf.sprintf "luoyan_tuple_pattern(%d, (luoyan_pattern_t[]){%s})" (List.length patterns) (String.concat ", " pattern_codes)
  | ExceptionPattern (name, pattern_opt) ->
      let name_code = escape_identifier name in
      let pattern_code = match pattern_opt with
        | Some pattern -> gen_pattern ctx pattern
        | None -> "luoyan_unit_pattern()"
      in
      Printf.sprintf "luoyan_exception_pattern(\"%s\", %s)" name_code pattern_code
  | ConstructorPattern (name, args) ->
      let arg_codes = List.map (gen_pattern ctx) args in
      Printf.sprintf "luoyan_constructor_pattern(\"%s\", %d, (luoyan_pattern_t[]){%s})" (escape_identifier name) (List.length args) (String.concat ", " arg_codes)
  | EmptyListPattern ->
      "luoyan_empty_list_pattern()"
  | PolymorphicVariantPattern (name, pattern_opt) ->
      let name_code = escape_identifier name in
      let pattern_code = match pattern_opt with
        | Some pattern -> gen_pattern ctx pattern
        | None -> "luoyan_unit_pattern()"
      in
      Printf.sprintf "luoyan_polymorphic_variant_pattern(\"%s\", %s)" name_code pattern_code
  | OrPattern (p1, p2) ->
      let p1_code = gen_pattern ctx p1 in
      let p2_code = gen_pattern ctx p2 in
      Printf.sprintf "luoyan_or_pattern(%s, %s)" p1_code p2_code

(** 生成控制流表达式代码 *)
and gen_control_flow ctx expr =
  match expr with
  | FunCallExpr (func_expr, args) -> gen_call_expr ctx func_expr args
  | FunExpr (params, body) -> gen_fun_expr ctx params body
  | CondExpr (cond_expr, then_expr, else_expr) -> gen_if_expr ctx cond_expr then_expr else_expr
  | LetExpr (var_name, value_expr, body_expr) -> gen_let_expr ctx var_name value_expr body_expr
  | MatchExpr (expr, patterns) -> gen_match_expr ctx expr patterns
  | _ -> failwith "gen_control_flow: 不支持的表达式类型"

(** 生成try-catch表达式代码 *)
and gen_try_catch_expr ctx try_expr catch_branches =
  let try_code = gen_expr ctx try_expr in
  let gen_catch_branch branch =
    let pattern_code = gen_pattern ctx branch.pattern in
    let handler_code = gen_expr ctx branch.expr in
    let guard_code = match branch.guard with
      | Some guard -> gen_expr ctx guard
      | None -> "luoyan_true()"
    in
    Printf.sprintf "{%s, %s, %s}" pattern_code guard_code handler_code
  in
  let catch_codes = List.map gen_catch_branch catch_branches in
  Printf.sprintf "luoyan_try_catch(%s, %d, (luoyan_catch_t[]){%s})" try_code (List.length catch_branches) (String.concat ", " catch_codes)

(** 生成raise表达式代码 *)
and gen_raise_expr ctx exception_expr =
  let exception_code = gen_expr ctx exception_expr in
  Printf.sprintf "luoyan_raise(%s)" exception_code

(** 生成异常处理表达式代码 *)
and gen_exception_handling ctx expr =
  match expr with
  | TryExpr (try_expr, catch_patterns, _) -> gen_try_catch_expr ctx try_expr catch_patterns
  | RaiseExpr exception_expr -> gen_raise_expr ctx exception_expr
  | _ -> failwith "gen_exception_handling: 不支持的表达式类型"

(** 生成序列表达式代码 *)
and gen_seq_expr ctx exprs =
  let expr_codes = List.map (gen_expr ctx) exprs in
  Printf.sprintf "luoyan_sequence(%d, (luoyan_value_t[]){%s})" (List.length exprs) (String.concat ", " expr_codes)


(** 生成高级控制流表达式代码 *)
and gen_advanced_control_flow ctx expr =
  match expr with
  | CombineExpr exprs -> gen_seq_expr ctx exprs
  | _ -> failwith "gen_advanced_control_flow: 不支持的表达式类型"

(** 主要的表达式生成函数 *)
and gen_expr ctx expr =
  log_info (Printf.sprintf "正在生成表达式代码: %s" (match expr with
    | LitExpr _ -> "字面量"
    | VarExpr _ -> "变量"
    | BinaryOpExpr _ -> "二元运算"
    | UnaryOpExpr _ -> "一元运算"
    | FunCallExpr _ -> "函数调用"
    | FunExpr _ -> "函数定义"
    | CondExpr _ -> "条件表达式"
    | LetExpr _ -> "let表达式"
    | MatchExpr _ -> "匹配表达式"
    | ListExpr _ -> "列表"
    | ArrayExpr _ -> "数组"
    | TupleExpr _ -> "元组"
    | RecordExpr _ -> "记录"
    | RefExpr _ -> "引用"
    | DerefExpr _ -> "解引用"
    | AssignExpr _ -> "赋值"
    | ArrayAccessExpr _ -> "数组访问"
    | FieldAccessExpr _ -> "记录访问"
    | CombineExpr _ -> "序列"
    | TryExpr _ -> "try表达式"
    | RaiseExpr _ -> "raise表达式"
    | _ -> "其他"));
  
  match expr with
  | LitExpr _ | VarExpr _ -> gen_literal_and_vars ctx expr
  | BinaryOpExpr _ | UnaryOpExpr _ -> gen_operations ctx expr
  | RefExpr _ | DerefExpr _ | AssignExpr _ -> gen_memory_operations ctx expr
  | ListExpr _ | ArrayExpr _ | ArrayAccessExpr _ -> gen_collections ctx expr
  | TupleExpr _ | RecordExpr _ | FieldAccessExpr _ -> gen_structured_data ctx expr
  | FunCallExpr _ | FunExpr _ | CondExpr _ | LetExpr _ | MatchExpr _ -> gen_control_flow ctx expr
  | TryExpr _ | RaiseExpr _ -> gen_exception_handling ctx expr
  | CombineExpr _ -> gen_advanced_control_flow ctx expr
  | _ -> failwith ("gen_expr: 不支持的表达式类型: " ^ (match expr with
    | ModuleExpr _ -> "模块表达式"
    | _ -> "未知表达式"))