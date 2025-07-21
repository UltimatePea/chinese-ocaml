(** 骆言统一错误处理系统 - 错误转换模块 *)

open Error_types

(** 将统一错误转换为字符串 *)
let unified_error_to_string = function
  | ParseError (msg, line, col) -> Printf.sprintf "解析错误 (%d:%d): %s" line col msg
  | RuntimeError msg -> Printf.sprintf "运行时错误: %s" msg
  | TypeError msg -> Printf.sprintf "类型错误: %s" msg
  | LexError (msg, pos) -> Printf.sprintf "词法错误 (%s:%d): %s" pos.filename pos.line msg
  | CompilerError msg -> Printf.sprintf "编译器错误: %s" msg
  | SystemError msg -> Printf.sprintf "系统错误: %s" msg
  (* 第二阶段：细致错误分类 *)
  | LexicalError (error_type, pos_opt) -> (
      let error_msg =
        match error_type with
        | InvalidCharacter s -> Printf.sprintf "词法错误：无效字符 '%s'" s
        | UnterminatedString -> "词法错误：未闭合的字符串"
        | InvalidNumber s -> Printf.sprintf "词法错误：无效数字 '%s'" s
        | UnicodeError s -> Printf.sprintf "词法错误：Unicode错误 '%s'" s
        | InvalidIdentifier s -> Printf.sprintf "词法错误：无效标识符 '%s'" s
        | UnterminatedQuotedIdentifier -> "词法错误：未闭合的引用标识符"
      in
      match pos_opt with
      | Some pos -> Printf.sprintf "%s (%s:%d)" error_msg pos.filename pos.line
      | None -> error_msg)
  | ParseError2 (error_type, pos_opt) -> (
      let error_msg =
        match error_type with
        | SyntaxError s -> Printf.sprintf "解析错误：语法错误 '%s'" s
        | UnexpectedToken s -> Printf.sprintf "解析错误：意外的标记 '%s'" s
        | MissingExpression -> "解析错误：缺少表达式"
        | InvalidExpression s -> Printf.sprintf "解析错误：无效表达式 '%s'" s
        | InvalidTypeKeyword s -> Printf.sprintf "解析错误：无效类型关键字 '%s'" s
        | InvalidPattern s -> Printf.sprintf "解析错误：无效模式 '%s'" s
      in
      match pos_opt with
      | Some pos -> Printf.sprintf "%s (%s:%d)" error_msg pos.filename pos.line
      | None -> error_msg)
  | RuntimeError2 (error_type, pos_opt) -> (
      let error_msg =
        match error_type with
        | ArithmeticError s -> Printf.sprintf "运行时错误：算术错误 '%s'" s
        | IndexOutOfBounds s -> Printf.sprintf "运行时错误：索引越界 '%s'" s
        | NullPointer s -> Printf.sprintf "运行时错误：空指针 '%s'" s
        | InvalidOperation s -> Printf.sprintf "运行时错误：无效操作 '%s'" s
        | ResourceError s -> Printf.sprintf "运行时错误：资源错误 '%s'" s
      in
      match pos_opt with
      | Some pos -> Printf.sprintf "%s (%s:%d)" error_msg pos.filename pos.line
      | None -> error_msg)
  | PoetryError (error_type, pos_opt) -> (
      let error_msg =
        match error_type with
        | InvalidRhymePattern s -> Printf.sprintf "诗词错误：无效韵律模式 '%s'" s
        | InvalidVerseStructure s -> Printf.sprintf "诗词错误：无效诗句结构 '%s'" s
        | RhymeDataError s -> Printf.sprintf "诗词错误：韵律数据错误 '%s'" s
        | ParallelismError s -> Printf.sprintf "诗词错误：对偶错误 '%s'" s
        | JsonParseError s -> Printf.sprintf "诗词错误：JSON解析错误 '%s'" s
        | FileLoadError s -> Printf.sprintf "诗词错误：文件加载错误 '%s'" s
      in
      match pos_opt with
      | Some pos -> Printf.sprintf "%s (%s:%d)" error_msg pos.filename pos.line
      | None -> error_msg)
  | SystemError2 (error_type, pos_opt) -> (
      let error_msg =
        match error_type with
        | FileSystemError s -> Printf.sprintf "系统错误：文件系统错误 '%s'" s
        | NetworkError s -> Printf.sprintf "系统错误：网络错误 '%s'" s
        | ConfigurationError s -> Printf.sprintf "系统错误：配置错误 '%s'" s
        | InternalError s -> Printf.sprintf "系统错误：内部错误 '%s'" s
      in
      match pos_opt with
      | Some pos -> Printf.sprintf "%s (%s:%d)" error_msg pos.filename pos.line
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