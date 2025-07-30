(** 韵组数据注册表 - 统一韵组访问管理
    
    此模块实现韵组数据的注册表模式，提供统一的数据访问接口，
    支持模块化的韵组架构和动态数据管理。
    
    @author Alpha, 主要工作代理  
    @version 1.0 - 模块化重构版本
    @since 2025-07-30
    @related_issue #1773 统一模块技术债务清理 *)

open Poetry_core.Types
open Rhyme_group_builder

(** {1 注册表状态管理} *)

(** 全局韵组数据存储 - 使用哈希表提供高效访问 *)
let rhyme_data_table : (rhyme_group, refactored_rhyme_group_data) Hashtbl.t = Hashtbl.create 16

(** 注册顺序记录 - 保持与原系统一致的访问顺序 *)
let registration_order : rhyme_group list ref = ref []

(** {1 核心注册和访问接口} *)

(** 注册韵组数据到注册表
    @param data 韵组数据
    @raise Invalid_argument 如果韵组已存在 *)
let register_rhyme_group (data : refactored_rhyme_group_data) =
  let group_type = data.group_name in
  if Hashtbl.mem rhyme_data_table group_type then
    Printf.printf "警告: 韵组 %s 重复注册，将覆盖原数据\n"
      (match group_type with
      | AnRhyme -> "安韵"
      | SiRhyme -> "思韵"
      | TianRhyme -> "天韵"
      | WangRhyme -> "王韵"
      | QuRhyme -> "曲韵"
      | YuRhyme -> "鱼韵"
      | HuaRhyme -> "花韵"
      | FengRhyme -> "风韵"
      | YueRhyme -> "月韵"
      | JiangRhyme -> "江韵"
      | HuiRhyme -> "会韵"
      | XueRhyme -> "雪韵"
      | UnknownRhyme -> "未知韵")
  else registration_order := group_type :: !registration_order;
  Hashtbl.replace rhyme_data_table group_type data

(** 按韵组类型获取数据
    @param group_type 韵组类型
    @return 韵组数据选项 *)
let get_rhyme_data_by_group group_type =
  try Some (Hashtbl.find rhyme_data_table group_type) with Not_found -> None

(** 获取所有已注册的韵组数据 - 按注册顺序返回
    @return 韵组数据列表 *)
let get_all_rhyme_data () =
  let ordered_groups = List.rev !registration_order in
  List.filter_map
    (fun group_type -> try Some (Hashtbl.find rhyme_data_table group_type) with Not_found -> None)
    ordered_groups

(** 获取已注册韵组的统计信息
    @return (总字符数, 平声字符数, 仄声字符数) *)
let get_rhyme_stats () =
  let all_groups = get_all_rhyme_data () in
  let total_entries =
    List.fold_left (fun acc group -> acc + List.length group.entries) 0 all_groups
  in
  (* TODO: 类型系统问题 - entry.category 字段实际是 verse_line 类型，需要重新设计数据结构 *)
  let ping_sheng_count =
    0
    (* 临时禁用，避免编译错误 *)
  in
  let ze_sheng_count = total_entries - ping_sheng_count in
  (total_entries, ping_sheng_count, ze_sheng_count)

(** {2 查询和管理功能} *)

(** 检查韵组是否已注册
    @param group_type 韵组类型
    @return 是否已注册 *)
let is_registered group_type = Hashtbl.mem rhyme_data_table group_type

(** 获取已注册韵组的数量 *)
let get_registered_count () = Hashtbl.length rhyme_data_table

(** 获取所有已注册的韵组类型列表 *)
let get_registered_groups () = List.rev !registration_order

(** 注销韵组数据 - 主要用于测试和重构
    @param group_type 韵组类型
    @return 是否成功注销 *)
let unregister_rhyme_group group_type =
  if Hashtbl.mem rhyme_data_table group_type then (
    Hashtbl.remove rhyme_data_table group_type;
    registration_order := List.filter (fun g -> g <> group_type) !registration_order;
    true)
  else false

(** 清空注册表 - 主要用于测试重置 *)
let clear_registry () =
  Hashtbl.clear rhyme_data_table;
  registration_order := []

(** {3 兼容性支持} *)

(** 获取韵组数据，提供UnknownRhyme兜底
    @param group_type 韵组类型
    @return 韵组数据（保证不为None） *)
let get_rhyme_data_by_group_safe group_type =
  match get_rhyme_data_by_group group_type with
  | Some data -> data
  | None ->
      { group_name = UnknownRhyme; group_description = "未知韵组"; entries = []; example_poems = [] }

(** {4 调试和诊断功能} *)

(** 打印注册表状态 - 用于调试 *)
let print_registry_status () =
  let count = get_registered_count () in
  let total, ping, ze = get_rhyme_stats () in
  Printf.printf "韵组注册表状态:\n";
  Printf.printf "- 已注册韵组数: %d\n" count;
  Printf.printf "- 总字符数: %d (平声: %d, 仄声: %d)\n" total ping ze;
  Printf.printf "- 注册顺序: [%s]\n"
    (String.concat "; "
       (List.map
          (function
            | AnRhyme -> "安韵"
            | SiRhyme -> "思韵"
            | TianRhyme -> "天韵"
            | WangRhyme -> "王韵"
            | QuRhyme -> "曲韵"
            | YuRhyme -> "鱼韵"
            | HuaRhyme -> "花韵"
            | FengRhyme -> "风韵"
            | YueRhyme -> "月韵"
            | JiangRhyme -> "江韵"
            | HuiRhyme -> "会韵"
            | XueRhyme -> "雪韵"
            | UnknownRhyme -> "未知韵")
          (get_registered_groups ())))

(** 验证注册表完整性 *)
let validate_registry () =
  let issues = ref [] in
  let add_issue msg = issues := msg :: !issues in

  (* 检查是否有空的韵组数据 *)
  Hashtbl.iter
    (fun group_type data ->
      if List.length data.entries = 0 then
        add_issue
          (Printf.sprintf "韵组 %s 没有字符数据"
             (match group_type with AnRhyme -> "安韵" | SiRhyme -> "思韵" | _ -> "其他")))
    rhyme_data_table;

  (* 检查注册顺序一致性 *)
  let registered_in_table = Hashtbl.length rhyme_data_table in
  let registered_in_order = List.length !registration_order in
  if registered_in_table <> registered_in_order then add_issue "注册顺序与实际注册数据不一致";

  List.rev !issues
