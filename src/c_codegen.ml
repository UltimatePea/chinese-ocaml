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

(** 转义标识符名称 - 保留中文字符，只转义C语言不支持的字符 *)
let escape_identifier name =
  let buf = Buffer.create (String.length name * 2) in
  String.iter (function
    | '0'..'9' | 'a'..'z' | 'A'..'Z' | '_' as c -> Buffer.add_char buf c
    | ' ' -> Buffer.add_string buf "_space_"
    | '-' -> Buffer.add_string buf "_dash_"
    | '+' -> Buffer.add_string buf "_plus_"
    | '*' -> Buffer.add_string buf "_star_"
    | '/' -> Buffer.add_string buf "_slash_"
    | '=' -> Buffer.add_string buf "_eq_"
    | '!' -> Buffer.add_string buf "_excl_"
    | '?' -> Buffer.add_string buf "_quest_"
    | '.' -> Buffer.add_string buf "_dot_"
    | ',' -> Buffer.add_string buf "_comma_"
    | ':' -> Buffer.add_string buf "_colon_"
    | ';' -> Buffer.add_string buf "_semicolon_"
    | '(' -> Buffer.add_string buf "_lparen_"
    | ')' -> Buffer.add_string buf "_rparen_"
    | '[' -> Buffer.add_string buf "_lbracket_"
    | ']' -> Buffer.add_string buf "_rbracket_"
    | '{' -> Buffer.add_string buf "_lbrace_"
    | '}' -> Buffer.add_string buf "_rbrace_"
    | '<' -> Buffer.add_string buf "_lt_"
    | '>' -> Buffer.add_string buf "_gt_"
    | '\'' -> Buffer.add_string buf "_quote_"
    | '"' -> Buffer.add_string buf "_dquote_"
    | '\\' -> Buffer.add_string buf "_backslash_"
    | '|' -> Buffer.add_string buf "_pipe_"
    | '&' -> Buffer.add_string buf "_amp_"
    | '%' -> Buffer.add_string buf "_percent_"
    | '^' -> Buffer.add_string buf "_caret_"
    | '~' -> Buffer.add_string buf "_tilde_"
    | '@' -> Buffer.add_string buf "_at_"
    | '#' -> Buffer.add_string buf "_hash_"
    | '$' -> Buffer.add_string buf "_dollar_"
    | '\n' -> Buffer.add_string buf "_newline_"
    | '\r' -> Buffer.add_string buf "_carriage_"
    | '\t' -> Buffer.add_string buf "_tab_"
    | c when Char.code c >= 32 && Char.code c <= 126 -> 
      (* 其他ASCII可打印字符，转义为安全形式 *)
      Buffer.add_string buf (Printf.sprintf "_ascii%d_" (Char.code c))
    | c -> 
      (* 保留中文和其他Unicode字符 *)
      Buffer.add_char buf c
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
  | RecordType_T _ -> "luoyan_record_t*"
  | ArrayType_T _ -> "luoyan_array_t*"
  | ClassType_T (_, _) -> "luoyan_object_t*"
  | ObjectType_T _ -> "luoyan_object_t*"

(** 生成表达式代码 *)
let rec gen_expr ctx expr =
  match expr with
  | LitExpr (IntLit i) -> Printf.sprintf "luoyan_int(%dL)" i
  | LitExpr (FloatLit f) -> Printf.sprintf "luoyan_float(%g)" f
  | LitExpr (StringLit s) -> 
    (* 对于C代码生成，我们需要保持UTF-8字符串原样，只转义必要的字符 *)
    let escape_for_c str =
      let buf = Buffer.create (String.length str * 2) in
      String.iter (function
        | '"' -> Buffer.add_string buf "\\\""
        | '\\' -> Buffer.add_string buf "\\\\"
        | '\n' -> Buffer.add_string buf "\\n"
        | '\r' -> Buffer.add_string buf "\\r"
        | '\t' -> Buffer.add_string buf "\\t"
        | c -> Buffer.add_char buf c
      ) str;
      Buffer.contents buf
    in
    Printf.sprintf "luoyan_string(\"%s\")" (escape_for_c s)
  | LitExpr (BoolLit b) -> Printf.sprintf "luoyan_bool(%s)" (if b then "true" else "false")
  | LitExpr UnitLit -> "luoyan_unit()"
  | VarExpr name -> 
    let escaped_name = escape_identifier name in
    Printf.sprintf "luoyan_env_lookup(env, \"%s\")" escaped_name
  | BinaryOpExpr (e1, op, e2) -> gen_binary_op ctx op e1 e2
  | UnaryOpExpr (op, e) -> gen_unary_op ctx op e
  | FunCallExpr (func_expr, arg_exprs) -> gen_call_expr ctx func_expr arg_exprs
  | CondExpr (cond, then_expr, else_expr) -> gen_if_expr ctx cond then_expr else_expr
  | TupleExpr _ -> failwith "Tuples not yet supported in C codegen"
  | ListExpr exprs -> gen_list_expr ctx exprs
  | MatchExpr (expr, patterns) -> gen_match_expr ctx expr patterns
  | FunExpr (params, body) -> gen_fun_expr ctx params body
  | LetExpr (var, value_expr, body_expr) -> gen_let_expr ctx var value_expr body_expr
  | MacroCallExpr _macro_call -> 
    (* 简化版本：暂时不支持宏调用在C代码生成中 *)
    "/* 宏调用尚未在C代码生成中实现 */ 0"
  | AsyncExpr _ -> failwith "Async expressions not yet supported in C codegen"
  | RefExpr expr -> gen_ref_expr ctx expr
  | DerefExpr expr -> gen_deref_expr ctx expr
  | AssignExpr (ref_expr, value_expr) -> gen_assign_expr ctx ref_expr value_expr
  | ConstructorExpr (constructor, args) -> gen_constructor_expr ctx constructor args
  | ClassDefExpr class_def -> gen_class_def_expr ctx class_def
  | NewObjectExpr (class_name, field_inits) -> gen_new_object_expr ctx class_name field_inits
  | MethodCallExpr (obj_expr, method_name, args) -> gen_method_call_expr ctx obj_expr method_name args
  | SelfExpr -> 
    (* 生成自己引用 - 在方法上下文中查找环境中的自己变量 *)
    Printf.sprintf "luoyan_env_lookup(env, \"%s\")" (escape_identifier "自己")
  | SemanticLetExpr (var, _semantic, value_expr, body_expr) -> gen_let_expr ctx var value_expr body_expr
  | CombineExpr _ -> failwith "Combine expressions not yet supported in C codegen"
  | OrElseExpr (_, _) -> failwith "OrElse expressions not yet supported in C codegen"
  | RecordExpr fields -> gen_record_expr ctx fields
  | FieldAccessExpr (record_expr, field_name) -> gen_field_access_expr ctx record_expr field_name
  | RecordUpdateExpr (record_expr, updates) -> gen_record_update_expr ctx record_expr updates
  | ArrayExpr exprs -> gen_array_expr ctx exprs
  | ArrayAccessExpr (array_expr, index_expr) -> gen_array_access_expr ctx array_expr index_expr
  | ArrayUpdateExpr (array_expr, index_expr, value_expr) -> gen_array_update_expr ctx array_expr index_expr value_expr
  | TryExpr _ -> failwith "Try expressions not yet supported in C codegen"
  | RaiseExpr _ -> failwith "Raise expressions not yet supported in C codegen"

(** OOP 支持函数 *)
and gen_class_def_expr ctx class_def =
  let class_var = gen_var_name ctx "class" in
  let class_name = escape_identifier class_def.class_name in
  let superclass_name = match class_def.superclass with
    | Some name -> Printf.sprintf "\"%s\"" (escape_identifier name)
    | None -> "NULL"
  in
  
  (* 生成字段名数组 *)
  let field_count = List.length class_def.fields in
  let field_names_array = if field_count > 0 then
    let field_names = List.map (fun (name, _) -> Printf.sprintf "\"%s\"" (escape_identifier name)) class_def.fields in
    Printf.sprintf "((char*[]){%s})" (String.concat ", " field_names)
  else
    "NULL"
  in
  
  (* 创建类 *)
  let create_class = Printf.sprintf "luoyan_class_create(\"%s\", %s, %s, %d)" 
    class_name superclass_name field_names_array field_count in
  
  (* 生成方法并添加到类 *)
  let method_additions = List.map (fun method_def ->
    let method_name = escape_identifier method_def.method_name in
    let func_name = Printf.sprintf "luoyan_var_func_%d_impl_%s" ctx.next_var_id method_def.method_name in
    ctx.next_var_id <- ctx.next_var_id + 1;
    
    (* 生成方法实现函数 *)
    let param_bindings = List.mapi (fun i param ->
      let escaped_param = escape_identifier param in
      Printf.sprintf "luoyan_env_bind(env, \"%s\", args[%d]);" escaped_param i
    ) method_def.method_params in
    
    let body_code = gen_expr ctx method_def.method_body in
    let func_impl = Printf.sprintf
      "luoyan_value_t* %s(luoyan_env_t* env, luoyan_value_t** args, int argc) {\n  %s\n  return %s;\n}"
      func_name (String.concat "\n  " param_bindings) body_code in
    
    ctx.functions <- func_impl :: ctx.functions;
    
    (* 添加方法到类 *)
    let param_names_array = if List.length method_def.method_params > 0 then
      let param_names = List.map (fun p -> Printf.sprintf "\"%s\"" (escape_identifier p)) method_def.method_params in
      Printf.sprintf "((char*[]){%s})" (String.concat ", " param_names)
    else
      "NULL"
    in
    Printf.sprintf "luoyan_class_add_method(%s, \"%s\", %s, %d, %s);"
      class_var method_name func_name (List.length method_def.method_params) param_names_array
  ) class_def.methods in
  
  Printf.sprintf "({ luoyan_value_t* %s = %s; %s %s; })"
    class_var create_class (String.concat " " method_additions) class_var

and gen_new_object_expr ctx class_name field_inits =
  let escaped_class_name = escape_identifier class_name in
  let field_count = List.length field_inits in
  
  if field_count = 0 then
    Printf.sprintf "luoyan_object_create(\"%s\", NULL, 0)" escaped_class_name
  else
    let field_var = gen_var_name ctx "field_values" in
    let field_assignments = List.mapi (fun i (_, expr) ->
      let field_code = gen_expr ctx expr in
      Printf.sprintf "%s[%d] = %s;" field_var i field_code
    ) field_inits in
    
    Printf.sprintf "({ luoyan_value_t** %s = malloc(sizeof(luoyan_value_t*) * %d); %s luoyan_object_create(\"%s\", %s, %d); })"
      field_var field_count (String.concat " " field_assignments) escaped_class_name field_var field_count

and gen_method_call_expr ctx obj_expr method_name args =
  let obj_code = gen_expr ctx obj_expr in
  let escaped_method_name = escape_identifier method_name in
  let arg_count = List.length args in
  
  if arg_count = 0 then
    Printf.sprintf "luoyan_method_call(%s, \"%s\", NULL, 0)" obj_code escaped_method_name
  else
    let args_var = gen_var_name ctx "method_args" in
    let arg_assignments = List.mapi (fun i arg ->
      let arg_code = gen_expr ctx arg in
      Printf.sprintf "%s[%d] = %s;" args_var i arg_code
    ) args in
    
    Printf.sprintf "({ luoyan_value_t** %s = malloc(sizeof(luoyan_value_t*) * %d); %s luoyan_method_call(%s, \"%s\", %s, %d); })"
      args_var arg_count (String.concat " " arg_assignments) obj_code escaped_method_name args_var arg_count

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
  | Concat -> Printf.sprintf "luoyan_concat(%s, %s)" left right
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

and gen_record_expr ctx fields =
  let record_var = gen_var_name ctx "record" in
  let init_code = Printf.sprintf "luoyan_record_create()" in
  match fields with
  | [] -> init_code
  | _ -> 
    let field_assignments = List.map (fun (field_name, field_expr) ->
      let field_code = gen_expr ctx field_expr in
      let escaped_field = escape_identifier field_name in
      Printf.sprintf "luoyan_record_set_field(%s, \"%s\", %s)" record_var escaped_field field_code
    ) fields in
    let assignments_code = String.concat "; " field_assignments in
    Printf.sprintf "({ luoyan_value_t* %s = %s; %s; %s; })" record_var init_code assignments_code record_var

and gen_field_access_expr ctx record_expr field_name =
  let record_code = gen_expr ctx record_expr in
  let escaped_field = escape_identifier field_name in
  Printf.sprintf "luoyan_record_get_field(%s, \"%s\")" record_code escaped_field

and gen_record_update_expr ctx record_expr updates =
  let record_code = gen_expr ctx record_expr in
  match updates with
  | [] -> record_code
  | (field_name, field_expr) :: rest ->
    let field_code = gen_expr ctx field_expr in
    let escaped_field = escape_identifier field_name in
    let first_update = Printf.sprintf "luoyan_record_update(%s, \"%s\", %s)" record_code escaped_field field_code in
    List.fold_left (fun acc_code (fname, fexpr) ->
      let fcode = gen_expr ctx fexpr in
      let escaped_fname = escape_identifier fname in
      Printf.sprintf "luoyan_record_update(%s, \"%s\", %s)" acc_code escaped_fname fcode
    ) first_update rest

(** 生成元组表达式代码 *)
and gen_tuple_expr ctx exprs =
  match exprs with
  | [] -> "luoyan_unit()"
  | [single] -> gen_expr ctx single
  | _ ->
    (* 元组存储为记录，字段名为_0, _1, _2等 *)
    let tuple_var = gen_var_name ctx "tuple" in
    let init_code = "luoyan_record_create()" in
    let field_assignments = List.mapi (fun i expr ->
      let field_name = Printf.sprintf "_%d" i in
      let field_code = gen_expr ctx expr in
      Printf.sprintf "luoyan_record_set_field(%s, \"%s\", %s)" tuple_var field_name field_code
    ) exprs in
    let assignments_code = String.concat "; " field_assignments in
    Printf.sprintf "({ luoyan_value_t* %s = %s; %s; %s; })" tuple_var init_code assignments_code tuple_var

(** 生成引用表达式代码 *)
and gen_ref_expr ctx expr =
  let value_code = gen_expr ctx expr in
  Printf.sprintf "luoyan_ref_create(%s)" value_code

(** 生成解引用表达式代码 *)
and gen_deref_expr ctx expr =
  let ref_code = gen_expr ctx expr in
  Printf.sprintf "luoyan_ref_get(%s)" ref_code

(** 生成赋值表达式代码 *)
and gen_assign_expr ctx ref_expr value_expr =
  let ref_code = gen_expr ctx ref_expr in
  let value_code = gen_expr ctx value_expr in
  Printf.sprintf "luoyan_ref_set(%s, %s)" ref_code value_code

(** 生成构造器表达式代码 *)
and gen_constructor_expr ctx constructor args =
  let constructor_name = escape_identifier constructor in
  match args with
  | [] -> 
    (* 无参数构造器，创建一个带有构造器名的记录 *)
    Printf.sprintf "luoyan_constructor_create(\"%s\", NULL)" constructor_name
  | _ ->
    let args_code = List.map (gen_expr ctx) args in
    let args_array = String.concat ", " args_code in
    Printf.sprintf "luoyan_constructor_create(\"%s\", luoyan_array_from_values(%s))" constructor_name args_array

(** 生成数组表达式代码 *)
and gen_array_expr ctx exprs =
  match exprs with
  | [] -> "luoyan_array_empty()"
  | _ ->
    let array_var = gen_var_name ctx "array" in
    let init_code = Printf.sprintf "luoyan_array_create(%d)" (List.length exprs) in
    let element_assignments = List.mapi (fun i expr ->
      let element_code = gen_expr ctx expr in
      Printf.sprintf "luoyan_array_set(%s, %d, %s)" array_var i element_code
    ) exprs in
    let assignments_code = String.concat "; " element_assignments in
    Printf.sprintf "({ luoyan_value_t* %s = %s; %s; %s; })" array_var init_code assignments_code array_var

(** 生成数组访问表达式代码 *)
and gen_array_access_expr ctx array_expr index_expr =
  let array_code = gen_expr ctx array_expr in
  let index_code = gen_expr ctx index_expr in
  Printf.sprintf "luoyan_array_get(%s, %s)" array_code index_code

(** 生成数组更新表达式代码 *)
and gen_array_update_expr ctx array_expr index_expr value_expr =
  let array_code = gen_expr ctx array_expr in
  let index_code = gen_expr ctx index_expr in
  let value_code = gen_expr ctx value_expr in
  Printf.sprintf "luoyan_array_update(%s, %s, %s)" array_code index_code value_code

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
  | ModuleTypeDefStmt _ -> "/* Module type definition ignored in C generation */"
  | MacroDefStmt _ -> "/* Macro definition ignored in C generation */"
  | ExceptionDefStmt (_, _) -> "/* Exception definition ignored in C generation */"
  | ClassDefStmt class_def -> 
    let class_expr_code = gen_class_def_expr ctx class_def in
    let escaped_class_name = escape_identifier class_def.class_name in
    Printf.sprintf "luoyan_env_bind(env, \"%s\", %s);" escaped_class_name class_expr_code

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
  
  let escaped_print = escape_identifier "打印" in
  let escaped_read = escape_identifier "读取" in
  let escaped_string_concat = escape_identifier "字符串连接" in
  let escaped_read_file = escape_identifier "读取文件" in
  let escaped_write_file = escape_identifier "写入文件" in
  let escaped_file_exists = escape_identifier "文件存在" in
  Printf.sprintf
    "%s\n\n\
    %s\n\n\
    int main() {\n\
    \  luoyan_runtime_init();\n\
    \  luoyan_env_t* env = luoyan_env_create(NULL);\n\
    \  \n\
    \  // 添加内置函数\n\
    \  luoyan_env_bind(env, \"%s\", luoyan_function_create(luoyan_builtin_print, env, \"打印\"));\n\
    \  luoyan_env_bind(env, \"%s\", luoyan_function_create(luoyan_builtin_read, env, \"读取\"));\n\
    \  luoyan_env_bind(env, \"%s\", luoyan_function_create(luoyan_builtin_string_concat, env, \"字符串连接\"));\n\
    \  luoyan_env_bind(env, \"%s\", luoyan_function_create(luoyan_builtin_read_file, env, \"读取文件\"));\n\
    \  luoyan_env_bind(env, \"%s\", luoyan_function_create(luoyan_builtin_write_file, env, \"写入文件\"));\n\
    \  luoyan_env_bind(env, \"%s\", luoyan_function_create(luoyan_builtin_file_exists, env, \"文件存在\"));\n\
    \  \n\
    \  // 设置全局环境供方法调用使用\n\
    \  luoyan_set_global_env(env);\n\
    \  \n\
    \  // 用户程序\n\
    %s\n\
    \  \n\
    \  luoyan_env_release(env);\n\
    \  luoyan_runtime_cleanup();\n\
    \  return 0;\n\
    }\n"
    includes functions escaped_print escaped_read escaped_string_concat escaped_read_file escaped_write_file escaped_file_exists main_code

(** 主要编译函数 *)
let compile_to_c config program =
  let c_code = generate_c_code config program in
  
  (* 写入C文件 *)
  let oc = open_out config.output_file in
  output_string oc c_code;
  close_out oc;
  
  Printf.printf "C代码已生成到: %s\n" config.output_file