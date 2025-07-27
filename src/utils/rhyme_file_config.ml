(** 韵律数据文件配置模块 - 从 rhyme_data_utils.ml 提取
    
    专门处理韵律数据文件路径配置、查找和加载逻辑，
    使用查找表优化性能。
    
    Author: Alpha, 主工作代理
    Fix #1460 Phase 2.1 - 韵律配置模块优化 *)

open Printf

(** 韵律分类 *)
type rhyme_category =
  | PingSheng  (* 平声韵 *)
  | ZeSheng    (* 仄声韵 *)
  | ShangSheng (* 上声韵 *)
  | QuSheng    (* 去声韵 *)
  | RuSheng    (* 入声韵 *)

(** 韵律组 *)
type rhyme_group =
  | AnRhyme     (* 安韵组 *)
  | SiRhyme     (* 思韵组 *)
  | TianRhyme   (* 天韵组 *)
  | WangRhyme   (* 望韵组 *)
  | QuRhyme     (* 去韵组 *)
  | YuRhyme     (* 鱼韵组 *)
  | HuaRhyme    (* 花韵组 *)
  | FengRhyme   (* 风韵组 *)
  | YueRhyme    (* 月韵组 *)
  | XueRhyme    (* 雪韵组 *)
  | JiangRhyme  (* 江韵组 *)
  | HuiRhyme    (* 灰韵组 *)
  | UnknownRhyme (* 未知韵组 *)

(** 韵律数据文件路径配置 *)
type rhyme_file_config = {
  base_path : string;
  ping_sheng_path : string;
  ze_sheng_path : string;
  fallback_paths : string list;
}

(** 默认韵律文件配置 *)
let default_rhyme_config = {
  base_path = "data/poetry/rhyme_groups/";
  ping_sheng_path = "ping_sheng/";
  ze_sheng_path = "ze_sheng/";
  fallback_paths = [
    "data/poetry/";
    "src/poetry/data/";
    "./poetry_data/";
  ];
}

(** 韵律分类名称查找表 - 性能优化 *)
let category_name_table = [
  (PingSheng, "ping_sheng");
  (ZeSheng, "ze_sheng");
  (ShangSheng, "shang_sheng");
  (QuSheng, "qu_sheng");
  (RuSheng, "ru_sheng");
]

(** 韵律组名称查找表 - 性能优化 *)
let group_name_table = [
  (AnRhyme, "an");
  (SiRhyme, "si");
  (TianRhyme, "tian");
  (WangRhyme, "wang");
  (QuRhyme, "qu");
  (YuRhyme, "yu");
  (HuaRhyme, "hua");
  (FengRhyme, "feng");
  (YueRhyme, "yue");
  (XueRhyme, "xue");
  (JiangRhyme, "jiang");
  (HuiRhyme, "hui");
  (UnknownRhyme, "unknown");
]

(** 韵律组特殊文件名映射表 - 减少模式匹配开销 *)
let group_file_table = [
  (FengRhyme, "feng_rhyme_data.json");
  (YueRhyme, "yue_rhyme_data.json");
  (JiangRhyme, "jiang_rhyme_data.json");
  (HuiRhyme, "hui_rhyme_data.json");
  (HuaRhyme, "hua_rhyme_data.json");
  (YuRhyme, "yu_rhyme_data.json");
]

(** 韵律分类名称转换 - 使用查找表优化 *)
let string_of_rhyme_category category =
  List.assoc category category_name_table

(** 韵律组名称转换 - 使用查找表优化 *)
let string_of_rhyme_group group =
  List.assoc group group_name_table

(** 获取韵律组文件名 - 使用查找表优化 *)
let get_rhyme_group_filename group =
  match List.assoc_opt group group_file_table with
  | Some filename -> filename
  | None -> sprintf "%s_rhyme_data.json" (string_of_rhyme_group group)

(** 获取分类路径 - 简化逻辑 *)
let get_category_path config category =
  match category with
  | PingSheng -> config.ping_sheng_path
  | ZeSheng | ShangSheng | QuSheng | RuSheng -> config.ze_sheng_path

(** 构建文件路径 - 使用查找表和预计算优化 *)
let build_rhyme_file_path config category group =
  let category_path = get_category_path config category in
  let group_filename = get_rhyme_group_filename group in
  config.base_path ^ category_path ^ group_filename

(** 查找韵律数据文件 *)
let find_rhyme_data_file config category group =
  let primary_path = build_rhyme_file_path config category group in
  match Common_patterns.find_data_file_with_candidates [primary_path] with
  | Some path -> Some path
  | None ->
      (* 使用预计算的文件名进行回退查找 *)
      let group_file = get_rhyme_group_filename group in
      let fallback_candidates = List.map (fun base -> base ^ group_file) config.fallback_paths in
      Common_patterns.find_data_file_with_candidates fallback_candidates

(** 批量构建文件路径 - 性能优化版本 *)
let batch_build_file_paths config category_group_pairs =
  List.map (fun (category, group) ->
    (category, group, build_rhyme_file_path config category group)
  ) category_group_pairs

(** 验证配置 *)
let validate_config config =
  let check_path path = String.length path > 0 && not (String.contains path '\000') in
  check_path config.base_path &&
  check_path config.ping_sheng_path &&
  check_path config.ze_sheng_path &&
  List.for_all check_path config.fallback_paths

(** 配置信息摘要 *)
let config_summary config =
  sprintf "韵律配置: 基础路径=%s, 回退路径数=%d" 
    config.base_path (List.length config.fallback_paths)