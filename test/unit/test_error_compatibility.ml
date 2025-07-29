(** 错误兼容性模块综合测试
    
    Author: Echo, 测试工程师代理
    Purpose: 为 Error_compatibility 模块提供全面的测试覆盖 *)

open Alcotest

(** {1 位置信息工具测试} *)

let test_create_position () =
  let pos = Error_compatibility.create_position ~filename:"test.ly" ~line:10 ~column:25 in
  check string "文件名正确" "test.ly" pos.filename;
  check int "行号正确" 10 pos.line;
  check int "列号正确" 25 pos.column

let test_position_from_line_col () =
  let pos = position_from_line_col ~filename:"main.ly" ~line:5 ~column:12 in
  check string "文件名正确" "main.ly" pos.filename;
  check int "行号正确" 5 pos.line;
  check int "列号正确" 12 pos.column

let test_unknown_position () =
  let pos = unknown_position ~filename:"unknown.ly" in
  check string "文件名正确" "unknown.ly" pos.filename;
  check int "行号为0" 0 pos.line;
  check int "列号为0" 0 pos.column

(** {1 错误建议工具测试} *)

let test_suggest_similar_identifier_exact_match () =
  let suggestions = suggest_similar_identifier "variable" ["variable"; "variable_1"; "other"] in
  check bool "包含精确匹配" true (List.mem "variable" suggestions);
  check bool "建议数量合理" true (List.length suggestions <= 3)

let test_suggest_similar_identifier_typo () =
  let suggestions = suggest_similar_identifier "variabel" ["variable"; "variables"; "other_var"] in
  check bool "包含相似建议" true (List.mem "variable" suggestions);
  check bool "建议数量合理" true (List.length suggestions <= 3)

let test_suggest_similar_identifier_no_candidates () =
  let suggestions = suggest_similar_identifier "xyz" ["abc"; "def"; "ghi"] in
  check bool "无相似建议时返回空列表" true (List.length suggestions = 0)

let test_suggest_similar_identifier_distance_limit () =
  let suggestions = suggest_similar_identifier "a" ["abcdefgh"; "ijklmnop"] in
  check bool "超过距离限制时不建议" true (List.length suggestions = 0)

let test_suggest_type_fix () =
  let suggestions = suggest_type_fix ~expected:"int" ~actual:"string" in
  check bool "包含期望和实际类型" true (List.length suggestions >= 1);
  check bool "第一条建议包含类型信息" true 
    (String.contains (List.hd suggestions) 'i' && String.contains (List.hd suggestions) 's')

let test_suggest_syntax_fix () =
  let suggestions = suggest_syntax_fix ~expected:";" in
  check bool "包含期望语法" true (List.length suggestions >= 1);
  check bool "第一条建议包含期望内容" true (String.contains (List.hd suggestions) ';')

(** {1 现代错误创建函数测试} *)

let test_create_type_error_basic () =
  try
    create_type_error "类型错误测试";
    check bool "应该抛出异常" false true
  with
  | CompilerError info ->
    (match info.error with
     | TypeError (msg, _) -> 
       check string "错误消息正确" "类型错误测试" msg;
       check (of_pp pp_severity) "严重级别为Error" Error info.severity
     | _ -> check bool "错误类型不匹配" false true)
  | _ -> check bool "异常类型错误" false true

let test_create_type_error_with_position () =
  let pos = create_position ~filename:"test.ly" ~line:5 ~column:10 in
  try
    create_type_error ~pos "带位置的类型错误";
    check bool "应该抛出异常" false true
  with
  | CompilerError info ->
    (match info.error with
     | TypeError (_, Some position) -> 
       check string "位置文件名正确" "test.ly" position.filename;
       check int "位置行号正确" 5 position.line
     | _ -> check bool "错误格式不匹配" false true)
  | _ -> check bool "异常类型错误" false true

let test_create_type_error_with_suggestions () =
  try
    create_type_error "类型错误" ~suggestions:["建议1"; "建议2"];
    check bool "应该抛出异常" false true
  with
  | CompilerError info ->
    check bool "建议数量正确" true (List.length info.suggestions = 2);
    check bool "包含正确建议" true (List.mem "建议1" info.suggestions)
  | _ -> check bool "异常类型错误" false true

let test_create_parse_error () =
  let pos = create_position ~filename:"parse.ly" ~line:3 ~column:7 in
  try
    create_parse_error ~pos "解析错误测试";
    check bool "应该抛出异常" false true
  with
  | CompilerError info ->
    (match info.error with
     | ParseError (msg, position) -> 
       check string "错误消息正确" "解析错误测试" msg;
       check string "位置文件名正确" "parse.ly" position.filename
     | _ -> check bool "错误类型不匹配" false true)
  | _ -> check bool "异常类型错误" false true

