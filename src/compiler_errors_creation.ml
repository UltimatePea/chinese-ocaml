(** 错误创建函数 - 骆言编译器 *)

open Compiler_errors_types

(** 创建错误信息 *)
let make_error_info ?(severity = (Error : error_severity)) ?(context = None) ?(suggestions = [])
    error =
  { error; severity; context; suggestions }

(** 位置信息创建辅助函数 *)
let make_position ?(filename = "") line column = { filename; line; column }

(** 常用错误创建函数 *)
let lex_error ?(suggestions = []) msg pos =
  let error_info = make_error_info ~suggestions (LexError (msg, pos)) in
  (Error error_info : 'a error_result)

let parse_error ?(suggestions = []) msg pos =
  let error_info = make_error_info ~suggestions (ParseError (msg, pos)) in
  (Error error_info : 'a error_result)

let syntax_error ?(suggestions = []) msg pos =
  let error_info = make_error_info ~suggestions (SyntaxError (msg, pos)) in
  (Error error_info : 'a error_result)

let poetry_parse_error ?(suggestions = []) msg pos_opt =
  let error_info = make_error_info ~suggestions (PoetryParseError (msg, pos_opt)) in
  (Error error_info : 'a error_result)

let type_error ?(suggestions = []) msg pos_opt =
  let error_info = make_error_info ~suggestions (TypeError (msg, pos_opt)) in
  (Error error_info : 'a error_result)

let semantic_error ?(suggestions = []) msg pos_opt =
  let error_info = make_error_info ~suggestions (SemanticError (msg, pos_opt)) in
  (Error error_info : 'a error_result)

let codegen_error ?(suggestions = []) ?(context = "unknown") msg =
  let error_info = make_error_info ~suggestions (CodegenError (msg, context)) in
  (Error error_info : 'a error_result)

let unimplemented_feature ?(suggestions = []) ?(context = "C代码生成") feature =
  let default_suggestions = [ "此功能目前尚未在C后端实现"; "您可以在Issue中请求实现此功能"; "或考虑使用解释器模式运行代码" ] in
  let all_suggestions = List.fold_right (fun x acc -> x :: acc) suggestions default_suggestions in
  let error_info =
    make_error_info ~suggestions:all_suggestions (UnimplementedFeature (feature, context))
  in
  (Error error_info : 'a error_result)

let internal_error ?(suggestions = []) msg =
  let default_suggestions = [ "这是编译器内部错误，请报告此问题"; "请在GitHub上创建Issue并包含重现步骤" ] in
  let all_suggestions = List.fold_right (fun x acc -> x :: acc) suggestions default_suggestions in
  let error_info =
    make_error_info ~severity:Fatal ~suggestions:all_suggestions (InternalError msg)
  in
  (Error error_info : 'a error_result)

let runtime_error ?(suggestions = []) msg pos_opt =
  let error_info = make_error_info ~suggestions (RuntimeError (msg, pos_opt)) in
  (Error error_info : 'a error_result)

let exception_raised ?(suggestions = []) msg pos_opt =
  let error_info = make_error_info ~suggestions (ExceptionRaised (msg, pos_opt)) in
  (Error error_info : 'a error_result)

let io_error ?(suggestions = []) msg filepath =
  let error_info = make_error_info ~suggestions (IOError (msg, filepath)) in
  (Error error_info : 'a error_result)

(** 常用错误消息的便捷函数 *)
let unsupported_keyword_error ?(suggestions = []) keyword pos =
  let msg = Printf.sprintf "不支持的关键字: %s" keyword in
  let default_suggestions = [ "请检查关键字拼写"; "查看文档了解支持的关键字" ] in
  let all_suggestions = List.fold_right (fun x acc -> x :: acc) suggestions default_suggestions in
  let error_info = make_error_info ~suggestions:all_suggestions (LexError (msg, pos)) in
  Error error_info

let unsupported_feature_error ?(suggestions = []) ?(context = "词法分析") feature _pos =
  let msg = Printf.sprintf "不支持的功能: %s" feature in
  let default_suggestions = [ "该功能可能在未来版本中实现"; "请查看项目路线图" ] in
  let all_suggestions = List.fold_right (fun x acc -> x :: acc) suggestions default_suggestions in
  let error_info =
    make_error_info ~suggestions:all_suggestions (UnimplementedFeature (msg, context))
  in
  Error error_info

let invalid_character_error ?(suggestions = []) char pos =
  let msg = Printf.sprintf "无效字符: %c" char in
  let default_suggestions = [ "请检查字符编码"; "确保使用UTF-8编码" ] in
  let all_suggestions = List.fold_right (fun x acc -> x :: acc) suggestions default_suggestions in
  let error_info = make_error_info ~suggestions:all_suggestions (LexError (msg, pos)) in
  Error error_info

let unexpected_state_error ?(suggestions = []) state context =
  let msg = Printf.sprintf "意外的状态: %s (上下文: %s)" state context in
  let default_suggestions = [ "这可能是编译器内部错误"; "请报告此问题" ] in
  let all_suggestions = List.fold_right (fun x acc -> x :: acc) suggestions default_suggestions in
  let error_info =
    make_error_info ~severity:Fatal ~suggestions:all_suggestions (InternalError msg)
  in
  Error error_info

(** 替换failwith的便捷函数 *)
let failwith_to_error ?(suggestions = []) ?(context = None) msg =
  let error_info = make_error_info ~suggestions ~context (InternalError msg) in
  Error error_info

(** 模式匹配错误处理 - 用于替换failwith的模式匹配 *)
let match_error ?(suggestions = []) ?(context = None) pattern_desc =
  let msg = Printf.sprintf "模式匹配失败: %s" pattern_desc in
  let default_suggestions = [ "请检查模式匹配的完整性"; "确保所有情况都已覆盖" ] in
  let all_suggestions = List.fold_right (fun x acc -> x :: acc) suggestions default_suggestions in
  let error_info = make_error_info ~suggestions:all_suggestions ~context (InternalError msg) in
  Error error_info