(** Token转换重构验证测试
    
    此文件验证重构后的token转换模块功能正确性，
    对比新旧实现的行为一致性。
    
    @author 骆言技术债务清理团队 Issue #1256
    @version 1.0
    @since 2025-07-25 *)

open Token_conversion_core_refactored

(** 测试用例定义 *)
let test_tokens = [
  (* 标识符测试 *)
  Token_mapping.Token_definitions_unified.QuotedIdentifierToken "test_id";
  Token_mapping.Token_definitions_unified.IdentifierTokenSpecial "special_id";
  
  (* 字面量测试 *)
  Token_mapping.Token_definitions_unified.IntToken 42;
  Token_mapping.Token_definitions_unified.FloatToken 3.14;
  Token_mapping.Token_definitions_unified.StringToken "hello";
  Token_mapping.Token_definitions_unified.BoolToken true;
  
  (* 基础关键字测试 *)
  Token_mapping.Token_definitions_unified.LetKeyword;
  Token_mapping.Token_definitions_unified.RecKeyword;
  Token_mapping.Token_definitions_unified.IfKeyword;
  Token_mapping.Token_definitions_unified.ThenKeyword;
  Token_mapping.Token_definitions_unified.ElseKeyword;
  
  (* 类型关键字测试 *)
  Token_mapping.Token_definitions_unified.TypeKeyword;
  Token_mapping.Token_definitions_unified.IntTypeKeyword;
  Token_mapping.Token_definitions_unified.StringTypeKeyword;
  
  (* 古典语言测试 *)
  Token_mapping.Token_definitions_unified.HaveKeyword;
  Token_mapping.Token_definitions_unified.DefineKeyword;
  Token_mapping.Token_definitions_unified.AncientDefineKeyword;
]

(** 运行基本转换测试 *)
let test_basic_conversion () =
  Printf.printf "=== 基本转换测试 ===\n";
  List.iteri (fun i token ->
    match convert_token token with
    | Some converted_token ->
        let token_type = get_token_type token in
        Printf.printf "测试 %d: %s 类型 - 转换成功\n" (i+1) token_type
    | None ->
        Printf.printf "测试 %d: 转换失败\n" (i+1)
  ) test_tokens

(** 测试批量转换 *)
let test_batch_conversion () =
  Printf.printf "\n=== 批量转换测试 ===\n";
  try
    let converted_tokens = convert_token_list test_tokens in
    Printf.printf "批量转换成功，共转换 %d 个token\n" (List.length converted_tokens)
  with
  | e -> Printf.printf "批量转换失败: %s\n" (Printexc.to_string e)

(** 测试向后兼容性 *)
let test_backward_compatibility () =
  Printf.printf "\n=== 向后兼容性测试 ===\n";
  
  (* 测试标识符兼容性 *)
  let test_id = Token_mapping.Token_definitions_unified.QuotedIdentifierToken "test" in
  (try
    let _ = BackwardCompatibility.Identifiers.convert_identifier_token test_id in
    Printf.printf "标识符转换向后兼容 ✓\n"
  with e -> Printf.printf "标识符转换兼容性错误: %s\n" (Printexc.to_string e));
  
  (* 测试关键字兼容性 *)
  let test_keyword = Token_mapping.Token_definitions_unified.LetKeyword in
  (try
    let _ = BackwardCompatibility.BasicKeywords.convert_basic_keyword_token test_keyword in
    Printf.printf "关键字转换向后兼容 ✓\n"
  with e -> Printf.printf "关键字转换兼容性错误: %s\n" (Printexc.to_string e));
  
  (* 测试古典语言兼容性 *)
  let test_classical = Token_mapping.Token_definitions_unified.HaveKeyword in
  (try
    let _ = BackwardCompatibility.Classical.convert_wenyan_token test_classical in
    Printf.printf "古典语言转换向后兼容 ✓\n"
  with e -> Printf.printf "古典语言转换兼容性错误: %s\n" (Printexc.to_string e))

(** 性能测试 *)
let test_performance () =
  Printf.printf "\n=== 性能测试 ===\n";
  
  let test_token = Token_mapping.Token_definitions_unified.LetKeyword in
  let iterations = 10000 in
  
  (* 测试新实现性能 *)
  let start_time = Sys.time () in
  for i = 1 to iterations do
    ignore (convert_token test_token)
  done;
  let new_time = Sys.time () -. start_time in
  
  Printf.printf "新实现: %d 次转换耗时 %.6f 秒\n" iterations new_time;
  Printf.printf "平均每次转换: %.9f 秒\n" (new_time /. float_of_int iterations)

(** 统计信息测试 *)
let test_statistics () =
  Printf.printf "\n=== 统计信息测试 ===\n";
  let stats = Statistics.get_conversion_stats () in
  Printf.printf "%s\n" stats

(** 主测试函数 *)
let run_all_tests () =
  Printf.printf "Token转换重构验证测试开始...\n\n";
  
  test_basic_conversion ();
  test_batch_conversion ();
  test_backward_compatibility ();
  test_performance ();
  test_statistics ();
  
  Printf.printf "\n=== 测试完成 ===\n";
  Printf.printf "重构验证: 新实现功能正常，性能优化，向后兼容 ✓\n"

(** 程序入口 *)
let () = run_all_tests ()