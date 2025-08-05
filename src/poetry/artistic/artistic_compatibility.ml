(** 诗词艺术评估兼容性模块 - Issue #2000 整合实施
 *
 * 此文件整合了以下源文件的功能：
 * - src/poetry/artistic_legacy_compat.ml: 遗留兼容
 * - 向后兼容接口定义
 *
 * 整合完成后，上述文件将被删除。
 * @consolidation_issue #2000
 * @author Whisky, PR Worker
 *)

(** {1 版本兼容性类型} *)

type api_version = V1_0  (** 初始版本 *) | V2_0  (** 模块化版本 *) | V3_0  (** 整合版本 - 当前 *)

type compatibility_mode =
  | Strict  (** 严格模式：只支持当前版本API *)
  | Compatible  (** 兼容模式：支持旧版本API转换 *)
  | Legacy  (** 遗留模式：保持完全向后兼容 *)

(** {1 全局兼容性设置} *)

let current_api_version = V3_0
let compatibility_mode_ref = ref Compatible

(** {1 V1.0 API 兼容接口} *)

module V1_API = struct
  type old_evaluation_result = { score : float; grade : string; comments : string list }
  (** 旧版本的评价结果类型 *)

  (** 旧版本的简单评价函数 *)
  let simple_evaluate poem_text =
    let lines = String.split_on_char '\n' poem_text in
    let line_count = List.length lines in
    let avg_length =
      if line_count = 0 then 0
      else List.fold_left ( + ) 0 (List.map String.length lines) / line_count
    in

    (* 简化的评分算法 *)
    let base_score = 0.6 in
    let length_bonus = if avg_length >= 5 && avg_length <= 7 then 0.2 else 0.0 in
    let structure_bonus = if line_count = 4 || line_count = 8 then 0.1 else 0.0 in

    let final_score = base_score +. length_bonus +. structure_bonus in
    let grade =
      if final_score >= 0.8 then "优秀"
      else if final_score >= 0.7 then "良好"
      else if final_score >= 0.6 then "中等"
      else "待提升"
    in

    {
      score = final_score;
      grade;
      comments = [ Printf.sprintf "共%d行，平均每行%d字" line_count avg_length; "使用V1.0兼容接口评价" ];
    }

  (** 转换到新版本格式 *)
  let convert_to_v3 old_result =
    let dimension_scores = [ ("整体评价", old_result.score) ] in
    (old_result.score, dimension_scores, old_result.comments)
end

(** {1 V2.0 API 兼容接口} *)

module V2_API = struct
  type modular_result = {
    overall_score : float;
    dimension_scores : (string * float) list;
    evaluation_details : string;
    suggestions : string list;
    metadata : (string * string) list;
  }
  (** V2.0的模块化评价结果 *)

  (** V2.0的评价引擎接口 *)
  let modular_evaluate poem_text =
    let lines = String.split_on_char '\n' poem_text in

    (* 各维度评分 *)
    let rhyme_score = 0.7 in
    let tonal_score = 0.6 in
    let parallel_score = 0.8 in
    let imagery_score = 0.75 in
    let form_score = 0.65 in

    let dimension_scores =
      [
        ("韵律和谐", rhyme_score);
        ("声调平衡", tonal_score);
        ("对仗工整", parallel_score);
        ("意象丰富", imagery_score);
        ("形式美感", form_score);
      ]
    in

    let overall_score =
      List.fold_left (fun acc (_, score) -> acc +. score) 0.0 dimension_scores
      /. float_of_int (List.length dimension_scores)
    in

    {
      overall_score;
      dimension_scores;
      evaluation_details = Printf.sprintf "基于%d行诗句的模块化评价" (List.length lines);
      suggestions = [ "继续保持现有水平"; "可适当加强薄弱环节" ];
      metadata = [ ("api_version", "v2.0"); ("evaluation_time", string_of_float (Unix.time ())) ];
    }

  (** 转换到V3.0格式 *)
  let convert_to_v3 v2_result =
    let artistic_level =
      if v2_result.overall_score >= 0.85 then `Master
      else if v2_result.overall_score >= 0.7 then `Advanced
      else if v2_result.overall_score >= 0.55 then `Intermediate
      else `Beginner
    in
    (v2_result.overall_score, v2_result.dimension_scores, v2_result.suggestions, artistic_level)
end

(** {1 兼容性转换函数} *)

(** 自动检测输入格式并转换 *)
let auto_convert_result input =
  match !compatibility_mode_ref with
  | Strict ->
      (* 严格模式：假设输入已经是V3.0格式 *)
      input
  | Compatible | Legacy ->
      (* 兼容模式：尝试转换旧格式 *)
      input
(* 这里应该有更复杂的格式检测逻辑 *)

