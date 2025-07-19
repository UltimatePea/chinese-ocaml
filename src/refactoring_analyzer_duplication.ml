(** 重复代码检测分析器模块 - 专门检测和分析代码重复模式 *)

open Ast
open Refactoring_analyzer_types

type expression_pattern = {
  pattern_name : string;
  pattern_signature : string;
  complexity_weight : int;
}
(** 表达式模式类型 *)

(** 提取表达式的结构模式 *)
let extract_expression_pattern expr =
  let rec analyze_structure expr =
    match expr with
    | LitExpr _ -> "Literal"
    | VarExpr _ -> "Variable"
    | BinaryOpExpr (left, op, right) ->
        let left_pattern = analyze_structure left in
        let right_pattern = analyze_structure right in
        Unified_logger.Legacy.sprintf "BinaryOp(%s,%s,%s)" left_pattern (show_binary_op op)
          right_pattern
    | UnaryOpExpr (op, expr) ->
        let expr_pattern = analyze_structure expr in
        Unified_logger.Legacy.sprintf "UnaryOp(%s,%s)" (show_unary_op op) expr_pattern
    | FunCallExpr (VarExpr func_name, args) ->
        let args_patterns = List.map analyze_structure args in
        let args_str = String.concat "," args_patterns in
        Unified_logger.Legacy.sprintf "FunCall(%s,[%s])" func_name args_str
    | FunCallExpr (func, args) ->
        let func_pattern = analyze_structure func in
        let args_patterns = List.map analyze_structure args in
        let args_str = String.concat "," args_patterns in
        Unified_logger.Legacy.sprintf "FunCall(%s,[%s])" func_pattern args_str
    | CondExpr (_, _, _) -> "Conditional"
    | MatchExpr (_, branches) -> Unified_logger.Legacy.sprintf "Match(%d)" (List.length branches)
    | LetExpr (_, _, _) -> "LetBinding"
    | FunExpr (params, _) -> Unified_logger.Legacy.sprintf "Function(%d)" (List.length params)
    | ListExpr exprs -> Unified_logger.Legacy.sprintf "List(%d)" (List.length exprs)
    | RecordExpr fields -> Unified_logger.Legacy.sprintf "Record(%d)" (List.length fields)
    | _ -> "Other"
  in
  let pattern_signature = analyze_structure expr in
  let complexity_weight =
    match expr with
    | BinaryOpExpr _ -> 2
    | FunCallExpr _ -> 3
    | CondExpr _ -> 4
    | MatchExpr _ -> 5
    | LetExpr _ -> 3
    | FunExpr _ -> 4
    | _ -> 1
  in
  { pattern_name = pattern_signature; pattern_signature; complexity_weight }

(** 检测简单的重复代码模式 *)
let detect_simple_duplication exprs =
  let expr_patterns = Hashtbl.create 16 in
  let suggestions = ref [] in

  (* 简化的表达式模式提取 *)
  let extract_simple_pattern expr =
    match expr with
    | BinaryOpExpr (_, op, _) -> "BinaryOp(" ^ show_binary_op op ^ ")"
    | FunCallExpr (VarExpr func_name, _) -> "FunCall(" ^ func_name ^ ")"
    | CondExpr (_, _, _) -> "Conditional"
    | MatchExpr (_, _) -> "PatternMatch"
    | LetExpr (_, _, _) -> "LetBinding"
    | _ -> "Other"
  in

  (* 统计模式出现次数 *)
  List.iter
    (fun expr ->
      let pattern = extract_simple_pattern expr in
      let count = try Hashtbl.find expr_patterns pattern with Not_found -> 0 in
      Hashtbl.replace expr_patterns pattern (count + 1))
    exprs;

  (* 检查重复模式 *)
  Hashtbl.iter
    (fun pattern count ->
      if count >= Config.min_duplication_threshold then
        suggestions :=
          {
            suggestion_type = DuplicatedCode [];
            message = Unified_logger.Legacy.sprintf "检测到%d处相似的「%s」模式，建议提取为公共函数" count pattern;
            confidence = 0.75;
            location = Some "多处代码位置";
            suggested_fix = Some (Unified_logger.Legacy.sprintf "创建「处理%s」函数来消除重复" pattern);
          }
          :: !suggestions)
    expr_patterns;

  !suggestions

