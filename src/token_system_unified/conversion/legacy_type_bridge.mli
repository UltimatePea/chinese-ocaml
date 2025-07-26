(** 骆言编译器 - Legacy Token类型兼容性桥接层接口
    
    为遗留Token系统提供向新统一Token系统的无缝迁移桥接。
    此模块确保现有代码可以继续使用旧的Token类型接口，
    同时在后台自动映射到新的统一Token系统。
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-26
    @issue #1355 Phase 2 Token系统整合 *)

open Yyocamlc_lib.Token_types
(* open Yyocamlc_lib.Error_types (* Currently unused *) *)
open Yyocamlc_lib.Token_types_core

(** {1 基础类型转换函数} *)

(** 基础字面量转换 *)
val convert_int_token : int -> Literals.literal_token
(** 创建整数字面量Token
    @param i 整数值
    @return 整数字面量Token *)

val convert_float_token : float -> Literals.literal_token
(** 创建浮点数字面量Token
    @param f 浮点数值
    @return 浮点数字面量Token *)

val convert_string_token : string -> Literals.literal_token
(** 创建字符串字面量Token
    @param s 字符串值
    @return 字符串字面量Token *)

val convert_bool_token : bool -> Literals.literal_token
(** 创建布尔字面量Token
    @param b 布尔值
    @return 布尔字面量Token *)

val convert_chinese_number_token : string -> Literals.literal_token
(** 创建中文数字字面量Token
    @param s 中文数字字符串
    @return 中文数字字面量Token *)

(** 标识符转换 *)
val convert_simple_identifier : string -> Identifiers.identifier_token
(** 创建简单标识符Token
    @param s 标识符名称
    @return 简单标识符Token *)

val convert_quoted_identifier : string -> Identifiers.identifier_token
(** 创建引用标识符Token
    @param s 标识符名称
    @return 引用标识符Token *)

val convert_special_identifier : string -> Identifiers.identifier_token
(** 创建特殊标识符Token
    @param s 标识符名称
    @return 特殊标识符Token *)

(** 核心关键字转换 *)
val convert_let_keyword : unit -> Keywords.keyword_token
(** 创建let关键字Token *)

val convert_fun_keyword : unit -> Keywords.keyword_token
(** 创建fun关键字Token *)

val convert_if_keyword : unit -> Keywords.keyword_token
(** 创建if关键字Token *)

val convert_then_keyword : unit -> Keywords.keyword_token
(** 创建then关键字Token *)

val convert_else_keyword : unit -> Keywords.keyword_token
(** 创建else关键字Token *)

(** 操作符转换 *)
val convert_plus_op : unit -> Operators.operator_token
(** 创建加法操作符Token *)

val convert_minus_op : unit -> Operators.operator_token
(** 创建减法操作符Token *)

val convert_multiply_op : unit -> Operators.operator_token
(** 创建乘法操作符Token *)

val convert_divide_op : unit -> Operators.operator_token
(** 创建除法操作符Token *)

val convert_equal_op : unit -> Operators.operator_token
(** 创建等于操作符Token *)

(** 分隔符转换 *)
val convert_left_paren : unit -> Delimiters.delimiter_token
(** 创建左括号分隔符Token *)

val convert_right_paren : unit -> Delimiters.delimiter_token
(** 创建右括号分隔符Token *)

val convert_comma : unit -> Delimiters.delimiter_token
(** 创建逗号分隔符Token *)

val convert_semicolon : unit -> Delimiters.delimiter_token
(** 创建分号分隔符Token *)

(** 特殊Token转换 *)
val convert_eof : unit -> Special.special_token
(** 创建EOF特殊Token *)

val convert_newline : unit -> Special.special_token
(** 创建换行特殊Token *)

val convert_comment : string -> Special.special_token
(** 创建注释特殊Token
    @param s 注释内容
    @return 注释特殊Token *)

val convert_whitespace : string -> Special.special_token
(** 创建空白字符特殊Token
    @param s 空白字符内容
    @return 空白字符特殊Token *)

(** {1 统一Token构造函数} *)

val make_literal_token : Literals.literal_token -> token
(** 创建字面量Token
    @param lit 字面量Token数据
    @return 统一Token *)

val make_identifier_token : Identifiers.identifier_token -> token
(** 创建标识符Token
    @param id 标识符Token数据
    @return 统一Token *)

val make_core_language_token : Keywords.keyword_token -> token
(** 创建核心语言关键字Token
    @param kw 关键字Token数据
    @return 统一Token *)

val make_operator_token : Operators.operator_token -> token
(** 创建操作符Token
    @param op 操作符Token数据
    @return 统一Token *)

val make_delimiter_token : Delimiters.delimiter_token -> token
(** 创建分隔符Token
    @param del 分隔符Token数据
    @return 统一Token *)

val make_special_token : Special.special_token -> token
(** 创建特殊Token
    @param sp 特殊Token数据
    @return 统一Token *)

(** {1 位置信息处理} *)

val make_position : line:int -> column:int -> offset:int -> position
(** 创建位置信息
    @param line 行号
    @param column 列号  
    @param offset 偏移量
    @return 位置信息 *)

val make_positioned_token : token:token -> position:position -> text:string -> positioned_token
(** 创建带位置的Token
    @param token Token数据
    @param position 位置信息
    @param text 原始文本
    @return 带位置的Token *)

(** {1 Token类别检查工具} *)

val get_token_category : token -> token_category
(** 检查Token类别
    @param token 要检查的Token
    @return Token类别 *)

val is_literal_token : token -> bool
(** 检查是否为字面量Token
    @param token 要检查的Token
    @return 如果是字面量返回true *)

val is_identifier_token : token -> bool
(** 检查是否为标识符Token
    @param token 要检查的Token
    @return 如果是标识符返回true *)

val is_keyword_token : token -> bool
(** 检查是否为关键字Token
    @param token 要检查的Token
    @return 如果是关键字返回true *)

val is_operator_token : token -> bool
(** 检查是否为操作符Token
    @param token 要检查的Token
    @return 如果是操作符返回true *)

val is_delimiter_token : token -> bool
(** 检查是否为分隔符Token
    @param token 要检查的Token
    @return 如果是分隔符返回true *)

val is_special_token : token -> bool
(** 检查是否为特殊Token
    @param token 要检查的Token
    @return 如果是特殊Token返回true *)

(** {1 调试和诊断工具} *)

val token_type_name : token -> string
(** 获取Token类型名称
    @param token 要检查的Token
    @return Token类型名称字符串 *)

val count_token_types : token list -> (string * int) list
(** 统计Token流中各类型Token的数量
    @param tokens Token列表
    @return (类型名称, 数量)的关联列表 *)

(** {1 批量处理工具} *)

val make_literal_tokens : (string * [`Int of int | `Float of float | `String of string | `Bool of bool]) list -> token list
(** 批量创建字面量Token
    @param values (名称, 值)对的列表
    @return Token列表 *)

val make_identifier_tokens : string list -> token list
(** 批量创建标识符Token
    @param names 标识符名称列表
    @return Token列表 *)

(** {1 实验性转换功能} *)

val infer_token_from_string : string -> token option
(** 尝试从字符串推断Token类型
    @param s 输入字符串
    @return 推断的Token，如果无法推断则返回None *)

val validate_token_stream : token list -> bool
(** 简单的Token流验证
    @param tokens Token列表
    @return 如果Token流有效返回true *)