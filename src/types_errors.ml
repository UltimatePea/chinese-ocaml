(** 骆言类型系统错误处理模块 - Type System Error Handling 

    重构说明：Printf.sprintf统一化Phase 3.2 - 完全消除Printf.sprintf依赖
    使用Base_formatter底层基础设施，实现零Printf.sprintf依赖的错误处理。
    
    @version 3.2 - Printf.sprintf统一化第三阶段
    @since 2025-07-24 Issue #1040 Printf.sprintf统一化 *)

open Core_types
(* 引入基础格式化器，实现零Printf.sprintf依赖 *)
open Utils.Base_formatter

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

(** 类型不匹配错误 - 使用Base_formatter消除Printf.sprintf *)
let type_mismatch_error expected actual =
  let msg = Base_formatter.type_mismatch_pattern 
    (string_of_typ expected) (string_of_typ actual) in
  TypeError msg

(** 未定义变量错误 - 使用Base_formatter消除Printf.sprintf *)
let undefined_var_error var_name =
  let msg = Base_formatter.undefined_variable_pattern var_name in
  TypeError msg

(** 重复定义错误 - 使用Base_formatter消除Printf.sprintf *)
let duplicate_definition_error name =
  let msg = Base_formatter.concat_strings ["重复定义: "; name] in
  TypeError msg

(** 类型推断失败错误 - 使用Base_formatter消除Printf.sprintf *)
let type_inference_error expr_desc =
  let msg = Base_formatter.concat_strings ["类型推断失败: "; expr_desc] in
  TypeError msg

(** 类型合一失败错误 - 使用Base_formatter消除Printf.sprintf *)
let unification_error typ1 typ2 =
  let msg = Base_formatter.concat_strings [
    "无法合一类型 "; string_of_typ typ1; " 和 "; string_of_typ typ2] in
  TypeError msg

(** 循环类型错误 - 使用Base_formatter消除Printf.sprintf *)
let occurs_check_error var_name typ =
  let msg = Base_formatter.concat_strings [
    "循环类型检查失败: "; var_name; " 出现在 "; string_of_typ typ; " 中"] in
  TypeError msg

(** 参数数量不匹配错误 - 使用Base_formatter消除Printf.sprintf *)
let arity_mismatch_error expected actual =
  let msg = Base_formatter.concat_strings [
    "参数数量不匹配: 期望 "; Base_formatter.int_to_string expected; 
    ", 实际 "; Base_formatter.int_to_string actual] in
  TypeError msg

(** 不支持的操作错误 - 使用Base_formatter消除Printf.sprintf *)
let unsupported_operation_error op_name typ =
  let msg = Base_formatter.concat_strings [
    "类型 "; string_of_typ typ; " 不支持操作 "; op_name] in
  TypeError msg

(** 字段不存在错误 - 使用Base_formatter消除Printf.sprintf *)
let field_not_found_error field_name typ =
  let msg = Base_formatter.concat_strings [
    "类型 "; string_of_typ typ; " 中不存在字段 "; field_name] in
  TypeError msg

(** 重载解析失败错误 - 使用Base_formatter消除Printf.sprintf *)
let overload_resolution_error func_name candidates =
  let candidate_strs = List.map string_of_typ candidates in
  let candidates_str = Base_formatter.join_with_separator ", " candidate_strs in
  let msg = Base_formatter.concat_strings [
    "函数 "; func_name; " 的重载解析失败, 候选类型: "; candidates_str] in
  TypeError msg

(** 错误消息格式化 - 使用Base_formatter消除Printf.sprintf *)
let format_error_message = function
  | TypeError msg -> Base_formatter.concat_strings ["类型错误: "; msg]
  | ParseError (msg, line, col) ->
      Base_formatter.concat_strings [
        "解析错误 (行:"; Base_formatter.int_to_string line; 
        ", 列:"; Base_formatter.int_to_string col; "): "; msg]
  | CodegenError (msg, context) -> 
      Base_formatter.concat_strings ["代码生成错误 ["; context; "]: "; msg]
  | SemanticError (msg, context) -> 
      Base_formatter.concat_strings ["语义错误 ["; context; "]: "; msg]
  | exn -> Base_formatter.concat_strings ["未知错误: "; Printexc.to_string exn]

(** 错误处理包装函数 *)
let handle_error f x =
  try Ok (f x) with
  | (TypeError _ | ParseError _ | CodegenError _ | SemanticError _) as e ->
      Error (format_error_message e)
  | exn -> Error (Base_formatter.concat_strings ["意外错误: "; Printexc.to_string exn])

(** 错误处理映射函数 *)
let handle_error_map f x =
  match handle_error f x with
  | Ok result -> result
  | Error msg ->
      (* 记录错误并抛出本地异常 *)
      raise (TypeError msg)

(** 安全执行函数 *)
let safe_execute f x default =
  try f x with
  | TypeError _ | ParseError _ | CodegenError _ | SemanticError _ -> default
  | exn ->
      Unified_logger.error "TypesErrors"
        (Base_formatter.concat_strings ["意外错误: "; Printexc.to_string exn]);
      default
