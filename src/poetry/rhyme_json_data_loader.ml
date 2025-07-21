(** 韵律数据JSON加载器 - 骆言诗词编程特性技术债务重构

    此模块负责从JSON文件加载诗词韵律数据，替代原有的硬编码数据结构。 实现数据与代码分离，提高可维护性和扩展性。

    @author 骆言诗词编程团队
    @version 2.0
    @since 2025-07-20 - 技术债务重构 Fix #724 *)

open Yojson.Safe.Util

(** 韵律类型定义 - 与原有模块保持兼容 *)
type rhyme_category = PingSheng | ZeSheng | ShangSheng | QuSheng | RuSheng

type rhyme_group =
  | AnRhyme
  | SiRhyme
  | TianRhyme
  | WangRhyme
  | QuRhyme
  | YuRhyme
  | HuaRhyme
  | FengRhyme
  | YueRhyme
  | XueRhyme
  | JiangRhyme
  | HuiRhyme
  | UnknownRhyme

type rhyme_char_data = { char : string; category : rhyme_category; group : rhyme_group }
(** 字符数据记录 *)

type rhyme_series = { name : string; description : string; characters : rhyme_char_data list }
(** 韵律数据系列 *)

type rhyme_metadata = {
  name : string;
  description : string;
  author : string;
  version : string;
  total_characters : int;
  rhyme_category : rhyme_category;
  rhyme_group : rhyme_group;
}
(** 韵律数据元信息 *)

type rhyme_data = {
  metadata : rhyme_metadata;
  series : rhyme_series list;
  all_characters : rhyme_char_data list;
}
(** 完整韵律数据 *)

(** 韵律类型字符串转换 *)
let rhyme_category_of_string = function
  | "PingSheng" -> PingSheng
  | "ZeSheng" -> ZeSheng
  | "ShangSheng" -> ShangSheng
  | "QuSheng" -> QuSheng
  | "RuSheng" -> RuSheng
  | s -> failwith ("解析错误：无效的韵律类别: " ^ s)

let rhyme_group_of_string = function
  | "AnRhyme" -> AnRhyme
  | "SiRhyme" -> SiRhyme
  | "TianRhyme" -> TianRhyme
  | "WangRhyme" -> WangRhyme
  | "QuRhyme" -> QuRhyme
  | "YuRhyme" -> YuRhyme
  | "HuaRhyme" -> HuaRhyme
  | "FengRhyme" -> FengRhyme
  | "YueRhyme" -> YueRhyme
  | "XueRhyme" -> XueRhyme
  | "JiangRhyme" -> JiangRhyme
  | "HuiRhyme" -> HuiRhyme
  | _ -> UnknownRhyme

(** JSON字符数据解析 *)
let parse_char_data json =
  let char = json |> member "char" |> to_string in
  let category = json |> member "category" |> to_string |> rhyme_category_of_string in
  let group = json |> member "group" |> to_string |> rhyme_group_of_string in
  { char; category; group }

(** JSON系列数据解析 *)
let parse_series_data name json =
  let description = json |> member "description" |> to_string in
  let characters = json |> member "characters" |> to_list |> List.map parse_char_data in
  { name; description; characters }

(** JSON元信息解析 *)
let parse_metadata json =
  let name = json |> member "name" |> to_string in
  let description = json |> member "description" |> to_string in
  let author = json |> member "author" |> to_string in
  let version = json |> member "version" |> to_string in
  let total_characters = json |> member "total_characters" |> to_int in
  let rhyme_category = json |> member "rhyme_category" |> to_string |> rhyme_category_of_string in
  let rhyme_group = json |> member "rhyme_group" |> to_string |> rhyme_group_of_string in
  { name; description; author; version; total_characters; rhyme_category; rhyme_group }

(** 从JSON文件加载韵律数据 *)
let load_rhyme_data_from_json file_path =
  try
    let json = Yojson.Safe.from_file file_path in
    let metadata = json |> member "metadata" |> parse_metadata in
    let character_series = json |> member "character_series" in

    let series =
      [
        parse_series_data "core_chars" (character_series |> member "core_chars");
        parse_series_data "dai_series" (character_series |> member "dai_series");
        parse_series_data "mai_series" (character_series |> member "mai_series");
        parse_series_data "pai_series" (character_series |> member "pai_series");
        parse_series_data "chai_series" (character_series |> member "chai_series");
        parse_series_data "cai_series" (character_series |> member "cai_series");
        parse_series_data "lai_series" (character_series |> member "lai_series");
        parse_series_data "hai_series" (character_series |> member "hai_series");
      ]
    in

    let all_characters = List.concat (List.map (fun s -> s.characters) series) in

    { metadata; series; all_characters }
  with
  | Sys_error msg -> failwith ("系统错误：JSON文件加载失败: " ^ msg)
  | Yojson.Json_error msg -> failwith ("解析错误：JSON解析错误: " ^ msg)
  | exn -> failwith ("系统错误：韵律数据加载意外错误: " ^ Printexc.to_string exn)

(** 缓存管理 *)
let rhyme_data_cache = ref None

(** 获取灰韵组数据 - 兼容原有接口 *)
let get_hui_rhyme_data () =
  match !rhyme_data_cache with
  | Some data -> data.all_characters
  | None ->
      let data =
        load_rhyme_data_from_json "data/poetry/rhyme_groups/ze_sheng/hui_rhyme_data.json"
      in
      rhyme_data_cache := Some data;
      data.all_characters

(** 获取灰韵组字符数量 - 兼容原有接口 *)
let get_hui_rhyme_count () =
  match !rhyme_data_cache with
  | Some data -> data.metadata.total_characters
  | None ->
      let data =
        load_rhyme_data_from_json "data/poetry/rhyme_groups/ze_sheng/hui_rhyme_data.json"
      in
      rhyme_data_cache := Some data;
      data.metadata.total_characters

(** 检查字符是否属于灰韵组 - 兼容原有接口 *)
let is_hui_rhyme_char char =
  let data = get_hui_rhyme_data () in
  List.exists (fun char_data -> char_data.char = char) data

(** 获取所有灰韵组字符列表 - 兼容原有接口 *)
let get_hui_rhyme_chars () =
  let data = get_hui_rhyme_data () in
  List.map (fun char_data -> char_data.char) data

(** 重置缓存 - 用于测试和重新加载 *)
let reset_cache () = rhyme_data_cache := None

(** 数据统计和调试信息 *)
let get_statistics () =
  match !rhyme_data_cache with
  | Some data ->
      let series_count = List.length data.series in
      let char_count = List.length data.all_characters in
      Printf.sprintf "韵律数据统计: %d个系列, %d个字符" series_count char_count
  | None -> "韵律数据未加载"
