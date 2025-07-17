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
  | Sub -> Printf.sprintf "luoyan_sub(%s, %s)" e1_code e2_code
  | Mul -> Printf.sprintf "luoyan_mul(%s, %s)" e1_code e2_code
  | Div -> Printf.sprintf "luoyan_div(%s, %s)" e1_code e2_code
  | Mod -> Printf.sprintf "luoyan_mod(%s, %s)" e1_code e2_code
  | Eq -> Printf.sprintf "luoyan_eq(%s, %s)" e1_code e2_code
  | Neq -> Printf.sprintf "luoyan_neq(%s, %s)" e1_code e2_code
  | Lt -> Printf.sprintf "luoyan_lt(%s, %s)" e1_code e2_code
  | Gt -> Printf.sprintf "luoyan_gt(%s, %s)" e1_code e2_code
  | Le -> Printf.sprintf "luoyan_lte(%s, %s)" e1_code e2_code
  | Ge -> Printf.sprintf "luoyan_gte(%s, %s)" e1_code e2_code
  | And -> Printf.sprintf "luoyan_and(%s, %s)" e1_code e2_code
  | Or -> Printf.sprintf "luoyan_or(%s, %s)" e1_code e2_code
  | Concat -> Printf.sprintf "luoyan_concat(%s, %s)" e1_code e2_code

(** 生成一元运算表达式代码 *)
and gen_unary_op ctx op e =
  let e_code = gen_expr ctx e in
  match op with
  | Neg -> Printf.sprintf "luoyan_neg(%s)" e_code
  | Not -> Printf.sprintf "luoyan_not(%s)" e_code

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
  let rec gen_list_elements = function
    | [] -> "luoyan_nil()"
    | expr :: rest ->
        let expr_code = gen_expr ctx expr in
        let rest_code = gen_list_elements rest in
        Printf.sprintf "luoyan_cons(%s, %s)" expr_code rest_code
  in
  gen_list_elements exprs

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
  let param_names = List.map escape_identifier params in
  let param_count = List.length params in
  let body_code = gen_expr ctx body in
  Printf.sprintf "luoyan_function(%d, (const char*[]){%s}, %s)" param_count 
    (String.concat ", " (List.map (Printf.sprintf "\"%s\"") param_names)) body_code

(** 生成条件表达式代码 *)
and gen_if_expr ctx cond_expr then_expr else_expr =
  let cond_code = gen_expr ctx cond_expr in
  let then_code = gen_expr ctx then_expr in
  let else_code = gen_expr ctx else_expr in
  Printf.sprintf "luoyan_if(%s, %s, %s)" cond_code then_code else_code

(** 生成let表达式代码 *)
and gen_let_expr ctx var_name value_expr body_expr =
  let value_code = gen_expr ctx value_expr in
  let escaped_var = escape_identifier var_name in
  let body_code = gen_expr ctx body_expr in
  Printf.sprintf "luoyan_let(\"%s\", %s, %s)" escaped_var value_code body_code

(** 生成匹配表达式代码 *)
and gen_match_expr ctx expr match_branches =
  let expr_code = gen_expr ctx expr in
  let gen_match_branch branch =
    let pattern_code = gen_pattern ctx branch.pattern in
    let result_code = gen_expr ctx branch.expr in
    let guard_code = match branch.guard with
      | Some guard -> gen_expr ctx guard
      | None -> "luoyan_true()"
    in
    Printf.sprintf "{%s, %s, %s}" pattern_code guard_code result_code
  in
  let branch_codes = List.map gen_match_branch match_branches in
  Printf.sprintf "luoyan_match(%s, %d, (luoyan_match_branch_t[]){%s})" expr_code (List.length match_branches) (String.concat ", " branch_codes)

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