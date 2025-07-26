(** Token工具函数模块 - 从unified_token_core.ml重构而来 *)

open Yyocamlc_lib.Token_types_core

(** 工具函数 *)
let make_positioned_token token position metadata = { token; position; metadata }

let make_simple_token token filename line column =
  let position = { filename; line; column; offset = 0 } in
  { token; position; metadata = None }

let get_token_priority token =
  match Token_category_checker.get_token_category token with
  | Keyword -> HighPriority
  | Operator | Delimiter -> MediumPriority
  | Literal | Identifier | Special -> LowPriority

let default_position filename = { filename; line = 1; column = 1; offset = 0 }

(** 简化的equal_token函数 - 只比较token构造器 *)
let equal_token t1 t2 =
  match (t1, t2) with
  | IntToken i1, IntToken i2 -> i1 = i2
  | FloatToken f1, FloatToken f2 -> Float.equal f1 f2
  | StringToken s1, StringToken s2 -> String.equal s1 s2
  | BoolToken b1, BoolToken b2 -> Bool.equal b1 b2
  | ChineseNumberToken s1, ChineseNumberToken s2 -> String.equal s1 s2
  | UnitToken, UnitToken -> true
  | IdentifierToken s1, IdentifierToken s2 -> String.equal s1 s2
  | QuotedIdentifierToken s1, QuotedIdentifierToken s2 -> String.equal s1 s2
  | ConstructorToken s1, ConstructorToken s2 -> String.equal s1 s2
  | IdentifierTokenSpecial s1, IdentifierTokenSpecial s2 -> String.equal s1 s2
  | ModuleNameToken s1, ModuleNameToken s2 -> String.equal s1 s2
  | TypeNameToken s1, TypeNameToken s2 -> String.equal s1 s2
  | Comment s1, Comment s2 -> String.equal s1 s2
  | LineComment s1, LineComment s2 -> String.equal s1 s2
  | BlockComment s1, BlockComment s2 -> String.equal s1 s2
  | DocComment s1, DocComment s2 -> String.equal s1 s2
  | ErrorToken (s1, _), ErrorToken (s2, _) -> String.equal s1 s2
  | EOF, EOF | Newline, Newline | Whitespace, Whitespace -> true
  | a, b when a = b -> true (* 对于不携带数据的构造器 *)
  | _ -> false
