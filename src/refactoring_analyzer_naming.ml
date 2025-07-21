(** 命名质量分析器模块 - 专门处理中文编程命名规范检查 *)

open Refactoring_analyzer_types

(** 中文编程命名检查规则 *)
let english_pattern = Str.regexp "^[a-zA-Z_][a-zA-Z0-9_]*$"

(** 检查是否为英文命名 *)
let is_english_naming name = Str.string_match english_pattern name 0

(** 检查是否为中英文混用 *)
let is_mixed_naming name =
  (* 简化的混用检测 - 检查是否同时包含ASCII字母和非ASCII字符 *)
  let has_chinese = ref false in
  let has_english = ref false in
  for i = 0 to String.length name - 1 do
    let c = name.[i] in
    if (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') then has_english := true
    else if Char.code c > 127 then (* 简化的中文字符检测 *)
      has_chinese := true
  done;
  !has_chinese && !has_english

(** 检查是否为过短命名 *)
let is_too_short name = String.length name <= 2 && not (List.mem name [ "我"; "你"; "他"; "它" ])

(** 检查是否为常见的无意义命名 *)
let is_meaningless_naming name =
  List.mem name [ "temp"; "tmp"; "data"; "info"; "obj"; "val"; "var"; "x"; "y"; "z" ]

(** 命名检查配置 *)
type naming_check = {
  check_function: string -> bool;
  improvement_type: string;
  message_template: string -> string;
  confidence: float;
  suggested_fix: string;
}

(** 命名检查规则定义 *)
let naming_checks = [
  {
    check_function = is_english_naming;
    improvement_type = "建议使用中文命名";
    message_template = (fun name -> Printf.sprintf "变量「%s」使用英文命名，建议改为中文以提高可读性" name);
    confidence = 0.75;
    suggested_fix = "使用更具描述性的中文名称";
  };
  {
    check_function = is_mixed_naming;
    improvement_type = "避免中英文混用";
    message_template = (fun name -> Printf.sprintf "变量「%s」混用中英文，建议统一使用中文命名" name);
    confidence = 0.80;
    suggested_fix = "统一使用中文命名风格";
  };
  {
    check_function = is_too_short;
    improvement_type = "名称过短";
    message_template = (fun name -> Printf.sprintf "变量「%s」名称过短，建议使用更具描述性的名称" name);
    confidence = 0.70;
    suggested_fix = "使用能表达具体含义的名称";
  };
  {
    check_function = is_meaningless_naming;
    improvement_type = "避免无意义命名";
    message_template = (fun name -> Printf.sprintf "变量「%s」使用了通用名称，建议使用更具体的名称" name);
    confidence = 0.85;
    suggested_fix = "使用能反映变量真实用途的名称";
  };
]

(** 创建命名建议 *)
let create_naming_suggestion name check =
  {
    suggestion_type = NamingImprovement check.improvement_type;
    message = check.message_template name;
    confidence = check.confidence;
    location = Some ("变量 " ^ name);
    suggested_fix = Some check.suggested_fix;
  }

(** 分析命名质量并生成建议 *)
let analyze_naming_quality name =
  List.fold_left (fun acc check ->
    if check.check_function name then
      create_naming_suggestion name check :: acc
    else
      acc
  ) [] naming_checks

(** 批量分析多个名称的命名质量 *)
let analyze_multiple_names names =
  List.fold_left (fun acc name -> List.rev_append (analyze_naming_quality name) acc) [] names

(** 获取命名建议的统计信息 *)
let get_naming_statistics suggestions =
  let naming_suggestions =
    List.filter
      (function { suggestion_type = NamingImprovement _; _ } -> true | _ -> false)
      suggestions
  in

  let english_count =
    List.length
      (List.filter
         (function { suggestion_type = NamingImprovement "建议使用中文命名"; _ } -> true | _ -> false)
         naming_suggestions)
  in

  let mixed_count =
    List.length
      (List.filter
         (function { suggestion_type = NamingImprovement "避免中英文混用"; _ } -> true | _ -> false)
         naming_suggestions)
  in

  let short_count =
    List.length
      (List.filter
         (function { suggestion_type = NamingImprovement "名称过短"; _ } -> true | _ -> false)
         naming_suggestions)
  in

  let meaningless_count =
    List.length
      (List.filter
         (function { suggestion_type = NamingImprovement "避免无意义命名"; _ } -> true | _ -> false)
         naming_suggestions)
  in

  (english_count, mixed_count, short_count, meaningless_count)

(** 生成命名质量报告 *)
let generate_naming_report suggestions =
  let english_count, mixed_count, short_count, meaningless_count =
    get_naming_statistics suggestions
  in

  let report = Buffer.create (Constants.BufferSizes.default_buffer ()) in

  Buffer.add_string report "📝 命名质量分析报告\n";
  Buffer.add_string report "========================\n\n";

  Buffer.add_string report (Unified_logger.Legacy.sprintf "📊 命名问题统计:\n");
  if english_count > 0 then
    Buffer.add_string report (Unified_logger.Legacy.sprintf "   🔤 英文命名: %d 个\n" english_count);
  if mixed_count > 0 then
    Buffer.add_string report (Unified_logger.Legacy.sprintf "   🔀 中英混用: %d 个\n" mixed_count);
  if short_count > 0 then
    Buffer.add_string report (Unified_logger.Legacy.sprintf "   📏 名称过短: %d 个\n" short_count);
  if meaningless_count > 0 then
    Buffer.add_string report (Unified_logger.Legacy.sprintf "   ❓ 无意义名称: %d 个\n" meaningless_count);

  let total_naming_issues = english_count + mixed_count + short_count + meaningless_count in
  Buffer.add_string report
    (Unified_logger.Legacy.sprintf "   📈 总计: %d 个命名问题\n\n" total_naming_issues);

  if total_naming_issues = 0 then Buffer.add_string report "✅ 恭喜！您的命名规范很好，符合中文编程最佳实践。\n"
  else (
    Buffer.add_string report "💡 改进建议:\n";
    Buffer.add_string report "   1. 优先使用中文命名，提高代码可读性\n";
    Buffer.add_string report "   2. 避免中英文混用，保持命名风格一致\n";
    Buffer.add_string report "   3. 使用具有描述性的名称，避免过短或无意义的命名\n");

  Buffer.contents report
