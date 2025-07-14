(** 智能代码重构建议模块 - AI驱动的代码质量改进建议 *)

open Ast

(** 重构建议类型 *)
type refactoring_suggestion = {
  suggestion_type: suggestion_type;
  message: string;
  confidence: float;        (* 置信度 0.0-1.0 *)
  location: string option;  (* 代码位置 *)
  suggested_fix: string option; (* 建议的修复方案 *)
}

(** 建议类型分类 *)
and suggestion_type =
  | DuplicatedCode of string list    (* 重复代码片段，包含重复的函数名或标识符 *)
  | FunctionComplexity of int        (* 函数复杂度，包含计算得出的复杂度值 *)
  | NamingImprovement of string      (* 命名改进建议，包含建议的新名称 *)
  | PerformanceHint of string        (* 性能优化提示，包含具体建议 *)

(** 代码分析上下文 *)
type analysis_context = {
  current_function: string option;    (* 当前分析的函数名 *)
  defined_vars: (string * type_expr option) list;  (* 已定义变量及其类型 *)
  function_calls: string list;        (* 函数调用历史 *)
  nesting_level: int;                (* 嵌套层级 *)
  expression_count: int;              (* 表达式计数 *)
}

(** 初始化分析上下文 *)
let empty_context = {
  current_function = None;
  defined_vars = [];
  function_calls = [];
  nesting_level = 0;
  expression_count = 0;
}

(** 复杂度阈值常量 *)
let max_function_complexity = 15    (* 函数最大复杂度阈值 *)
let max_nesting_level = 5          (* 最大嵌套层级 *)
let min_duplication_threshold = 3   (* 最小重复代码检测阈值 *)

(** 中文编程命名检查规则 *)
let english_pattern = Str.regexp "^[a-zA-Z_][a-zA-Z0-9_]*$"

(** 检查是否为英文命名 *)
let is_english_naming name =
  Str.string_match english_pattern name 0

