(** 骆言词法分析器基础关键字Token转换模块综合测试
  
    本测试模块提供对 lexer_token_conversion_basic_keywords.ml 的全面测试覆盖。
    
    技术债务改进：测试覆盖率系统性提升计划 - 第四阶段核心组件架构优化 - Fix #954
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-23 *)

open Alcotest
open Yyocamlc_lib
open Lexer_token_conversion_basic_keywords

(** ==================== 测试辅助函数 ==================== *)

(** 创建所有需要测试的token对映射 *)
let get_all_basic_keyword_mappings () = [
  (* 基础关键字 *)
  (Token_mapping.Token_definitions_unified.LetKeyword, Lexer_tokens.LetKeyword, "let关键字");
  (Token_mapping.Token_definitions_unified.RecKeyword, Lexer_tokens.RecKeyword, "rec关键字");
  (Token_mapping.Token_definitions_unified.InKeyword, Lexer_tokens.InKeyword, "in关键字");
  (Token_mapping.Token_definitions_unified.FunKeyword, Lexer_tokens.FunKeyword, "fun关键字");
  (Token_mapping.Token_definitions_unified.IfKeyword, Lexer_tokens.IfKeyword, "if关键字");
  (Token_mapping.Token_definitions_unified.ThenKeyword, Lexer_tokens.ThenKeyword, "then关键字");
  (Token_mapping.Token_definitions_unified.ElseKeyword, Lexer_tokens.ElseKeyword, "else关键字");
  (Token_mapping.Token_definitions_unified.MatchKeyword, Lexer_tokens.MatchKeyword, "match关键字");
  (Token_mapping.Token_definitions_unified.WithKeyword, Lexer_tokens.WithKeyword, "with关键字");
  (Token_mapping.Token_definitions_unified.OtherKeyword, Lexer_tokens.OtherKeyword, "other关键字");
  (Token_mapping.Token_definitions_unified.AndKeyword, Lexer_tokens.AndKeyword, "and关键字");
  (Token_mapping.Token_definitions_unified.OrKeyword, Lexer_tokens.OrKeyword, "or关键字");
  (Token_mapping.Token_definitions_unified.NotKeyword, Lexer_tokens.NotKeyword, "not关键字");
  (Token_mapping.Token_definitions_unified.OfKeyword, Lexer_tokens.OfKeyword, "of关键字");
  
  (* 语义关键字 *)
  (Token_mapping.Token_definitions_unified.AsKeyword, Lexer_tokens.AsKeyword, "as关键字");
  (Token_mapping.Token_definitions_unified.CombineKeyword, Lexer_tokens.CombineKeyword, "combine关键字");
  (Token_mapping.Token_definitions_unified.WithOpKeyword, Lexer_tokens.WithOpKeyword, "withop关键字");
  (Token_mapping.Token_definitions_unified.WhenKeyword, Lexer_tokens.WhenKeyword, "when关键字");
  
  (* 错误恢复关键字 *)
  (Token_mapping.Token_definitions_unified.WithDefaultKeyword, Lexer_tokens.WithDefaultKeyword, "withdefault关键字");
  (Token_mapping.Token_definitions_unified.ExceptionKeyword, Lexer_tokens.ExceptionKeyword, "exception关键字");
  (Token_mapping.Token_definitions_unified.RaiseKeyword, Lexer_tokens.RaiseKeyword, "raise关键字");
  (Token_mapping.Token_definitions_unified.TryKeyword, Lexer_tokens.TryKeyword, "try关键字");
  (Token_mapping.Token_definitions_unified.ModuleKeyword, Lexer_tokens.ModuleKeyword, "module关键字");
  (Token_mapping.Token_definitions_unified.StructKeyword, Lexer_tokens.StructKeyword, "struct关键字");
  (Token_mapping.Token_definitions_unified.SigKeyword, Lexer_tokens.SigKeyword, "sig关键字");
  (Token_mapping.Token_definitions_unified.EndKeyword, Lexer_tokens.EndKeyword, "end关键字");
  (Token_mapping.Token_definitions_unified.OpenKeyword, Lexer_tokens.OpenKeyword, "open关键字");
  (Token_mapping.Token_definitions_unified.IncludeKeyword, Lexer_tokens.IncludeKeyword, "include关键字");
  (Token_mapping.Token_definitions_unified.TypeKeyword, Lexer_tokens.TypeKeyword, "type关键字");
  (Token_mapping.Token_definitions_unified.ValKeyword, Lexer_tokens.ValKeyword, "val关键字");
  (Token_mapping.Token_definitions_unified.ExternalKeyword, Lexer_tokens.ExternalKeyword, "external关键字");
  (Token_mapping.Token_definitions_unified.MutableKeyword, Lexer_tokens.MutableKeyword, "mutable关键字");
  (Token_mapping.Token_definitions_unified.PrivateKeyword, Lexer_tokens.PrivateKeyword, "private关键字");
  (Token_mapping.Token_definitions_unified.VirtualKeyword, Lexer_tokens.VirtualKeyword, "virtual关键字");
  (Token_mapping.Token_definitions_unified.ConstraintKeyword, Lexer_tokens.ConstraintKeyword, "constraint关键字");
  (Token_mapping.Token_definitions_unified.NewKeyword, Lexer_tokens.NewKeyword, "new关键字");
  (Token_mapping.Token_definitions_unified.ClassKeyword, Lexer_tokens.ClassKeyword, "class关键字");
  (Token_mapping.Token_definitions_unified.InheritKeyword, Lexer_tokens.InheritKeyword, "inherit关键字");
  (Token_mapping.Token_definitions_unified.InitializerKeyword, Lexer_tokens.InitializerKeyword, "initializer关键字");
  (Token_mapping.Token_definitions_unified.ObjectKeyword, Lexer_tokens.ObjectKeyword, "object关键字");
  (Token_mapping.Token_definitions_unified.MethodKeyword, Lexer_tokens.MethodKeyword, "method关键字");
  (Token_mapping.Token_definitions_unified.LazyKeyword, Lexer_tokens.LazyKeyword, "lazy关键字");
  (Token_mapping.Token_definitions_unified.AssertKeyword, Lexer_tokens.AssertKeyword, "assert关键字");
  (Token_mapping.Token_definitions_unified.ForKeyword, Lexer_tokens.ForKeyword, "for关键字");
  (Token_mapping.Token_definitions_unified.ToKeyword, Lexer_tokens.ToKeyword, "to关键字");
  (Token_mapping.Token_definitions_unified.DowntoKeyword, Lexer_tokens.DowntoKeyword, "downto关键字");
  (Token_mapping.Token_definitions_unified.WhileKeyword, Lexer_tokens.WhileKeyword, "while关键字");
  (Token_mapping.Token_definitions_unified.DoKeyword, Lexer_tokens.DoKeyword, "do关键字");
  (Token_mapping.Token_definitions_unified.DoneKeyword, Lexer_tokens.DoneKeyword, "done关键字");
  (Token_mapping.Token_definitions_unified.BeginKeyword, Lexer_tokens.BeginKeyword, "begin关键字");
]

