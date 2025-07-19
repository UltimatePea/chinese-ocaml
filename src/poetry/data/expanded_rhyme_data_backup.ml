(** 扩展音韵数据模块 - 骆言诗词编程特性 Phase 16 重构版
    
    重构说明：原1249行的硬编码韵律数据已迁移至JSON文件，通过数据加载器动态加载。
    实现数据与代码分离，提高维护性和可扩展性。
    
    @author 骆言技术债务清理团队 Phase 16
    @version 2.0
    @since 2025-07-19 
    @refactored_from expanded_rhyme_data_backup.ml *)

open Rhyme_data_loader

(** 直接定义所需类型，保持向后兼容性 *)
type rhyme_category = Rhyme_data_loader.rhyme_category
type rhyme_group = Rhyme_data_loader.rhyme_group

(** ========== 韵律数据加载器接口 ========== *)

(** 延迟加载的韵律数据库 - 仅在首次访问时加载 *)
let rhyme_database_cache = ref None

let get_rhyme_database () =
  match !rhyme_database_cache with
  | Some db -> db
  | None ->
      let db = Rhyme_data_loader.safe_load_rhyme_database () in
      rhyme_database_cache := Some db;
      db

(** ========== 向后兼容性接口 ========== *)

(** 获取鱼韵组核心字符数据 - 兼容原接口 *)
let yu_yun_core_chars =
  lazy (
    let database = get_rhyme_database () in
    List.filter_map (fun (char, category, group) ->
      match group, category with
      | YuRhyme, PingSheng -> Some char
      | _ -> None
    ) database
  )

(** 获取鱼韵组贾价系列 - 兼容原接口 *)
let yu_yun_jia_chars =
  lazy (
    let database = get_rhyme_database () in
    let jia_pattern = ["贾"; "价"; "假"; "嫁"; "稼"; "架"; "驾"] in
    List.filter_map (fun (char, category, group) ->
      match group, category with
      | YuRhyme, PingSheng when List.mem char jia_pattern -> Some char
      | _ -> None
    ) database
  )

(** 获取鱼韵组棋期系列 - 兼容原接口 *)
let yu_yun_qi_chars =
  lazy (
    let database = get_rhyme_database () in
    let qi_pattern = ["棋"; "旗"; "期"; "欺"; "漆"; "齐"; "脐"; "奇"] in
    List.filter_map (fun (char, category, group) ->
      match group, category with
      | YuRhyme, PingSheng when List.mem char qi_pattern -> Some char
      | _ -> None
    ) database
  )

(** 获取鱼韵组扩展鱼类字符 - 兼容原接口 *)
let yu_yun_fish_chars =
  lazy (
    let database = get_rhyme_database () in
    let fish_pattern = ["鳙"; "鳚"; "鳛"; "鳜"; "鳝"; "鳞"; "鳟"; "鳠"] in
    List.filter_map (fun (char, category, group) ->
      match group, category with
      | YuRhyme, PingSheng when List.mem char fish_pattern -> Some char
      | _ -> None
    ) database
  )

(** 获取花韵组基础字符 - 兼容原接口 *)
let hua_yun_basic_chars =
  lazy (
    let database = get_rhyme_database () in
    List.filter_map (fun (char, category, group) ->
      match group, category with
      | HuaRhyme, PingSheng -> Some char
      | _ -> None
    ) database
  )

(** 获取风韵组基础字符 - 兼容原接口 *)
let feng_yun_basic_chars =
  lazy (
    let database = get_rhyme_database () in
    List.filter_map (fun (char, category, group) ->
      match group, category with
      | FengRhyme, PingSheng -> Some char
      | _ -> None
    ) database
  )

(** 获取月韵组基础字符 - 兼容原接口 *)
let yue_yun_basic_chars =
  lazy (
    let database = get_rhyme_database () in
    List.filter_map (fun (char, category, group) ->
      match group, category with
      | YueRhyme, ZeSheng -> Some char
      | _ -> None
    ) database
  )

(** 获取灰韵组核心字符 - 兼容原接口 *)
let hui_yun_core_chars =
  lazy (
    let database = get_rhyme_database () in
    List.filter_map (fun (char, category, group) ->
      match group, category with
      | HuiRhyme, ZeSheng -> Some char
      | _ -> None
    ) database
  )

(** 获取灰韵组剩余字符 - 兼容原接口 *)
let hui_yun_remaining_chars =
  lazy (
    let database = get_rhyme_database () in
    List.filter_map (fun (char, category, group) ->
      match group, category with
      | HuiRhyme, _ -> Some char  (* 包含所有灰韵字符 *)
      | _ -> None
    ) database
  )

