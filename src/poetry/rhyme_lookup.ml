(** 音韵查询优化模块 - 骆言诗词编程特性 Phase 1

    应Issue #419需求，使用哈希表优化音韵查询性能。 从线性查询O(n)优化到哈希表查询O(1)。 支持快速韵组查询和韵类检测。

    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-18 *)

open Rhyme_types
open Rhyme_data

(** {1 哈希表查询优化} *)

(** 音韵查询哈希表 - 字符到韵组+韵类的映射 *)
let rhyme_lookup_table = Hashtbl.create 2048

(** 扩展音韵查询哈希表 - 字符到韵组+韵类的映射 *)
let expanded_rhyme_lookup_table = Hashtbl.create 2048

(** 韵组查询哈希表 - 字符到韵组的映射 *)
let rhyme_group_lookup_table = Hashtbl.create 2048

(** 韵类查询哈希表 - 字符到韵类的映射 *)
let rhyme_category_lookup_table = Hashtbl.create 2048

(** {2 初始化函数} *)

(** 初始化音韵查询哈希表 *)
let initialize_rhyme_lookup () =
  (* 初始化原始数据库 *)
  List.iter
    (fun (char, category, group) ->
      Hashtbl.replace rhyme_lookup_table char (category, group);
      Hashtbl.replace rhyme_group_lookup_table char group;
      Hashtbl.replace rhyme_category_lookup_table char category)
    rhyme_database;

  (* 初始化扩展数据库 *)
  List.iter
    (fun (char, category, group) ->
      Hashtbl.replace expanded_rhyme_lookup_table char (category, group);
      Hashtbl.replace rhyme_group_lookup_table char group;
      Hashtbl.replace rhyme_category_lookup_table char category)
    expanded_rhyme_database

(** 确保哈希表已初始化 *)
let ensure_initialized () = if Hashtbl.length rhyme_lookup_table = 0 then initialize_rhyme_lookup ()

(** {2 快速查询函数} *)

(** 快速查询字符的韵组和韵类 *)
let lookup_rhyme_fast char =
  ensure_initialized ();
  try Some (Hashtbl.find rhyme_lookup_table char) with Not_found -> None

(** 快速查询字符的韵组和韵类（使用扩展数据库） *)
let lookup_rhyme_expanded_fast char =
  ensure_initialized ();
  try Some (Hashtbl.find expanded_rhyme_lookup_table char) with Not_found -> None

(** 快速查询字符的韵组 *)
let lookup_rhyme_group_fast char =
  ensure_initialized ();
  try Some (Hashtbl.find rhyme_group_lookup_table char) with Not_found -> None

(** 快速查询字符的韵类 *)
let lookup_rhyme_category_fast char =
  ensure_initialized ();
  try Some (Hashtbl.find rhyme_category_lookup_table char) with Not_found -> None

(** 快速检查字符是否在音韵数据库中 *)
let is_rhyme_char_fast char =
  ensure_initialized ();
  Hashtbl.mem rhyme_lookup_table char

(** 快速检查字符是否在扩展音韵数据库中 *)
let is_expanded_rhyme_char_fast char =
  ensure_initialized ();
  Hashtbl.mem expanded_rhyme_lookup_table char

(** 快速检查字符是否为平声 *)
let is_ping_sheng_fast char =
  match lookup_rhyme_category_fast char with Some PingSheng -> true | _ -> false

(** 快速检查字符是否为仄声 *)
let is_ze_sheng_fast char =
  match lookup_rhyme_category_fast char with
  | Some (ZeSheng | ShangSheng | QuSheng | RuSheng) -> true
  | _ -> false

(** 快速检查两个字符是否同韵 *)
let is_same_rhyme_fast char1 char2 =
  match (lookup_rhyme_group_fast char1, lookup_rhyme_group_fast char2) with
  | Some group1, Some group2 -> group1 = group2
  | _ -> false

(** 快速检查两个字符是否同韵类 *)
let is_same_category_fast char1 char2 =
  match (lookup_rhyme_category_fast char1, lookup_rhyme_category_fast char2) with
  | Some cat1, Some cat2 -> cat1 = cat2
  | _ -> false

(** {2 批量查询函数} *)

(** 批量查询字符串中每个字符的韵组 *)
let lookup_string_rhyme_groups str =
  ensure_initialized ();
  let chars = String.to_seq str |> List.of_seq in
  List.map (fun char -> (char, lookup_rhyme_group_fast (String.make 1 char))) chars

(** 批量查询字符串中每个字符的韵类 *)
let lookup_string_rhyme_categories str =
  ensure_initialized ();
  let chars = String.to_seq str |> List.of_seq in
  List.map (fun char -> (char, lookup_rhyme_category_fast (String.make 1 char))) chars