(** ==================== 基础关键字转换测试 ==================== *)

(** 测试所有基础关键字的正确转换 *)
let test_all_basic_keyword_conversions () =
  let mappings = get_all_basic_keyword_mappings () in
  List.iter (fun (input_token, expected_output, description) ->
    let actual_output = convert_basic_keyword_token input_token in
    check (module Lexer_tokens) description expected_output actual_output
  ) mappings;
  ()

(** 测试基础控制结构关键字 *)
let test_control_structure_keywords () =
  (* if-then-else结构 *)
  check (module Lexer_tokens) "if关键字转换" Lexer_tokens.IfKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.IfKeyword);
  check (module Lexer_tokens) "then关键字转换" Lexer_tokens.ThenKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.ThenKeyword);
  check (module Lexer_tokens) "else关键字转换" Lexer_tokens.ElseKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.ElseKeyword);
  
  (* match-with结构 *)
  check (module Lexer_tokens) "match关键字转换" Lexer_tokens.MatchKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.MatchKeyword);
  check (module Lexer_tokens) "with关键字转换" Lexer_tokens.WithKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.WithKeyword);
  
  (* let-in结构 *)
  check (module Lexer_tokens) "let关键字转换" Lexer_tokens.LetKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.LetKeyword);
  check (module Lexer_tokens) "in关键字转换" Lexer_tokens.InKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.InKeyword);
  ()

(** 测试函数定义相关关键字 *)
let test_function_definition_keywords () =
  check (module Lexer_tokens) "fun关键字转换" Lexer_tokens.FunKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.FunKeyword);
  check (module Lexer_tokens) "rec关键字转换" Lexer_tokens.RecKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.RecKeyword);
  ()

(** 测试逻辑运算关键字 *)
let test_logical_operator_keywords () =
  check (module Lexer_tokens) "and关键字转换" Lexer_tokens.AndKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.AndKeyword);
  check (module Lexer_tokens) "or关键字转换" Lexer_tokens.OrKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.OrKeyword);
  check (module Lexer_tokens) "not关键字转换" Lexer_tokens.NotKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.NotKeyword);
  ()

(** ==================== 语义关键字转换测试 ==================== *)

