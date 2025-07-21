(** 骆言统一错误处理系统 - Chinese Programming Language Unified Error Handling System Phase 17 统一化扩展版本 *)

open String_processing.Unified_string_formatting

(** 第二阶段：详细错误分类 - 用于替代分散的异常处理 *)

(** 词法错误子类型 *)
type lexical_error_type =
  | InvalidCharacter of string (* 无效字符 *)
  | UnterminatedString (* 未闭合字符串 *)
  | InvalidNumber of string (* 无效数字 *)
  | UnicodeError of string (* Unicode错误 *)
  | InvalidIdentifier of string (* 无效标识符 *)
  | UnterminatedQuotedIdentifier (* 未闭合的引用标识符 *)

(** 解析错误子类型 *)
type parse_error_type =
  | SyntaxError of string (* 语法错误 *)
  | UnexpectedToken of string (* 意外的标记 *)
  | MissingExpression (* 缺少表达式 *)
  | InvalidExpression of string (* 无效表达式 *)
  | InvalidTypeKeyword of string (* 无效类型关键字 *)
  | InvalidPattern of string (* 无效模式 *)

(** 运行时错误子类型 *)
type runtime_error_type =
  | ArithmeticError of string (* 算术错误 *)
  | IndexOutOfBounds of string (* 索引越界 *)
  | NullPointer of string (* 空指针 *)
  | InvalidOperation of string (* 无效操作 *)
  | ResourceError of string (* 资源错误 *)

(** 诗词分析错误子类型 *)
type poetry_error_type =
  | InvalidRhymePattern of string (* 无效韵律模式 *)
  | InvalidVerseStructure of string (* 无效诗句结构 *)
  | RhymeDataError of string (* 韵律数据错误 *)
  | ParallelismError of string (* 对偶错误 *)
  | JsonParseError of string (* JSON解析错误 *)
  | FileLoadError of string (* 文件加载错误 *)

(** 系统错误子类型 *)
type system_error_type =
  | FileSystemError of string (* 文件系统错误 *)
  | NetworkError of string (* 网络错误 *)
  | ConfigurationError of string (* 配置错误 *)
  | InternalError of string (* 内部错误 *)

(** 统一错误类型 - 用于替代分散的异常处理 *)
type unified_error =
  | ParseError of string * int * int (* 解析错误：消息，行，列 *)
  | RuntimeError of string (* 运行时错误：消息 *)
  | TypeError of string (* 类型错误：消息 *)
  | LexError of string * Compiler_errors.position (* 词法错误：消息，位置 *)
  | CompilerError of string (* 编译器错误：消息 *)
  | SystemError of string (* 系统错误：消息 *)
  (* 第二阶段：细致错误分类 *)
  | LexicalError of lexical_error_type * Compiler_errors.position option
  | ParseError2 of parse_error_type * Compiler_errors.position option
  | RuntimeError2 of runtime_error_type * Compiler_errors.position option
  | PoetryError of poetry_error_type * Compiler_errors.position option
  | SystemError2 of system_error_type * Compiler_errors.position option

type 'a unified_result = ('a, unified_error) result
(** 统一错误结果类型 *)

(** 简化错误处理辅助函数 - 保持与现有系统兼容 *)

(** 将Result转换为值，在出错时抛出异常 *)
let result_to_value = function Result.Ok value -> value | Result.Error exn -> raise exn

(** 创建位置信息 *)
let create_eval_position line_hint : Compiler_errors.position =
  { filename = "<expression_evaluator>"; line = line_hint; column = 0 }

(** Phase 17 新增：统一错误处理函数 *)

