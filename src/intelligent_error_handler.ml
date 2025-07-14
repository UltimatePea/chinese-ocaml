(** 骆言智能错误处理器 - AI驱动的错误解释和修复建议系统 *)

open Error_messages
open Ai.Natural_language

(** 错误上下文信息 *)
type error_context = {
  source_location: string option;
  function_name: string option;
  variable_scope: string list;
  expression_type: string option;
  code_snippet: string option;
}

(** 智能修复建议类型 *)
type fix_strategy =
  | AutoFix of string * string         (* 自动修复：旧代码 -> 新代码 *)
  | SuggestPattern of string * string  (* 建议模式：模式描述 -> 代码模板 *)
  | RefactorHint of string list        (* 重构提示：步骤列表 *)
  | ExampleCode of string * string     (* 示例代码：描述 -> 代码 *)

(** 智能错误解释 *)
type intelligent_explanation = {
  chinese_message: string;
  technical_detail: string;
  cause_analysis: string list;
  impact_assessment: string;
  learning_note: string option;
}

(** AI辅助错误诊断 *)
let diagnose_error_with_ai error_msg error_context =
  (* 使用自然语言处理分析错误信息 *)
  let semantic_units = extract_semantic_units error_msg in
  let error_keywords = List.filter_map (fun unit ->
    match unit.word_type with
    | Verb action -> Some ("动作", action)
    | Noun obj -> Some ("对象", obj)
    | Keyword kw -> Some ("关键字", kw)
    | _ -> None
  ) semantic_units in

  let diagnosis = Buffer.create 512 in
  Buffer.add_string diagnosis "🤖 AI错误诊断:\n\n";

  (* 分析错误类型 *)
  let error_type =
    if List.exists (fun (_, action) -> action = "undefined" || action = "未定义") error_keywords then
      "未定义错误"
    else if List.exists (fun (_, obj) -> obj = "type" || obj = "类型") error_keywords then
      "类型错误"
    else if List.exists (fun (_, obj) -> obj = "function" || obj = "函数") error_keywords then
      "函数错误"
    else
      "语法错误"
  in

  Buffer.add_string diagnosis (Printf.sprintf "📊 错误分类: %s\n" error_type);

  (* 上下文分析 *)
  begin match error_context.source_location with
  | Some loc -> Buffer.add_string diagnosis (Printf.sprintf "📍 源码位置: %s\n" loc)
  | None -> ()
  end;

  begin match error_context.function_name with
  | Some name -> Buffer.add_string diagnosis (Printf.sprintf "🔧 当前函数: %s\n" name)
  | None -> ()
  end;

  if List.length error_context.variable_scope > 0 then
    Buffer.add_string diagnosis (Printf.sprintf "📦 作用域变量: %s\n"
      (String.concat "、" error_context.variable_scope));

  Buffer.add_string diagnosis "\n🧠 语义分析:\n";
  List.iter (fun (category, value) ->
    Buffer.add_string diagnosis (Printf.sprintf "   %s: %s\n" category value)
  ) error_keywords;

  Buffer.contents diagnosis

