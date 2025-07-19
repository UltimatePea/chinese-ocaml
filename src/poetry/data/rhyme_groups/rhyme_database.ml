(** 统一韵律数据库接口模块 - 骆言诗词编程特性
    
    此模块整合所有韵组数据，提供统一的数据库访问接口。
    保持与原 expanded_rhyme_data.ml 的完全向后兼容性，
    同时提供新的模块化查询接口。
    
    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-19 - Phase 14.2 模块化重构 *)

open Yu_rhyme_data
open Hua_rhyme_data
open Ping_sheng_rhymes.Feng_rhyme_data
open Ze_sheng_rhymes.Yue_rhyme_data
open Ze_sheng_rhymes.Jiang_rhyme_data
open Ze_sheng_rhymes.Hui_rhyme_data

(** {1 韵律数据库构建} *)

(** 类型转换函数 - 将各模块的本地类型转换为统一类型 *)

(** 转换韵类类型 *)
let convert_rhyme_category = function
  | Ping_sheng_rhymes.Feng_rhyme_data.PingSheng -> Rhyme_types.PingSheng
  | Ping_sheng_rhymes.Feng_rhyme_data.ZeSheng -> Rhyme_types.ZeSheng
  | Ping_sheng_rhymes.Feng_rhyme_data.ShangSheng -> Rhyme_types.ShangSheng
  | Ping_sheng_rhymes.Feng_rhyme_data.QuSheng -> Rhyme_types.QuSheng
  | Ping_sheng_rhymes.Feng_rhyme_data.RuSheng -> Rhyme_types.RuSheng

(** 转换韵组类型 *)
let convert_rhyme_group = function
  | Ping_sheng_rhymes.Feng_rhyme_data.AnRhyme -> Rhyme_types.AnRhyme
  | Ping_sheng_rhymes.Feng_rhyme_data.SiRhyme -> Rhyme_types.SiRhyme
  | Ping_sheng_rhymes.Feng_rhyme_data.TianRhyme -> Rhyme_types.TianRhyme
  | Ping_sheng_rhymes.Feng_rhyme_data.WangRhyme -> Rhyme_types.WangRhyme
  | Ping_sheng_rhymes.Feng_rhyme_data.QuRhyme -> Rhyme_types.QuRhyme
  | Ping_sheng_rhymes.Feng_rhyme_data.YuRhyme -> Rhyme_types.YuRhyme
  | Ping_sheng_rhymes.Feng_rhyme_data.HuaRhyme -> Rhyme_types.HuaRhyme
  | Ping_sheng_rhymes.Feng_rhyme_data.FengRhyme -> Rhyme_types.FengRhyme
  | Ping_sheng_rhymes.Feng_rhyme_data.YueRhyme -> Rhyme_types.YueRhyme
  | Ping_sheng_rhymes.Feng_rhyme_data.XueRhyme -> Rhyme_types.XueRhyme
  | Ping_sheng_rhymes.Feng_rhyme_data.JiangRhyme -> Rhyme_types.JiangRhyme
  | Ping_sheng_rhymes.Feng_rhyme_data.HuiRhyme -> Rhyme_types.HuiRhyme
  | Ping_sheng_rhymes.Feng_rhyme_data.UnknownRhyme -> Rhyme_types.UnknownRhyme

(** 仄声韵类型转换 *)
let convert_ze_rhyme_category = function
  | Ze_sheng_rhymes.Yue_rhyme_data.PingSheng -> Rhyme_types.PingSheng
  | Ze_sheng_rhymes.Yue_rhyme_data.ZeSheng -> Rhyme_types.ZeSheng
  | Ze_sheng_rhymes.Yue_rhyme_data.ShangSheng -> Rhyme_types.ShangSheng
  | Ze_sheng_rhymes.Yue_rhyme_data.QuSheng -> Rhyme_types.QuSheng
  | Ze_sheng_rhymes.Yue_rhyme_data.RuSheng -> Rhyme_types.RuSheng