(** 将统一错误转换为字符串 *)
let unified_error_to_string = function
  | ParseError (msg, line, col) -> Error.parse_error_with_position line col msg
  | RuntimeError msg -> Error.error_template "运行时错误" msg
  | TypeError msg -> Error.error_template "类型错误" msg
  | LexError (msg, pos) -> Error.error_template (Printf.sprintf "词法错误 (%s:%d)" pos.filename pos.line) msg
  | CompilerError msg -> Error.error_template "编译器错误" msg
  | SystemError msg -> Error.error_template "系统错误" msg
  (* 第二阶段：细致错误分类 *)
  | LexicalError (error_type, pos_opt) -> (
      let error_msg =
        match error_type with
        | InvalidCharacter s -> Error.error_type_template "词法错误：无效字符" s
        | UnterminatedString -> "词法错误：未闭合的字符串"
        | InvalidNumber s -> Error.error_type_template "词法错误：无效数字" s
        | UnicodeError s -> Error.error_type_template "词法错误：Unicode错误" s
        | InvalidIdentifier s -> Error.error_type_template "词法错误：无效标识符" s
        | UnterminatedQuotedIdentifier -> "词法错误：未闭合的引用标识符"
      in
      match pos_opt with
      | Some pos -> Position.position_with_context error_msg pos.filename pos.line
      | None -> error_msg)
  | ParseError2 (error_type, pos_opt) -> (
      let error_msg =
        match error_type with
        | SyntaxError s -> Error.error_type_template "解析错误：语法错误" s
        | UnexpectedToken s -> Error.error_type_template "解析错误：意外的标记" s
        | MissingExpression -> "解析错误：缺少表达式"
        | InvalidExpression s -> Error.error_type_template "解析错误：无效表达式" s
        | InvalidTypeKeyword s -> Error.error_type_template "解析错误：无效类型关键字" s
        | InvalidPattern s -> Error.error_type_template "解析错误：无效模式" s
      in
      match pos_opt with
      | Some pos -> Position.position_with_context error_msg pos.filename pos.line
      | None -> error_msg)
  | RuntimeError2 (error_type, pos_opt) -> (
      let error_msg =
        match error_type with
        | ArithmeticError s -> Error.error_type_template "运行时错误：算术错误" s
        | IndexOutOfBounds s -> Error.error_type_template "运行时错误：索引越界" s
        | NullPointer s -> Error.error_type_template "运行时错误：空指针" s
        | InvalidOperation s -> Error.error_type_template "运行时错误：无效操作" s
        | ResourceError s -> Error.error_type_template "运行时错误：资源错误" s
      in
      match pos_opt with
      | Some pos -> Position.position_with_context error_msg pos.filename pos.line
      | None -> error_msg)
  | PoetryError (error_type, pos_opt) -> (
      let error_msg =
        match error_type with
        | InvalidRhymePattern s -> Error.error_type_template "诗词错误：无效韵律模式" s
        | InvalidVerseStructure s -> Error.error_type_template "诗词错误：无效诗句结构" s
        | RhymeDataError s -> Error.error_type_template "诗词错误：韵律数据错误" s
        | ParallelismError s -> Error.error_type_template "诗词错误：对偶错误" s
        | JsonParseError s -> Data.json_parse_error "诗词数据" s
        | FileLoadError s -> Data.loading_failure "诗词" "unknown" s
      in
      match pos_opt with
      | Some pos -> Position.position_with_context error_msg pos.filename pos.line
      | None -> error_msg)
  | SystemError2 (error_type, pos_opt) -> (
      let error_msg =
        match error_type with
        | FileSystemError s -> Error.error_type_template "系统错误：文件系统错误" s
        | NetworkError s -> Error.error_type_template "系统错误：网络错误" s
        | ConfigurationError s -> Error.error_type_template "系统错误：配置错误" s
        | InternalError s -> Error.error_type_template "系统错误：内部错误" s
      in
      match pos_opt with
      | Some pos -> Position.position_with_context error_msg pos.filename pos.line
      | None -> error_msg)

