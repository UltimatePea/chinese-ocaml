(** 统一Token映射器 - 替代所有分散的token转换逻辑 *)

open Utils.Base_formatter

(** 本地token类型定义 *)
type local_token =
  (* 字面量 *)
  | IntToken of int
  | FloatToken of float
  | StringToken of string
  | BoolToken of bool
  | ChineseNumberToken of string
  (* 标识符 *)
  | QuotedIdentifierToken of string
  | IdentifierTokenSpecial of string
  (* 关键字 *)
  | LetKeyword
  | RecKeyword
  | InKeyword
  | FunKeyword
  | IfKeyword
  | ThenKeyword
  | ElseKeyword
  | MatchKeyword
  | WithKeyword
  | OtherKeyword
  | TrueKeyword
  | FalseKeyword
  | AndKeyword
  | OrKeyword
  | NotKeyword
  | TypeKeyword
  | PrivateKeyword
  (* 类型关键字 *)
  | IntTypeKeyword
  | FloatTypeKeyword
  | StringTypeKeyword
  | BoolTypeKeyword
  | UnitTypeKeyword
  | ListTypeKeyword
  | ArrayTypeKeyword
  (* 运算符 *)
  | Plus
  | Minus
  | Multiply
  | Divide
  | Equal
  | NotEqual
  | Less
  | Greater
  | Arrow
  (* 其他 *)
  | UnknownToken

(** 数据类型，用于传递token值 *)
type value_data = Int of int | Float of float | String of string | Bool of bool

(** 显示token的字符串表示 *)
let show_token = function
  | IntToken i -> token_pattern "IntToken" (int_to_string i)
  | FloatToken f -> token_pattern "FloatToken" (float_to_string f)
  | StringToken s -> token_pattern "StringToken" s
  | BoolToken b -> token_pattern "BoolToken" (bool_to_string b)
  | ChineseNumberToken s -> token_pattern "ChineseNumberToken" s
  | QuotedIdentifierToken s -> token_pattern "QuotedIdentifierToken" s
  | IdentifierTokenSpecial s -> token_pattern "IdentifierTokenSpecial" s
  | LetKeyword -> "LetKeyword"
  | RecKeyword -> "RecKeyword"
  | InKeyword -> "InKeyword"
  | FunKeyword -> "FunKeyword"
  | IfKeyword -> "IfKeyword"
  | ThenKeyword -> "ThenKeyword"
  | ElseKeyword -> "ElseKeyword"
  | MatchKeyword -> "MatchKeyword"
  | WithKeyword -> "WithKeyword"
  | OtherKeyword -> "OtherKeyword"
  | TrueKeyword -> "TrueKeyword"
  | FalseKeyword -> "FalseKeyword"
  | AndKeyword -> "AndKeyword"
  | OrKeyword -> "OrKeyword"
  | NotKeyword -> "NotKeyword"
  | TypeKeyword -> "TypeKeyword"
  | PrivateKeyword -> "PrivateKeyword"
  | IntTypeKeyword -> "IntTypeKeyword"
  | FloatTypeKeyword -> "FloatTypeKeyword"
  | StringTypeKeyword -> "StringTypeKeyword"
  | BoolTypeKeyword -> "BoolTypeKeyword"
  | UnitTypeKeyword -> "UnitTypeKeyword"
  | ListTypeKeyword -> "ListTypeKeyword"
  | ArrayTypeKeyword -> "ArrayTypeKeyword"
  | Plus -> "Plus"
  | Minus -> "Minus"
  | Multiply -> "Multiply"
  | Divide -> "Divide"
  | Equal -> "Equal"
  | NotEqual -> "NotEqual"
  | Less -> "Less"
  | Greater -> "Greater"
  | Arrow -> "Arrow"
  | UnknownToken -> "UnknownToken"

(** 统一token映射结果类型 *)
type mapping_result =
  | Success of local_token
  | NotFound of string
  | ConversionError of string * string

(** 映射字面量token *)
let map_literal_token source_token_name value_data =
  match (source_token_name, value_data) with
  | "IntToken", Some (Int value) -> Some (IntToken value)
  | "FloatToken", Some (Float value) -> Some (FloatToken value)
  | "StringToken", Some (String value) -> Some (StringToken value)
  | "BoolToken", Some (Bool value) -> Some (BoolToken value)
  | "ChineseNumberToken", Some (String value) -> Some (ChineseNumberToken value)
  | _ -> None

(** 映射标识符token *)
let map_identifier_token source_token_name value_data =
  match (source_token_name, value_data) with
  | "QuotedIdentifierToken", Some (String value) -> Some (QuotedIdentifierToken value)
  | "IdentifierTokenSpecial", Some (String value) -> Some (IdentifierTokenSpecial value)
  | _ -> None

(** 映射基础关键字token *)
let map_basic_keyword_token source_token_name =
  match source_token_name with
  | "LetKeyword" -> Some LetKeyword
  | "RecKeyword" -> Some RecKeyword
  | "InKeyword" -> Some InKeyword
  | "FunKeyword" -> Some FunKeyword
  | "IfKeyword" -> Some IfKeyword
  | "ThenKeyword" -> Some ThenKeyword
  | "ElseKeyword" -> Some ElseKeyword
  | "MatchKeyword" -> Some MatchKeyword
  | "WithKeyword" -> Some WithKeyword
  | "OtherKeyword" -> Some OtherKeyword
  | "TrueKeyword" -> Some TrueKeyword
  | "FalseKeyword" -> Some FalseKeyword
  | "AndKeyword" -> Some AndKeyword
  | "OrKeyword" -> Some OrKeyword
  | "NotKeyword" -> Some NotKeyword
  | "TypeKeyword" -> Some TypeKeyword
  | "PrivateKeyword" -> Some PrivateKeyword
  | _ -> None

