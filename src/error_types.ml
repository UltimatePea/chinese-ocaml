(** 骆言统一错误处理系统 - 错误类型定义模块 *)

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

(** 统一错误结果类型 *)
type 'a unified_result = ('a, unified_error) result