(** 仄声韵组转换 *)
let convert_ze_rhyme_group = function
  | Ze_sheng_rhymes.Yue_rhyme_data.AnRhyme -> Rhyme_types.AnRhyme
  | Ze_sheng_rhymes.Yue_rhyme_data.SiRhyme -> Rhyme_types.SiRhyme
  | Ze_sheng_rhymes.Yue_rhyme_data.TianRhyme -> Rhyme_types.TianRhyme
  | Ze_sheng_rhymes.Yue_rhyme_data.WangRhyme -> Rhyme_types.WangRhyme
  | Ze_sheng_rhymes.Yue_rhyme_data.QuRhyme -> Rhyme_types.QuRhyme
  | Ze_sheng_rhymes.Yue_rhyme_data.YuRhyme -> Rhyme_types.YuRhyme
  | Ze_sheng_rhymes.Yue_rhyme_data.HuaRhyme -> Rhyme_types.HuaRhyme
  | Ze_sheng_rhymes.Yue_rhyme_data.FengRhyme -> Rhyme_types.FengRhyme
  | Ze_sheng_rhymes.Yue_rhyme_data.YueRhyme -> Rhyme_types.YueRhyme
  | Ze_sheng_rhymes.Yue_rhyme_data.XueRhyme -> Rhyme_types.XueRhyme
  | Ze_sheng_rhymes.Yue_rhyme_data.JiangRhyme -> Rhyme_types.JiangRhyme
  | Ze_sheng_rhymes.Yue_rhyme_data.HuiRhyme -> Rhyme_types.HuiRhyme
  | Ze_sheng_rhymes.Yue_rhyme_data.UnknownRhyme -> Rhyme_types.UnknownRhyme

(** 江韵模块类型转换 *)
let convert_jiang_rhyme_category = function
  | Ze_sheng_rhymes.Jiang_rhyme_data.PingSheng -> Rhyme_types.PingSheng
  | Ze_sheng_rhymes.Jiang_rhyme_data.ZeSheng -> Rhyme_types.ZeSheng
  | Ze_sheng_rhymes.Jiang_rhyme_data.ShangSheng -> Rhyme_types.ShangSheng
  | Ze_sheng_rhymes.Jiang_rhyme_data.QuSheng -> Rhyme_types.QuSheng
  | Ze_sheng_rhymes.Jiang_rhyme_data.RuSheng -> Rhyme_types.RuSheng

let convert_jiang_rhyme_group = function
  | Ze_sheng_rhymes.Jiang_rhyme_data.AnRhyme -> Rhyme_types.AnRhyme
  | Ze_sheng_rhymes.Jiang_rhyme_data.SiRhyme -> Rhyme_types.SiRhyme
  | Ze_sheng_rhymes.Jiang_rhyme_data.TianRhyme -> Rhyme_types.TianRhyme
  | Ze_sheng_rhymes.Jiang_rhyme_data.WangRhyme -> Rhyme_types.WangRhyme
  | Ze_sheng_rhymes.Jiang_rhyme_data.QuRhyme -> Rhyme_types.QuRhyme
  | Ze_sheng_rhymes.Jiang_rhyme_data.YuRhyme -> Rhyme_types.YuRhyme
  | Ze_sheng_rhymes.Jiang_rhyme_data.HuaRhyme -> Rhyme_types.HuaRhyme
  | Ze_sheng_rhymes.Jiang_rhyme_data.FengRhyme -> Rhyme_types.FengRhyme
  | Ze_sheng_rhymes.Jiang_rhyme_data.YueRhyme -> Rhyme_types.YueRhyme
  | Ze_sheng_rhymes.Jiang_rhyme_data.XueRhyme -> Rhyme_types.XueRhyme
  | Ze_sheng_rhymes.Jiang_rhyme_data.JiangRhyme -> Rhyme_types.JiangRhyme
  | Ze_sheng_rhymes.Jiang_rhyme_data.HuiRhyme -> Rhyme_types.HuiRhyme
  | Ze_sheng_rhymes.Jiang_rhyme_data.UnknownRhyme -> Rhyme_types.UnknownRhyme

