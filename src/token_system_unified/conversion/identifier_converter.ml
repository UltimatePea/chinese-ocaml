(** 骆言编译器 - 标识符转换器
    
    专门处理标识符Token的转换，支持中英文标识符、
    引用标识符和特殊标识符。
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

open Yyocamlc_lib.Token_types
open Token_system_core.Token_errors
open Token_converter

type identifier_type = [ `Simple | `Quoted | `Special | `Invalid ]
(** 标识符类型 *)

(** 检查是否为有效的标识符 *)
let rec is_valid_identifier text =
  let len = String.length text in
  if len = 0 then false
  else
    let rec check_chars i =
      if i >= len then true
      else
        let c = String.get text i in
        let is_valid_char =
          (* 允许中文字符、英文字母、数字和下划线 *)
          (c >= 'a' && c <= 'z')
          || (c >= 'A' && c <= 'Z')
          || (c >= '0' && c <= '9' && i > 0)
          (* 数字不能开头 *)
          || c = '_'
          ||
          (* 简单的中文字符检测 - 检查是否为多字节UTF-8字符 *)
          Char.code c >= 128
        in
        if is_valid_char then check_chars (i + 1) else false
    in
    (* 检查首字符不能是数字 *)
    let first_char = String.get text 0 in
    if first_char >= '0' && first_char <= '9' then false else check_chars 0

(** 标识符转换器实现 *)
and identifier_converter =
  let module IdentifierConverter = struct
    let name = "identifier_converter"
    let converter_type = IdentifierConverter

    let string_to_token config text =
      let _config = config in
      (* 检查是否为引用标识符（用「」包围） *)
      let len = String.length text in
      if len >= 6 && String.sub text 0 3 = "「" && String.sub text (len - 3) 3 = "」" then
        let content = String.sub text 3 (len - 6) in
        ok_result (Identifier (QuotedIdentifierToken content)) (* 检查是否为特殊标识符（以$开头） *)
      else if len >= 2 && String.get text 0 = '$' then
        let content = String.sub text 1 (len - 1) in
        ok_result (Identifier (IdentifierTokenSpecial content)) (* 检查是否为有效的简单标识符 *)
      else if is_valid_identifier text then ok_result (Identifier (SimpleIdentifier text))
      else
        error_result (InvalidTokenFormat ("identifier", text, { line = 0; column = 0; offset = 0 }))

    let token_to_string _config token =
      match token with
      | Identifier (QuotedIdentifierToken s) -> ok_result ("「" ^ s ^ "」")
      | Identifier (IdentifierTokenSpecial s) -> ok_result ("$" ^ s)
      | Identifier (SimpleIdentifier s) -> ok_result s
      | _ -> error_result (ConversionError ("identifier_token", "string"))

    let can_handle_string text =
      let len = String.length text in
      (* 引用标识符 *)
      (len >= 6 && String.sub text 0 3 = "「" && String.sub text (len - 3) 3 = "」")
      (* 特殊标识符 *)
      || (len >= 2 && String.get text 0 = '$')
      ||
      (* 简单标识符 *)
      is_valid_identifier text

    let can_handle_token = function Identifier _ -> true | _ -> false

    let supported_tokens () =
      [
        Identifier (SimpleIdentifier "example");
        Identifier (QuotedIdentifierToken "example");
        Identifier (IdentifierTokenSpecial "example");
      ]
  end in
  (module IdentifierConverter : CONVERTER)

(** 标识符类型检测 *)
let detect_identifier_type text =
  let len = String.length text in
  if len >= 6 && String.sub text 0 3 = "「" && String.sub text (len - 3) 3 = "」" then `Quoted
  else if len >= 2 && String.get text 0 = '$' then `Special
  else if is_valid_identifier text then `Simple
  else `Invalid

(** 验证标识符名称的有效性 *)
let validate_identifier_name name =
  if String.length name = 0 then
    error_result (InvalidTokenFormat ("identifier", name, { line = 0; column = 0; offset = 0 }))
  else if is_valid_identifier name then ok_result name
  else error_result (InvalidTokenFormat ("identifier", name, { line = 0; column = 0; offset = 0 }))

(** 创建标识符Token的安全函数 *)
let create_identifier_token identifier_type name =
  match validate_identifier_name name with
  | Ok validated_name -> (
      match identifier_type with
      | `Simple -> ok_result (Identifier (SimpleIdentifier validated_name))
      | `Quoted -> ok_result (Identifier (QuotedIdentifierToken validated_name))
      | `Special -> ok_result (Identifier (IdentifierTokenSpecial validated_name))
      | `Invalid ->
          error_result
            (InvalidTokenFormat ("identifier_type", name, { line = 0; column = 0; offset = 0 })))
  | Error err -> error_result err

(** 提取标识符名称 *)
let extract_identifier_name = function
  | Identifier (SimpleIdentifier name) -> ok_result name
  | Identifier (QuotedIdentifierToken name) -> ok_result name
  | Identifier (IdentifierTokenSpecial name) -> ok_result name
  | _ -> error_result (ConversionError ("token", "identifier_name"))

(** 检查标识符是否包含中文字符 *)
let contains_chinese_chars text =
  let rec check i =
    if i >= String.length text then false
    else
      let c = String.get text i in
      if Char.code c >= 128 then true (* 简单的多字节字符检测 *) else check (i + 1)
  in
  check 0

(** 标识符统计信息 *)
let get_identifier_stats token_list =
  let count_by_type =
    List.fold_left
      (fun (simple, quoted, special) token ->
        match token with
        | Identifier (SimpleIdentifier _) -> (simple + 1, quoted, special)
        | Identifier (QuotedIdentifierToken _) -> (simple, quoted + 1, special)
        | Identifier (IdentifierTokenSpecial _) -> (simple, quoted, special + 1)
        | _ -> (simple, quoted, special))
      (0, 0, 0) token_list
  in
  let simple_count, quoted_count, special_count = count_by_type in
  [
    ("simple_identifiers", simple_count);
    ("quoted_identifiers", quoted_count);
    ("special_identifiers", special_count);
    ("total_identifiers", simple_count + quoted_count + special_count);
  ]
