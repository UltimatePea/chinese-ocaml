(** 骆言词法分析器 - 标识符Token *)

(** 标识符类型token，包括引用标识符和特殊标识符 *)
type identifier_token =
  | QuotedIdentifierToken of string    (** 「标识符」- 所有标识符必须引用 *)
  | IdentifierTokenSpecial of string   (** 特殊保护的标识符，如"数值" *)
[@@deriving show, eq]

(** 将标识符token转换为字符串表示 *)
val to_string : identifier_token -> string

(** 获取标识符的名称（去除引号） *)
val get_name : identifier_token -> string

(** 检查是否为引用标识符 *)
val is_quoted : identifier_token -> bool

(** 检查是否为特殊标识符 *)
val is_special : identifier_token -> bool