let test_create_syntax_error () =
  let pos = create_position ~filename:"syntax.ly" ~line:2 ~column:15 in
  try
    create_syntax_error ~pos "语法错误测试";
    check bool "应该抛出异常" false true
  with
  | CompilerError info ->
    (match info.error with
     | SyntaxError (msg, position) -> 
       check string "错误消息正确" "语法错误测试" msg;
       check int "位置列号正确" 15 position.column
     | _ -> check bool "错误类型不匹配" false true)
  | _ -> check bool "异常类型错误" false true

let test_create_semantic_error_with_context () =
  try
    create_semantic_error "语义错误测试" ~context:"函数定义";
    check bool "应该抛出异常" false true
  with
  | CompilerError info ->
    (match info.error with
     | SemanticError (msg, _) -> 
       check string "错误消息正确" "语义错误测试" msg;
       check (option string) "上下文正确" (Some "函数定义") info.context
     | _ -> check bool "错误类型不匹配" false true)
  | _ -> check bool "异常类型错误" false true

let test_create_codegen_error () =
  try
    create_codegen_error ~context:"C代码生成" "代码生成错误测试";
    check bool "应该抛出异常" false true
  with
  | CompilerError info ->
    (match info.error with
     | CodegenError (msg, context) -> 
       check string "错误消息正确" "代码生成错误测试" msg;
       check string "上下文正确" "C代码生成" context
     | _ -> check bool "错误类型不匹配" false true)
  | _ -> check bool "异常类型错误" false true

let test_create_runtime_error () =
  try
    create_runtime_error "运行时错误测试";
    check bool "应该抛出异常" false true
  with
  | CompilerError info ->
    (match info.error with
     | RuntimeError (msg, _) -> 
       check string "错误消息正确" "运行时错误测试" msg;
       check (of_pp pp_severity) "严重级别为Error" Error info.severity
     | _ -> check bool "错误类型不匹配" false true)
  | _ -> check bool "异常类型错误" false true

(** {1 遗留异常适配器测试} *)

let test_legacy_type_error () =
  try
    legacy_type_error "遗留类型错误";
    check bool "应该抛出异常" false true
  with
  | CompilerError info ->
    (match info.error with
     | TypeError (msg, _) -> 
       check string "错误消息正确" "遗留类型错误" msg;
       check bool "包含建议" true (List.length info.suggestions > 0)
     | _ -> check bool "错误类型不匹配" false true)
  | _ -> check bool "异常类型错误" false true

let test_legacy_parse_error () =
  try
    legacy_parse_error "遗留解析错误" 8 20;
    check bool "应该抛出异常" false true
  with
  | CompilerError info ->
    (match info.error with
     | ParseError (msg, position) -> 
       check string "错误消息正确" "遗留解析错误" msg;
       check int "位置行号正确" 8 position.line;
       check int "位置列号正确" 20 position.column;
       check bool "包含建议" true (List.length info.suggestions > 0)
     | _ -> check bool "错误类型不匹配" false true)
  | _ -> check bool "异常类型错误" false true

let test_legacy_codegen_error () =
  try
    legacy_codegen_error "遗留代码生成错误" "遗留上下文";
    check bool "应该抛出异常" false true
  with
  | CompilerError info ->
    (match info.error with
     | CodegenError (msg, context) -> 
       check string "错误消息正确" "遗留代码生成错误" msg;
       check string "上下文正确" "遗留上下文" context;
       check bool "包含建议" true (List.length info.suggestions > 0)
     | _ -> check bool "错误类型不匹配" false true)
  | _ -> check bool "异常类型错误" false true

let test_legacy_semantic_error () =
  try
    legacy_semantic_error "遗留语义错误" "遗留语义上下文";
    check bool "应该抛出异常" false true
  with
  | CompilerError info ->
    (match info.error with
     | SemanticError (msg, _) -> 
       check string "错误消息正确" "遗留语义错误" msg;
       check (option string) "上下文正确" (Some "遗留语义上下文") info.context;
       check bool "包含建议" true (List.length info.suggestions > 0)
     | _ -> check bool "错误类型不匹配" false true)
  | _ -> check bool "异常类型错误" false true

(** {1 错误处理综合测试} *)