(** 测试语义增强关键字 *)
let test_semantic_keywords () =
  check (module Lexer_tokens) "as关键字转换" Lexer_tokens.AsKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.AsKeyword);
  check (module Lexer_tokens) "combine关键字转换" Lexer_tokens.CombineKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.CombineKeyword);
  check (module Lexer_tokens) "withop关键字转换" Lexer_tokens.WithOpKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.WithOpKeyword);
  check (module Lexer_tokens) "when关键字转换" Lexer_tokens.WhenKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.WhenKeyword);
  ()

(** ==================== 错误恢复关键字测试 ==================== *)

(** 测试错误处理相关关键字 *)
let test_error_handling_keywords () =
  check (module Lexer_tokens) "exception关键字转换" Lexer_tokens.ExceptionKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.ExceptionKeyword);
  check (module Lexer_tokens) "raise关键字转换" Lexer_tokens.RaiseKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.RaiseKeyword);
  check (module Lexer_tokens) "try关键字转换" Lexer_tokens.TryKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.TryKeyword);
  check (module Lexer_tokens) "withdefault关键字转换" Lexer_tokens.WithDefaultKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.WithDefaultKeyword);
  ()

(** ==================== 模块系统关键字测试 ==================== *)

(** 测试模块系统相关关键字 *)
let test_module_system_keywords () =
  check (module Lexer_tokens) "module关键字转换" Lexer_tokens.ModuleKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.ModuleKeyword);
  check (module Lexer_tokens) "struct关键字转换" Lexer_tokens.StructKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.StructKeyword);
  check (module Lexer_tokens) "sig关键字转换" Lexer_tokens.SigKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.SigKeyword);
  check (module Lexer_tokens) "end关键字转换" Lexer_tokens.EndKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.EndKeyword);
  check (module Lexer_tokens) "open关键字转换" Lexer_tokens.OpenKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.OpenKeyword);
  check (module Lexer_tokens) "include关键字转换" Lexer_tokens.IncludeKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.IncludeKeyword);
  ()

(** ==================== 类型系统关键字测试 ==================== *)

(** 测试类型系统相关关键字 *)
let test_type_system_keywords () =
  check (module Lexer_tokens) "type关键字转换" Lexer_tokens.TypeKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.TypeKeyword);
  check (module Lexer_tokens) "val关键字转换" Lexer_tokens.ValKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.ValKeyword);
  check (module Lexer_tokens) "external关键字转换" Lexer_tokens.ExternalKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.ExternalKeyword);
  check (module Lexer_tokens) "mutable关键字转换" Lexer_tokens.MutableKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.MutableKeyword);
  check (module Lexer_tokens) "constraint关键字转换" Lexer_tokens.ConstraintKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.ConstraintKeyword);
  ()

(** ==================== 面向对象关键字测试 ==================== *)

(** 测试面向对象编程相关关键字 *)
let test_object_oriented_keywords () =
  check (module Lexer_tokens) "class关键字转换" Lexer_tokens.ClassKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.ClassKeyword);
  check (module Lexer_tokens) "object关键字转换" Lexer_tokens.ObjectKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.ObjectKeyword);
  check (module Lexer_tokens) "method关键字转换" Lexer_tokens.MethodKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.MethodKeyword);
  check (module Lexer_tokens) "new关键字转换" Lexer_tokens.NewKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.NewKeyword);
  check (module Lexer_tokens) "inherit关键字转换" Lexer_tokens.InheritKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.InheritKeyword);
  check (module Lexer_tokens) "initializer关键字转换" Lexer_tokens.InitializerKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.InitializerKeyword);
  check (module Lexer_tokens) "virtual关键字转换" Lexer_tokens.VirtualKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.VirtualKeyword);
  check (module Lexer_tokens) "private关键字转换" Lexer_tokens.PrivateKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.PrivateKeyword);
  ()

(** ==================== 循环控制关键字测试 ==================== *)

(** 测试循环控制相关关键字 *)
let test_loop_control_keywords () =
  check (module Lexer_tokens) "for关键字转换" Lexer_tokens.ForKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.ForKeyword);
  check (module Lexer_tokens) "to关键字转换" Lexer_tokens.ToKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.ToKeyword);
  check (module Lexer_tokens) "downto关键字转换" Lexer_tokens.DowntoKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.DowntoKeyword);
  check (module Lexer_tokens) "while关键字转换" Lexer_tokens.WhileKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.WhileKeyword);
  check (module Lexer_tokens) "do关键字转换" Lexer_tokens.DoKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.DoKeyword);
  check (module Lexer_tokens) "done关键字转换" Lexer_tokens.DoneKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.DoneKeyword);
  ()

(** ==================== 其他实用关键字测试 ==================== *)

