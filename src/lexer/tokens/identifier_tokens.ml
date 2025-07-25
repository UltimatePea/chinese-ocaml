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

let from_string s =
  (* 检查是否以「开头并以」结尾 *)
  if String.length s >= 6 then
    let starts_with_quote = String.sub s 0 3 = "「" in
    let ends_with_quote = String.sub s (String.length s - 3) 3 = "」" in
    if starts_with_quote && ends_with_quote then
      let content = String.sub s 3 (String.length s - 6) in
      Some (QuotedIdentifierToken content)
    else None
  else if s = "数值" then
    Some (IdentifierTokenSpecial s)
  else
    None