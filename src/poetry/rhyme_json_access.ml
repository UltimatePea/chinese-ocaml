(** 韵律JSON数据访问接口
    
    提供便捷的韵律数据查询和访问功能，封装底层数据操作复杂性。
    
    @author 骆言诗词编程团队 
    @version 1.0
    @since 2025-07-20 - Phase 29 rhyme_json_loader重构 *)

open Rhyme_json_types

(** {1 数据查询函数} *)

(** 获取所有韵组 *)
let get_all_rhyme_groups () =
  let data = Rhyme_json_io.get_rhyme_data () in
  data.rhyme_groups

(** 获取指定韵组的字符列表 *)
let get_rhyme_group_characters group_name =
  let groups = get_all_rhyme_groups () in
  try
    let (_, group_data) = List.find (fun (name, _) -> name = group_name) groups in
    group_data.characters
  with
  | Not_found -> []

(** 获取指定韵组的韵类 *)
let get_rhyme_group_category group_name =
  let groups = get_all_rhyme_groups () in
  try
    let (_, group_data) = List.find (fun (name, _) -> name = group_name) groups in
    string_to_rhyme_category group_data.category
  with
  | Not_found -> PingSheng (* 默认平声 *)

(** 获取韵律映射关系 *)
let get_rhyme_mappings () =
  let groups = get_all_rhyme_groups () in
  let mappings = ref [] in
  List.iter (fun (group_name, group_data) ->
    let rhyme_category = string_to_rhyme_category group_data.category in
    let rhyme_group = string_to_rhyme_group group_name in
    (* 为每个字符创建映射 *)
    List.iter (fun char ->
      mappings := (char, (rhyme_category, rhyme_group)) :: !mappings
    ) group_data.characters
  ) groups;
  List.rev !mappings

(** {1 数据统计函数} *)

(** 获取数据统计信息 *)
let get_data_statistics () =
  try
    let data_opt = Rhyme_json_io.get_rhyme_data () in
    let total_groups = List.length data_opt.rhyme_groups in
    let total_chars = List.fold_left (fun acc (_, group_data) ->
      acc + List.length group_data.characters
    ) 0 data_opt.rhyme_groups in
    Some (total_groups, total_chars)
  with
  | _ -> None

(** 打印统计信息 *)
let print_statistics () =
  match get_data_statistics () with
  | Some (total_groups, total_chars) ->
    Printf.printf "韵律数据统计:\n";
    Printf.printf "  韵组总数: %d\n" total_groups;
    Printf.printf "  字符总数: %d\n" total_chars;
    Printf.printf "  平均每组字符数: %.1f\n" 
      (if total_groups > 0 then float_of_int total_chars /. float_of_int total_groups else 0.0)
  | None ->
    Printf.printf "无法获取韵律数据统计信息\n"