(** 检测结构相似的重复代码 *)
let detect_structural_duplication exprs =
  let pattern_groups = Hashtbl.create 32 in
  let suggestions = ref [] in

  (* 按结构模式分组 *)
  List.iter
    (fun expr ->
      let pattern = extract_expression_pattern expr in
      let existing =
        try Hashtbl.find pattern_groups pattern.pattern_signature with Not_found -> []
      in
      Hashtbl.replace pattern_groups pattern.pattern_signature (expr :: existing))
    exprs;

  (* 检查每个组的重复数量 *)
  Hashtbl.iter
    (fun pattern_sig exprs_list ->
      let count = List.length exprs_list in
      if count >= Config.min_duplication_threshold then
        let pattern_obj = extract_expression_pattern (List.hd exprs_list) in
        let confidence =
          if pattern_obj.complexity_weight >= 3 then 0.85
          else if pattern_obj.complexity_weight >= 2 then 0.75
          else 0.60
        in
        suggestions :=
          {
            suggestion_type = DuplicatedCode [];
            message = Unified_logger.Legacy.sprintf "发现%d处结构相似的代码模式「%s」" count pattern_sig;
            confidence;
            location = Some "多个函数或表达式";
            suggested_fix = Some "考虑提取公共模式为可重用的函数或模块";
          }
          :: !suggestions)
    pattern_groups;

  !suggestions

(** 检测函数级别的重复 *)
let detect_function_duplication function_exprs =
  let suggestions = ref [] in
  let function_patterns = Hashtbl.create 16 in

  (* 为每个函数生成简化的模式签名 *)
  List.iter
    (fun (name, expr) ->
      let pattern = extract_expression_pattern expr in
      let existing =
        try Hashtbl.find function_patterns pattern.pattern_signature with Not_found -> []
      in
      Hashtbl.replace function_patterns pattern.pattern_signature ((name, expr) :: existing))
    function_exprs;

  (* 检查相似的函数 *)
  Hashtbl.iter
    (fun _pattern_sig functions ->
      let count = List.length functions in
      if count >= 2 then
        let function_names = List.map fst functions in
        suggestions :=
          {
            suggestion_type = DuplicatedCode function_names;
            message =
              Unified_logger.Legacy.sprintf "函数 %s 具有相似的结构，可能存在重复逻辑"
                (String.concat "、" function_names);
            confidence = 0.70;
            location = Some ("函数: " ^ String.concat ", " function_names);
            suggested_fix = Some "考虑提取公共逻辑为辅助函数，或使用高阶函数消除重复";
          }
          :: !suggestions)
    function_patterns;

  !suggestions

(** 检测克隆代码（Clone Detection） *)
let detect_code_clones exprs =
  let suggestions = ref [] in

  (* Type-1 克隆: 完全相同的代码（除了空白和注释） *)
  let exact_patterns = Hashtbl.create 16 in

  (* Type-2 克隆: 结构相同但变量名不同的代码 *)
  let structural_patterns = Hashtbl.create 16 in

  List.iter
    (fun expr ->
      (* 生成精确模式 *)
      let exact_pattern = extract_expression_pattern expr in
      let exact_count =
        try Hashtbl.find exact_patterns exact_pattern.pattern_signature with Not_found -> 0
      in
      Hashtbl.replace exact_patterns exact_pattern.pattern_signature (exact_count + 1);

      (* 生成结构模式（忽略具体的变量名和字面量） *)
      let structural_pattern =
        Str.global_replace (Str.regexp "Variable") "VAR" exact_pattern.pattern_signature
        |> Str.global_replace (Str.regexp "Literal") "LIT"
      in
      let struct_count =
        try Hashtbl.find structural_patterns structural_pattern with Not_found -> 0
      in
      Hashtbl.replace structural_patterns structural_pattern (struct_count + 1))
    exprs;

  (* 检查Type-1克隆 *)
  Hashtbl.iter
    (fun _pattern count ->
      if count >= Config.min_duplication_threshold then
        suggestions :=
          {
            suggestion_type = DuplicatedCode [];
            message = Unified_logger.Legacy.sprintf "发现%d处完全相同的代码块" count;
            confidence = 0.95;
            location = Some "多处代码位置";
            suggested_fix = Some "立即提取为公共函数以消除重复";
          }
          :: !suggestions)
    exact_patterns;

  (* 检查Type-2克隆 *)
  Hashtbl.iter
    (fun _pattern count ->
      if count >= Config.min_duplication_threshold then
        suggestions :=
          {
            suggestion_type = DuplicatedCode [];
            message = Unified_logger.Legacy.sprintf "发现%d处结构相同的代码块（变量名可能不同）" count;
            confidence = 0.80;
            location = Some "多处代码位置";
            suggested_fix = Some "考虑参数化公共结构，提取为可配置的函数";
          }
          :: !suggestions)
    structural_patterns;

  !suggestions