(** 检查是否为中英文混用 *)
let is_mixed_naming name =
  (* 简化的混用检测 - 检查是否同时包含ASCII字母和非ASCII字符 *)
  let has_chinese = ref false in
  let has_english = ref false in
  for i = 0 to String.length name - 1 do
    let c = name.[i] in
    if (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') then
      has_english := true
    else if Char.code c > 127 then  (* 简化的中文字符检测 *)
      has_chinese := true
  done;
  !has_chinese && !has_english

(** 计算表达式复杂度 *)
let rec calculate_expression_complexity expr context =
  let base_complexity = 1 in
  let nested_complexity = context.nesting_level * 2 in

  match expr with
  | LitExpr _ | VarExpr _ -> base_complexity

  | BinaryOpExpr (left, _, right) ->
    base_complexity +
    (calculate_expression_complexity left context) +
    (calculate_expression_complexity right context)

  | UnaryOpExpr (_, expr) ->
    base_complexity + (calculate_expression_complexity expr context)

  | FunCallExpr (func, args) ->
    base_complexity + 2 +  (* 函数调用额外复杂度 *)
    (calculate_expression_complexity func context) +
    (List.fold_left (fun acc arg ->
      acc + (calculate_expression_complexity arg context)) 0 args)

  | CondExpr (cond, then_expr, else_expr) ->
    let new_context = { context with nesting_level = context.nesting_level + 1 } in
    base_complexity + 3 +  (* 条件表达式额外复杂度 *)
    (calculate_expression_complexity cond context) +
    (calculate_expression_complexity then_expr new_context) +
    (calculate_expression_complexity else_expr new_context)

  | MatchExpr (expr, branches) ->
    let new_context = { context with nesting_level = context.nesting_level + 1 } in
    base_complexity + (List.length branches) + (* 每个分支增加复杂度 *)
    (calculate_expression_complexity expr context) +
    (List.fold_left (fun acc branch ->
      acc + (calculate_expression_complexity branch.expr new_context)) 0 branches)

  | LetExpr (_, val_expr, in_expr) ->
    base_complexity +
    (calculate_expression_complexity val_expr context) +
    (calculate_expression_complexity in_expr context)

  | _ -> base_complexity + nested_complexity

(** 分析函数复杂度 *)
let analyze_function_complexity name expr context =
  let complexity = calculate_expression_complexity expr context in
  if complexity > max_function_complexity then
    Some {
      suggestion_type = FunctionComplexity complexity;
      message = Printf.sprintf "函数「%s」复杂度过高（%d），建议分解为更小的函数" name complexity;
      confidence = 0.85;
      location = Some ("函数 " ^ name);
      suggested_fix = Some (Printf.sprintf "考虑将「%s」分解为%d个更简单的子函数"
                           name (complexity / max_function_complexity + 1));
    }
  else None

(** 分析命名质量 *)
let analyze_naming_quality name =
  let suggestions = ref [] in

  (* 检查英文命名 *)
  if is_english_naming name then
    suggestions := {
      suggestion_type = NamingImprovement ("建议使用中文命名");
      message = Printf.sprintf "变量「%s」使用英文命名，建议改为中文以提高可读性" name;
      confidence = 0.75;
      location = Some ("变量 " ^ name);
      suggested_fix = Some "使用更具描述性的中文名称";
    } :: !suggestions;

  (* 检查中英文混用 *)
  if is_mixed_naming name then
    suggestions := {
      suggestion_type = NamingImprovement ("避免中英文混用");
      message = Printf.sprintf "变量「%s」混用中英文，建议统一使用中文命名" name;
      confidence = 0.80;
      location = Some ("变量 " ^ name);
      suggested_fix = Some "统一使用中文命名风格";
    } :: !suggestions;

  (* 检查常见的不良命名模式 *)
  if String.length name <= 2 && not (List.mem name ["我"; "你"; "他"; "它"]) then
    suggestions := {
      suggestion_type = NamingImprovement ("名称过短");
      message = Printf.sprintf "变量「%s」名称过短，建议使用更具描述性的名称" name;
      confidence = 0.70;
      location = Some ("变量 " ^ name);
      suggested_fix = Some "使用能表达具体含义的名称";
    } :: !suggestions;

  !suggestions

(** 检测重复代码模式 *)
let detect_code_duplication exprs =
  let expr_patterns = Hashtbl.create 16 in
  let suggestions = ref [] in

  (* 简化的表达式模式提取 *)
  let extract_pattern expr =
    match expr with
    | BinaryOpExpr (_, op, _) -> "BinaryOp(" ^ (show_binary_op op) ^ ")"
    | FunCallExpr (VarExpr func_name, _) -> "FunCall(" ^ func_name ^ ")"
    | CondExpr (_, _, _) -> "Conditional"
    | MatchExpr (_, _) -> "PatternMatch"
    | LetExpr (_, _, _) -> "LetBinding"
    | _ -> "Other"
  in

  (* 统计模式出现次数 *)
  List.iter (fun expr ->
    let pattern = extract_pattern expr in
    let count = try Hashtbl.find expr_patterns pattern with Not_found -> 0 in
    Hashtbl.replace expr_patterns pattern (count + 1)
  ) exprs;

  (* 检查重复模式 *)
  Hashtbl.iter (fun pattern count ->
    if count >= min_duplication_threshold then
      suggestions := {
        suggestion_type = DuplicatedCode [];
        message = Printf.sprintf "检测到%d处相似的「%s」模式，建议提取为公共函数" count pattern;
        confidence = 0.75;
        location = Some "多处代码位置";
        suggested_fix = Some (Printf.sprintf "创建「处理%s」函数来消除重复" pattern);
      } :: !suggestions
  ) expr_patterns;

  !suggestions

(** 性能优化建议 *)
let analyze_performance_hints expr _context =
  let suggestions = ref [] in

  let rec analyze_expr expr =
    match expr with
    | FunCallExpr (VarExpr "连接", [ListExpr _; ListExpr _]) ->
      suggestions := {
        suggestion_type = PerformanceHint "列表连接优化";
        message = "检测到列表连接操作，对于大量数据建议使用更高效的方法";
        confidence = 0.65;
        location = Some "列表连接操作";
        suggested_fix = Some "考虑使用累加器模式或专用的列表连接函数";
      } :: !suggestions

    | MatchExpr (_, branches) when List.length branches > 10 ->
      suggestions := {
        suggestion_type = PerformanceHint "大量分支优化";
        message = Printf.sprintf "匹配表达式包含%d个分支，可能影响性能" (List.length branches);
        confidence = 0.70;
        location = Some "模式匹配";
        suggested_fix = Some "考虑使用哈希表或重构为更少的分支";
      } :: !suggestions

    | CondExpr (_, then_expr, else_expr) ->
      analyze_expr then_expr;
      analyze_expr else_expr

    | BinaryOpExpr (left, _, right) ->
      analyze_expr left;
      analyze_expr right

    | FunCallExpr (func, args) ->
      analyze_expr func;
      List.iter analyze_expr args

    | _ -> ()
  in

  analyze_expr expr;
  !suggestions

(** 主要分析函数 - 分析单个表达式 *)
let analyze_expression expr context =
  let suggestions = ref [] in

  let rec analyze expr ctx =
    (* 更新表达式计数 *)
    let new_ctx = { ctx with expression_count = ctx.expression_count + 1 } in

    match expr with
    | VarExpr name ->
      suggestions := (analyze_naming_quality name) @ !suggestions

    | LetExpr (name, val_expr, in_expr) ->
      suggestions := (analyze_naming_quality name) @ !suggestions;
      let new_ctx = { new_ctx with defined_vars = (name, None) :: new_ctx.defined_vars } in
      analyze val_expr new_ctx;
      analyze in_expr new_ctx

    | FunExpr (params, body) ->
      let param_suggestions = List.fold_left (fun acc param ->
        (analyze_naming_quality param) @ acc
      ) [] params in
      suggestions := param_suggestions @ !suggestions;

      let new_ctx = { new_ctx with
        defined_vars = (List.map (fun p -> (p, None)) params) @ new_ctx.defined_vars;
        nesting_level = new_ctx.nesting_level + 1;
      } in
      analyze body new_ctx

    | CondExpr (cond, then_expr, else_expr) ->
      let new_ctx = { new_ctx with nesting_level = new_ctx.nesting_level + 1 } in
      analyze cond new_ctx;
      analyze then_expr new_ctx;
      analyze else_expr new_ctx;

      (* 检查嵌套过深 *)
      if new_ctx.nesting_level > max_nesting_level then
        suggestions := {
          suggestion_type = FunctionComplexity new_ctx.nesting_level;
          message = Printf.sprintf "嵌套层级过深（%d层），建议重构以提高可读性" new_ctx.nesting_level;
          confidence = 0.80;
          location = Some "条件表达式";
          suggested_fix = Some "考虑提取嵌套逻辑为独立函数";
        } :: !suggestions

    | FunCallExpr (func, args) ->
      analyze func new_ctx;
      List.iter (fun arg -> analyze arg new_ctx) args

    | MatchExpr (matched_expr, branches) ->
      analyze matched_expr new_ctx;
      let new_ctx = { new_ctx with nesting_level = new_ctx.nesting_level + 1 } in
      List.iter (fun branch -> analyze branch.expr new_ctx) branches

    | BinaryOpExpr (left, _, right) ->
      analyze left new_ctx;
      analyze right new_ctx

    | UnaryOpExpr (_, expr) ->
      analyze expr new_ctx

    | _ -> () (* 其他表达式类型的基础处理 *)
  in

  analyze expr context;
  !suggestions

(** 分析语句 *)
let analyze_statement stmt context =
  match stmt with
  | ExprStmt expr -> analyze_expression expr context
  | LetStmt (name, expr) ->
    let naming_suggestions = analyze_naming_quality name in
    let expr_suggestions = analyze_expression expr context in
    naming_suggestions @ expr_suggestions
  | RecLetStmt (name, expr) ->
    let naming_suggestions = analyze_naming_quality name in
    let new_context = { context with current_function = Some name } in
    let complexity_suggestion = match analyze_function_complexity name expr new_context with
      | Some s -> [s]
      | None -> []
    in
    let expr_suggestions = analyze_expression expr new_context in
    naming_suggestions @ complexity_suggestion @ expr_suggestions
  | _ -> []

(** 分析整个程序 *)
let analyze_program program =
  let all_suggestions = ref [] in
  let context = ref empty_context in

  (* 收集所有表达式用于重复代码检测 *)
  let all_expressions = ref [] in

  let collect_expressions = function
    | ExprStmt expr -> all_expressions := expr :: !all_expressions
    | LetStmt (_, expr) -> all_expressions := expr :: !all_expressions
    | RecLetStmt (_, expr) -> all_expressions := expr :: !all_expressions
    | _ -> ()
  in

  (* 分析每个语句 *)
  List.iter (fun stmt ->
    collect_expressions stmt;
    let stmt_suggestions = analyze_statement stmt !context in
    all_suggestions := stmt_suggestions @ !all_suggestions
  ) program;

  (* 进行重复代码检测 *)
  let duplication_suggestions = detect_code_duplication !all_expressions in
  all_suggestions := duplication_suggestions @ !all_suggestions;

  (* 按置信度排序建议 *)
  List.sort (fun a b -> compare b.confidence a.confidence) !all_suggestions

(** 格式化输出建议 *)
let format_suggestion suggestion =
  let type_prefix = match suggestion.suggestion_type with
    | DuplicatedCode _ -> "🔄 [重复代码]"
    | FunctionComplexity _ -> "⚡ [复杂度]"
    | NamingImprovement _ -> "📝 [命名]"
    | PerformanceHint _ -> "🚀 [性能]"
  in

  let confidence_text = Printf.sprintf "置信度: %.0f%%" (suggestion.confidence *. 100.0) in
  let location_text = match suggestion.location with
    | Some loc -> " [位置: " ^ loc ^ "]"
    | None -> ""
  in
  let fix_text = match suggestion.suggested_fix with
    | Some fix -> "\n   💡 建议: " ^ fix
    | None -> ""
  in

  Printf.sprintf "%s %s (%s)%s%s"
    type_prefix
    suggestion.message
    confidence_text
    location_text
    fix_text

(** 生成重构报告 *)
let generate_refactoring_report suggestions =
  let total_count = List.length suggestions in
  let high_confidence = List.filter (fun s -> s.confidence >= 0.8) suggestions in
  let medium_confidence = List.filter (fun s -> s.confidence >= 0.6 && s.confidence < 0.8) suggestions in
  let low_confidence = List.filter (fun s -> s.confidence < 0.6) suggestions in

  let report = Buffer.create 1024 in

  Buffer.add_string report "📋 智能代码重构建议报告\n";
  Buffer.add_string report "========================================\n\n";

  Buffer.add_string report (Printf.sprintf "📊 建议统计:\n");
  Buffer.add_string report (Printf.sprintf "   🚨 高置信度: %d 个\n" (List.length high_confidence));
  Buffer.add_string report (Printf.sprintf "   ⚠️ 中置信度: %d 个\n" (List.length medium_confidence));
  Buffer.add_string report (Printf.sprintf "   💡 低置信度: %d 个\n" (List.length low_confidence));
  Buffer.add_string report (Printf.sprintf "   📈 总计: %d 个建议\n\n" total_count);

  if total_count > 0 then (
    Buffer.add_string report "📝 详细建议:\n\n";
    List.iteri (fun i suggestion ->
      Buffer.add_string report (Printf.sprintf "%d. %s\n\n" (i + 1) (format_suggestion suggestion))
    ) suggestions;

    Buffer.add_string report "🛠️ 优先级建议:\n";
    if List.length high_confidence > 0 then
      Buffer.add_string report "   1. 优先处理高置信度建议，这些对代码质量影响最大\n";
    if List.length medium_confidence > 0 then
      Buffer.add_string report "   2. 考虑中置信度建议，可以进一步提升代码质量\n";
    if List.length low_confidence > 0 then
      Buffer.add_string report "   3. 评估低置信度建议，根据实际情况选择性应用\n";
  ) else (
    Buffer.add_string report "✅ 恭喜！您的代码质量很好，没有发现需要重构的问题。\n";
  );

  Buffer.add_string report "\n---\n";
  Buffer.add_string report "🤖 Generated with 智能代码重构建议系统\n";

  Buffer.contents report