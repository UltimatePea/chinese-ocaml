(** 词法分析器错误处理适配器 - 统一错误处理系统迁移 *)

open Token_types
open Compiler_errors

(** 将Token_types.position转换为Lexer.position *)
let convert_position (pos : Token_types.position) : Lexer.position =
  { Lexer.filename = pos.filename; line = pos.line; column = pos.column }

(** 创建词法错误的统一处理函数 *)
let create_lex_error ?(suggestions = []) msg pos =
  let lexer_pos = convert_position pos in
  lex_error ~suggestions msg lexer_pos

(** 词法分析器错误处理结果类型 *)
type 'a lex_result = LexOk of 'a | LexError of error_info

(** 安全的词法分析函数包装器 *)
let safe_lex_operation f =
  try
    let result = f () in
    LexOk result
  with
  | Lexer_core.LexError (msg, pos) ->
      let error_info = extract_error_info (create_lex_error msg pos) in
      LexError error_info
  | exn ->
      let error_info =
        extract_error_info (internal_error ("词法分析内部错误: " ^ Printexc.to_string exn))
      in
      LexError error_info

(** 词法分析器错误处理的便捷函数 *)
module LexErrorHandler = struct
  let unterminated_comment pos =
    create_lex_error
      ~suggestions:[ "检查注释是否正确关闭"; "确保 (* 和 *) 配对"; "检查是否有嵌套注释" ]
      Constants.ErrorMessages.unterminated_comment pos

  let unterminated_chinese_comment pos =
    create_lex_error
      ~suggestions:[ "检查中文注释是否正确关闭"; "确保 （ 和 ） 配对" ]
      Constants.ErrorMessages.unterminated_chinese_comment pos

  let unterminated_string pos =
    create_lex_error
      ~suggestions:[ "检查字符串是否正确关闭"; "确保引号配对"; "检查是否有转义字符问题" ]
      Constants.ErrorMessages.unterminated_string pos

  let unterminated_quoted_identifier pos =
    create_lex_error
      ~suggestions:[ "检查引用标识符是否正确关闭"; "确保「」配对"; "检查标识符语法" ]
      Constants.ErrorMessages.unterminated_quoted_identifier pos

  let identifiers_must_be_quoted pos =
    create_lex_error
      ~suggestions:[ "使用引用语法包围标识符"; "例如：「标识符」"; "检查标识符命名规则" ]
      Constants.ErrorMessages.identifiers_must_be_quoted pos

  let ascii_letters_as_keywords_only pos =
    create_lex_error
      ~suggestions:[ "ASCII字符仅可用作关键字"; "使用中文字符作为标识符"; "检查关键字拼写" ]
      Constants.ErrorMessages.ascii_letters_as_keywords_only pos
end

(** 兼容性函数：将错误结果转换为异常 *)
let raise_from_error_result = function
  | LexOk value -> value
  | LexError error_info -> raise (CompilerError error_info)

(** 批量处理词法分析结果 *)
let process_lex_results results =
  let rec process acc errors = function
    | [] -> (List.rev acc, errors)
    | LexOk value :: rest -> process (value :: acc) errors rest
    | LexError error :: rest -> process acc (error :: errors) rest
  in
  process [] [] results

(** 错误恢复策略 *)
let attempt_error_recovery error_info input_state =
  match error_info.error with
  | LexError (msg, pos) ->
      (* 尝试跳过当前字符继续分析 *)
      if String.contains msg "未终止" then Some "尝试跳过到下一个可能的终止符" else Some "跳过当前字符继续分析"
  | _ -> None

(** 词法分析器状态与统一错误处理系统的集成 *)
let integrate_with_error_handler state error_info =
  let context =
    Error_handler.create_context ~source_file:state.Lexer_core.filename ~function_name:"lexer_core"
      ~module_name:"Lexer_core" ()
  in
  Error_handler.handle_error ~context error_info