(** 综合重复代码检测 *)
let detect_code_duplication exprs =
  let simple_suggestions = detect_simple_duplication exprs in
  let structural_suggestions = detect_structural_duplication exprs in
  let clone_suggestions = detect_code_clones exprs in

  (* 合并所有建议并去重 *)
  let all_suggestions = simple_suggestions @ structural_suggestions @ clone_suggestions in

  (* 按置信度排序 *)
  List.sort (fun a b -> compare b.confidence a.confidence) all_suggestions

(** 分析重复代码的影响 *)
let analyze_duplication_impact suggestions =
  let duplication_suggestions =
    List.filter
      (function { suggestion_type = DuplicatedCode _; _ } -> true | _ -> false)
      suggestions
  in

  let high_impact = List.filter (fun s -> s.confidence >= 0.8) duplication_suggestions in
  let medium_impact =
    List.filter (fun s -> s.confidence >= 0.6 && s.confidence < 0.8) duplication_suggestions
  in
  let low_impact = List.filter (fun s -> s.confidence < 0.6) duplication_suggestions in

  (List.length high_impact, List.length medium_impact, List.length low_impact)

(** 生成重复代码分析报告 *)
let generate_duplication_report suggestions =
  let high_impact, medium_impact, low_impact = analyze_duplication_impact suggestions in
  let total_duplications = high_impact + medium_impact + low_impact in

  let report = Buffer.create (Constants.BufferSizes.default_buffer ()) in

  Buffer.add_string report "🔄 重复代码检测报告\n";
  Buffer.add_string report "========================\n\n";

  Buffer.add_string report (Unified_logger.Legacy.sprintf "📊 重复代码统计:\n");
  Buffer.add_string report (Unified_logger.Legacy.sprintf "   🚨 高影响: %d 个\n" high_impact);
  Buffer.add_string report (Unified_logger.Legacy.sprintf "   ⚠️ 中影响: %d 个\n" medium_impact);
  Buffer.add_string report (Unified_logger.Legacy.sprintf "   💡 低影响: %d 个\n" low_impact);
  Buffer.add_string report
    (Unified_logger.Legacy.sprintf "   📈 总计: %d 个重复问题\n\n" total_duplications);

  if total_duplications = 0 then Buffer.add_string report "✅ 恭喜！没有发现明显的代码重复问题。\n"
  else (
    Buffer.add_string report "🛠️ 重复代码优化建议:\n";
    if high_impact > 0 then Buffer.add_string report "   1. 优先处理高影响的重复代码，这些会显著影响维护性\n";
    if medium_impact > 0 then Buffer.add_string report "   2. 考虑重构中等影响的重复代码\n";
    if low_impact > 0 then Buffer.add_string report "   3. 评估低影响的重复代码，根据实际情况决定是否重构\n";

    Buffer.add_string report "\n💡 通用重构策略:\n";
    Buffer.add_string report "   • 提取公共函数消除代码重复\n";
    Buffer.add_string report "   • 使用高阶函数处理相似的逻辑模式\n";
    Buffer.add_string report "   • 考虑引入设计模式（策略模式、模板方法等）\n";
    Buffer.add_string report "   • 参数化重复的代码结构\n");

  Buffer.contents report
