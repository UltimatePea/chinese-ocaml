(** 骆言词法分析器 - 标识符令牌类型定义 *)

(** 标识符类型 *)
type identifier_token =
  | QuotedIdentifierToken of string (* 「标识符」 - 所有标识符必须引用 *)
  | IdentifierTokenSpecial of string (* 特殊保护的标识符，如"数值" *)
[@@deriving show, eq]

(** 标识符转换为字符串 *)
let identifier_token_to_string = function
  | QuotedIdentifierToken s -> "「" ^ s ^ "」"
  | IdentifierTokenSpecial s -> s

(** 判断是否为引用标识符 *)
let is_quoted_identifier = function QuotedIdentifierToken _ -> true | _ -> false

(** 判断是否为特殊标识符 *)
let is_special_identifier = function IdentifierTokenSpecial _ -> true | _ -> false

(** 提取标识符内容 *)
let extract_identifier_content = function QuotedIdentifierToken s | IdentifierTokenSpecial s -> s

(** 创建引用标识符 *)
let create_quoted_identifier s = QuotedIdentifierToken s

(** 创建特殊标识符 *)
let create_special_identifier s = IdentifierTokenSpecial s
