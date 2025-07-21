(** 风韵组数据模块 - 骆言诗词编程特性 (重构版)

    风送中东，秋风萧瑟意无穷。风韵组包含"风、送、中、东"等字符， 依《平水韵》传统分类，属平声韵，意境壮阔豪放，为诗词创作提供飘逸豪迈的韵律选择。

    重构说明: 本模块已重构为从JSON数据文件加载韵律数据，提升可维护性和扩展性。
    原硬编码数据已外化到 data/poetry/rhyme_groups/ping_sheng/feng_rhyme_data.json

    @author 骆言诗词编程团队
    @version 2.0 - 技术债务清理重构版
    @since 2025-07-21 - Fix #792 长函数重构优化 *)

(** 使用统一的韵律类型定义 - 保持与主模块兼容 *)
type rhyme_category =
  | PingSheng (* 平声韵 *)
  | ZeSheng (* 仄声韵 *)
  | ShangSheng (* 上声韵 *)
  | QuSheng (* 去声韵 *)
  | RuSheng (* 入声韵 *)

type rhyme_group =
  | AnRhyme (* 安韵组 *)
  | SiRhyme (* 思韵组 *)
  | TianRhyme (* 天韵组 *)
  | WangRhyme (* 望韵组 *)
  | QuRhyme (* 去韵组 *)
  | YuRhyme (* 鱼韵组 *)
  | HuaRhyme (* 花韵组 *)
  | FengRhyme (* 风韵组 *)
  | YueRhyme (* 月韵组 *)
  | XueRhyme (* 雪韵组 *)
  | JiangRhyme (* 江韵组 *)
  | HuiRhyme (* 灰韵组 *)
  | UnknownRhyme (* 未知韵组 *)

(** JSON数据加载器模块 *)
module DataLoader = struct
  let find_data_file () =
    let candidates = [
      "data/poetry/rhyme_groups/ping_sheng/feng_rhyme_data.json";  (* 项目根目录 *)
      "../data/poetry/rhyme_groups/ping_sheng/feng_rhyme_data.json";  (* 从test目录 *)
      "../../data/poetry/rhyme_groups/ping_sheng/feng_rhyme_data.json";  (* 从深层test目录 *)
      "../../../data/poetry/rhyme_groups/ping_sheng/feng_rhyme_data.json";  (* 从build目录访问 *)
      "../../../../data/poetry/rhyme_groups/ping_sheng/feng_rhyme_data.json";  (* 从更深层访问 *)
    ] in
    List.find (fun path -> Sys.file_exists path) candidates
  
  let parse_character json =
    let open Yojson.Basic.Util in
    let char = json |> member "char" |> to_string in
    let category_str = json |> member "category" |> to_string in
    let group_str = json |> member "rhyme_group" |> to_string in
    let category = match category_str with
      | "PingSheng" -> PingSheng
      | "ZeSheng" -> ZeSheng
      | "ShangSheng" -> ShangSheng
      | "QuSheng" -> QuSheng
      | "RuSheng" -> RuSheng
      | _ -> PingSheng
    in
    let group = match group_str with
      | "FengRhyme" -> FengRhyme
      | _ -> FengRhyme
    in
    (char, category, group)
  
  let load_character_group group_name =
    try
      let data_file = find_data_file () in
      let json = Yojson.Basic.from_file data_file in
      let open Yojson.Basic.Util in
      let group = json |> member "character_groups" |> member group_name in
      let characters = group |> member "characters" |> to_list in
      List.map parse_character characters
    with
    | Not_found ->
        Printf.eprintf "警告: 无法找到风韵组数据文件\n";
        []
    | Sys_error msg ->
        Printf.eprintf "警告: 无法加载风韵组数据文件: %s\n" msg;
        []
    | Yojson.Json_error msg ->
        Printf.eprintf "警告: JSON解析错误: %s\n" msg;
        []

  let load_all_groups () =
    let group_names = [
      "basic_chars"; "chong_group"; "song_group"; "tong_group"; 
      "die_group"; "nian_group"; "lian_group"; "lie_group"; 
      "li_group"; "fish_group"
    ] in
    List.fold_left (fun acc group_name ->
      let chars = load_character_group group_name in
      acc @ chars
    ) [] group_names
end

(** {1 风韵组核心字符数据} - 从JSON文件加载的结构化数据 *)

(** 风韵基础字符组 - 从JSON文件加载的结构化数据 *)
let feng_yun_basic_chars = DataLoader.load_character_group "basic_chars"

(** 风韵充冲组 - 充冲虫崇等字 *)
let feng_yun_chong_group = DataLoader.load_character_group "chong_group"

(** 风韵松宋组 - 松宋颂等字 *)
let feng_yun_song_group = DataLoader.load_character_group "song_group"

(** 风韵同童组 - 同童通等字 *)
let feng_yun_tong_group = DataLoader.load_character_group "tong_group"

(** 风韵迭叠组 - 迭叠蝶等字 *)
let feng_yun_die_group = DataLoader.load_character_group "die_group"

(** 风韵年念组 - 年念捻等字 *)
let feng_yun_nian_group = DataLoader.load_character_group "nian_group"

(** 风韵连恋组 - 连恋莲等字 *)
let feng_yun_lian_group = DataLoader.load_character_group "lian_group"

(** 风韵猎烈组 - 猎烈列等字 *)
let feng_yun_lie_group = DataLoader.load_character_group "lie_group"

(** 风韵厉励组 - 厉励礼李等字 *)
let feng_yun_li_group = DataLoader.load_character_group "li_group"

(** 风韵鱼类字组 - 各种鱼类名称 *)
let feng_yun_fish_group = DataLoader.load_character_group "fish_group"

(** 风韵组平声韵数据 - 完整的风韵平声韵数据 *)
let feng_yun_ping_sheng = DataLoader.load_all_groups ()

(** {1 公共接口} *)

(** 获取风韵组的所有数据

    @return 风韵组的完整韵律数据列表 *)
let get_all_data () = feng_yun_ping_sheng

(** 获取风韵组字符数量统计

    @return 风韵组包含的字符总数 *)
let get_char_count () = List.length feng_yun_ping_sheng

(** 导出数据供外部模块使用 *)
let () = ()