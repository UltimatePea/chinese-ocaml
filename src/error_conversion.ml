(** 骆言统一错误处理系统 - 错误转换模块 *)

open Error_types
open Unified_formatter

(** 辅助函数：为错误消息添加位置信息 *)
let add_position_to_error_msg error_msg pos_opt =
  match pos_opt with
  | Some (pos : Compiler_errors.position) ->
      ErrorHandling.error_with_position error_msg pos.filename pos.line
  | None -> error_msg

(** 错误格式化工具模块 *)
module ErrorFormatter = struct
  (** 词法错误转换为字符串 *)
  let lexical_error_to_string = function
    | InvalidCharacter s -> ErrorHandling.lexical_error_with_char s
    | UnterminatedString -> "词法错误：未闭合的字符串"
    | InvalidNumber s -> ErrorHandling.error_with_detail "词法错误" ("无效数字 " ^ s)
    | UnicodeError s -> ErrorHandling.error_with_detail "词法错误" ("Unicode错误 " ^ s)
    | InvalidIdentifier s -> ErrorHandling.error_with_detail "词法错误" ("无效标识符 " ^ s)
    | UnterminatedQuotedIdentifier -> "词法错误：未闭合的引用标识符"

  (** 语法错误转换为字符串 *)
  let parse_error_to_string = function
    | SyntaxError s -> ErrorHandling.parse_error_syntax s
    | UnexpectedToken s -> ErrorHandling.error_with_detail "解析错误" ("意外的标记 " ^ s)
    | MissingExpression -> "解析错误：缺少表达式"
    | InvalidExpression s -> ErrorHandling.error_with_detail "解析错误" ("无效表达式 " ^ s)
    | InvalidTypeKeyword s -> ErrorHandling.error_with_detail "解析错误" ("无效类型关键字 " ^ s)
    | InvalidPattern s -> ErrorHandling.error_with_detail "解析错误" ("无效模式 " ^ s)

  (** 运行时错误转换为字符串 *)
  let runtime_error_to_string = function
    | ArithmeticError s -> ErrorHandling.runtime_arithmetic_error s
    | IndexOutOfBounds s -> ErrorHandling.error_with_detail "运行时错误" ("索引越界 " ^ s)
    | NullPointer s -> ErrorHandling.error_with_detail "运行时错误" ("空指针 " ^ s)
    | InvalidOperation s -> ErrorHandling.error_with_detail "运行时错误" ("无效操作 " ^ s)
    | ResourceError s -> ErrorHandling.error_with_detail "运行时错误" ("资源错误 " ^ s)

  (** 诗词错误转换为字符串 *)
  let poetry_error_to_string = function
    | InvalidRhymePattern s -> ErrorHandling.error_with_detail "诗词错误" ("无效韵律模式 " ^ s)
    | InvalidVerseStructure s -> ErrorHandling.error_with_detail "诗词错误" ("无效诗句结构 " ^ s)
    | RhymeDataError s -> ErrorHandling.error_with_detail "诗词错误" ("韵律数据错误 " ^ s)
    | ParallelismError s -> ErrorHandling.error_with_detail "诗词错误" ("对偶错误 " ^ s)
    | JsonParseError s -> ErrorHandling.error_with_detail "诗词错误" ("JSON解析错误 " ^ s)
    | FileLoadError s -> ErrorHandling.error_with_detail "诗词错误" ("文件加载错误 " ^ s)

  (** 系统错误转换为字符串 *)
  let system_error_to_string = function
    | FileSystemError s -> ErrorHandling.error_with_detail "系统错误" ("文件系统错误 " ^ s)
    | NetworkError s -> ErrorHandling.error_with_detail "系统错误" ("网络错误 " ^ s)
    | ConfigurationError s -> ErrorHandling.error_with_detail "系统错误" ("配置错误 " ^ s)
    | InternalError s -> ErrorHandling.error_with_detail "系统错误" ("内部错误 " ^ s)
end

