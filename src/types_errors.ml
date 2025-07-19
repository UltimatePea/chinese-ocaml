(** 骆言类型系统错误处理模块 - Type System Error Handling *)

open Core_types

exception TypeError of string
(** 类型错误异常 *)

exception ParseError of string * int * int
(** 解析错误异常 *)

exception CodegenError of string * string
(** 代码生成错误异常 *)

exception SemanticError of string * string
(** 语义分析错误异常 *)

(** 类型错误创建函数 *)
let type_error msg = TypeError msg

(** 解析错误创建函数 *)
let parse_error msg line col = ParseError (msg, line, col)

(** 代码生成错误创建函数 *)
let codegen_error msg context = CodegenError (msg, context)

(** 语义错误创建函数 *)
let semantic_error msg context = SemanticError (msg, context)

(** 类型不匹配错误 *)
let type_mismatch_error expected actual =
  let msg = Unified_logger.Legacy.sprintf "类型不匹配: 期望 %s, 实际 %s" (string_of_typ expected) (string_of_typ actual) in
  TypeError msg

(** 未定义变量错误 *)
let undefined_var_error var_name =
  let msg = Unified_logger.Legacy.sprintf "未定义的变量: %s" var_name in
  TypeError msg

(** 重复定义错误 *)
let duplicate_definition_error name =
  let msg = Unified_logger.Legacy.sprintf "重复定义: %s" name in
  TypeError msg

(** 类型推断失败错误 *)
let type_inference_error expr_desc =
  let msg = Unified_logger.Legacy.sprintf "类型推断失败: %s" expr_desc in
  TypeError msg

(** 类型合一失败错误 *)
let unification_error typ1 typ2 =
  let msg = Unified_logger.Legacy.sprintf "无法合一类型 %s 和 %s" (string_of_typ typ1) (string_of_typ typ2) in
  TypeError msg

(** 循环类型错误 *)
let occurs_check_error var_name typ =
  let msg = Unified_logger.Legacy.sprintf "循环类型检查失败: %s 出现在 %s 中" var_name (string_of_typ typ) in
  TypeError msg

(** 参数数量不匹配错误 *)
let arity_mismatch_error expected actual =
  let msg = Unified_logger.Legacy.sprintf "参数数量不匹配: 期望 %d, 实际 %d" expected actual in
  TypeError msg

(** 不支持的操作错误 *)
let unsupported_operation_error op_name typ =
  let msg = Unified_logger.Legacy.sprintf "类型 %s 不支持操作 %s" (string_of_typ typ) op_name in
  TypeError msg

(** 字段不存在错误 *)
let field_not_found_error field_name typ =
  let msg = Unified_logger.Legacy.sprintf "类型 %s 中不存在字段 %s" (string_of_typ typ) field_name in
  TypeError msg

(** 重载解析失败错误 *)
let overload_resolution_error func_name candidates =
  let candidate_strs = List.map string_of_typ candidates in
  let msg =
    Unified_logger.Legacy.sprintf "函数 %s 的重载解析失败, 候选类型: %s" func_name (String.concat ", " candidate_strs)
  in
  TypeError msg

(** 错误消息格式化 *)
let format_error_message = function
  | TypeError msg -> Unified_logger.Legacy.sprintf "类型错误: %s" msg
  | ParseError (msg, line, col) -> Unified_logger.Legacy.sprintf "解析错误 (行:%d, 列:%d): %s" line col msg
  | CodegenError (msg, context) -> Unified_logger.Legacy.sprintf "代码生成错误 [%s]: %s" context msg
  | SemanticError (msg, context) -> Unified_logger.Legacy.sprintf "语义错误 [%s]: %s" context msg
  | exn -> Unified_logger.Legacy.sprintf "未知错误: %s" (Printexc.to_string exn)

(** 错误处理包装函数 *)
let handle_error f x =
  try Ok (f x) with
  | (TypeError _ | ParseError _ | CodegenError _ | SemanticError _) as e ->
      Error (format_error_message e)
  | exn -> Error (Unified_logger.Legacy.sprintf "意外错误: %s" (Printexc.to_string exn))

(** 错误处理映射函数 *)
let handle_error_map f x =
  match handle_error f x with Ok result -> result | Error msg -> failwith msg

(** 安全执行函数 *)
let safe_execute f x default =
  try f x with
  | TypeError _ | ParseError _ | CodegenError _ | SemanticError _ -> default
  | exn ->
      Unified_logger.error "TypesErrors" (Unified_logger.Legacy.sprintf "意外错误: %s" (Printexc.to_string exn));
      default