(** 生成智能修复策略 *)
let generate_fix_strategies error_analysis _error_context =
  let strategies = ref [] in

  (match error_analysis.error_type with
  | "undefined_variable" ->
    (* 自动修复：变量名纠错 *)
    begin match error_analysis.suggestions with
    | suggestion :: _ when String.contains suggestion (String.get "「" 0) ->
      let parts = String.split_on_char (String.get "「" 0) suggestion in
      begin match parts with
      | _ :: rest ->
        let var_parts = String.split_on_char (String.get "」" 0) (String.concat "「" rest) in
        begin match var_parts with
        | var_name :: _ ->
          strategies := AutoFix (
            "错误的变量名",
            Printf.sprintf "使用正确的变量名「%s」" var_name
          ) :: !strategies
        | _ -> ()
        end
      | _ -> ()
      end
    | _ -> ()
    end;

    (* 建议模式：变量定义 *)
    strategies := SuggestPattern (
      "变量定义模式",
      "让 「变量名」 = 值"
    ) :: !strategies;

    (* 示例代码 *)
    strategies := ExampleCode (
      "常见变量定义示例",
      "让 「用户名」 = \"张三\"\n让 「年龄」 = 25\n让 「分数列表」 = [85; 90; 78]"
    ) :: !strategies

  | "type_mismatch" ->
    (* 自动修复：类型转换 *)
    begin match error_analysis.fix_hints with
    | hint :: _ when String.contains hint '(' ->
      strategies := AutoFix (
        "类型不匹配",
        "添加类型转换: " ^ hint
      ) :: !strategies
    | _ -> ()
    end;

    (* 重构提示 *)
    strategies := RefactorHint [
      "检查变量定义时的类型";
      "考虑使用显式类型标注";
      "验证函数参数和返回值类型";
    ] :: !strategies;

    (* 示例代码 *)
    strategies := ExampleCode (
      "类型转换示例",
      "让 「数字字符串」 = \"123\"\n让 「数字」 = 转换为整数 「数字字符串」\n让 「文本」 = 转换为字符串 42"
    ) :: !strategies

  | "function_arity" ->
    (* 建议模式：函数调用 *)
    strategies := SuggestPattern (
      "正确的函数调用模式",
      "函数名 参数1 参数2 参数3"
    ) :: !strategies;

    (* 示例代码 *)
    strategies := ExampleCode (
      "函数定义和调用示例",
      "递归 让 「加法」 = 函数 a b → a + b\n让 「结果」 = 「加法」 10 20"
    ) :: !strategies

  | "pattern_match" ->
    (* 建议模式：完整模式匹配 *)
    strategies := SuggestPattern (
      "完整模式匹配模式",
      "匹配 表达式 与\n｜ 模式1 → 结果1\n｜ 模式2 → 结果2\n｜ _ → 默认结果"
    ) :: !strategies;

    (* 示例代码 *)
    strategies := ExampleCode (
      "模式匹配示例",
      "匹配 「数字」 与\n｜ 0 → \"零\"\n｜ 1 → \"一\"\n｜ _ → \"其他数字\""
    ) :: !strategies

  | _ ->
    (* 通用重构提示 *)
    strategies := (RefactorHint [
      "检查代码语法是否正确";
      "验证变量和函数定义";
      "查看相关文档和示例";
    ]) :: !strategies);

  !strategies

(** 生成智能错误解释 *)
let generate_intelligent_explanation error_type _error_msg _context =
  let explanation = match error_type with
  | "undefined_variable" ->
    {
      chinese_message = "变量未定义错误";
      technical_detail = "编译器在当前作用域中找不到指定的变量名";
      cause_analysis = [
        "变量名可能存在拼写错误";
        "变量可能未在当前作用域中定义";
        "变量可能在定义之前被使用";
      ];
      impact_assessment = "程序无法继续执行，需要修复后才能运行";
      learning_note = Some "在骆言中，所有变量都必须先定义后使用，使用「让」关键字定义变量";
    }

  | "type_mismatch" ->
    {
      chinese_message = "类型不匹配错误";
      technical_detail = "表达式的实际类型与期望类型不符";
      cause_analysis = [
        "函数参数类型与定义不匹配";
        "运算符操作数类型不正确";
        "变量赋值时类型不兼容";
      ];
      impact_assessment = "类型安全检查失败，可能导致运行时错误";
      learning_note = Some "骆言具有静态类型系统，能在编译时发现类型错误，保证程序安全性";
    }

  | "function_arity" ->
    {
      chinese_message = "函数参数数量错误";
      technical_detail = "函数调用时提供的参数数量与函数定义不匹配";
      cause_analysis = [
        "调用函数时遗漏了必需的参数";
        "调用函数时提供了多余的参数";
        "函数定义与调用处理解不一致";
      ];
      impact_assessment = "函数无法正确执行，可能导致逻辑错误";
      learning_note = Some "在骆言中，函数调用必须提供与定义时相同数量的参数";
    }

  | "pattern_match" ->
    {
      chinese_message = "模式匹配不完整错误";
      technical_detail = "模式匹配表达式没有覆盖所有可能的情况";
      cause_analysis = [
        "遗漏了某些可能的匹配模式";
        "没有提供默认的通配符模式";
        "对数据类型的理解不完整";
      ];
      impact_assessment = "运行时可能遇到未处理的情况，导致程序崩溃";
      learning_note = Some "骆言要求模式匹配必须穷尽，这有助于编写更安全的程序";
    }

  | _ ->
    {
      chinese_message = "编程错误";
      technical_detail = "程序中存在语法或逻辑错误";
      cause_analysis = ["需要进一步分析错误的具体原因"];
      impact_assessment = "程序无法正常编译或运行";
      learning_note = None;
    }
  in
  explanation

