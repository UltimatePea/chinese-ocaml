(** 骆言C代码生成器语句模块 - Chinese Programming Language C Code Generator Statement Module *)

open Ast
open C_codegen_context
open C_codegen_expressions

(** 初始化模块日志器 *)
let log_info = Logger_utils.init_info_logger "CCodegenStmt"

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
        "luoyan_env_bind(env, \"%s\", luoyan_unit()); luoyan_env_bind(env, \"%s\", %s);" escaped_var
        escaped_var expr_code
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
  | IncludeStmt module_expr ->
      let module_code = gen_expr ctx module_expr in
      Printf.sprintf "luoyan_include_module(%s);" module_code
  | LetStmtWithType (var, _type_expr, expr) ->
      (* 带类型注解的let语句：忽略类型信息，按普通let处理 *)
      let expr_code = gen_expr ctx expr in
      let escaped_var = escape_identifier var in
      Printf.sprintf "luoyan_env_bind(env, \"%s\", %s);" escaped_var expr_code
  | RecLetStmtWithType (var, _type_expr, expr) ->
      (* 带类型注解的递归let语句：忽略类型信息，按普通递归let处理 *)
      let expr_code = gen_expr ctx expr in
      let escaped_var = escape_identifier var in
      Printf.sprintf
        "luoyan_env_bind(env, \"%s\", luoyan_unit()); luoyan_env_bind(env, \"%s\", %s);" escaped_var
        escaped_var expr_code

(** 生成程序代码 *)
let gen_program ctx program =
  let rec gen_stmts = function
    | [] -> ""
    | stmt :: rest ->
        let stmt_code = gen_stmt ctx stmt in
        let rest_code = gen_stmts rest in
        if rest_code = "" then stmt_code else stmt_code ^ "\n" ^ rest_code
  in
  gen_stmts program

(** 生成内置函数绑定代码 *)
let generate_builtin_bindings () =
  let builtins =
    [
      ("打印", "luoyan_builtin_print");
      ("读取", "luoyan_builtin_read");
      ("字符串连接", "luoyan_builtin_string_concat");
      ("读取文件", "luoyan_builtin_read_file");
      ("写入文件", "luoyan_builtin_write_file");
      ("文件存在", "luoyan_builtin_file_exists");
    ]
  in
  List.map
    (fun (name, func) ->
      let escaped_name = escape_identifier name in
      Printf.sprintf "  luoyan_env_bind(env, \"%s\", luoyan_function_create(%s, env, \"%s\"));"
        escaped_name func name)
    builtins
  |> String.concat "\n"

(** 生成主函数模板 *)
let generate_main_function program_code builtin_bindings =
  Printf.sprintf
    "int main() {\n\
    \  luoyan_runtime_init();\n\
    \  luoyan_env_t* env = luoyan_env_create(NULL);\n\
    \  \n\
    \  // 添加内置函数\n\
     %s\n\
    \  \n\
    \  %s\n\
    \  \n\
    \  luoyan_env_destroy(env);\n\
    \  return 0;\n\
     }\n"
    builtin_bindings program_code

(** 生成完整的C代码 *)
let generate_c_code config program =
  let ctx = create_context config in
  let program_code = gen_program ctx program in
  let includes = String.concat "\n" (List.map (Printf.sprintf "#include <%s>") ctx.includes) in
  let functions = String.concat "\n\n" (List.rev ctx.functions) in
  let builtin_bindings = generate_builtin_bindings () in
  let main_function = generate_main_function program_code builtin_bindings in

  Printf.sprintf "%s\n\n%s\n\n%s\n" includes functions main_function

(** 编译为C代码 *)
let compile_to_c config program =
  log_info (Printf.sprintf "开始编译为C代码，输出文件：%s" config.c_output_file);
  try
    let c_code = generate_c_code config program in
    let output_channel = open_out config.c_output_file in
    output_string output_channel c_code;
    close_out output_channel;
    log_info (Printf.sprintf "成功生成C代码文件：%s" config.c_output_file);
    Ok ()
  with
  | Sys_error msg ->
      let error_msg = Printf.sprintf "文件系统错误：%s" msg in
      log_info error_msg;
      Error (Compiler_errors.CodegenError (error_msg, "文件操作"))
  | ex ->
      let error_msg = Printf.sprintf "代码生成错误：%s" (Printexc.to_string ex) in
      log_info error_msg;
      Error (Compiler_errors.CodegenError (error_msg, "代码生成"))