(** 将统一错误转换为传统异常（向后兼容） *)
let unified_error_to_exception = function
  | ParseError (msg, line, col) ->
      let pos = { Compiler_errors.filename = ""; line; column = col } in
      Compiler_errors.CompilerError
        {
          error = Compiler_errors.ParseError (msg, pos);
          severity = Compiler_errors.Error;
          context = None;
          suggestions = [];
        }
  | RuntimeError msg ->
      Compiler_errors.CompilerError
        {
          error = Compiler_errors.RuntimeError (msg, None);
          severity = Compiler_errors.Error;
          context = None;
          suggestions = [];
        }
  | TypeError msg ->
      Compiler_errors.CompilerError
        {
          error = Compiler_errors.TypeError (msg, None);
          severity = Compiler_errors.Error;
          context = None;
          suggestions = [];
        }
  | LexError (msg, pos) ->
      Compiler_errors.CompilerError
        {
          error = Compiler_errors.LexError (msg, pos);
          severity = Compiler_errors.Error;
          context = None;
          suggestions = [];
        }
  | CompilerError msg ->
      Compiler_errors.CompilerError
        {
          error = Compiler_errors.InternalError msg;
          severity = Compiler_errors.Error;
          context = None;
          suggestions = [];
        }
  | SystemError msg -> Failure msg
  (* 第二阶段：细致错误分类转换 *)
  | LexicalError (error_type, pos_opt) ->
      let msg =
        match error_type with
        | InvalidCharacter s -> Printf.sprintf "词法错误：无效字符 '%s'" s
        | UnterminatedString -> "词法错误：未闭合的字符串"
        | InvalidNumber s -> Printf.sprintf "词法错误：无效数字 '%s'" s
        | UnicodeError s -> Printf.sprintf "词法错误：Unicode错误 '%s'" s
        | InvalidIdentifier s -> Printf.sprintf "词法错误：无效标识符 '%s'" s
        | UnterminatedQuotedIdentifier -> "词法错误：未闭合的引用标识符"
      in
      let pos =
        match pos_opt with
        | Some p -> p
        | None -> { Compiler_errors.filename = ""; line = 0; column = 0 }
      in
      Compiler_errors.CompilerError
        {
          error = Compiler_errors.LexError (msg, pos);
          severity = Compiler_errors.Error;
          context = None;
          suggestions = [];
        }
  | ParseError2 (error_type, pos_opt) ->
      let msg =
        match error_type with
        | SyntaxError s -> Printf.sprintf "解析错误：语法错误 '%s'" s
        | UnexpectedToken s -> Printf.sprintf "解析错误：意外的标记 '%s'" s
        | MissingExpression -> "解析错误：缺少表达式"
        | InvalidExpression s -> Printf.sprintf "解析错误：无效表达式 '%s'" s
        | InvalidTypeKeyword s -> Printf.sprintf "解析错误：无效类型关键字 '%s'" s
        | InvalidPattern s -> Printf.sprintf "解析错误：无效模式 '%s'" s
      in
      let pos =
        match pos_opt with
        | Some p -> p
        | None -> { Compiler_errors.filename = ""; line = 0; column = 0 }
      in
      Compiler_errors.CompilerError
        {
          error = Compiler_errors.ParseError (msg, pos);
          severity = Compiler_errors.Error;
          context = None;
          suggestions = [];
        }
  | RuntimeError2 (error_type, pos_opt) ->
      let msg =
        match error_type with
        | ArithmeticError s -> Printf.sprintf "运行时错误：算术错误 '%s'" s
        | IndexOutOfBounds s -> Printf.sprintf "运行时错误：索引越界 '%s'" s
        | NullPointer s -> Printf.sprintf "运行时错误：空指针 '%s'" s
        | InvalidOperation s -> Printf.sprintf "运行时错误：无效操作 '%s'" s
        | ResourceError s -> Printf.sprintf "运行时错误：资源错误 '%s'" s
      in
      Compiler_errors.CompilerError
        {
          error = Compiler_errors.RuntimeError (msg, pos_opt);
          severity = Compiler_errors.Error;
          context = None;
          suggestions = [];
        }
  | PoetryError (error_type, _pos_opt) ->
      let msg =
        match error_type with
        | InvalidRhymePattern s -> Printf.sprintf "诗词错误：无效韵律模式 '%s'" s
        | InvalidVerseStructure s -> Printf.sprintf "诗词错误：无效诗句结构 '%s'" s
        | RhymeDataError s -> Printf.sprintf "诗词错误：韵律数据错误 '%s'" s
        | ParallelismError s -> Printf.sprintf "诗词错误：对偶错误 '%s'" s
        | JsonParseError s -> Printf.sprintf "诗词错误：JSON解析错误 '%s'" s
        | FileLoadError s -> Printf.sprintf "诗词错误：文件加载错误 '%s'" s
      in
      Failure msg
  | SystemError2 (error_type, _pos_opt) ->
      let msg =
        match error_type with
        | FileSystemError s -> Printf.sprintf "系统错误：文件系统错误 '%s'" s
        | NetworkError s -> Printf.sprintf "系统错误：网络错误 '%s'" s
        | ConfigurationError s -> Printf.sprintf "系统错误：配置错误 '%s'" s
        | InternalError s -> Printf.sprintf "系统错误：内部错误 '%s'" s
      in
      Failure msg

