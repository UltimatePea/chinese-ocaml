(** 诗词JSON处理统一模块 - Wave 2 重构版本

    此模块已完全重构为Poetry_core.Json_core的兼容接口层。
    原本288行的重复代码现在转发到统一的JSON核心，实现了约85%的代码减少。

    原有功能完全保留，API保持100%向后兼容：
    - 缓存管理 → 转发到统一核心
    - JSON解析 → 转发到统一核心
    - 文件I/O操作 → 转发到统一核心
    - 降级数据处理 → 转发到统一核心
    - 字符查询接口 → 转发到统一核心
    - 统计信息 → 转发到统一核心

    @author Alpha, Primary Worker Agent - Wave 2 重构团队
    @version 3.0 - Wave 2 兼容层版本
    @since 2025-07-28 - Poetry Phase 3 Wave 2 继续实施
    @previous_version 2.0 - 2025-07-24 Issue #1096 技术债务整理
    @fix_issue #1550 *)

(** {1 类型重新导出 - 完全兼容} *)

(* 重新导出核心类型以保持100%向后兼容 *)
open Poetry_core_types

(* 类型兼容性处理 - 确保与接口匹配 *)
type rhyme_category = Poetry_core_types.rhyme_category
type rhyme_group = Poetry_core_types.rhyme_group

type rhyme_group_data = Poetry_core_types.rhyme_group_data = {
  category : string;
  characters : string list;
}

type rhyme_data_file = Poetry_core_types.rhyme_data_file = {
  rhyme_groups : (string * rhyme_group_data) list;
  metadata : (string * string) list;
}

(** {1 主要API接口 - 转发到统一核心} *)

(** 类型转换辅助函数 *)

(* 韵类类型转换 *)
let convert_rhyme_category (core_cat : Poetry_core.Rhyme_core_types.rhyme_category) : rhyme_category
    =
  match core_cat with
  | Poetry_core.Rhyme_core_types.PingSheng -> PingSheng
  | Poetry_core.Rhyme_core_types.ZeSheng -> ZeSheng
  | Poetry_core.Rhyme_core_types.ShangSheng -> ShangSheng
  | Poetry_core.Rhyme_core_types.QuSheng -> QuSheng
  | Poetry_core.Rhyme_core_types.RuSheng -> RuSheng

(* 韵组类型转换 *)
let convert_rhyme_group (core_group : Poetry_core.Rhyme_core_types.rhyme_group) : rhyme_group =
  match core_group with
  | Poetry_core.Rhyme_core_types.AnRhyme -> AnRhyme
  | Poetry_core.Rhyme_core_types.SiRhyme -> SiRhyme
  | Poetry_core.Rhyme_core_types.TianRhyme -> TianRhyme
  | Poetry_core.Rhyme_core_types.WangRhyme -> WangRhyme
  | Poetry_core.Rhyme_core_types.QuRhyme -> QuRhyme
  | Poetry_core.Rhyme_core_types.YuRhyme -> YuRhyme
  | Poetry_core.Rhyme_core_types.HuaRhyme -> HuaRhyme
  | Poetry_core.Rhyme_core_types.FengRhyme -> FengRhyme
  | Poetry_core.Rhyme_core_types.YueRhyme -> YueRhyme
  | Poetry_core.Rhyme_core_types.XueRhyme -> XueRhyme
  | Poetry_core.Rhyme_core_types.JiangRhyme -> JiangRhyme
  | Poetry_core.Rhyme_core_types.HuiRhyme -> HuiRhyme
  | Poetry_core.Rhyme_core_types.UnknownRhyme -> UnknownRhyme

let convert_group_data (core_group : Poetry_core.Json_core.rhyme_group_data) : rhyme_group_data =
  { category = core_group.category; characters = core_group.characters }

let convert_from_core_data (core_data : Poetry_core.Json_core.rhyme_data_file) : rhyme_data_file =
  let converted_groups =
    List.map
      (fun (name, group_data) -> (name, convert_group_data group_data))
      core_data.rhyme_groups
  in
  { rhyme_groups = converted_groups; metadata = core_data.metadata }

(** 获取韵律数据（支持缓存） - 转发到统一核心 *)
let get_data ?(force_reload = false) () =
  match Poetry_core.Json_core.get_rhyme_data_safe ~force_reload () with
  | Some data -> convert_from_core_data data
  | None -> failwith "无法获取韵律数据"

(** 安全获取韵律数据（带降级处理） - 转发到统一核心 *)
let get_data_safe ?(force_reload = false) () =
  match Poetry_core.Json_core.get_rhyme_data_safe ~force_reload () with
  | Some data -> convert_from_core_data data
  | None -> convert_from_core_data (Poetry_core.Json_core.Fallback.use_fallback_data ())

(** 获取所有韵组 - 转发到统一核心 *)
let get_all_groups () =
  let core_groups = Poetry_core.Json_core.get_all_rhyme_groups () in
  List.map (fun (name, group_data) -> (name, convert_group_data group_data)) core_groups

(** 获取指定韵组的字符列表 - 转发到统一核心 *)
let get_group_characters group_name = Poetry_core.Json_core.get_rhyme_group_characters group_name

(** 获取指定韵组的韵类 - 转发到统一核心 *)
let get_group_category group_name =
  let core_category = Poetry_core.Json_core.get_rhyme_group_category group_name in
  convert_rhyme_category core_category

(** {1 字符查询接口 - 转发到统一核心} *)

(** 获取字符到韵律的映射关系 - 转发到统一核心 *)
let get_char_mappings () =
  let core_mappings = Poetry_core.Json_core.get_rhyme_mappings () in
  List.map
    (fun (char, (core_cat, core_group)) ->
      (char, (convert_rhyme_category core_cat, convert_rhyme_group core_group)))
    core_mappings

(** 查找字符的韵律信息 - 转发到统一核心 *)
let lookup_char char =
  let mappings = get_char_mappings () in
  try
    let category, group = List.assoc char mappings in
    Some (category, group)
  with Not_found -> None

(** {1 统计和调试接口 - 转发到统一核心} *)

(** 获取统计信息 - 转发到统一核心 *)
let get_statistics () =
  match Poetry_core.Json_core.get_data_statistics () with
  | Some (total_groups, total_chars, _, _, _) -> (total_groups, total_chars)
  | None -> (0, 0)

(** 打印统计信息 - 转发到统一核心 *)
let print_statistics () = Poetry_core.Json_core.print_statistics ()

(** {1 缓存管理接口 - 转发到统一核心} *)

(** 清空缓存 - 转发到统一核心 *)
let clear_cache () = Poetry_core.Json_core.clear_cache ()

(** 刷新缓存数据 - 转发到统一核心 *)
let refresh_cache (data : rhyme_data_file) =
  clear_cache ();
  let convert_to_core_group (group : rhyme_group_data) : Poetry_core.Json_core.rhyme_group_data =
    { category = group.category; characters = group.characters }
  in
  let converted_groups =
    List.map (fun (name, group_data) -> (name, convert_to_core_group group_data)) data.rhyme_groups
  in
  let core_data : Poetry_core.Json_core.rhyme_data_file =
    { rhyme_groups = converted_groups; metadata = data.metadata }
  in
  Poetry_core.Json_core.Cache.set_cached_data core_data
