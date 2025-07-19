(** 扩展音韵数据模块 - 骆言诗词编程特性 Phase 1
    
    应Issue #419需求，扩展音韵数据从300字到1000字。 依《平水韵》、《中华新韵》等韵书传统，精心收录常用诗词字符。 按韵组分类，音韵和谐，便于诗词创作和分析。
    
    Phase 14.3 重构：此模块现在通过统一的韵律数据库接口提供向后兼容的数据访问。
    所有韵组数据已完成模块化，通过 rhyme_groups.rhyme_database 统一管理。
    
    @author 骆言诗词编程团队
    @version 2.0
    @since 2025-07-18
    @updated 2025-07-19 - Phase 14.3 模块化重构完成 *)

(** 直接定义所需类型，避免循环依赖 *)
type rhyme_category =
  | PingSheng (* 平声韵 *)
  | ZeSheng (* 仄声韵 *)
  | ShangSheng (* 上声韵 *)
  | QuSheng (* 去声韵 *)
  | RuSheng (* 入声韵 *)

type rhyme_group =
  | AnRhyme (* 安韵组 *)
  | SiRhyme (* 思韵组 *)
  | TianRhyme (* 天韵组 *)
  | WangRhyme (* 望韵组 *)
  | QuRhyme (* 去韵组 *)
  | YuRhyme (* 鱼韵组 *)
  | HuaRhyme (* 花韵组 *)
  | FengRhyme (* 风韵组 *)
  | YueRhyme (* 月韵组 *)
  | XueRhyme (* 雪韵组 *)
  | JiangRhyme (* 江韵组 *)
  | HuiRhyme (* 灰韵组 *)
  | UnknownRhyme (* 未知韵组 *)

(** {1 韵律数据辅助工具} *)

(** 创建韵律数据项的辅助函数 *)
let create_rhyme_data chars category group = List.map (fun char -> (char, category, group)) chars

(** {1 模块化数据接口} *)

(** 通过韵律数据库获取所有数据 - Phase 14.3 模块化架构

    现在从统一的韵律数据库模块获取完整的韵律数据，实现了数据的完全集成。 确保向后兼容性的同时，提供完整的1000+字符韵律数据库支持。 *)
let expanded_rhyme_database =
  (* Phase 14.3 模块化重构完成 - 通过内部导入获取完整的集成数据 *)
  let module RDB = Rhyme_groups.Rhyme_database in
  let convert_item (char, category_ext, group_ext) =
    let category =
      match category_ext with
      | Rhyme_groups.Rhyme_types.PingSheng -> PingSheng
      | Rhyme_groups.Rhyme_types.ZeSheng -> ZeSheng
      | Rhyme_groups.Rhyme_types.ShangSheng -> ShangSheng
      | Rhyme_groups.Rhyme_types.QuSheng -> QuSheng
      | Rhyme_groups.Rhyme_types.RuSheng -> RuSheng
    in
    let group =
      match group_ext with
      | Rhyme_groups.Rhyme_types.YuRhyme -> YuRhyme
      | Rhyme_groups.Rhyme_types.HuaRhyme -> HuaRhyme
      | Rhyme_groups.Rhyme_types.FengRhyme -> FengRhyme
      | Rhyme_groups.Rhyme_types.YueRhyme -> YueRhyme
      | Rhyme_groups.Rhyme_types.JiangRhyme -> JiangRhyme
      | Rhyme_groups.Rhyme_types.HuiRhyme -> HuiRhyme
      | _ -> UnknownRhyme
    in
    (char, category, group)
  in
  List.map convert_item (RDB.get_expanded_rhyme_database ())

(** {1 向后兼容接口 - 保持与原接口完全一致} *)

(** 扩展音韵数据库字符统计 *)
let expanded_rhyme_char_count = List.length expanded_rhyme_database

(** 获取扩展音韵数据库 *)
let get_expanded_rhyme_database () = expanded_rhyme_database

(** 检查字符是否在扩展音韵数据库中 *)
let is_in_expanded_rhyme_database char =
  List.exists (fun (c, _, _) -> c = char) expanded_rhyme_database

(** 获取扩展音韵数据库中的字符列表 *)
let get_expanded_char_list () = List.map (fun (c, _, _) -> c) expanded_rhyme_database

(** {1 说明}

    Phase 14.3 模块化重构完成后，原有的韵组数据已迁移到独立的模块中：
    - src/poetry/data/rhyme_groups/yu_rhyme_data.ml - 鱼韵组
    - src/poetry/data/rhyme_groups/hua_rhyme_data.ml - 花韵组
    - src/poetry/data/rhyme_groups/ping_sheng/feng_rhyme_data.ml - 风韵组
    - src/poetry/data/rhyme_groups/ze_sheng/yue_rhyme_data.ml - 月韵组
    - src/poetry/data/rhyme_groups/ze_sheng/jiang_rhyme_data.ml - 江韵组
    - src/poetry/data/rhyme_groups/ze_sheng/hui_rhyme_data.ml - 灰韵组

    通过rhyme_database.ml模块可以统一访问所有韵组数据。 此文件现在仅保留向后兼容的基础接口。 *)
