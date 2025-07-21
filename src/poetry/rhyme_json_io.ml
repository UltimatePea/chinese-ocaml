(** 韵律JSON文件I/O操作

    处理韵律数据文件的读取，提供安全的文件操作和错误处理。

    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-20 - Phase 29 rhyme_json_loader重构 *)

open Rhyme_json_types
open Rhyme_json_parser
open Rhyme_json_cache

(** {1 配置} *)

(** 默认数据文件路径 *)
let default_data_file = "data/poetry/rhyme_groups/rhyme_data.json"

(** {1 文件操作函数} *)

(** 安全地读取文件内容 *)
let safe_read_file filename =
  try
    let ic = open_in filename in
    let content = really_input_string ic (in_channel_length ic) in
    close_in ic;
    content
  with
  | Sys_error msg -> raise (Rhyme_data_not_found ("文件读取失败: " ^ msg))
  | _ -> raise (Rhyme_data_not_found ("文件读取时发生未知错误: " ^ filename))

(** {1 数据加载函数} *)

(** 从文件加载韵律数据 *)
let load_rhyme_data_from_file ?(filename = default_data_file) () =
  try
    let content = safe_read_file filename in
    let rhyme_groups = parse_nested_json content in
    let data = { rhyme_groups; metadata = [] } in
    set_cached_data data;
    data
  with
  | Json_parse_error msg -> raise (Json_parse_error ("JSON解析错误: " ^ msg))
  | Rhyme_data_not_found msg -> raise (Rhyme_data_not_found msg)
  | exn -> raise (Json_parse_error ("加载韵律数据时发生异常: " ^ Printexc.to_string exn))

(** 获取韵律数据（支持缓存） *)
let get_rhyme_data ?(force_reload = false) () =
  if force_reload then (
    clear_cache ();
    load_rhyme_data_from_file ())
  else if is_cache_valid () then get_cached_data ()
  else load_rhyme_data_from_file ()
