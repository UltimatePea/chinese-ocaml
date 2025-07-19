(** 统一Token映射器综合测试 *)

open Token_mapping.Token_registry
open Token_mapping.Unified_token_mapper

(** 测试基础token映射功能 *)
let test_basic_token_mapping () =
  Printf.printf "=== 测试基础Token映射功能 ===\n";

  (* 测试字面量映射 *)
  let int_result = map_int_token 42 in
  validate_mapping_result int_result;

  let float_result = map_float_token 3.14 in
  validate_mapping_result float_result;

  let string_result = map_string_token "测试字符串" in
  validate_mapping_result string_result;

  let bool_result = map_bool_token true in
  validate_mapping_result bool_result;

  let chinese_num_result = map_chinese_number_token "一二三" in
  validate_mapping_result chinese_num_result;

  (* 测试标识符映射 *)
  let quoted_id_result = map_quoted_identifier_token "「变量名」" in
  validate_mapping_result quoted_id_result;

  let special_id_result = map_special_identifier_token "数值" in
  validate_mapping_result special_id_result;

  (* 测试关键字映射 *)
  let keyword_results =
    [
      map_keyword_token "LetKeyword";
      map_keyword_token "IfKeyword";
      map_keyword_token "ThenKeyword";
      map_keyword_token "ElseKeyword";
      map_keyword_token "MatchKeyword";
    ]
  in
  List.iter validate_mapping_result keyword_results;

  (* 测试运算符映射 *)
  let operator_results =
    [
      map_operator_token "Plus";
      map_operator_token "Minus";
      map_operator_token "Equal";
      map_operator_token "Arrow";
    ]
  in
  List.iter validate_mapping_result operator_results

(** 测试批量映射 *)
let test_batch_mapping () =
  Printf.printf "\n=== 测试批量Token映射 ===\n";

  let token_specs =
    [
      ("IntToken", Some (Int 100));
      ("StringToken", Some (String "批量测试"));
      ("LetKeyword", None);
      ("IfKeyword", None);
      ("Plus", None);
      ("InvalidToken", None);
      (* 故意的无效token *)
    ]
  in

  let results = map_tokens token_specs in
  validate_mapping_results results

(** 测试错误处理 *)
let test_error_handling () =
  Printf.printf "\n=== 测试错误处理 ===\n";

  (* 测试未知token *)
  let unknown_result = map_keyword_token "UnknownKeyword" in
  validate_mapping_result unknown_result;

  (* 测试类型不匹配 *)
  let mismatch_result = map_token "IntToken" (Some (String "不是整数")) in
  validate_mapping_result mismatch_result

(** 测试注册器功能 *)
let test_registry_functions () =
  Printf.printf "\n=== 测试注册器功能 ===\n";

  (* 初始化注册器 *)
  initialize_registry ();

  (* 验证注册器 *)
  validate_registry ();

  (* 显示统计信息 *)
  Printf.printf "%s\n" (get_registry_stats ());

  (* 测试按分类查询 *)
  let literal_mappings = get_mappings_by_category "literal" in
  Printf.printf "字面量映射数量: %d\n" (List.length literal_mappings);

  let keyword_mappings = get_mappings_by_category "basic_keyword" in
  Printf.printf "基础关键字映射数量: %d\n" (List.length keyword_mappings)

(** 测试向后兼容性 *)
let test_backward_compatibility () =
  Printf.printf "\n=== 测试向后兼容性 ===\n";

  (* 测试与现有token转换的兼容性 *)
  let legacy_tokens =
    [
      ("LetKeyword", Lexer_tokens.LetKeyword);
      ("RecKeyword", Lexer_tokens.RecKeyword);
      ("IfKeyword", Lexer_tokens.IfKeyword);
      ("ThenKeyword", Lexer_tokens.ThenKeyword);
      ("Plus", Lexer_tokens.Plus);
      ("Minus", Lexer_tokens.Minus);
    ]
  in

  Printf.printf "向后兼容性测试:\n";
  List.iter
    (fun (name, expected_token) ->
      match map_keyword_token name with
      | Success actual_token when Lexer_tokens.equal_token actual_token expected_token ->
          Printf.printf "✅ %s: 兼容\n" name
      | Success actual_token ->
          Printf.printf "❌ %s: 不兼容 (期望: %s, 实际: %s)\n" name
            (Lexer_tokens.show_token expected_token)
            (Lexer_tokens.show_token actual_token)
      | NotFound _ -> Printf.printf "❌ %s: 未找到\n" name
      | ConversionError (_, error) -> Printf.printf "❌ %s: 转换错误 - %s\n" name error)
    legacy_tokens

(** 性能基准测试 *)
let test_performance () =
  Printf.printf "\n=== 性能基准测试 ===\n";

  (* 测试不同规模的性能 *)
  let test_sizes = [ 100; 1000; 10000 ] in
  List.iter
    (fun size ->
      Printf.printf "\n--- 测试规模: %d ---\n" size;
      performance_test size)
    test_sizes

(** 完整性测试 *)
let test_completeness () =
  Printf.printf "\n=== 完整性测试 ===\n";

  (* 显示所有支持的映射 *)
  show_supported_mappings ();

  (* 验证所有基础token类型都有映射 *)
  let required_tokens =
    [
      "IntToken";
      "FloatToken";
      "StringToken";
      "BoolToken";
      "ChineseNumberToken";
      "QuotedIdentifierToken";
      "IdentifierTokenSpecial";
      "LetKeyword";
      "RecKeyword";
      "InKeyword";
      "FunKeyword";
      "IfKeyword";
      "ThenKeyword";
      "ElseKeyword";
      "MatchKeyword";
      "TypeKeyword";
      "IntTypeKeyword";
      "StringTypeKeyword";
      "Plus";
      "Minus";
      "Equal";
      "Arrow";
    ]
  in

  let missing_tokens =
    List.filter
      (fun token_name -> match find_token_mapping token_name with None -> true | Some _ -> false)
      required_tokens
  in

  if missing_tokens = [] then Printf.printf "✅ 所有必需的token映射都已注册\n"
  else Printf.printf "❌ 缺少以下token映射: %s\n" (String.concat ", " missing_tokens)

(** 主测试函数 *)
let run_all_tests () =
  Printf.printf "开始统一Token映射器综合测试...\n\n";

  test_registry_functions ();
  test_basic_token_mapping ();
  test_batch_mapping ();
  test_error_handling ();
  test_backward_compatibility ();
  test_completeness ();
  test_performance ();

  Printf.printf "\n=== 测试完成 ===\n"

(* 运行测试 *)
let () = run_all_tests ()