(** 测试其他实用关键字 *)
let test_utility_keywords () =
  check (module Lexer_tokens) "of关键字转换" Lexer_tokens.OfKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.OfKeyword);
  check (module Lexer_tokens) "other关键字转换" Lexer_tokens.OtherKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.OtherKeyword);
  check (module Lexer_tokens) "lazy关键字转换" Lexer_tokens.LazyKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.LazyKeyword);
  check (module Lexer_tokens) "assert关键字转换" Lexer_tokens.AssertKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.AssertKeyword);
  check (module Lexer_tokens) "begin关键字转换" Lexer_tokens.BeginKeyword 
    (convert_basic_keyword_token Token_mapping.Token_definitions_unified.BeginKeyword);
  ()

(** ==================== 批量转换测试 ==================== *)

(** 测试批量关键字转换的一致性 *)
let test_batch_conversion_consistency () =
  let test_keywords = [
    Token_mapping.Token_definitions_unified.LetKeyword;
    Token_mapping.Token_definitions_unified.RecKeyword;
    Token_mapping.Token_definitions_unified.InKeyword;
    Token_mapping.Token_definitions_unified.FunKeyword;
    Token_mapping.Token_definitions_unified.IfKeyword;
    Token_mapping.Token_definitions_unified.ThenKeyword;
    Token_mapping.Token_definitions_unified.ElseKeyword;
  ] in
  
  (* 测试多次转换的一致性 *)
  List.iter (fun keyword ->
    let result1 = convert_basic_keyword_token keyword in
    let result2 = convert_basic_keyword_token keyword in
    check (module Lexer_tokens) "转换结果一致性" result1 result2
  ) test_keywords;
  ()

(** ==================== 性能测试 ==================== *)

(** 测试大量转换操作的性能 *)
let test_conversion_performance () =
  let test_keyword = Token_mapping.Token_definitions_unified.LetKeyword in
  let expected_result = Lexer_tokens.LetKeyword in
  
  (* 执行1000次转换操作 *)
  for _ = 1 to 1000 do
    let result = convert_basic_keyword_token test_keyword in
    if result <> expected_result then
      fail "性能测试中发现转换错误"
  done;
  
  check bool "性能测试完成" true true;
  ()

(** ==================== 边界情况测试 ==================== *)

(** 测试所有定义的关键字都能被正确处理 *)
let test_comprehensive_coverage () =
  let all_mappings = get_all_basic_keyword_mappings () in
  let total_keywords = List.length all_mappings in
  
  (* 验证我们测试了足够数量的关键字 *)
  check bool "关键字数量充足" true (total_keywords >= 40);
  
  (* 验证每个关键字转换都不会抛出异常 *)
  List.iter (fun (input_token, _expected, _desc) ->
    try
      ignore (convert_basic_keyword_token input_token);
      ()
    with
    | _ -> fail "关键字转换不应抛出异常"
  ) all_mappings;
  ()

(** ==================== 测试套件定义 ==================== *)

let basic_conversion_tests = [
  test_case "所有基础关键字转换测试" `Quick test_all_basic_keyword_conversions;
  test_case "控制结构关键字测试" `Quick test_control_structure_keywords;
  test_case "函数定义关键字测试" `Quick test_function_definition_keywords;
  test_case "逻辑运算关键字测试" `Quick test_logical_operator_keywords;
]

let semantic_tests = [
  test_case "语义关键字测试" `Quick test_semantic_keywords;
]

let error_handling_tests = [
  test_case "错误处理关键字测试" `Quick test_error_handling_keywords;
]

let module_system_tests = [
  test_case "模块系统关键字测试" `Quick test_module_system_keywords;
  test_case "类型系统关键字测试" `Quick test_type_system_keywords;
]

let object_oriented_tests = [
  test_case "面向对象关键字测试" `Quick test_object_oriented_keywords;
]

let control_flow_tests = [
  test_case "循环控制关键字测试" `Quick test_loop_control_keywords;
  test_case "实用关键字测试" `Quick test_utility_keywords;
]

let advanced_tests = [
  test_case "批量转换一致性测试" `Quick test_batch_conversion_consistency;
  test_case "转换性能测试" `Quick test_conversion_performance;
  test_case "综合覆盖率测试" `Quick test_comprehensive_coverage;
]

(** 主测试运行器 *)
let () = run "Lexer_token_conversion_basic_keywords 综合测试" [
  ("基础转换功能", basic_conversion_tests);
  ("语义关键字", semantic_tests);
  ("错误处理", error_handling_tests);
  ("模块和类型系统", module_system_tests);
  ("面向对象", object_oriented_tests);
  ("控制流程", control_flow_tests);
  ("高级功能测试", advanced_tests);
]