(** 骆言词法分析器 - 标识符令牌类型定义接口 *)

(** 标识符类型 *)
type identifier_token =
  | QuotedIdentifierToken of string (* 「标识符」 - 所有标识符必须引用 *)
  | IdentifierTokenSpecial of string (* 特殊保护的标识符，如"数值" *)
[@@deriving show, eq]

val identifier_token_to_string : identifier_token -> string
(** 标识符转换为字符串 *)

val is_quoted_identifier : identifier_token -> bool
(** 判断是否为引用标识符 *)

val is_special_identifier : identifier_token -> bool
(** 判断是否为特殊标识符 *)

val extract_identifier_content : identifier_token -> string
(** 提取标识符内容 *)

val create_quoted_identifier : string -> identifier_token
(** 创建引用标识符 *)

val create_special_identifier : string -> identifier_token
(** 创建特殊标识符 *)