(** 快速检查字符串是否全部为平声 *)
let is_all_ping_sheng str =
  let chars = String.to_seq str |> List.of_seq in
  List.for_all (fun char -> is_ping_sheng_fast (String.make 1 char)) chars

(** 快速检查字符串是否全部为仄声 *)
let is_all_ze_sheng str =
  let chars = String.to_seq str |> List.of_seq in
  List.for_all (fun char -> is_ze_sheng_fast (String.make 1 char)) chars

(** {2 统计信息函数} *)

(** 获取音韵数据库大小 *)
let get_rhyme_database_size () =
  ensure_initialized ();
  Hashtbl.length rhyme_lookup_table

(** 获取扩展音韵数据库大小 *)
let get_expanded_rhyme_database_size () =
  ensure_initialized ();
  Hashtbl.length expanded_rhyme_lookup_table

(** 获取所有韵组列表 *)
let get_all_rhyme_groups () =
  ensure_initialized ();
  let groups = Hashtbl.fold (fun _ group acc -> group :: acc) rhyme_group_lookup_table [] in
  List.sort_uniq compare groups

(** 获取所有韵类列表 *)
let get_all_rhyme_categories () =
  ensure_initialized ();
  let categories =
    Hashtbl.fold (fun _ category acc -> category :: acc) rhyme_category_lookup_table []
  in
  List.sort_uniq compare categories

(** 按韵组分组字符 *)
let group_chars_by_rhyme_group () =
  ensure_initialized ();
  let groups = Hashtbl.create 32 in
  Hashtbl.iter
    (fun char group ->
      let chars = try Hashtbl.find groups group with Not_found -> [] in
      Hashtbl.replace groups group (char :: chars))
    rhyme_group_lookup_table;
  Hashtbl.fold (fun group chars acc -> (group, List.rev chars) :: acc) groups []

(** 按韵类分组字符 *)
let group_chars_by_rhyme_category () =
  ensure_initialized ();
  let categories = Hashtbl.create 8 in
  Hashtbl.iter
    (fun char category ->
      let chars = try Hashtbl.find categories category with Not_found -> [] in
      Hashtbl.replace categories category (char :: chars))
    rhyme_category_lookup_table;
  Hashtbl.fold (fun category chars acc -> (category, List.rev chars) :: acc) categories []

(** {2 性能测试函数} *)

(** 测试哈希表查询性能 *)
let benchmark_lookup_performance test_chars iterations =
  ensure_initialized ();
  let start_time = Unix.gettimeofday () in
  for _i = 1 to iterations do
    List.iter (fun char -> ignore (lookup_rhyme_fast char)) test_chars
  done;
  let end_time = Unix.gettimeofday () in
  end_time -. start_time

(** 测试列表查询性能 *)
let benchmark_list_performance test_chars iterations =
  let start_time = Unix.gettimeofday () in
  for _i = 1 to iterations do
    List.iter (fun char -> ignore (is_in_expanded_rhyme_database char)) test_chars
  done;
  let end_time = Unix.gettimeofday () in
  end_time -. start_time

(** 比较查询性能 *)
let compare_performance test_chars iterations =
  let hash_time = benchmark_lookup_performance test_chars iterations in
  let list_time = benchmark_list_performance test_chars iterations in
  let speedup = list_time /. hash_time in
  (hash_time, list_time, speedup)

(** {2 缓存管理} *)

(** 清空所有缓存 *)
let clear_all_caches () =
  Hashtbl.clear rhyme_lookup_table;
  Hashtbl.clear expanded_rhyme_lookup_table;
  Hashtbl.clear rhyme_group_lookup_table;
  Hashtbl.clear rhyme_category_lookup_table

(** 重新初始化缓存 *)
let refresh_caches () =
  clear_all_caches ();
  initialize_rhyme_lookup ()

(** 获取缓存统计信息 *)
let get_cache_stats () =
  ensure_initialized ();
  {|
缓存统计信息：
- 音韵查询表大小: |}
  ^ string_of_int (Hashtbl.length rhyme_lookup_table)
  ^ {|
- 扩展音韵查询表大小: |}
  ^ string_of_int (Hashtbl.length expanded_rhyme_lookup_table)
  ^ {|
- 韵组查询表大小: |}
  ^ string_of_int (Hashtbl.length rhyme_group_lookup_table)
  ^ {|
- 韵类查询表大小: |}
  ^ string_of_int (Hashtbl.length rhyme_category_lookup_table)
  ^ {|
|}

(** 模块初始化 *)
let () = initialize_rhyme_lookup ()