(** 将统一错误转换为字符串 *)
let unified_error_to_string = function
  | ParseError (msg, line, col) ->
      ErrorHandling.error_with_detail "解析错误" (Printf.sprintf "(%d:%d): %s" line col msg)
  | RuntimeError msg -> ErrorHandling.simple_category_error ("运行时错误: " ^ msg)
  | TypeError msg -> ErrorHandling.simple_category_error ("类型错误: " ^ msg)
  | LexError (msg, pos) -> ErrorHandling.lexical_error_with_position pos.filename pos.line msg
  | CompilerError msg -> ErrorHandling.simple_category_error ("编译器错误: " ^ msg)
  | SystemError msg -> ErrorHandling.simple_category_error ("系统错误: " ^ msg)
  (* 第二阶段：细致错误分类 *)
  | LexicalError (error_type, pos_opt) ->
      let error_msg = ErrorFormatter.lexical_error_to_string error_type in
      add_position_to_error_msg error_msg pos_opt
  | ParseError2 (error_type, pos_opt) ->
      let error_msg = ErrorFormatter.parse_error_to_string error_type in
      add_position_to_error_msg error_msg pos_opt
  | RuntimeError2 (error_type, pos_opt) ->
      let error_msg = ErrorFormatter.runtime_error_to_string error_type in
      add_position_to_error_msg error_msg pos_opt
  | PoetryError (error_type, pos_opt) ->
      let error_msg = ErrorFormatter.poetry_error_to_string error_type in
      add_position_to_error_msg error_msg pos_opt
  | SystemError2 (error_type, pos_opt) ->
      let error_msg = ErrorFormatter.system_error_to_string error_type in
      add_position_to_error_msg error_msg pos_opt

(** 异常转换工具模块 *)
module ExceptionConverter = struct
  (** 创建编译器错误的通用函数 *)
  let create_compiler_error error severity =
    Compiler_errors.CompilerError { error; severity; context = None; suggestions = [] }

  (** 获取默认位置信息 *)
  let default_position () = { Compiler_errors.filename = ""; line = 0; column = 0 }

  (** 转换位置信息 *)
  let convert_position pos_opt = match pos_opt with Some p -> p | None -> default_position ()

  (** 转换词法错误到异常 *)
  let convert_lexical_error error_type pos_opt =
    let msg = ErrorFormatter.lexical_error_to_string error_type in
    let pos = convert_position pos_opt in
    create_compiler_error (Compiler_errors.LexError (msg, pos)) Compiler_errors.Error

  (** 转换语法错误到异常 *)
  let convert_parse_error error_type pos_opt =
    let msg = ErrorFormatter.parse_error_to_string error_type in
    let pos = convert_position pos_opt in
    create_compiler_error (Compiler_errors.ParseError (msg, pos)) Compiler_errors.Error

  (** 转换运行时错误到异常 *)
  let convert_runtime_error error_type pos_opt =
    let msg = ErrorFormatter.runtime_error_to_string error_type in
    create_compiler_error (Compiler_errors.RuntimeError (msg, pos_opt)) Compiler_errors.Error

  (** 转换诗词错误到异常 *)
  let convert_poetry_error error_type _pos_opt =
    let msg = ErrorFormatter.poetry_error_to_string error_type in
    Failure msg

  (** 转换系统错误到异常 *)
  let convert_system_error error_type _pos_opt =
    let msg = ErrorFormatter.system_error_to_string error_type in
    Failure msg
end

(** 将统一错误转换为传统异常（向后兼容） *)
let unified_error_to_exception = function
  | ParseError (msg, line, col) ->
      let pos = { Compiler_errors.filename = ""; line; column = col } in
      ExceptionConverter.create_compiler_error
        (Compiler_errors.ParseError (msg, pos))
        Compiler_errors.Error
  | RuntimeError msg ->
      ExceptionConverter.create_compiler_error
        (Compiler_errors.RuntimeError (msg, None))
        Compiler_errors.Error
  | TypeError msg ->
      ExceptionConverter.create_compiler_error
        (Compiler_errors.TypeError (msg, None))
        Compiler_errors.Error
  | LexError (msg, pos) ->
      ExceptionConverter.create_compiler_error
        (Compiler_errors.LexError (msg, pos))
        Compiler_errors.Error
  | CompilerError msg ->
      ExceptionConverter.create_compiler_error (Compiler_errors.InternalError msg)
        Compiler_errors.Error
  | SystemError msg -> Failure msg
  | LexicalError (error_type, pos_opt) ->
      ExceptionConverter.convert_lexical_error error_type pos_opt
  | ParseError2 (error_type, pos_opt) -> ExceptionConverter.convert_parse_error error_type pos_opt
  | RuntimeError2 (error_type, pos_opt) ->
      ExceptionConverter.convert_runtime_error error_type pos_opt
  | PoetryError (error_type, pos_opt) -> ExceptionConverter.convert_poetry_error error_type pos_opt
  | SystemError2 (error_type, pos_opt) -> ExceptionConverter.convert_system_error error_type pos_opt
