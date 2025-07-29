(** 韵律数据加载器兼容层实现 - Phase 2.2: 向后兼容性保证
    
    此模块代理所有原始rhyme_data_loader的接口到unified_data_loader_comprehensive，
    确保现有代码无需任何修改即可使用新的统一架构。
    
    @author Alpha, 技术债务清理专员
    @version 2.2 - Phase 2.2 兼容层
    @since 2025-07-29
    @fix_issue #1732 *)

open Unified_data_loader_comprehensive

(** {1 类型定义 - 直接使用Poetry_types的统一类型} *)

(* 类型别名以匹配接口声明 *)
type rhyme_category = Poetry_core.Poetry_types.rhyme_category
type rhyme_group = Poetry_core.Poetry_types.rhyme_group

type rhyme_data_load_error =
  | RhymeFileNotFound of string
  | RhymeParseError of string * string
  | RhymeValidationError of string

exception RhymeDataLoadError of rhyme_data_load_error

(** {1 类型转换工具函数} *)

(** 由于comprehensive模块使用相同的Poetry_types，无需转换 *)
let convert_from_comprehensive_category category = category

let convert_from_comprehensive_group group = group

(** 转换综合数据库格式到兼容格式 *)
let convert_comprehensive_rhyme_data comprehensive_data =
  List.map
    (fun (char, category, group) ->
      (char, convert_from_comprehensive_category category, convert_from_comprehensive_group group))
    comprehensive_data

(** 将comprehensive错误转换为兼容层错误 *)
let convert_comprehensive_error = function
  | ComprehensiveLoadError (RhymeLoadError (msg, detail)) ->
      RhymeDataLoadError (RhymeParseError (msg, detail))
  | ComprehensiveLoadError (UnifiedLoadError msg) -> RhymeDataLoadError (RhymeValidationError msg)
  | ComprehensiveLoadError (CompatibilityError msg) -> RhymeDataLoadError (RhymeValidationError msg)
  | _ -> RhymeDataLoadError (RhymeValidationError "未知错误")

(** {1 错误处理实现} *)

let format_rhyme_error = function
  | RhymeFileNotFound filename -> Printf.sprintf "韵律数据文件未找到: %s" filename
  | RhymeParseError (msg, detail) -> Printf.sprintf "韵律数据解析错误: %s (详细: %s)" msg detail
  | RhymeValidationError msg -> Printf.sprintf "韵律数据验证错误: %s" msg

(** {1 韵律数据加载接口实现} *)

let load_ping_sheng_rhymes () =
  try
    let comprehensive_data = load_ping_sheng_rhymes_comprehensive () in
    convert_comprehensive_rhyme_data comprehensive_data
  with
  | ComprehensiveLoadError _ as e -> raise (convert_comprehensive_error e)
  | e -> raise (RhymeDataLoadError (RhymeValidationError (Printexc.to_string e)))

let load_ze_sheng_rhymes () =
  try
    let comprehensive_data = load_ze_sheng_rhymes_comprehensive () in
    convert_comprehensive_rhyme_data comprehensive_data
  with
  | ComprehensiveLoadError _ as e -> raise (convert_comprehensive_error e)
  | e -> raise (RhymeDataLoadError (RhymeValidationError (Printexc.to_string e)))

let load_complete_rhyme_database () =
  try
    let comprehensive_data = load_complete_rhyme_database_comprehensive () in
    convert_comprehensive_rhyme_data comprehensive_data
  with
  | ComprehensiveLoadError _ as e -> raise (convert_comprehensive_error e)
  | e -> raise (RhymeDataLoadError (RhymeValidationError (Printexc.to_string e)))

let safe_load_rhyme_database () =
  try load_complete_rhyme_database () with
  | RhymeDataLoadError error ->
      let error_msg = format_rhyme_error error in
      Printf.printf "警告: 韵律数据库加载失败，返回空列表: %s\n" error_msg;
      []
  | e ->
      Printf.printf "警告: 韵律数据库加载失败，返回空列表: %s\n" (Printexc.to_string e);
      []

(** {1 数据查询和统计实现} *)

let get_rhyme_char_count database = List.length database
let is_char_in_rhyme_database char database = List.exists (fun (c, _, _) -> c = char) database
let get_char_list database = List.map (fun (char, _, _) -> char) database
