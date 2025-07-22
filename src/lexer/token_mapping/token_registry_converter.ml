(** Token注册器 - 代码生成和转换功能 *)

open Token_registry_core
open Token_registry_literals
open Token_registry_identifiers
open Token_registry_keywords
open Token_registry_operators
open Utils.Base_formatter

(** 统一Token代码生成函数 *)
let generate_token_code_by_category entry =
  match entry.category with
  | "literal" -> (
      try generate_literal_token_code entry.target_token with Invalid_argument _ -> "UnknownToken")
  | "identifier" -> (
      try generate_identifier_token_code entry.target_token
      with Invalid_argument _ -> "UnknownToken")
  | "basic_keyword" -> (
      try generate_basic_keyword_code entry.target_token with Invalid_argument _ -> "UnknownToken")
  | "type_keyword" -> (
      try generate_type_keyword_code entry.target_token with Invalid_argument _ -> "UnknownToken")
  | "operator" -> (
      try generate_operator_code entry.source_token with Invalid_argument _ -> "UnknownToken")
  | _ -> "UnknownToken"

(** 生成token转换函数 - 重构后的版本 *)
let generate_token_converter () =
  let mappings = get_sorted_mappings () in
  let conversion_cases =
    List.map
      (fun entry ->
        concat_strings ["  | "; entry.source_token; " -> "; generate_token_code_by_category entry; " (* "; entry.description; " *)"])
      mappings
  in

  concat_strings [
    "\n";
    "(** 自动生成的Token转换函数 - 重构后的模块化版本 *)\n";
    "let convert_registered_token = function\n";
    String.concat "\n" conversion_cases;
    "\n  | _ -> raise (Unified_errors.unified_error_to_exception (Unified_errors.SystemError \"未注册的token类型\"))\n"
  ]
