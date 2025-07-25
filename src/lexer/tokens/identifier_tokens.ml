(** 骆言词法分析器 - 标识符Token *)

type identifier_token =
  | QuotedIdentifierToken of string    
  | IdentifierTokenSpecial of string   
[@@deriving show, eq]

let to_string = function
  | QuotedIdentifierToken s -> "「" ^ s ^ "」"
  | IdentifierTokenSpecial s -> s

let get_name = function
  | QuotedIdentifierToken s -> s
  | IdentifierTokenSpecial s -> s

let is_quoted = function
  | QuotedIdentifierToken _ -> true
  | _ -> false

let is_special = function
  | IdentifierTokenSpecial _ -> true
  | _ -> false