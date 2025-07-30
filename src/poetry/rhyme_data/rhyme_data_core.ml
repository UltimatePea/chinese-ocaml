(** 韵律数据核心模块 - 共享类型和辅助函数
    
    此模块包含所有韵组数据模块共享的类型定义和辅助函数，
    支持模块化重构，提高代码可维护性。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 韵组数据模块化重构 
    @since 2025-07-30
    @refactor_from unified_rhyme_groups_data.ml *)

open Poetry_core.Rhyme_core_types

(** {1 共享类型定义} *)

type rhyme_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  variants : string list;
  usage_frequency : float;
}
(** 韵组数据条目类型 *)

type rhyme_group_data = {
  group_name : rhyme_group;
  group_description : string;
  entries : rhyme_entry list;
  example_poems : string list;
}
(** 韵组数据结构类型 *)

(** {1 共享辅助函数} *)

(** 辅助函数：将元组列表转换为rhyme_group_data结构 *)
let make_rhyme_group_data group_name description tuples_list =
  let entries =
    List.map
      (fun (char, category, group) ->
        { character = char; category; group; variants = []; usage_frequency = 1.0 })
      tuples_list
  in
  { group_name; group_description = description; entries; example_poems = [] }

(** 辅助函数：创建平声组数据 *)
let make_ping_sheng_group rhyme_type chars =
  List.map (fun char -> (char, PingSheng, rhyme_type)) chars

(** 辅助函数：创建仄声组数据 *)
let make_ze_sheng_group rhyme_type chars = List.map (fun char -> (char, ZeSheng, rhyme_type)) chars

(** 统一创建韵组数据的函数 *)
let create_rhyme_data rhyme_type description ping_chars ze_chars =
  let ping_sheng_data = make_ping_sheng_group rhyme_type ping_chars in
  let ze_sheng_data = make_ze_sheng_group rhyme_type ze_chars in
  let tuples_data = ping_sheng_data @ ze_sheng_data in
  make_rhyme_group_data rhyme_type description tuples_data
