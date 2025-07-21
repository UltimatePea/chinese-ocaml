(** 鱼韵组数据模块 - 第二阶段技术债务重构版本
 
    基于数据外化重构，将原有硬编码的长函数数据移动到外部JSON文件，
    实现数据与代码分离，大幅减少代码行数，提升可维护性。
    
    修复 Issue #801 - 技术债务改进第二阶段：超长函数重构和数据外化
    
    @author 骆言诗词编程团队
    @version 2.0 (数据外化重构版)
    @since 2025-07-21 - 技术债务改进第二阶段 *)

open Rhyme_group_types
open Yojson.Safe.Util

(** {1 数据加载异常处理} *)

exception Yu_rhyme_data_error of string

(** {1 数据文件路径配置} *)

(** 获取数据文件路径 *)
let get_data_file_path filename =
  let rec find_project_root dir =
    let dune_project = Filename.concat dir "dune-project" in
    if Sys.file_exists dune_project then dir
    else
      let parent = Filename.dirname dir in
      if parent = dir then 
        (* Reached filesystem root, fallback to current directory *)
        Sys.getcwd ()
      else find_project_root parent
  in
  let project_root = find_project_root (Sys.getcwd ()) in
  Filename.concat (Filename.concat project_root "data/poetry/rhyme_groups") filename

(** 鱼韵组数据文件路径 *)
let yu_rhyme_data_file = get_data_file_path "yu_rhyme.json"

(** {1 JSON数据解析} *)

(** 解析字符组数据 *)
let parse_character_group json group_name =
  try
    let group_json = json |> member "character_groups" |> member group_name in
    let characters = group_json |> member "characters" |> to_list |> List.map to_string in
    characters
  with
  | Type_error (msg, _) -> 
    raise (Yu_rhyme_data_error (Printf.sprintf "解析字符组 '%s' 失败: %s" group_name msg))
  | _ -> 
    raise (Yu_rhyme_data_error (Printf.sprintf "字符组 '%s' 不存在" group_name))

(** {1 懒加载数据缓存} *)

(** 数据缓存 *)
let json_data_cache = ref None

(** 获取JSON数据 (懒加载) *)
let get_json_data () =
  match !json_data_cache with
  | Some data -> data
  | None ->
    try
      let data = Yojson.Safe.from_file yu_rhyme_data_file in
      json_data_cache := Some data;
      data
    with
    | Sys_error msg -> 
      raise (Yu_rhyme_data_error (Printf.sprintf "无法读取数据文件: %s" msg))
    | Yojson.Json_error msg ->
      raise (Yu_rhyme_data_error (Printf.sprintf "JSON格式错误: %s" msg))

(** {1 数据获取函数} *)

(** 获取鱼韵组核心字符数据 *)
let yu_yun_core_chars =
  lazy (
    let json = get_json_data () in
    parse_character_group json "core_chars"
  )

(** 获取鱼韵组贾价系列字符数据 *)
let yu_yun_jia_chars =
  lazy (
    let json = get_json_data () in
    parse_character_group json "jia_chars"
  )

(** 获取鱼韵组棋期系列字符数据 *)
let yu_yun_qi_chars =
  lazy (
    let json = get_json_data () in
    parse_character_group json "qi_chars"
  )

(** 获取鱼韵组扩展鱼类字符数据 *)
let yu_yun_fish_chars =
  lazy (
    let json = get_json_data () in
    parse_character_group json "fish_chars"
  )

(** {1 数据合成函数} *)

(** 鱼韵组平声韵数据 (懒加载) *)
let yu_yun_ping_sheng =
  lazy (
    List.concat [
      create_rhyme_data (Lazy.force yu_yun_core_chars) PingSheng YuRhyme;
      create_rhyme_data (Lazy.force yu_yun_jia_chars) PingSheng YuRhyme;
      create_rhyme_data (Lazy.force yu_yun_qi_chars) PingSheng YuRhyme;
      create_rhyme_data (Lazy.force yu_yun_fish_chars) PingSheng YuRhyme;
    ]
  )

(** {1 统计信息函数 (兼容性接口)} *)

(** 获取鱼韵组字符总数 *)
let yu_yun_char_count = 
  lazy (List.length (Lazy.force yu_yun_ping_sheng))

(** 获取鱼韵组核心字符数量 *)
let yu_yun_core_count = 
  lazy (List.length (Lazy.force yu_yun_core_chars))

(** 获取鱼韵组贾价系列字符数量 *)
let yu_yun_jia_count = 
  lazy (List.length (Lazy.force yu_yun_jia_chars))

(** 获取鱼韵组棋期系列字符数量 *)
let yu_yun_qi_count = 
  lazy (List.length (Lazy.force yu_yun_qi_chars))

(** 获取鱼韵组鱼类扩展字符数量 *)
let yu_yun_fish_count = 
  lazy (List.length (Lazy.force yu_yun_fish_chars))

(** {1 向后兼容性接口} *)

(** 提供与原始模块兼容的即时访问接口 *)
module Compatibility = struct
  (** 立即获取核心字符列表 *)
  let get_yu_yun_core_chars () = Lazy.force yu_yun_core_chars
  
  (** 立即获取贾价系列字符列表 *)  
  let get_yu_yun_jia_chars () = Lazy.force yu_yun_jia_chars
  
  (** 立即获取棋期系列字符列表 *)
  let get_yu_yun_qi_chars () = Lazy.force yu_yun_qi_chars
  
  (** 立即获取鱼类扩展字符列表 *)
  let get_yu_yun_fish_chars () = Lazy.force yu_yun_fish_chars
  
  (** 立即获取平声韵数据 *)
  let get_yu_yun_ping_sheng () = Lazy.force yu_yun_ping_sheng
  
  (** 立即获取字符总数 *)
  let get_yu_yun_char_count () = Lazy.force yu_yun_char_count
  
  (** 立即获取核心字符数量 *)
  let get_yu_yun_core_count () = Lazy.force yu_yun_core_count
  
  (** 立即获取贾价系列字符数量 *)
  let get_yu_yun_jia_count () = Lazy.force yu_yun_jia_count
  
  (** 立即获取棋期系列字符数量 *)
  let get_yu_yun_qi_count () = Lazy.force yu_yun_qi_count
  
  (** 立即获取鱼类扩展字符数量 *)
  let get_yu_yun_fish_count () = Lazy.force yu_yun_fish_count
end