(** 灰韵模块类型转换 *)
let convert_hui_rhyme_category = function
  | Ze_sheng_rhymes.Hui_rhyme_data.PingSheng -> Rhyme_types.PingSheng
  | Ze_sheng_rhymes.Hui_rhyme_data.ZeSheng -> Rhyme_types.ZeSheng
  | Ze_sheng_rhymes.Hui_rhyme_data.ShangSheng -> Rhyme_types.ShangSheng
  | Ze_sheng_rhymes.Hui_rhyme_data.QuSheng -> Rhyme_types.QuSheng
  | Ze_sheng_rhymes.Hui_rhyme_data.RuSheng -> Rhyme_types.RuSheng

let convert_hui_rhyme_group = function
  | Ze_sheng_rhymes.Hui_rhyme_data.AnRhyme -> Rhyme_types.AnRhyme
  | Ze_sheng_rhymes.Hui_rhyme_data.SiRhyme -> Rhyme_types.SiRhyme
  | Ze_sheng_rhymes.Hui_rhyme_data.TianRhyme -> Rhyme_types.TianRhyme
  | Ze_sheng_rhymes.Hui_rhyme_data.WangRhyme -> Rhyme_types.WangRhyme
  | Ze_sheng_rhymes.Hui_rhyme_data.QuRhyme -> Rhyme_types.QuRhyme
  | Ze_sheng_rhymes.Hui_rhyme_data.YuRhyme -> Rhyme_types.YuRhyme
  | Ze_sheng_rhymes.Hui_rhyme_data.HuaRhyme -> Rhyme_types.HuaRhyme
  | Ze_sheng_rhymes.Hui_rhyme_data.FengRhyme -> Rhyme_types.FengRhyme
  | Ze_sheng_rhymes.Hui_rhyme_data.YueRhyme -> Rhyme_types.YueRhyme
  | Ze_sheng_rhymes.Hui_rhyme_data.XueRhyme -> Rhyme_types.XueRhyme
  | Ze_sheng_rhymes.Hui_rhyme_data.JiangRhyme -> Rhyme_types.JiangRhyme
  | Ze_sheng_rhymes.Hui_rhyme_data.HuiRhyme -> Rhyme_types.HuiRhyme
  | Ze_sheng_rhymes.Hui_rhyme_data.UnknownRhyme -> Rhyme_types.UnknownRhyme

(** 转换数据函数 *)
let convert_feng_data (char, cat, group) = 
  (char, convert_rhyme_category cat, convert_rhyme_group group)

let convert_yue_data (char, cat, group) = 
  (char, convert_ze_rhyme_category cat, convert_ze_rhyme_group group)

let convert_jiang_data (char, cat, group) = 
  (char, convert_jiang_rhyme_category cat, convert_jiang_rhyme_group group)

let convert_hui_data (char, cat, group) = 
  (char, convert_hui_rhyme_category cat, convert_hui_rhyme_group group)

(** 扩展韵律数据库 - 完整的韵律数据库
    
    整合所有韵组的数据，构建完整的扩展韵律数据库。
    包含所有已模块化的韵组：鱼韵组、花韵组、风韵组、月韵组、江韵组、灰韵组。
    通过类型转换确保所有数据使用统一的 Rhyme_types。 *)
let expanded_rhyme_database =
  let all_data = List.concat
    [
      yu_yun_ping_sheng;
      hua_yun_ping_sheng;
      List.map convert_feng_data feng_yun_ping_sheng;
      List.map convert_yue_data yue_yun_ze_sheng;
      List.map convert_jiang_data jiang_yun_ze_sheng;
      List.map convert_hui_data hui_yun_ze_sheng;
    ]
  in
  (* 去重处理：保留首次出现的字符，优先保留平声韵数据 *)
  let deduplicate data =
    let seen = Hashtbl.create 1000 in
    List.fold_left (fun acc (char, category, group) ->
      if Hashtbl.mem seen char then
        acc  (* 跳过重复字符 *)
      else (
        Hashtbl.add seen char true;
        (char, category, group) :: acc
      )
    ) [] data
    |> List.rev
  in
  deduplicate all_data

