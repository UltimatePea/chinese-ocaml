(** 骆言C代码生成器 - Chinese Programming Language C Code Generator *)

open Ast
open Types

(** 代码生成配置 *)
type codegen_config = {
  output_file: string;
  include_debug: bool;
  optimize: bool;
  runtime_path: string;
}

(** 代码生成上下文 *)
type codegen_context = {
  config: codegen_config;
  mutable next_var_id: int;
  mutable next_label_id: int;
  mutable includes: string list;
  mutable global_vars: string list;
  mutable functions: string list;
}

(** 创建代码生成上下文 *)
let create_context config = {
  config;
  next_var_id = 0;
  next_label_id = 0;
  includes = ["luoyan_runtime.h"];
  global_vars = [];
  functions = [];
}

(** 生成唯一变量名 *)
let gen_var_name ctx prefix =
  let id = ctx.next_var_id in
  ctx.next_var_id <- id + 1;
  Printf.sprintf "luoyan_var_%s_%d" prefix id

(** 生成唯一标签名 *)
let gen_label_name ctx prefix =
  let id = ctx.next_label_id in
  ctx.next_label_id <- id + 1;
  Printf.sprintf "luoyan_label_%s_%d" prefix id

(** 转义标识符名称 *)
let escape_identifier name =
  let buf = Buffer.create (String.length name * 2) in
  String.iter (function
    | '0'..'9' | 'a'..'z' | 'A'..'Z' | '_' as c -> Buffer.add_char buf c
    | _ as c -> 
      let code = Char.code c in
      Buffer.add_string buf (Printf.sprintf "_%04x_" code)
  ) name;
  Buffer.contents buf

(** 生成C类型名 *)
let c_type_of_luoyan_type = function
  | IntType_T -> "luoyan_int_t"
  | FloatType_T -> "luoyan_float_t"
  | StringType_T -> "luoyan_string_t*"
  | BoolType_T -> "luoyan_bool_t"
  | ListType_T _ -> "luoyan_list_t*"
  | FunType_T (_, _) -> "luoyan_function_t*"
  | UnitType_T -> "void"
  | TypeVar_T _ -> "luoyan_value_t*"
  | TupleType_T _ -> "luoyan_value_t*"
  | ConstructType_T (_, _) -> "luoyan_value_t*"
  | RefType_T _ -> "luoyan_ref_t*"

(** 生成表达式代码 *)
let rec gen_expr ctx expr =
  match expr with
  | LitExpr (IntLit i) -> Printf.sprintf "luoyan_int(%dL)" i
  | LitExpr (FloatLit f) -> Printf.sprintf "luoyan_float(%g)" f
  | LitExpr (StringLit s) -> Printf.sprintf "luoyan_string(\"%s\")" (String.escaped s)
  | LitExpr (BoolLit b) -> Printf.sprintf "luoyan_bool(%s)" (if b then "true" else "false")
  | LitExpr UnitLit -> "luoyan_unit()"
  | VarExpr name -> 
    let escaped_name = escape_identifier name in
    Printf.sprintf "luoyan_env_lookup(env, \"%s\")" escaped_name
  | BinaryOpExpr (e1, op, e2) -> gen_binary_op ctx op e1 e2
  | UnaryOpExpr (op, e) -> gen_unary_op ctx op e
  | CondExpr (cond, then_expr, else_expr) -> gen_if_expr ctx cond then_expr else_expr
  | LetExpr (var, value_expr, body_expr) -> gen_let_expr ctx var value_expr body_expr
  | FunExpr (params, body) -> gen_fun_expr ctx params body
  | FunCallExpr (func_expr, arg_exprs) -> gen_call_expr ctx func_expr arg_exprs
  | MatchExpr (expr, patterns) -> gen_match_expr ctx expr patterns
  | ListExpr exprs -> gen_list_expr ctx exprs
  | TryExpr (_, _, _) -> failwith "Try-catch expressions not yet supported in C codegen"
  | RaiseExpr _ -> failwith "Raise expressions not yet supported in C codegen"
  | RecordExpr _ -> failwith "Record expressions not yet supported in C codegen"
  | FieldAccessExpr _ -> failwith "Field access not yet supported in C codegen"
  | RecordUpdateExpr _ -> failwith "Record update not yet supported in C codegen"
  | ArrayExpr _ -> failwith "Array expressions not yet supported in C codegen"
  | ArrayAccessExpr _ -> failwith "Array access not yet supported in C codegen"
  | ArrayUpdateExpr _ -> failwith "Array update not yet supported in C codegen"
  | SemanticLetExpr (_, _, _, _) -> failwith "Semantic let expressions not yet supported in C codegen"
  | CombineExpr _ -> failwith "Combine expressions not yet supported in C codegen"
  | OrElseExpr _ -> failwith "OrElse expressions not yet supported in C codegen"
  | TupleExpr _ -> failwith "Tuple expressions not yet supported in C codegen"
  | MacroCallExpr _ -> failwith "Macro calls not yet supported in C codegen"
  | AsyncExpr _ -> failwith "Async expressions not yet supported in C codegen"
  | RefExpr _ -> failwith "Reference expressions not yet supported in C codegen"
  | DerefExpr _ -> failwith "Dereference expressions not yet supported in C codegen"
  | AssignExpr _ -> failwith "Assignment expressions not yet supported in C codegen"
  | ConstructorExpr _ -> failwith "Constructor expressions not yet supported in C codegen"