(** 生成完整的AI错误报告 *)
let generate_ai_error_report error_type error_details context =
  (* 进行智能错误分析 *)
  let analysis = intelligent_error_analysis error_type error_details context in

  (* 生成智能解释 *)
  let explanation = generate_intelligent_explanation error_type analysis.error_message context in

  (* 生成修复策略 *)
  let strategies = generate_fix_strategies analysis {
    source_location = context;
    function_name = None;
    variable_scope = [];
    expression_type = None;
    code_snippet = None
  } in

  (* AI诊断 *)
  let ai_diagnosis = diagnose_error_with_ai analysis.error_message {
    source_location = context;
    function_name = None;
    variable_scope = [];
    expression_type = None;
    code_snippet = None
  } in

  let buffer = Buffer.create 1024 in

  (* 基础错误信息 *)
  Buffer.add_string buffer (generate_intelligent_error_report analysis);
  Buffer.add_string buffer "\n";

  (* AI诊断 *)
  Buffer.add_string buffer ai_diagnosis;
  Buffer.add_string buffer "\n";

  (* 智能解释 *)
  Buffer.add_string buffer "📚 智能解释:\n";
  Buffer.add_string buffer (Printf.sprintf "   类型: %s\n" explanation.chinese_message);
  Buffer.add_string buffer (Printf.sprintf "   详情: %s\n" explanation.technical_detail);
  Buffer.add_string buffer "   原因分析:\n";
  List.iteri (fun i cause ->
    Buffer.add_string buffer (Printf.sprintf "      %d. %s\n" (i + 1) cause)
  ) explanation.cause_analysis;
  Buffer.add_string buffer (Printf.sprintf "   影响评估: %s\n" explanation.impact_assessment);
  begin match explanation.learning_note with
  | Some note -> Buffer.add_string buffer (Printf.sprintf "   💡 学习提示: %s\n" note)
  | None -> ()
  end;
  Buffer.add_string buffer "\n";

  (* 修复策略 *)
  if List.length strategies > 0 then begin
    Buffer.add_string buffer "🛠️ AI修复策略:\n";
    List.iteri (fun i strategy ->
      match strategy with
      | AutoFix (desc, fix) ->
        Buffer.add_string buffer (Printf.sprintf "   %d. [自动修复] %s\n      → %s\n" (i + 1) desc fix)
      | SuggestPattern (desc, pattern) ->
        Buffer.add_string buffer (Printf.sprintf "   %d. [建议模式] %s\n      → %s\n" (i + 1) desc pattern)
      | RefactorHint hints ->
        Buffer.add_string buffer (Printf.sprintf "   %d. [重构提示]\n" (i + 1));
        List.iter (fun hint ->
          Buffer.add_string buffer (Printf.sprintf "      • %s\n" hint)
        ) hints
      | ExampleCode (desc, code) ->
        Buffer.add_string buffer (Printf.sprintf "   %d. [示例代码] %s\n" (i + 1) desc);
        let lines = String.split_on_char '\n' code in
        List.iter (fun line ->
          Buffer.add_string buffer (Printf.sprintf "      %s\n" line)
        ) lines
    ) strategies;
    Buffer.add_string buffer "\n"
  end;

  Buffer.contents buffer

(** 测试智能错误处理功能 *)
let test_intelligent_error_handler () =
  Printf.printf "=== 智能错误处理器测试 ===\n\n";

  let test_cases = [
    ("undefined_variable", ["用户姓名"; "用户名;姓名;年龄;分数"], Some "函数内部");
    ("type_mismatch", ["整数类型"; "字符串类型"], Some "表达式求值");
    ("function_arity", ["2"; "1"; "加法函数"], Some "函数调用");
    ("pattern_match", ["true分支"; "false分支"], Some "匹配表达式");
  ] in

  List.iter (fun (error_type, error_details, context) ->
    Printf.printf "🔍 测试错误类型: %s\n" error_type;
    let report = generate_ai_error_report error_type error_details context in
    Printf.printf "%s\n" report;
    Printf.printf "%s\n" (String.make 80 '-');
  ) test_cases;

  Printf.printf "🎉 智能错误处理器测试完成！\n"