let test_error_compatibility_integration () =
  (* 测试不同错误类型的统一处理 *)
  let handle_error f expected_error_type =
    try
      f ();
      check bool "应该抛出异常" false true
    with
    | CompilerError info ->
      (match info.error, expected_error_type with
       | TypeError _, `Type -> check bool "类型错误匹配" true true
       | ParseError _, `Parse -> check bool "解析错误匹配" true true
       | SyntaxError _, `Syntax -> check bool "语法错误匹配" true true
       | SemanticError _, `Semantic -> check bool "语义错误匹配" true true
       | CodegenError _, `Codegen -> check bool "代码生成错误匹配" true true
       | RuntimeError _, `Runtime -> check bool "运行时错误匹配" true true
       | _ -> check bool "错误类型不匹配" false true)
    | _ -> check bool "异常类型错误" false true
  in
  
  handle_error (fun () -> legacy_type_error "测试") `Type;
  handle_error (fun () -> legacy_parse_error "测试" 1 1) `Parse;
  handle_error (fun () -> legacy_codegen_error "测试" "上下文") `Codegen;
  handle_error (fun () -> legacy_semantic_error "测试" "语义") `Semantic

(** {1 性能和边界测试} *)

let test_large_candidate_list () =
  (* 测试大量候选项的建议性能 *)
  let large_candidates = List.init 1000 (fun i -> Printf.sprintf "var_%d" i) in
  let suggestions = suggest_similar_identifier "var_1" large_candidates in
  check bool "大量候选项时建议数量合理" true (List.length suggestions <= 3);
  check bool "包含正确建议" true (List.mem "var_1" suggestions)

let test_empty_error_message () =
  try
    create_type_error "";
    check bool "应该抛出异常" false true
  with
  | CompilerError info ->
    (match info.error with
     | TypeError (msg, _) -> check string "空消息处理正确" "" msg
     | _ -> check bool "错误类型不匹配" false true)
  | _ -> check bool "异常类型错误" false true

let test_unicode_error_messages () =
  try
    create_type_error "类型错误：中文测试 🚫";
    check bool "应该抛出异常" false true
  with
  | CompilerError info ->
    (match info.error with
     | TypeError (msg, _) -> 
       check bool "Unicode消息处理正确" true (String.length msg > 0)
     | _ -> check bool "错误类型不匹配" false true)
  | _ -> check bool "异常类型错误" false true

(** {1 测试套件} *)

let () =
  run "错误兼容性模块综合测试"
    [
      ( "位置信息工具",
        [
          test_case "创建位置信息" `Quick test_create_position;
          test_case "从行列号创建位置" `Quick test_position_from_line_col;
          test_case "未知位置创建" `Quick test_unknown_position;
        ] );
      ( "错误建议系统",
        [
          test_case "精确匹配建议" `Quick test_suggest_similar_identifier_exact_match;
          test_case "拼写错误建议" `Quick test_suggest_similar_identifier_typo;
          test_case "无候选项处理" `Quick test_suggest_similar_identifier_no_candidates;
          test_case "距离限制测试" `Quick test_suggest_similar_identifier_distance_limit;
          test_case "类型修复建议" `Quick test_suggest_type_fix;
          test_case "语法修复建议" `Quick test_suggest_syntax_fix;
        ] );
      ( "现代错误创建",
        [
          test_case "基本类型错误" `Quick test_create_type_error_basic;
          test_case "带位置类型错误" `Quick test_create_type_error_with_position;
          test_case "带建议类型错误" `Quick test_create_type_error_with_suggestions;
          test_case "解析错误创建" `Quick test_create_parse_error;
          test_case "语法错误创建" `Quick test_create_syntax_error;
          test_case "带上下文语义错误" `Quick test_create_semantic_error_with_context;
          test_case "代码生成错误创建" `Quick test_create_codegen_error;
          test_case "运行时错误创建" `Quick test_create_runtime_error;
        ] );
      ( "遗留适配器",
        [
          test_case "遗留类型错误适配" `Quick test_legacy_type_error;
          test_case "遗留解析错误适配" `Quick test_legacy_parse_error;
          test_case "遗留代码生成错误适配" `Quick test_legacy_codegen_error;
          test_case "遗留语义错误适配" `Quick test_legacy_semantic_error;
        ] );
      ( "综合测试",
        [
          test_case "错误兼容性集成" `Quick test_error_compatibility_integration;
          test_case "大候选列表性能" `Quick test_large_candidate_list;
          test_case "空错误消息处理" `Quick test_empty_error_message;
          test_case "Unicode错误消息" `Quick test_unicode_error_messages;
        ] );
    ]