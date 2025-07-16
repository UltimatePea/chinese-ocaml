(** 统一错误处理工具模块 *)

open Constants.ErrorMessages

(** 标准化错误消息格式 *)
let format_undefined_variable var_name = undefined_variable var_name

let format_module_not_found mod_name = module_not_found mod_name

let format_member_not_found mod_name member_name = member_not_found mod_name member_name

let format_scope_error operation = 
  Printf.sprintf "作用域错误: %s" operation

let format_syntax_error expected pos =
  Printf.sprintf "语法错误 (行:%d, 列:%d): 期望 %s" pos.Lexer.line pos.Lexer.column expected

let format_lexer_error msg pos =
  Printf.sprintf "词法错误 (行:%d, 列:%d): %s" pos.Lexer.line pos.Lexer.column msg

let format_type_error msg =
  Printf.sprintf "类型错误: %s" msg

let format_runtime_error msg =
  Printf.sprintf "运行时错误: %s" msg

(** 错误恢复辅助函数 *)
let safe_operation ~operation ~fallback =
  try operation ()
  with _ -> fallback

let with_error_context context f =
  try f ()
  with 
  | Value_operations.RuntimeError msg -> 
      raise (Value_operations.RuntimeError (context ^ ": " ^ msg))
  | Semantic.SemanticError msg -> 
      raise (Semantic.SemanticError (context ^ ": " ^ msg))
  | Parser_utils.SyntaxError (msg, pos) ->
      raise (Parser_utils.SyntaxError (context ^ ": " ^ msg, pos))
  | e -> raise e

(** 输入验证辅助函数 *)
let validate_non_empty_string field_name value =
  if String.trim value = "" then
    invalid_arg (Printf.sprintf "%s 不能为空" field_name)
  else value

let validate_non_empty_list field_name list =
  if List.length list = 0 then
    invalid_arg (Printf.sprintf "%s 不能为空列表" field_name)
  else list

(** 模块访问错误处理 *)
let safe_module_lookup env mod_name _member_name =
  try
    Value_operations.lookup_var env mod_name
  with Value_operations.RuntimeError _ ->
    raise (Value_operations.RuntimeError (format_module_not_found mod_name))

(** 作用域操作错误处理 *)
let safe_scope_operation operation_name f =
  try f ()
  with Semantic.SemanticError msg ->
    raise (Semantic.SemanticError (format_scope_error (operation_name ^ ": " ^ msg)))

(** 位置信息辅助函数 *)
let make_position line column filename =
  { Lexer.line; column; filename }

let default_position = 
  make_position 1 1 "<unknown>"

(** 错误报告格式化 *)
let format_error_report error_type details suggestions =
  let buffer = Buffer.create (Constants.BufferSizes.default_buffer ()) in
  Printf.bprintf buffer "🚨 %s\n\n" error_type;
  Printf.bprintf buffer "详细信息: %s\n\n" details;
  if List.length suggestions > 0 then (
    Buffer.add_string buffer "建议的解决方案:\n";
    List.iteri (fun i suggestion ->
      Printf.bprintf buffer "  %d. %s\n" (i + 1) suggestion
    ) suggestions;
    Buffer.add_string buffer "\n"
  );
  Buffer.contents buffer

(** 错误统计和报告 *)
type error_stats = {
  mutable lexer_errors : int;
  mutable syntax_errors : int;
  mutable semantic_errors : int;
  mutable runtime_errors : int;
  mutable total_errors : int;
}

let error_stats = {
  lexer_errors = 0;
  syntax_errors = 0;
  semantic_errors = 0;
  runtime_errors = 0;
  total_errors = 0;
}

let record_lexer_error () =
  error_stats.lexer_errors <- error_stats.lexer_errors + 1;
  error_stats.total_errors <- error_stats.total_errors + 1

let record_syntax_error () =
  error_stats.syntax_errors <- error_stats.syntax_errors + 1;
  error_stats.total_errors <- error_stats.total_errors + 1

let record_semantic_error () =
  error_stats.semantic_errors <- error_stats.semantic_errors + 1;
  error_stats.total_errors <- error_stats.total_errors + 1

let record_runtime_error () =
  error_stats.runtime_errors <- error_stats.runtime_errors + 1;
  error_stats.total_errors <- error_stats.total_errors + 1

let get_error_stats () = error_stats

let reset_error_stats () =
  error_stats.lexer_errors <- 0;
  error_stats.syntax_errors <- 0;
  error_stats.semantic_errors <- 0;
  error_stats.runtime_errors <- 0;
  error_stats.total_errors <- 0

let print_error_summary () =
  if error_stats.total_errors > 0 then (
    Printf.printf "\n=== 错误统计摘要 ===\n";
    Printf.printf "词法错误: %d\n" error_stats.lexer_errors;
    Printf.printf "语法错误: %d\n" error_stats.syntax_errors;
    Printf.printf "语义错误: %d\n" error_stats.semantic_errors;
    Printf.printf "运行时错误: %d\n" error_stats.runtime_errors;
    Printf.printf "总错误数: %d\n" error_stats.total_errors;
    Printf.printf "==================\n\n"
  )