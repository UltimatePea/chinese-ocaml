(** 简化的Token映射器 - 避免循环依赖的简单实现 已重构使用Base_formatter，消除Printf.sprintf依赖 - Fix #857 *)

open Utils
open Base_formatter

(** 简化的token类型，避免依赖主要的lexer_tokens *)
type simple_token =
  | IntToken of int
  | StringToken of string
  | KeywordToken of string
  | OperatorToken of string
  | UnknownToken of string

type mapping_entry = { name : string; category : string; description : string }
(** Token映射条目 *)

(** 简单的token映射表 *)
let token_mappings =
  [
    { name = "LetKeyword"; category = "keyword"; description = "让 - let" };
    { name = "IfKeyword"; category = "keyword"; description = "如果 - if" };
    { name = "ThenKeyword"; category = "keyword"; description = "那么 - then" };
    { name = "ElseKeyword"; category = "keyword"; description = "否则 - else" };
    { name = "Plus"; category = "operator"; description = "加法 - +" };
    { name = "Minus"; category = "operator"; description = "减法 - -" };
    { name = "Equal"; category = "operator"; description = "等于 - ==" };
  ]

(** 查找token映射 *)
let find_mapping name = List.find_opt (fun entry -> entry.name = name) token_mappings

(** 简单的token转换 *)
let convert_token name int_value string_value =
  match find_mapping name with
  | Some entry -> (
      match entry.category with
      | "keyword" -> KeywordToken name
      | "operator" -> OperatorToken name
      | _ -> UnknownToken name)
  | None -> (
      match name with
      | "IntToken" when int_value <> None -> IntToken (Option.get int_value)
      | "StringToken" when string_value <> None -> StringToken (Option.get string_value)
      | _ -> UnknownToken name)

(** 获取统计信息 *)
let get_stats () =
  let total = List.length token_mappings in
  let categories = List.map (fun e -> e.category) token_mappings |> List.sort_uniq String.compare in
  concat_strings
    [ "注册Token数: "; int_to_string total; ", 分类: "; join_with_separator ", " categories ]

(** 测试函数 *)
let test_mapping () =
  Printf.printf "=== 简化Token映射器测试 ===\n";
  Printf.printf "%s\n" (get_stats ());

  let test_cases =
    [
      ("LetKeyword", None, None);
      ("IfKeyword", None, None);
      ("Plus", None, None);
      ("IntToken", Some 42, None);
      ("StringToken", None, Some "测试");
      ("UnknownToken", None, None);
    ]
  in

  List.iter
    (fun (name, int_val, str_val) ->
      let result = convert_token name int_val str_val in
      Printf.printf "映射 %s -> %s\n" name
        (match result with
        | IntToken i -> token_pattern "IntToken" (int_to_string i)
        | StringToken s -> token_pattern "StringToken" s
        | KeywordToken k -> token_pattern "KeywordToken" k
        | OperatorToken o -> token_pattern "OperatorToken" o
        | UnknownToken u -> token_pattern "UnknownToken" u))
    test_cases