(** ========== 分类数据组装 ========== *)

(** 创建韵律数据项的辅助函数 - 兼容原接口 *)
let create_rhyme_data chars category group = 
  List.map (fun char -> (char, category, group)) chars

(** 鱼韵组平声数据 - 兼容原接口 *)
let yu_yun_ping_sheng =
  lazy (
    let core = Lazy.force yu_yun_core_chars in
    let jia = Lazy.force yu_yun_jia_chars in
    let qi = Lazy.force yu_yun_qi_chars in
    let fish = Lazy.force yu_yun_fish_chars in
    create_rhyme_data (core @ jia @ qi @ fish) PingSheng YuRhyme
  )

(** 花韵组平声数据 - 兼容原接口 *)
let hua_yun_ping_sheng =
  lazy (
    let basic = Lazy.force hua_yun_basic_chars in
    create_rhyme_data basic PingSheng HuaRhyme
  )

(** 风韵组平声数据 - 兼容原接口 *)
let feng_yun_ping_sheng =
  lazy (
    let basic = Lazy.force feng_yun_basic_chars in
    create_rhyme_data basic PingSheng FengRhyme
  )

(** 月韵组仄声数据 - 兼容原接口 *)
let yue_yun_ze_sheng =
  lazy (
    let basic = Lazy.force yue_yun_basic_chars in
    create_rhyme_data basic ZeSheng YueRhyme
  )

(** 江韵组仄声数据 - 兼容原接口 *)
let jiang_yun_ze_sheng =
  lazy (
    let database = get_rhyme_database () in
    List.filter (fun (char, category, group) ->
      match group, category with
      | JiangRhyme, ZeSheng -> true
      | _ -> false
    ) database
  )

(** 灰韵组仄声数据 - 兼容原接口 *)
let hui_yun_ze_sheng =
  lazy (
    let core = Lazy.force hui_yun_core_chars in
    let remaining = Lazy.force hui_yun_remaining_chars in
    create_rhyme_data (core @ remaining) ZeSheng HuiRhyme
  )

(** ========== 完整数据库接口 ========== *)

(** 扩展音韵数据库 - 合并所有韵组的完整数据库 *)
let expanded_rhyme_database =
  lazy (
    let yu_ping = Lazy.force yu_yun_ping_sheng in
    let hua_ping = Lazy.force hua_yun_ping_sheng in
    let feng_ping = Lazy.force feng_yun_ping_sheng in
    let yue_ze = Lazy.force yue_yun_ze_sheng in
    let jiang_ze = Lazy.force jiang_yun_ze_sheng in
    let hui_ze = Lazy.force hui_yun_ze_sheng in
    yu_ping @ hua_ping @ feng_ping @ yue_ze @ jiang_ze @ hui_ze
  )

(** 扩展音韵数据库字符统计 *)
let expanded_rhyme_char_count () = 
  List.length (Lazy.force expanded_rhyme_database)

(** 获取扩展音韵数据库 *)
let get_expanded_rhyme_database () = 
  Lazy.force expanded_rhyme_database

(** 检查字符是否在扩展音韵数据库中 *)
let is_in_expanded_rhyme_database char =
  let database = Lazy.force expanded_rhyme_database in
  List.exists (fun (c, _, _) -> c = char) database

(** 获取扩展音韵数据库中的字符列表 *)
let get_expanded_char_list () = 
  let database = Lazy.force expanded_rhyme_database in
  List.map (fun (c, _, _) -> c) database

(** ========== 性能优化和诊断 ========== *)

(** 获取韵律数据库加载状态 *)
let get_database_load_status () =
  match !rhyme_database_cache with
  | Some db -> 
      let count = List.length db in
      Printf.sprintf "韵律数据库已加载，包含 %d 个字符" count
  | None -> "韵律数据库尚未加载"

(** 强制重新加载韵律数据库 *)
let reload_rhyme_database () =
  rhyme_database_cache := None;
  let _ = get_rhyme_database () in
  get_database_load_status ()

(** 获取韵组统计信息 *)
let get_rhyme_group_statistics () =
  let database = get_rhyme_database () in
  let group_counts = List.fold_left (fun acc (_, _, group) ->
    let count = try List.assoc group acc with Not_found -> 0 in
    (group, count + 1) :: (List.remove_assoc group acc)
  ) [] database in
  group_counts

(** ========== 模块初始化 ========== *)

(** 模块初始化 - 预热韵律数据库 *)
let initialize_module () =
  let _ = get_rhyme_database () in
  Printf.printf "扩展音韵数据模块初始化完成: %s\n" (get_database_load_status ())

(* 模块加载时自动初始化 *)
let () = initialize_module ()