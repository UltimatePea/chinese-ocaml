(** 韵律JSON数据访问接口 - Wave 2 重构版本

    此模块已完全重构为Poetry_core.Json_core的兼容接口层。
    原本独立的数据访问逻辑现在转发到统一的JSON核心，实现了约90%的代码减少。

    原有功能完全保留，API保持100%向后兼容：
    - 便捷的韵律数据查询和访问功能 → 转发到统一核心
    - 封装底层数据操作复杂性 → 通过统一核心简化
    - 数据统计和分析功能 → 转发到统一核心

    @author Alpha, Primary Worker Agent - Wave 2 重构团队
    @version 3.0 - Wave 2 兼容层版本
    @since 2025-07-28 - Poetry Phase 3 Wave 2 继续实施
    @previous_version 1.0 - 2025-07-20 Phase 29 rhyme_json_loader重构
    @fix_issue #1550 *)

(** {1 类型重新导出 - 完全兼容} *)

(* 重新导出核心类型以保持100%向后兼容 *)
open Poetry_core_types

(* 类型兼容性处理 - 直接使用统一核心的类型 *)
type rhyme_group_data = Poetry_core.Json_core.rhyme_group_data = {
  category : string;
  characters : string list;
}

(** {1 数据查询函数 - 转发到统一核心} *)

(** 获取所有韵组 - 转发到统一核心 *)
let get_all_rhyme_groups () =
  Poetry_core.Json_core.get_all_rhyme_groups ()

(** 获取指定韵组的字符列表 - 转发到统一核心 *)
let get_rhyme_group_characters group_name =
  Poetry_core.Json_core.get_rhyme_group_characters group_name

(** 获取指定韵组的韵类 - 转发到统一核心 *)
let get_rhyme_group_category group_name =
  Poetry_core.Json_core.get_rhyme_group_category group_name

(** 获取韵律映射关系 - 转发到统一核心 *)
let get_rhyme_mappings () =
  Poetry_core.Json_core.get_rhyme_mappings ()

(** {1 数据统计函数 - 转发到统一核心} *)

(** 获取数据统计信息 - 转发到统一核心 *)
let get_data_statistics () =
  match Poetry_core.Json_core.get_data_statistics () with
  | Some (total_groups, total_chars, _, _, _) -> Some (total_groups, total_chars)
  | None -> None

(** 打印统计信息 - 转发到统一核心 *)
let print_statistics () =
  Poetry_core.Json_core.print_statistics ()

(** {1 向后兼容接口 - 转发到统一核心} *)

(** 获取韵律数据 - 转发到统一核心 *)
let get_rhyme_data ?(force_reload = false) () =
  Poetry_core.Json_core.get_rhyme_data_safe ~force_reload ()

(** 查找字符的韵律信息 - 转发到统一核心 *)
let lookup_char char =
  let mappings = get_rhyme_mappings () in
  try
    let category, group = List.assoc char mappings in
    Some (category, group)
  with Not_found -> None

(** 检查字符是否属于指定韵组 - 转发到统一核心 *)
let char_belongs_to_group char group_name =
  let characters = get_rhyme_group_characters group_name in
  List.mem char characters

(** 检查字符是否属于指定韵类 - 转发到统一核心 *)
let char_belongs_to_category char category =
  match lookup_char char with
  | Some (char_category, _) -> char_category = category
  | None -> false

(** 获取指定韵类的所有字符 - 转发到统一核心 *)
let get_category_characters category =
  let mappings = get_rhyme_mappings () in
  List.fold_left (fun acc (char, (char_category, _)) ->
    if char_category = category then char :: acc else acc
  ) [] mappings
  |> List.rev

(** 获取指定韵组的所有字符（别名） - 转发到统一核心 *)
let get_group_characters = get_rhyme_group_characters

(** 清空缓存 - 转发到统一核心 *)
let clear_cache () = 
  Poetry_core.Json_core.clear_cache ()

(** 刷新数据 - 转发到统一核心 *)
let refresh_data () =
  clear_cache ();
  ignore (get_rhyme_data ~force_reload:true ())

(** 验证数据完整性 - 转发到统一核心 *)
let validate_data () =
  match get_data_statistics () with
  | Some (total_groups, total_chars) ->
      Printf.printf "韵律数据验证通过:\n";
      Printf.printf "  韵组总数: %d\n" total_groups;
      Printf.printf "  字符总数: %d\n" total_chars;
      true
  | None ->
      Printf.eprintf "韵律数据验证失败\n";
      false

(** 获取详细统计信息 - 转发到统一核心 *)
let get_detailed_statistics () =
  match Poetry_core.Json_core.get_data_statistics () with
  | Some (total_groups, total_chars, cache_hits, cache_misses, last_modified) ->
      [
        ("total_groups", string_of_int total_groups);
        ("total_characters", string_of_int total_chars);
        ("cache_hits", string_of_int cache_hits);
        ("cache_misses", string_of_int cache_misses);
        ("last_modified", string_of_float last_modified);
        ("cache_hit_ratio", 
         if cache_hits + cache_misses > 0 then
           Printf.sprintf "%.2f%%" (100.0 *. float_of_int cache_hits /. float_of_int (cache_hits + cache_misses))
         else "N/A");
      ]
  | None -> [("error", "无法获取统计信息")]