(** 安全执行函数，返回Result而不是抛出异常 *)
let safe_execute f =
  try Ok (f ()) with
  | Compiler_errors.CompilerError err -> (
      match err.error with
      | Compiler_errors.ParseError (msg, pos) -> Error (ParseError (msg, pos.line, pos.column))
      | Compiler_errors.RuntimeError (msg, _) -> Error (RuntimeError msg)
      | Compiler_errors.TypeError (msg, _) -> Error (TypeError msg)
      | Compiler_errors.LexError (msg, pos) -> Error (LexError (msg, pos))
      | Compiler_errors.InternalError msg -> Error (CompilerError msg)
      | _ -> Error (SystemError ("编译器错误: " ^ Compiler_errors.format_error_message err.error)))
  | Failure msg -> Error (SystemError msg)
  | e -> Error (SystemError (Printexc.to_string e))

(** 将Result转换为统一错误Result *)
let result_to_unified_result = function
  | Ok value -> Ok value
  | Error exn -> Error (SystemError (Printexc.to_string exn))

(** 链式错误处理 - monadic bind *)
let ( >>= ) result f = match result with Ok value -> f value | Error err -> Error err

(** 错误映射 *)
let map_error f = function Ok value -> Ok value | Error err -> Error (f err)

(** 默认值处理 *)
let with_default default = function Ok value -> value | Error _ -> default

(** 记录错误到日志（如果启用） *)
let log_error error =
  let current_level = Logger.get_level () in
  if current_level = Logger.DEBUG then
    Logger.debug "unified_errors" ("统一错误处理: " ^ unified_error_to_string error)

(** 第二阶段：便捷错误创建函数 *)

(** 创建词法错误 *)
let create_lexical_error ?pos error_type = LexicalError (error_type, pos)

(** 创建解析错误 *)
let create_parse_error ?pos error_type = ParseError2 (error_type, pos)

(** 创建运行时错误 *)
let create_runtime_error ?pos error_type = RuntimeError2 (error_type, pos)

(** 创建诗词错误 *)
let create_poetry_error ?pos error_type = PoetryError (error_type, pos)

(** 创建系统错误 *)
let create_system_error ?pos error_type = SystemError2 (error_type, pos)

(** 便捷函数：创建无效字符错误 *)
let invalid_character_error ?pos char = create_lexical_error ?pos (InvalidCharacter char)

(** 便捷函数：创建未闭合引用标识符错误 *)
let unterminated_quoted_identifier_error ?pos () =
  create_lexical_error ?pos UnterminatedQuotedIdentifier

(** 便捷函数：创建无效类型关键字错误 *)
let invalid_type_keyword_error ?pos keyword = create_parse_error ?pos (InvalidTypeKeyword keyword)

(** 便捷函数：创建算术错误 *)
let arithmetic_error ?pos msg = create_runtime_error ?pos (ArithmeticError msg)

(** 便捷函数：创建韵律数据错误 *)
let rhyme_data_error ?pos msg = create_poetry_error ?pos (RhymeDataError msg)

(** 便捷函数：创建JSON解析错误 *)
let json_parse_error ?pos msg = create_poetry_error ?pos (JsonParseError msg)

(** 便捷函数：创建文件加载错误 *)
let file_load_error ?pos msg = create_poetry_error ?pos (FileLoadError msg)

(** 便捷函数：创建对偶错误 *)
let parallelism_error ?pos msg = create_poetry_error ?pos (ParallelismError msg)

(** 将新错误类型转换为Result.Error *)
let error_to_result error = Error error

(** 安全执行函数，将failwith替换为统一错误 *)
let safe_failwith_to_error error_creator msg = error_to_result (error_creator msg)
