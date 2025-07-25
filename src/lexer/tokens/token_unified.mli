(** 骆言词法分析器 - 统一Token类型定义 *)

open Basic_tokens
(** 引入所有专门模块 *)

open Identifier_tokens
open Core_keywords
open Wenyan_keywords
open Ancient_keywords
open Poetry_keywords
open Operator_tokens
open Delimiter_tokens
open Chinese_delimiters

type position = { line : int; column : int; filename : string } [@@deriving show, eq]
(** 位置信息类型 *)

(** 统一的token类型，将所有专门模块的token类型组合 *)
type token =
  | Basic of basic_token  (** 基础数据类型token *)
  | Identifier of identifier_token  (** 标识符token *)
  | CoreKeyword of core_keyword  (** 核心语言关键字 *)
  | WenyanKeyword of wenyan_keyword  (** 文言风格关键字 *)
  | AncientKeyword of ancient_keyword  (** 古雅体关键字 *)
  | PoetryKeyword of poetry_keyword  (** 诗词音韵关键字 *)
  | Operator of operator_token  (** 运算符token *)
  | Delimiter of delimiter_token  (** 分隔符token *)
  | ChineseDelimiter of chinese_delimiter  (** 中文标点符号token *)
[@@deriving show, eq]

type positioned_token = token * position [@@deriving show, eq]
(** 带位置信息的token *)

exception LexError of string * position
(** 词法错误异常 *)

val to_string : token -> string
(** 将统一token转换为字符串表示 *)

val from_string : string -> token option
(** 尝试将字符串转换为统一token *)

val is_literal : token -> bool
(** 检查token是否为字面量类型 *)

val is_keyword : token -> bool
(** 检查token是否为关键字类型 *)

val is_operator : token -> bool
(** 检查token是否为运算符类型 *)

val is_delimiter : token -> bool
(** 检查token是否为分隔符类型 *)

val is_chinese_related : token -> bool
(** 检查token是否为中文相关的token *)

val get_category : token -> string
(** 获取token的分类字符串 *)

val compare_precedence : token -> token -> int
(** 比较两个token的优先级（用于运算符） *)
