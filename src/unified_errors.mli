(** 骆言统一错误处理系统接口 - Chinese Programming Language Unified Error Handling System Interface Phase 17
    统一化扩展版本 *)

(** 第二阶段：详细错误分类 *)

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

(** 统一错误类型 *)
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

(** 向后兼容的辅助函数 *)
val result_to_value : ('a, exn) result -> 'a
(** 将Result转换为值，在出错时抛出异常 *)

val create_eval_position : int -> Compiler_errors.position
(** 创建位置信息 *)

(** Phase 17 新增：统一错误处理接口 *)

val unified_error_to_string : unified_error -> string
(** 将统一错误转换为字符串 *)

val unified_error_to_exception : unified_error -> exn
(** 将统一错误转换为传统异常（向后兼容） *)

val safe_execute : (unit -> 'a) -> 'a unified_result
(** 安全执行函数，返回Result而不是抛出异常 *)

val result_to_unified_result : ('a, exn) result -> 'a unified_result
(** 将Result转换为统一错误Result *)

val ( >>= ) : 'a unified_result -> ('a -> 'b unified_result) -> 'b unified_result
(** 链式错误处理 - monadic bind *)

val map_error : (unified_error -> unified_error) -> 'a unified_result -> 'a unified_result
(** 错误映射 *)

val with_default : 'a -> 'a unified_result -> 'a
(** 默认值处理 *)

val log_error : unified_error -> unit
(** 记录错误到日志（如果启用） *)

(** 第二阶段：便捷错误创建函数 *)

val create_lexical_error : ?pos:Compiler_errors.position -> lexical_error_type -> unified_error
(** 创建词法错误 *)

val create_parse_error : ?pos:Compiler_errors.position -> parse_error_type -> unified_error
(** 创建解析错误 *)

val create_runtime_error : ?pos:Compiler_errors.position -> runtime_error_type -> unified_error
(** 创建运行时错误 *)

val create_poetry_error : ?pos:Compiler_errors.position -> poetry_error_type -> unified_error
(** 创建诗词错误 *)

val create_system_error : ?pos:Compiler_errors.position -> system_error_type -> unified_error
(** 创建系统错误 *)

val invalid_character_error : ?pos:Compiler_errors.position -> string -> unified_error
(** 便捷函数：创建无效字符错误 *)

val unterminated_quoted_identifier_error : ?pos:Compiler_errors.position -> unit -> unified_error
(** 便捷函数：创建未闭合引用标识符错误 *)

val invalid_type_keyword_error : ?pos:Compiler_errors.position -> string -> unified_error
(** 便捷函数：创建无效类型关键字错误 *)

val arithmetic_error : ?pos:Compiler_errors.position -> string -> unified_error
(** 便捷函数：创建算术错误 *)

val rhyme_data_error : ?pos:Compiler_errors.position -> string -> unified_error
(** 便捷函数：创建韵律数据错误 *)

val json_parse_error : ?pos:Compiler_errors.position -> string -> unified_error
(** 便捷函数：创建JSON解析错误 *)

val file_load_error : ?pos:Compiler_errors.position -> string -> unified_error
(** 便捷函数：创建文件加载错误 *)

val parallelism_error : ?pos:Compiler_errors.position -> string -> unified_error
(** 便捷函数：创建对偶错误 *)

val error_to_result : unified_error -> 'a unified_result
(** 将新错误类型转换为Result.Error *)

val safe_failwith_to_error : (string -> unified_error) -> string -> 'a unified_result
(** 安全执行函数，将failwith替换为统一错误 *)
