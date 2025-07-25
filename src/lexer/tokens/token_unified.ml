(** 骆言词法分析器 - 统一Token类型定义 *)

open Basic_tokens
open Identifier_tokens
open Core_keywords
open Wenyan_keywords
open Ancient_keywords
open Poetry_keywords
open Operator_tokens
open Delimiter_tokens
open Chinese_delimiters

type position = { line : int; column : int; filename : string } [@@deriving show, eq]

type token =
  | Basic of basic_token
  | Identifier of identifier_token
  | CoreKeyword of core_keyword
  | WenyanKeyword of wenyan_keyword
  | AncientKeyword of ancient_keyword
  | PoetryKeyword of poetry_keyword
  | Operator of operator_token
  | Delimiter of delimiter_token
  | ChineseDelimiter of chinese_delimiter
[@@deriving show, eq]

type positioned_token = token * position [@@deriving show, eq]

exception LexError of string * position

let to_string = function
  | Basic bt -> Basic_tokens.to_string bt
  | Identifier it -> Identifier_tokens.to_string it
  | CoreKeyword ck -> Core_keywords.to_string ck
  | WenyanKeyword wk -> Wenyan_keywords.to_string wk
  | AncientKeyword ak -> Ancient_keywords.to_string ak
  | PoetryKeyword pk -> Poetry_keywords.to_string pk
  | Operator ot -> Operator_tokens.to_string ot
  | Delimiter dt -> Delimiter_tokens.to_string dt
  | ChineseDelimiter cd -> Chinese_delimiters.to_string cd

let from_string s =
  match Basic_tokens.from_string s with
  | Some bt -> Some (Basic bt)
  | None ->
      match Identifier_tokens.from_string s with
      | Some it -> Some (Identifier it)
      | None ->
          match Core_keywords.from_string s with
          | Some ck -> Some (CoreKeyword ck)
          | None ->
              match Wenyan_keywords.from_string s with
              | Some wk -> Some (WenyanKeyword wk)
              | None ->
                  match Ancient_keywords.from_string s with
                  | Some ak -> Some (AncientKeyword ak)
                  | None ->
                      match Poetry_keywords.from_string s with
                      | Some pk -> Some (PoetryKeyword pk)
                      | None ->
                          match Operator_tokens.from_string s with
                          | Some ot -> Some (Operator ot)
                          | None ->
                              match Delimiter_tokens.from_string s with
                              | Some dt -> Some (Delimiter dt)
                              | None ->
                                  match Chinese_delimiters.from_string s with
                                  | Some cd -> Some (ChineseDelimiter cd)
                                  | None -> None

let is_literal = function
  | Basic _ -> true
  | _ -> false

let is_keyword = function
  | CoreKeyword _ | WenyanKeyword _ | AncientKeyword _ | PoetryKeyword _ -> true
  | _ -> false

let is_operator = function
  | Operator _ -> true
  | _ -> false

let is_delimiter = function
  | Delimiter _ | ChineseDelimiter _ -> true
  | _ -> false

let is_chinese_related = function
  | WenyanKeyword _ | AncientKeyword _ | PoetryKeyword _ | ChineseDelimiter _ -> true
  | Basic (ChineseNumberToken _) -> true
  | _ -> false

let get_category = function
  | Basic _ -> "字面量"
  | Identifier _ -> "标识符"
  | CoreKeyword _ -> "核心关键字"
  | WenyanKeyword _ -> "文言关键字"
  | AncientKeyword _ -> "古雅体关键字"
  | PoetryKeyword _ -> "诗词关键字"
  | Operator _ -> "运算符"
  | Delimiter _ -> "分隔符"
  | ChineseDelimiter _ -> "中文标点"

let compare_precedence t1 t2 =
  let get_precedence = function
    | Operator op -> Operator_tokens.precedence op
    | _ -> 0
  in
  let p1 = get_precedence t1 in
  let p2 = get_precedence t2 in
  compare p1 p2