(** 测试修复后的策略模式是否正确工作 
    验证Issue #1335中的代码重复问题已解决 *)

open Yyocamlc_lib.Token_conversion_keywords_refactored
open Yyocamlc_lib.Token_mapping.Token_definitions_unified
open Yyocamlc_lib.Lexer_tokens

(** 测试用例：基础语言关键字 *)
let test_basic_tokens = [
  (LetKeyword, "let");
  (FunKeyword, "fun");
  (IfKeyword, "if");
  (ThenKeyword, "then");
  (ElseKeyword, "else");
]

(** 测试用例：其他类型关键字 *)
let test_other_tokens = [
  (AsKeyword, "as");  (* 语义关键字 *)
  (TryKeyword, "try");  (* 错误恢复关键字 *)
  (ModuleKeyword, "module");  (* 模块系统关键字 *)
  (DefineKeyword, "define");  (* 自然语言关键字 *)
  (HaveKeyword, "have");  (* 文言文关键字 *)
  (AncientDefineKeyword, "ancient_define");  (* 古雅体关键字 *)
]

let all_test_tokens = test_basic_tokens @ test_other_tokens

(** 测试两种策略是否产生相同结果 *)
let test_strategy_consistency () =
  Printf.printf "测试策略一致性...\n";
  let failures = ref [] in
  
  List.iter (fun (token, name) ->
    try
      let readable_result = convert_with_strategy Readable token in
      let fast_result = convert_with_strategy Fast token in
      
      if readable_result = fast_result then
        Printf.printf "✅ %s: 两种策略结果一致\n" name
      else begin
        Printf.printf "❌ %s: 策略结果不一致!\n" name;
        failures := name :: !failures
      end
    with
    | Unknown_keyword_token msg ->
        Printf.printf "⚠️  %s: 无法转换 - %s\n" name msg;
        failures := name :: !failures
  ) all_test_tokens;
  
  if !failures = [] then begin
    Printf.printf "\n🎉 所有测试通过！两种策略产生相同结果。\n";
    true
  end else begin
    Printf.printf "\n💥 发现%d个失败案例: %s\n" 
      (List.length !failures) 
      (String.concat ", " !failures);
    false
  end

(** 测试向后兼容性 *)
let test_backward_compatibility () =
  Printf.printf "\n测试向后兼容性...\n";
  let failures = ref [] in
  
  List.iter (fun (token, name) ->
    try
      let old_result = convert_basic_keyword_token token in
      let new_result = convert_with_strategy Readable token in
      let opt_result = convert_basic_keyword_token_optimized token in
      
      if old_result = new_result && new_result = opt_result then
        Printf.printf "✅ %s: 向后兼容性保持\n" name
      else begin
        Printf.printf "❌ %s: 向后兼容性破坏!\n" name;
        failures := name :: !failures
      end
    with
    | Unknown_keyword_token msg ->
        Printf.printf "⚠️  %s: 转换异常 - %s\n" name msg;
        failures := name :: !failures
  ) all_test_tokens;
  
  if !failures = [] then begin
    Printf.printf "\n🎉 向后兼容性测试通过！\n";
    true
  end else begin
    Printf.printf "\n💥 向后兼容性测试失败: %s\n" 
      (String.concat ", " !failures);
    false
  end

(** 主测试函数 *)
let main () =
  Printf.printf "=== Token转换策略修复验证 ===\n\n";
  
  let strategy_ok = test_strategy_consistency () in
  let compat_ok = test_backward_compatibility () in
  
  if strategy_ok && compat_ok then begin
    Printf.printf "\n🎊 所有测试通过！代码重复问题已修复。\n";
    Printf.printf "✅ Issue #1335第1项（代码重复问题）已解决\n";
    exit 0
  end else begin
    Printf.printf "\n💥 测试失败！需要进一步修复。\n";
    exit 1
  end

let () = main ()