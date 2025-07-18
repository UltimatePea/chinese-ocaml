(** 骆言语义分析器 - Chinese Programming Language Semantic Analyzer *)

(** 重构后的主入口模块 *)

(** 重新导出所有公共类型和函数 *)

include Semantic_context
(** 从 Semantic_context 重新导出 *)

(** 从 Semantic_builtins 重新导出 *)
let add_builtin_functions = Semantic_builtins.add_builtin_functions

(** 从 Semantic_types 重新导出 *)
let resolve_type_expr = Semantic_types.resolve_type_expr

let add_algebraic_type = Semantic_types.add_algebraic_type
let symbol_table_to_env = Semantic_types.symbol_table_to_env

(** 从 Semantic_expressions 重新导出 *)
let analyze_expression = Semantic_expressions.analyze_expression

let check_expression_semantics = Semantic_expressions.check_expression_semantics
let check_pattern_semantics = Semantic_expressions.check_pattern_semantics

(** 从 Semantic_statements 重新导出 *)
let analyze_statement = Semantic_statements.analyze_statement

exception SemanticError of string
(** 语义错误异常 *)

(** 创建带有内置函数的初始上下文 *)
let create_semantic_context () =
  let initial_context = create_initial_context () in
  add_builtin_functions initial_context

(** 分析程序 *)
let analyze_program stmt_list =
  try
    let context = create_semantic_context () in
    let final_context, _ = Semantic_statements.analyze_statements context stmt_list in

    (* 检查是否有错误 *)
    if Semantic_errors.has_errors final_context then
      let error_messages = Semantic_errors.format_all_errors final_context in
      Error error_messages
    else Ok "语义分析成功"
  with
  | SemanticError msg -> Error [ msg ]
  | exn -> Error [ "未知错误: " ^ Printexc.to_string exn ]

(** 类型检查程序入口函数 *)
let type_check stmt_list = match analyze_program stmt_list with Ok _ -> true | Error _ -> false

(** 安静模式类型检查（用于测试） *)
let type_check_quiet stmt_list = type_check stmt_list

(** 获取表达式的类型 *)
let get_expression_type context expr =
  let _, typ_opt = analyze_expression context expr in
  typ_opt
