(** Token重复消除效果演示测试 *)

open Yyocamlc_lib.Parser_expressions_token_reducer
open Yyocamlc_lib.Lexer_tokens

(** 演示Token重复消除的效果 *)
let demo_token_deduplication () =
  Printf.printf "=== Token重复消除效果演示 ===\n\n";
  
  (* 模拟解析器表达式中常见的Token序列 *)
  let sample_tokens = [
    (* 关键字重复 *)
    LetKeyword; LetKeyword; LetKeyword; LetKeyword; LetKeyword;
    FunKeyword; FunKeyword; FunKeyword;
    IfKeyword; IfKeyword; IfKeyword; IfKeyword;
    MatchKeyword; MatchKeyword;
    
    (* 文言文关键字重复 *)
    HaveKeyword; HaveKeyword; HaveKeyword;
    SetKeyword; SetKeyword;
    OneKeyword; OneKeyword; OneKeyword; OneKeyword;
    
    (* 古雅体关键字重复 *)
    AncientDefineKeyword; AncientDefineKeyword;
    AncientObserveKeyword; AncientObserveKeyword; AncientObserveKeyword;
    
    (* 运算符重复 *)
    Plus; Plus; Plus; Plus; Plus;
    Minus; Minus; Minus;
    Equal; Equal; Equal; Equal;
    Arrow; Arrow; Arrow;
    
    (* 分隔符重复 *)
    LeftParen; LeftParen; LeftParen; LeftParen; LeftParen; LeftParen;
    RightParen; RightParen; RightParen; RightParen; RightParen; RightParen;
    LeftBracket; LeftBracket; LeftBracket;
    RightBracket; RightBracket; RightBracket;
    Comma; Comma; Comma; Comma; Comma;
    
    (* 中文分隔符重复 *)
    ChineseLeftParen; ChineseLeftParen; ChineseLeftParen;
    ChineseRightParen; ChineseRightParen; ChineseRightParen;
    ChineseComma; ChineseComma;
    
    (* 字面量重复 *)
    IntToken 42; IntToken 100; IntToken 0;
    StringToken "hello"; StringToken "world"; StringToken "test";
    BoolToken true; BoolToken false; BoolToken true;
    ChineseNumberToken "一"; ChineseNumberToken "二"; ChineseNumberToken "三";
    
    (* 标识符重复 *)
    QuotedIdentifierToken "变量"; QuotedIdentifierToken "函数"; QuotedIdentifierToken "参数";
  ] in
  
  Printf.printf "📊 原始Token列表:\n";
  Printf.printf "Token总数: %d\n" (List.length sample_tokens);
  
  (* 显示前20个token作为示例 *)
  Printf.printf "前20个Token示例:\n";
  List.iteri (fun i token ->
    if i < 20 then
      Printf.printf "  %d. %s\n" (i+1) (show_token token)
  ) sample_tokens;
  Printf.printf "  ...\n\n";
  
  (* 分析Token重复情况 *)
  let stats = TokenDeduplication.analyze_token_duplication sample_tokens in
  let report = TokenDeduplication.generate_dedup_report stats in
  Printf.printf "%s\n" report;
  
  (* 演示Token处理器的工作 *)
  Printf.printf "🔧 演示Token分组处理:\n";
  let processor = UnifiedTokenProcessor.default_processor in
  
  Printf.printf "处理前5个不同类型的Token:\n";
  UnifiedTokenProcessor.process_token processor LetKeyword;
  UnifiedTokenProcessor.process_token processor Plus;
  UnifiedTokenProcessor.process_token processor LeftParen;
  UnifiedTokenProcessor.process_token processor (IntToken 42);
  UnifiedTokenProcessor.process_token processor HaveKeyword;
  
  Printf.printf "\n✅ Token重复消除演示完成！\n";
  Printf.printf "通过分组处理，我们将%d个重复的Token调用减少到%d个组处理。\n"
    stats.original_token_count stats.grouped_token_count;
  Printf.printf "重复减少率: %.1f%%\n\n" stats.reduction_percentage

(** 演示解析器表达式专用处理器 *)
let demo_parser_expression_processor () =
  Printf.printf "=== 解析器表达式专用处理器演示 ===\n\n";
  
  let processor = ParserExpressionTokenProcessor.create_expression_processor () in
  
  Printf.printf "🎯 解析器表达式Token处理演示:\n";
  
  (* 模拟解析器表达式中常见的Token处理 *)
  let expression_tokens = [
    LetKeyword; QuotedIdentifierToken "变量"; Equal; IntToken 42;
    IfKeyword; QuotedIdentifierToken "条件"; ThenKeyword; StringToken "结果";
    FunKeyword; QuotedIdentifierToken "函数"; Arrow; IntToken 0;
    HaveKeyword; OneKeyword; NameKeyword; QuotedIdentifierToken "文言变量";
    AncientDefineKeyword; QuotedIdentifierToken "古雅函数";
    Plus; Minus; LeftParen; RightParen; Comma;
  ] in
  
  Printf.printf "处理%d个解析器表达式Token...\n" (List.length expression_tokens);
  UnifiedTokenProcessor.process_token_list processor expression_tokens;
  
  Printf.printf "\n✅ 解析器表达式处理器演示完成！\n\n"

(** 主演示函数 *)
let run_demo () =
  Printf.printf "🚀 开始Token重复消除系统演示...\n\n";
  demo_token_deduplication ();
  demo_parser_expression_processor ();
  Printf.printf "🎉 演示完成！\n";
  Printf.printf "💡 这展示了如何通过Token分组和统一处理来减少解析器表达式中的重复逻辑。\n"

(** 程序入口点 *)
let () = run_demo ()