(** 映射类型关键字token *)
let map_type_keyword_token source_token_name =
  match source_token_name with
  | "IntTypeKeyword" -> Some IntTypeKeyword
  | "FloatTypeKeyword" -> Some FloatTypeKeyword
  | "StringTypeKeyword" -> Some StringTypeKeyword
  | "BoolTypeKeyword" -> Some BoolTypeKeyword
  | "UnitTypeKeyword" -> Some UnitTypeKeyword
  | "ListTypeKeyword" -> Some ListTypeKeyword
  | "ArrayTypeKeyword" -> Some ArrayTypeKeyword
  | _ -> None

(** 映射运算符token *)
let map_operator_token source_token_name =
  match source_token_name with
  | "Plus" -> Some Plus
  | "Minus" -> Some Minus
  | "Multiply" -> Some Multiply
  | "Divide" -> Some Divide
  | "Equal" -> Some Equal
  | "NotEqual" -> Some NotEqual
  | "Less" -> Some Less
  | "Greater" -> Some Greater
  | "Arrow" -> Some Arrow
  | _ -> None

(** 主要的统一token映射函数 *)
let map_token source_token_name value_data =
  (* 简化的映射逻辑，通过分类处理不同类型的token *)
  try
    let result_token =
      match map_literal_token source_token_name value_data with
      | Some token -> token
      | None -> (
          match map_identifier_token source_token_name value_data with
          | Some token -> token
          | None -> (
              match map_basic_keyword_token source_token_name with
              | Some token -> token
              | None -> (
                  match map_type_keyword_token source_token_name with
                  | Some token -> token
                  | None -> (
                      match map_operator_token source_token_name with
                      | Some token -> token
                      | None -> UnknownToken))))
    in
    Success result_token
  with exn -> ConversionError (source_token_name, Printexc.to_string exn)

(** 便利的token映射函数，用于不同类型的值 *)

(** 映射整数token *)
let map_int_token value = map_token "IntToken" (Some (Int value))

(** 映射浮点数token *)
let map_float_token value = map_token "FloatToken" (Some (Float value))

(** 映射字符串token *)
let map_string_token value = map_token "StringToken" (Some (String value))

(** 映射布尔token *)
let map_bool_token value = map_token "BoolToken" (Some (Bool value))

(** 映射中文数字token *)
let map_chinese_number_token value = map_token "ChineseNumberToken" (Some (String value))

(** 映射引用标识符token *)
let map_quoted_identifier_token value = map_token "QuotedIdentifierToken" (Some (String value))

(** 映射特殊标识符token *)
let map_special_identifier_token value = map_token "IdentifierTokenSpecial" (Some (String value))

(** 映射关键字token *)
let map_keyword_token keyword_name = map_token keyword_name None

(** 映射运算符token *)
let map_operator_token operator_name = map_token operator_name None

(** 批量映射tokens *)
let map_tokens token_specs =
  List.map (fun (name, value_data) -> (name, map_token name value_data)) token_specs

(** 验证映射结果 *)
let validate_mapping_result = function
  | Success token -> Printf.printf "✅ 映射成功: %s\n" (show_token token)
  | NotFound name -> Printf.printf "❌ 未找到映射: %s\n" name
  | ConversionError (name, error) ->
      Printf.printf "❌ 转换错误: %s\n" (context_message_pattern name error)

(** 批量验证映射结果 *)
let validate_mapping_results results =
  let success_count, error_count =
    List.fold_left
      (fun (s, e) (_, result) -> match result with Success _ -> (s + 1, e) | _ -> (s, e + 1))
      (0, 0) results
  in

  let success_rate =
    if success_count + error_count > 0 then
      float_of_int success_count /. float_of_int (success_count + error_count) *. 100.0
    else 0.0
  in
  let report =
    concat_strings
      [
        "\n=== Token映射验证结果 ===\n";
        "成功映射: " ^ int_to_string success_count ^ " 个\n";
        "失败映射: " ^ int_to_string error_count ^ " 个\n";
        "成功率: " ^ float_to_string success_rate ^ "%%\n";
      ]
  in
  Printf.printf "%s" report

(** 性能测试 *)
let performance_test iterations =
  let start_time = Sys.time () in

  for i = 1 to iterations do
    let _ = map_int_token i in
    let _ = map_string_token (string_of_int i) in
    let _ = map_keyword_token "LetKeyword" in
    let _ = map_operator_token "Plus" in
    ()
  done;

  let end_time = Sys.time () in
  let duration = end_time -. start_time in

  let total_tests = iterations * 4 in
  let avg_duration = duration /. float_of_int total_tests in
  let throughput = float_of_int total_tests /. duration in
  let report =
    concat_strings
      [
        "\n=== Token映射性能测试 ===\n";
        "测试次数: " ^ int_to_string total_tests ^ " 次\n";
        "总耗时: " ^ float_to_string duration ^ " 秒\n";
        "平均耗时: " ^ float_to_string avg_duration ^ " 秒/次\n";
        "吞吐量: " ^ float_to_string throughput ^ " 次/秒\n";
      ]
  in
  Printf.printf "%s" report

(** 显示所有支持的映射 *)
let show_supported_mappings () =
  Token_registry.initialize_registry ();
  let mappings = Token_registry.get_sorted_mappings () in

  Printf.printf "=== 支持的Token映射 ===\n";
  List.iter
    (fun entry ->
      let mapping_info =
        concat_strings
          [
            "- ";
            entry.Token_registry.source_token;
            " (";
            entry.Token_registry.category;
            "): ";
            entry.Token_registry.description;
            "\n";
          ]
      in
      Printf.printf "%s" mapping_info)
    mappings;

  Printf.printf "%s\n" (Token_registry.get_registry_stats ())