(** 生成二元运算代码 *)
and gen_binary_op ctx op e1 e2 =
  let left = gen_expr ctx e1 in
  let right = gen_expr ctx e2 in
  match op with
  | Add -> Printf.sprintf "luoyan_add(%s, %s)" left right
  | Sub -> Printf.sprintf "luoyan_subtract(%s, %s)" left right
  | Mul -> Printf.sprintf "luoyan_multiply(%s, %s)" left right
  | Div -> Printf.sprintf "luoyan_divide(%s, %s)" left right
  | Mod -> Printf.sprintf "luoyan_modulo(%s, %s)" left right
  | Eq -> Printf.sprintf "luoyan_equal(%s, %s)" left right
  | Neq -> Printf.sprintf "luoyan_not_equal(%s, %s)" left right
  | Lt -> Printf.sprintf "luoyan_less_than(%s, %s)" left right
  | Le -> Printf.sprintf "luoyan_less_equal(%s, %s)" left right
  | Gt -> Printf.sprintf "luoyan_greater_than(%s, %s)" left right
  | Ge -> Printf.sprintf "luoyan_greater_equal(%s, %s)" left right
  | And -> Printf.sprintf "luoyan_logical_and(%s, %s)" left right
  | Or -> Printf.sprintf "luoyan_logical_or(%s, %s)" left right

(** 生成一元运算代码 *)
and gen_unary_op ctx op e =
  let operand = gen_expr ctx e in
  match op with
  | Not -> Printf.sprintf "luoyan_logical_not(%s)" operand
  | Neg -> Printf.sprintf "luoyan_subtract(luoyan_int(0), %s)" operand

(** 生成条件表达式代码 *)
and gen_if_expr ctx cond then_expr else_expr =
  let cond_var = gen_var_name ctx "cond" in
  let cond_code = gen_expr ctx cond in
  let then_code = gen_expr ctx then_expr in
  let else_code = gen_expr ctx else_expr in
  Printf.sprintf
    "({ luoyan_value_t* %s = %s; \
        ((%s->type == LUOYAN_BOOL && %s->data.bool_val)) ? (%s) : (%s); })"
    cond_var cond_code cond_var cond_var then_code else_code

(** 生成let表达式代码 *)
and gen_let_expr ctx var value_expr body_expr =
  let value_code = gen_expr ctx value_expr in
  let escaped_var = escape_identifier var in
  let body_code = gen_expr ctx body_expr in
  Printf.sprintf
    "({ luoyan_env_bind(env, \"%s\", %s); %s; })"
    escaped_var value_code body_code

(** 生成函数表达式代码 *)
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
    Printf.sprintf "luoyan_function_create(%s_impl_%s, env, \"%s\")" func_name first_param func_name

(** 生成函数调用代码 *)
and gen_call_expr ctx func_expr arg_exprs =
  let func_code = gen_expr ctx func_expr in
  match arg_exprs with
  | [] -> func_code  (* 无参数调用 *)
  | [arg_expr] ->
    let arg_code = gen_expr ctx arg_expr in
    Printf.sprintf "luoyan_function_call(%s, %s)" func_code arg_code
  | _ ->
    (* 多参数调用：连续调用curry化的函数 *)
    List.fold_left (fun acc_func arg_expr ->
      let arg_code = gen_expr ctx arg_expr in
      Printf.sprintf "luoyan_function_call(%s, %s)" acc_func arg_code
    ) func_code arg_exprs

(** 生成模式匹配代码 *)
and gen_match_expr ctx expr patterns =
  let expr_var = gen_var_name ctx "match_expr" in
  let expr_code = gen_expr ctx expr in
  
  let rec gen_patterns = function
    | [] -> "luoyan_unit()" (* 应该不会到达这里 *)
    | (pattern, expr) :: rest ->
      let pattern_check = gen_pattern_check ctx expr_var pattern in
      let expr_code = gen_expr ctx expr in
      if rest = [] then
        Printf.sprintf "(%s) ? (%s) : (luoyan_unit())" pattern_check expr_code
      else
        Printf.sprintf "(%s) ? (%s) : (%s)" pattern_check expr_code (gen_patterns rest)
  in
  
  Printf.sprintf
    "({ luoyan_value_t* %s = %s; %s; })"
    expr_var expr_code (gen_patterns patterns)

