(** 统一Token映射器 - 替代所有分散的token转换逻辑 *)

(* 使用Token_registry中定义的本地token类型 *)
open Token_registry

(** 统一token映射结果类型 *)
type mapping_result =
  | Success of local_token
  | NotFound of string
  | ConversionError of string * string

(** 主要的统一token映射函数 *)
let map_token source_token_name value_data =
  (* 初始化注册器（如果尚未初始化） *)
  initialize_registry ();

  match find_token_mapping source_token_name with
  | Some entry -> (
      try
        (* 根据token类型和数据创建具体的token实例 *)
        let result_token =
          match (entry.target_token, value_data) with
          (* 字面量tokens *)
          | IntToken _, Some (Int value) -> IntToken value
          | FloatToken _, Some (Float value) -> FloatToken value
          | StringToken _, Some (String value) -> StringToken value
          | BoolToken _, Some (Bool value) -> BoolToken value
          | ChineseNumberToken _, Some (String value) -> ChineseNumberToken value
          (* 标识符tokens *)
          | QuotedIdentifierToken _, Some (String value) -> QuotedIdentifierToken value
          | IdentifierTokenSpecial _, Some (String value) -> IdentifierTokenSpecial value
          (* 关键字和运算符tokens（无需额外数据） *)
          | token, None -> token
          | token, _ -> token (* 默认返回注册的token *)
        in
        Success result_token
      with exn -> ConversionError (source_token_name, Printexc.to_string exn))
  | None -> NotFound source_token_name

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
  | ConversionError (name, error) -> Printf.printf "❌ 转换错误: %s - %s\n" name error

(** 批量验证映射结果 *)
let validate_mapping_results results =
  let success_count, error_count =
    List.fold_left
      (fun (s, e) (_, result) -> match result with Success _ -> (s + 1, e) | _ -> (s, e + 1))
      (0, 0) results
  in

  Printf.printf {|
=== Token映射验证结果 ===
成功映射: %d 个
失败映射: %d 个
成功率: %.1f%%
  |} success_count
    error_count
    (if success_count + error_count > 0 then
       float_of_int success_count /. float_of_int (success_count + error_count) *. 100.0
     else 0.0)

(** 数据类型，用于传递token值 *)
type value_data = Int of int | Float of float | String of string | Bool of bool

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

  Printf.printf {|
=== Token映射性能测试 ===
测试次数: %d 次
总耗时: %.6f 秒
平均耗时: %.9f 秒/次
吞吐量: %.0f 次/秒
  |}
    (iterations * 4) duration
    (duration /. float_of_int (iterations * 4))
    (float_of_int (iterations * 4) /. duration)

(** 显示所有支持的映射 *)
let show_supported_mappings () =
  Token_registry.initialize_registry ();
  let mappings = Token_registry.get_sorted_mappings () in

  Printf.printf "=== 支持的Token映射 ===\n";
  List.iter
    (fun entry ->
      Printf.printf "- %s (%s): %s\n" entry.Token_registry.source_token
        entry.Token_registry.category entry.Token_registry.description)
    mappings;

  Printf.printf "%s\n" (Token_registry.get_registry_stats ())
