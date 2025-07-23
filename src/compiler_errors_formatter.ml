(** 错误信息格式化 - 骆言编译器 *)

open Compiler_errors_types
open Utils.Base_formatter
module PF = String_processing_utils.PositionFormatting

(** 错误消息格式化 *)
let format_position (pos : position) =
  PF.format_position_with_fields ~filename:pos.filename ~line:pos.line ~column:pos.column

let format_error_message error =
  match error with
  | LexError (msg, pos) ->
      Unified_formatter.Position.format_error_with_position (format_position pos) "词法错误" msg
  | ParseError (msg, pos) ->
      Unified_formatter.Position.format_error_with_position (format_position pos) "语法错误" msg
  | SyntaxError (msg, pos) ->
      Unified_formatter.Position.format_error_with_position (format_position pos) "语法错误" msg
  | PoetryParseError (msg, pos_opt) ->
      let pos_str =
        PF.format_optional_position_with_extractor pos_opt
          ~get_filename:(fun p -> p.filename)
          ~get_line:(fun p -> p.line)
          ~get_column:(fun p -> p.column)
      in
      Unified_formatter.ErrorMessages.generic_error ("诗词解析错误" ^ pos_str) msg
  | TypeError (msg, pos_opt) ->
      let pos_str =
        PF.format_optional_position_with_extractor pos_opt
          ~get_filename:(fun p -> p.filename)
          ~get_line:(fun p -> p.line)
          ~get_column:(fun p -> p.column)
      in
      Unified_formatter.ErrorMessages.generic_error ("类型错误" ^ pos_str) msg
  | SemanticError (msg, pos_opt) ->
      let pos_str =
        PF.format_optional_position_with_extractor pos_opt
          ~get_filename:(fun p -> p.filename)
          ~get_line:(fun p -> p.line)
          ~get_column:(fun p -> p.column)
      in
      Unified_formatter.ErrorMessages.generic_error ("语义错误" ^ pos_str) msg
  | CodegenError (msg, context) ->
      Unified_formatter.ErrorMessages.generic_error ("代码生成错误 [" ^ context ^ "]") msg
  | RuntimeError (msg, pos_opt) ->
      let pos_str =
        PF.format_optional_position_with_extractor pos_opt
          ~get_filename:(fun p -> p.filename)
          ~get_line:(fun p -> p.line)
          ~get_column:(fun p -> p.column)
      in
      Unified_formatter.ErrorMessages.generic_error ("运行时错误" ^ pos_str) msg
  | ExceptionRaised (msg, pos_opt) ->
      let pos_str =
        PF.format_optional_position_with_extractor pos_opt
          ~get_filename:(fun p -> p.filename)
          ~get_line:(fun p -> p.line)
          ~get_column:(fun p -> p.column)
      in
      Unified_formatter.ErrorMessages.generic_error ("异常" ^ pos_str) msg
  | UnimplementedFeature (feature, context) ->
      Unified_formatter.ErrorMessages.generic_error ("未实现功能 [" ^ context ^ "]") feature
  | InternalError msg -> Unified_formatter.ErrorMessages.generic_error "内部错误" msg
  | IOError (msg, filepath) ->
      Unified_formatter.ErrorMessages.generic_error ("IO错误 [" ^ filepath ^ "]") msg

(** 格式化完整错误信息 *)
let format_error_info info =
  let severity_str = match info.severity with Warning -> "警告" | Error -> "错误" | Fatal -> "严重错误" in
  let main_msg = concat_strings [ "["; severity_str; "] "; format_error_message info.error ] in
  let context_msg = match info.context with Some ctx -> "\n上下文: " ^ ctx | None -> "" in
  let suggestions_msg =
    if List.length info.suggestions > 0 then
      let buffer = Buffer.create 64 in
      Buffer.add_string buffer "\n建议:\n";
      List.iter (fun s ->
        Buffer.add_string buffer "  - ";
        Buffer.add_string buffer s;
        Buffer.add_char buffer '\n'
      ) info.suggestions;
      (* Remove the trailing newline *)
      let content = Buffer.contents buffer in
      String.sub content 0 (String.length content - 1)
    else ""
  in
  main_msg ^ context_msg ^ suggestions_msg

(** 输出错误信息 - 使用统一错误处理系统 *)
let print_error_info info =
  (* 使用配置系统决定输出方式 *)
  let runtime_cfg = Config.get_runtime_config () in
  if runtime_cfg.colored_output then
    let color_code =
      match info.severity with
      | Warning -> Constants.Colors.warn_color
      | Error -> Constants.Colors.error_color
      | Fatal -> Constants.Colors.fatal_color
    in
    Unified_logging.Legacy.eprintf "%s%s%s\n" color_code (format_error_info info)
      Constants.Colors.reset
  else Unified_logging.Legacy.eprintf "%s\n" (format_error_info info);
  flush stderr