(** {1 向后兼容接口} *)

(** 扩展韵律数据库字符总数 *)
let expanded_rhyme_char_count = List.length expanded_rhyme_database

(** 获取扩展韵律数据库
    
    获取完整的扩展韵律数据库，与原接口完全兼容。
    
    @return 完整的韵律数据库列表 *)
let get_expanded_rhyme_database () = expanded_rhyme_database

(** 检查字符是否在扩展韵律数据库中
    
    检查指定字符是否存在于扩展韵律数据库中，与原接口完全兼容。
    
    @param char 要检查的字符
    @return 如果字符存在则返回 true，否则返回 false *)
let is_in_expanded_rhyme_database char =
  List.exists (fun (c, _, _) -> c = char) expanded_rhyme_database

(** 获取扩展韵律数据库中的字符列表
    
    提取数据库中所有字符，与原接口完全兼容。
    
    @return 字符列表 *)
let get_expanded_char_list () = 
  List.map (fun (c, _, _) -> c) expanded_rhyme_database

(** {1 新增模块化接口} *)

(** 按韵组获取数据
    
    根据指定的韵组获取对应的韵律数据。
    
    @param group 韵组
    @return 该韵组的所有韵律数据 *)
let get_rhyme_data_by_group group =
  List.filter (fun (_, _, g) -> g = group) expanded_rhyme_database

(** 按韵类获取数据
    
    根据指定的韵类获取对应的韵律数据。
    
    @param category 韵类
    @return 该韵类的所有韵律数据 *)
let get_rhyme_data_by_category category =
  List.filter (fun (_, c, _) -> c = category) expanded_rhyme_database

(** 获取所有韵组列表
    
    提取数据库中所有的韵组，去重后返回。
    
    @return 所有韵组的列表 *)
let get_all_rhyme_groups () =
  expanded_rhyme_database
  |> List.map (fun (_, _, group) -> group)
  |> List.sort_uniq compare

(** 获取特定韵组的字符数量
    
    统计指定韵组包含的字符数量。
    
    @param group 韵组
    @return 该韵组的字符数量 *)
let get_rhyme_group_char_count group =
  List.length (get_rhyme_data_by_group group)

(** 获取特定韵类的字符数量
    
    统计指定韵类包含的字符数量。
    
    @param category 韵类
    @return 该韵类的字符数量 *)
let get_rhyme_category_char_count category =
  List.length (get_rhyme_data_by_category category)

(** {1 数据库状态查询} *)

(** 获取数据库统计信息
    
    提供数据库的基本统计信息，包括总字符数、韵组数量等。
    
    @return (总字符数, 韵组数量, 韵类数量) *)
let get_database_stats () =
  let total_chars = expanded_rhyme_char_count in
  let rhyme_groups = get_all_rhyme_groups () |> List.length in
  let rhyme_categories = 
    expanded_rhyme_database
    |> List.map (fun (_, category, _) -> category)
    |> List.sort_uniq compare
    |> List.length
  in
  (total_chars, rhyme_groups, rhyme_categories)

(** 验证数据库完整性
    
    检查数据库的完整性，确保没有重复字符和格式正确。
    
    @return (是否完整, 重复字符列表) *)
let validate_database () =
  let chars = get_expanded_char_list () in
  let unique_chars = List.sort_uniq String.compare chars in
  let duplicates = 
    List.fold_left (fun acc char ->
      let count = List.filter (String.equal char) chars |> List.length in
      if count > 1 then char :: acc else acc
    ) [] unique_chars
  in
  (List.length duplicates = 0, duplicates)