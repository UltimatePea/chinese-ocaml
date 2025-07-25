(** Token转换重构保护测试
    确保重构过程中不破坏现有功能
    
    @author Alpha, 主要工作代理
    @version 1.0  
    @since 2025-07-25 *)

open Yyocamlc_lib.Token_conversion_keywords_refactored
open Yyocamlc_lib.Token_conversion_classical
open Yyocamlc_lib.Lexer_tokens
module Token_mapping = Token_mapping

(** 测试基础关键字转换 *)
let test_basic_keyword_conversion () =
  (* 测试基础语言关键字 *)
  let test_cases = [
    (Token_mapping.Token_definitions_unified.LetKeyword, LetKeyword);
    (Token_mapping.Token_definitions_unified.FunKeyword, FunKeyword);
    (Token_mapping.Token_definitions_unified.IfKeyword, IfKeyword);
    (Token_mapping.Token_definitions_unified.ThenKeyword, ThenKeyword);
    (Token_mapping.Token_definitions_unified.ElseKeyword, ElseKeyword);
  ] in
  List.iter (fun (input, expected) ->
    Alcotest.(check bool) "Token conversion" true 
      (convert_basic_keyword_token input = expected)
  ) test_cases

(** 测试古雅体关键字转换 *)  
let test_ancient_keyword_conversion () =
  let test_cases = [
    (Token_mapping.Token_definitions_unified.AncientDefineKeyword, AncientDefineKeyword);
    (Token_mapping.Token_definitions_unified.AncientEndKeyword, AncientEndKeyword);
    (Token_mapping.Token_definitions_unified.AncientAlgorithmKeyword, AncientAlgorithmKeyword);
    (Token_mapping.Token_definitions_unified.AncientCompleteKeyword, AncientCompleteKeyword);
  ] in
  List.iter (fun (input, expected) ->
    Alcotest.(check bool) "Ancient token conversion" true 
      (convert_basic_keyword_token input = expected)
  ) test_cases

(** 测试文言文关键字转换 *)
let test_wenyan_keyword_conversion () =
  let test_cases = [
    (Token_mapping.Token_definitions_unified.HaveKeyword, HaveKeyword);
    (Token_mapping.Token_definitions_unified.NameKeyword, NameKeyword);
    (Token_mapping.Token_definitions_unified.SetKeyword, SetKeyword);
    (Token_mapping.Token_definitions_unified.CallKeyword, CallKeyword);
  ] in
  List.iter (fun (input, expected) ->
    Alcotest.(check bool) "Wenyan token conversion" true 
      (convert_basic_keyword_token input = expected)
  ) test_cases

(** 测试古典语言转换器 *)
let test_classical_token_conversion () =
  let test_cases = [
    (Token_mapping.Token_definitions_unified.HaveKeyword, HaveKeyword);
    (Token_mapping.Token_definitions_unified.OneKeyword, OneKeyword);
    (Token_mapping.Token_definitions_unified.ValueKeyword, ValueKeyword);
  ] in
  List.iter (fun (input, expected) ->
    Alcotest.(check bool) "Classical token conversion" true 
      (convert_classical_token input = expected)
  ) test_cases

let () =
  let open Alcotest in
  run "Token转换重构保护测试" [
    "基础功能", [
      test_case "基础关键字转换" `Quick test_basic_keyword_conversion;
      test_case "古雅体关键字转换" `Quick test_ancient_keyword_conversion;
      test_case "文言文关键字转换" `Quick test_wenyan_keyword_conversion;
      test_case "古典语言转换器" `Quick test_classical_token_conversion;
    ];
  ]