(** 生成模式检查代码 *)
and gen_pattern_check ctx expr_var = function
  | LitPattern (IntLit i) -> Printf.sprintf "luoyan_equals(%s, luoyan_int(%d))" expr_var i
  | LitPattern (StringLit s) -> Printf.sprintf "luoyan_equals(%s, luoyan_string(\"%s\"))" expr_var (String.escaped s)
  | LitPattern (BoolLit b) -> Printf.sprintf "luoyan_equals(%s, luoyan_bool(%s))" expr_var (if b then "true" else "false")
  | LitPattern UnitLit -> Printf.sprintf "luoyan_equals(%s, luoyan_unit())" expr_var
  | LitPattern (FloatLit f) -> Printf.sprintf "luoyan_equals(%s, luoyan_float(%g))" expr_var f
  | VarPattern var -> 
    let escaped_var = escape_identifier var in
    Printf.sprintf "(luoyan_env_bind(env, \"%s\", %s), true)" escaped_var expr_var
  | EmptyListPattern -> Printf.sprintf "luoyan_list_is_empty(%s)->data.bool_val" expr_var
  | ConsPattern (head_pat, tail_pat) -> 
    let head_check = gen_pattern_check ctx (Printf.sprintf "luoyan_list_head(%s)" expr_var) head_pat in
    let tail_check = gen_pattern_check ctx (Printf.sprintf "luoyan_list_tail(%s)" expr_var) tail_pat in
    Printf.sprintf "(!luoyan_list_is_empty(%s)->data.bool_val && %s && %s)" expr_var head_check tail_check
  | WildcardPattern -> "true"
  | _ -> failwith "Unsupported pattern in C codegen"

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

(** 生成语句代码 *)
let gen_stmt ctx = function
  | ExprStmt expr -> 
    let expr_code = gen_expr ctx expr in
    Printf.sprintf "%s;" expr_code
  | LetStmt (var, expr) ->
    let expr_code = gen_expr ctx expr in
    let escaped_var = escape_identifier var in
    Printf.sprintf "luoyan_env_bind(env, \"%s\", %s);" escaped_var expr_code
  | RecLetStmt (var, expr) ->
    (* 递归函数需要特殊处理 *)
    let escaped_var = escape_identifier var in
    let expr_code = gen_expr ctx expr in
    Printf.sprintf
      "luoyan_env_bind(env, \"%s\", luoyan_unit()); \
       luoyan_env_bind(env, \"%s\", %s);"
      escaped_var escaped_var expr_code
  | SemanticLetStmt (var, _semantic, expr) ->
    (* 语义let语句与普通let相同 *)
    let expr_code = gen_expr ctx expr in
    let escaped_var = escape_identifier var in
    Printf.sprintf "luoyan_env_bind(env, \"%s\", %s);" escaped_var expr_code
  | TypeDefStmt (_, _) -> "/* Type definition ignored in C generation */"
  | ModuleDefStmt _ -> "/* Module definition ignored in C generation */"
  | ModuleImportStmt _ -> "/* Module import ignored in C generation */"
  | MacroDefStmt _ -> "/* Macro definition ignored in C generation */"
  | ExceptionDefStmt (_, _) -> "/* Exception definition ignored in C generation */"

(** 生成程序代码 *)
let gen_program ctx program =
  let rec gen_stmts = function
    | [] -> ""
    | stmt :: rest ->
      let stmt_code = gen_stmt ctx stmt in
      stmt_code ^ "\n" ^ gen_stmts rest
  in
  gen_stmts program

(** 生成完整的C代码 *)
let generate_c_code config program =
  let ctx = create_context config in
  
  (* 生成主要代码 *)
  let main_code = gen_program ctx program in
  
  (* 生成完整的C文件 *)
  let includes = String.concat "\n" (List.map (Printf.sprintf "#include \"%s\"") ctx.includes) in
  let functions = String.concat "\n\n" (List.rev ctx.functions) in
  
  Printf.sprintf
    "%s\n\n\
    %s\n\n\
    int main() {\n\
    \  luoyan_runtime_init();\n\
    \  luoyan_env_t* env = luoyan_env_create(NULL);\n\
    \  \n\
    \  // 添加内置函数\n\
    \  luoyan_env_bind(env, \"打印\", luoyan_function_create(luoyan_builtin_print, env, \"打印\"));\n\
    \  luoyan_env_bind(env, \"读取\", luoyan_function_create(luoyan_builtin_read, env, \"读取\"));\n\
    \  \n\
    \  // 用户程序\n\
    %s\n\
    \  \n\
    \  luoyan_env_release(env);\n\
    \  luoyan_runtime_cleanup();\n\
    \  return 0;\n\
    }\n"
    includes functions main_code

(** 主要编译函数 *)
let compile_to_c config program =
  let c_code = generate_c_code config program in
  
  (* 写入C文件 *)
  let oc = open_out config.output_file in
  output_string oc c_code;
  close_out oc;
  
  Printf.printf "C代码已生成到: %s\n" config.output_file