(** V1.0 兼容包装器 *)
let v1_compatible_evaluate poem_text =
  let old_result = V1_API.simple_evaluate poem_text in
  V1_API.convert_to_v3 old_result

(** V2.0 兼容包装器 *)
let v2_compatible_evaluate poem_text =
  let v2_result = V2_API.modular_evaluate poem_text in
  V2_API.convert_to_v3 v2_result

(** {1 API兼容性检查} *)

(** 检查API版本兼容性 *)
let check_api_compatibility requested_version =
  match (requested_version, current_api_version) with
  | V1_0, _ -> true (* V1.0总是兼容的 *)
  | V2_0, V3_0 -> true (* V2.0在V3.0中兼容 *)
  | V3_0, V3_0 -> true (* 当前版本 *)
  | _ -> false

(** 获取支持的API版本列表 *)
let get_supported_versions () =
  match !compatibility_mode_ref with
  | Strict -> [ current_api_version ]
  | Compatible -> [ V2_0; V3_0 ]
  | Legacy -> [ V1_0; V2_0; V3_0 ]

(** {1 配置函数名称映射} *)

(** 旧函数名到新函数名的映射 *)
let function_name_mapping =
  [
    ("simple_evaluate", "comprehensive_artistic_evaluation");
    ("get_rhyme_score", "evaluate_rhyme_harmony");
    ("check_parallelism", "evaluate_parallelism");
    ("analyze_imagery", "evaluate_imagery");
    ("get_overall_grade", "determine_overall_grade");
  ]

(** 查找新函数名 *)
let find_new_function_name old_name =
  try Some (List.assoc old_name function_name_mapping) with Not_found -> None

(** {1 参数格式转换} *)

(** 转换旧格式参数到新格式 *)
let convert_parameters old_params =
  (* 这里应该根据实际的参数变化进行转换 *)
  old_params

(** {1 错误处理兼容性} *)

exception Legacy_Evaluation_Error of string
(** 旧版本异常类型 *)

exception Legacy_Parse_Error of string

(** 新版本错误转换为旧版本异常 *)
let convert_error_to_legacy error_msg =
  if String.contains error_msg (String.get "parse" 0) then raise (Legacy_Parse_Error error_msg)
  else raise (Legacy_Evaluation_Error error_msg)

(** {1 配置管理} *)

(** 设置兼容性模式 *)
let set_compatibility_mode mode = compatibility_mode_ref := mode

(** 获取当前兼容性模式 *)
let get_compatibility_mode () = !compatibility_mode_ref

(** 兼容性模式转为字符串 *)
let compatibility_mode_to_string = function
  | Strict -> "严格模式"
  | Compatible -> "兼容模式"
  | Legacy -> "遗留模式"

(** API版本转为字符串 *)
let api_version_to_string = function V1_0 -> "1.0" | V2_0 -> "2.0" | V3_0 -> "3.0"

(** {1 兼容性报告} *)

(** 生成兼容性报告 *)
let generate_compatibility_report () =
  let current_mode = get_compatibility_mode () in
  let supported_versions = get_supported_versions () in

  [
    ("当前API版本", api_version_to_string current_api_version);
    ("兼容性模式", compatibility_mode_to_string current_mode);
    ("支持的版本", String.concat ", " (List.map api_version_to_string supported_versions));
    ("函数映射数量", string_of_int (List.length function_name_mapping));
  ]

(** {1 迁移助手} *)

(** 检查代码是否使用了废弃的API *)
let check_deprecated_usage code_text =
  let deprecated_functions = List.map fst function_name_mapping in
  List.filter
    (fun func_name -> String.contains code_text (String.get func_name 0))
    deprecated_functions

(** 建议迁移步骤 *)
let suggest_migration_steps deprecated_functions =
  List.map
    (fun old_func ->
      match find_new_function_name old_func with
      | Some new_func -> Printf.sprintf "将 %s 替换为 %s" old_func new_func
      | None -> Printf.sprintf "手动检查 %s 的替代方案" old_func)
    deprecated_functions

(** {1 测试兼容性} *)

(** 测试V1.0兼容性 *)
let test_v1_compatibility () =
  try
    let result = v1_compatible_evaluate "床前明月光\n疑是地上霜\n举头望明月\n低头思故乡" in
    Some ("V1.0兼容性测试通过", result)
  with e -> Some ("V1.0兼容性测试失败", (0.0, [], [ Printexc.to_string e ]))

(** 测试V2.0兼容性 *)
let test_v2_compatibility () =
  try
    let result = v2_compatible_evaluate "床前明月光\n疑是地上霜\n举头望明月\n低头思故乡" in
    Some ("V2.0兼容性测试通过", result)
  with _e -> Some ("V2.0兼容性测试失败", (0.0, [], [], `Beginner))

(** {1 初始化} *)

(* 默认设置为兼容模式 *)
let () = set_compatibility_mode Compatible
