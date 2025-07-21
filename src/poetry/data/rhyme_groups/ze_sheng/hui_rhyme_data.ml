(** 灰韵组数据模块 - 骆言诗词编程特性

    灰回推开，灰飞烟灭韵苍茫。灰韵组包含"灰、回、推、开"等字符， 依《平水韵》传统分类，属仄声韵，意境深沉苍凉，为诗词创作提供厚重有力的韵律选择。

    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-19 - Phase 14.3 模块化重构 *)

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

(** {1 灰韵组字符数据} *)

(** 灰韵组核心字符：常用基础字符 *)
let hui_yun_core_chars =
  [
    ("灰", ZeSheng, HuiRhyme);
    ("回", ZeSheng, HuiRhyme);
    ("推", ZeSheng, HuiRhyme);
    ("开", ZeSheng, HuiRhyme);
    ("该", ZeSheng, HuiRhyme);
    ("改", ZeSheng, HuiRhyme);
    ("盖", ZeSheng, HuiRhyme);
    ("概", ZeSheng, HuiRhyme);
    ("钙", ZeSheng, HuiRhyme);
    ("溉", ZeSheng, HuiRhyme);
  ]

(** 灰韵组带字系列：带、戴、代等字符 *)
let hui_yun_dai_series =
  [
    ("戴", ZeSheng, HuiRhyme);
    ("带", ZeSheng, HuiRhyme);
    ("待", ZeSheng, HuiRhyme);
    ("代", ZeSheng, HuiRhyme);
    ("呆", ZeSheng, HuiRhyme);
    ("袋", ZeSheng, HuiRhyme);
    ("逮", ZeSheng, HuiRhyme);
    ("怠", ZeSheng, HuiRhyme);
    ("殆", ZeSheng, HuiRhyme);
    ("贷", ZeSheng, HuiRhyme);
  ]

(** 灰韵组买字系列：买、迈、麦等字符 *)
let hui_yun_mai_series =
  [
    ("埋", ZeSheng, HuiRhyme);
    ("买", ZeSheng, HuiRhyme);
    ("迈", ZeSheng, HuiRhyme);
    ("麦", ZeSheng, HuiRhyme);
    ("卖", ZeSheng, HuiRhyme);
    ("脉", ZeSheng, HuiRhyme);
  ]

(** 灰韵组拍字系列：拍、牌、排等字符 *)
let hui_yun_pai_series =
  [
    ("派", ZeSheng, HuiRhyme);
    ("拍", ZeSheng, HuiRhyme);
    ("牌", ZeSheng, HuiRhyme);
    ("排", ZeSheng, HuiRhyme);
    ("徘", ZeSheng, HuiRhyme);
  ]

(** 灰韵组柴字系列：柴、拆、豺等字符 *)
let hui_yun_chai_series =
  [
    ("差", ZeSheng, HuiRhyme);
    ("柴", ZeSheng, HuiRhyme);
    ("拆", ZeSheng, HuiRhyme);
    ("豺", ZeSheng, HuiRhyme);
  ]

(** 灰韵组菜字系列：菜、蔡、采等字符 *)
let hui_yun_cai_series =
  [
    ("蔡", ZeSheng, HuiRhyme);
    ("菜", ZeSheng, HuiRhyme);
    ("采", ZeSheng, HuiRhyme);
    ("彩", ZeSheng, HuiRhyme);
    ("财", ZeSheng, HuiRhyme);
    ("材", ZeSheng, HuiRhyme);
    ("才", ZeSheng, HuiRhyme);
    ("裁", ZeSheng, HuiRhyme);
    ("猜", ZeSheng, HuiRhyme);
  ]

(** 灰韵组来字系列：来、莱、赖等字符 *)
let hui_yun_lai_series =
  [
    ("来", ZeSheng, HuiRhyme);
    ("莱", ZeSheng, HuiRhyme);
    ("赖", ZeSheng, HuiRhyme);
    ("癞", ZeSheng, HuiRhyme);
    ("睐", ZeSheng, HuiRhyme);
    ("籁", ZeSheng, HuiRhyme);
  ]

(** 灰韵组海字系列：海、害、亥等字符 *)
let hui_yun_hai_series =
  [
    ("海", ZeSheng, HuiRhyme);
    ("害", ZeSheng, HuiRhyme);
    ("亥", ZeSheng, HuiRhyme);
    ("骇", ZeSheng, HuiRhyme);
  ]

(** 灰韵组岁字系列：岁、穗、随等字符 *)
let hui_yun_sui_series =
  [
    ("邃", ZeSheng, HuiRhyme);
    ("碎", ZeSheng, HuiRhyme);
    ("岁", ZeSheng, HuiRhyme);
    ("穗", ZeSheng, HuiRhyme);
    ("随", ZeSheng, HuiRhyme);
    ("髓", ZeSheng, HuiRhyme);
    ("遂", ZeSheng, HuiRhyme);
    ("隧", ZeSheng, HuiRhyme);
    ("祟", ZeSheng, HuiRhyme);
  ]

(** 灰韵组宗字系列：宗、综、踪等字符 *)
let hui_yun_zong_series =
  [
    ("崇", ZeSheng, HuiRhyme);
    ("宗", ZeSheng, HuiRhyme);
    ("综", ZeSheng, HuiRhyme);
    ("踪", ZeSheng, HuiRhyme);
    ("粽", ZeSheng, HuiRhyme);
    ("鬃", ZeSheng, HuiRhyme);
    ("棕", ZeSheng, HuiRhyme);
  ]

(** 灰韵组松字系列：松、耸、送等字符 *)
let hui_yun_song_series =
  [
    ("松", ZeSheng, HuiRhyme);
    ("耸", ZeSheng, HuiRhyme);
    ("送", ZeSheng, HuiRhyme);
    ("宋", ZeSheng, HuiRhyme);
    ("颂", ZeSheng, HuiRhyme);
    ("诵", ZeSheng, HuiRhyme);
    ("怂", ZeSheng, HuiRhyme);
    ("悚", ZeSheng, HuiRhyme);
  ]

(** 灰韵组从字系列：从、丛、聪等字符 *)
let hui_yun_cong_series =
  [
    ("从", ZeSheng, HuiRhyme);
    ("丛", ZeSheng, HuiRhyme);
    ("聪", ZeSheng, HuiRhyme);
    ("葱", ZeSheng, HuiRhyme);
    ("囱", ZeSheng, HuiRhyme);
  ]

(** 灰韵组冲字系列：冲、充、虫等字符 *)
let hui_yun_chong_series =
  [
    ("冲", ZeSheng, HuiRhyme);
    ("充", ZeSheng, HuiRhyme);
    ("虫", ZeSheng, HuiRhyme);
    ("重", ZeSheng, HuiRhyme);
    ("种", ZeSheng, HuiRhyme);
    ("钟", ZeSheng, HuiRhyme);
    ("终", ZeSheng, HuiRhyme);
  ]

(** 灰韵组东字系列：东、冬、中等字符 *)
let hui_yun_dong_series =
  [ ("冬", ZeSheng, HuiRhyme); ("东", ZeSheng, HuiRhyme); ("中", ZeSheng, HuiRhyme) ]

(** 灰韵组风字系列：风、峰、锋等字符 *)
let hui_yun_feng_series =
  [
    ("风", ZeSheng, HuiRhyme);
    ("峰", ZeSheng, HuiRhyme);
    ("锋", ZeSheng, HuiRhyme);
    ("丰", ZeSheng, HuiRhyme);
    ("封", ZeSheng, HuiRhyme);
    ("蜂", ZeSheng, HuiRhyme);
    ("逢", ZeSheng, HuiRhyme);
    ("缝", ZeSheng, HuiRhyme);
    ("奉", ZeSheng, HuiRhyme);
  ]

(** 灰韵组繁体字系列：传统字符保持文化传承 *)
let hui_yun_traditional_series =
  [
    ("紅", ZeSheng, HuiRhyme);
    ("東", ZeSheng, HuiRhyme);
    ("鳳", ZeSheng, HuiRhyme);
    ("經", ZeSheng, HuiRhyme);
    ("聰", ZeSheng, HuiRhyme);
    ("從", ZeSheng, HuiRhyme);
    ("豐", ZeSheng, HuiRhyme);
    ("龍", ZeSheng, HuiRhyme);
    ("龔", ZeSheng, HuiRhyme);
  ]

(** JSON数据加载器模块 *)
module DataLoader = struct
  let find_data_file () =
    let candidates = [
      "data/poetry/rhyme_groups/ze_sheng/hui_rhyme_data.json";  (* 项目根目录 *)
      "../data/poetry/rhyme_groups/ze_sheng/hui_rhyme_data.json";  (* 从test目录 *)
      "../../data/poetry/rhyme_groups/ze_sheng/hui_rhyme_data.json";  (* 从深层test目录 *)
      "../../../data/poetry/rhyme_groups/ze_sheng/hui_rhyme_data.json";  (* 从build目录访问 *)
      "../../../../data/poetry/rhyme_groups/ze_sheng/hui_rhyme_data.json";  (* 从更深层访问 *)
    ] in
    List.find (fun path -> Sys.file_exists path) candidates
  
  let parse_character json =
    let open Yojson.Basic.Util in
    let char = json |> member "char" |> to_string in
    let category_str = json |> member "category" |> to_string in
    let group_str = json |> member "group" |> to_string in
    let category = match category_str with
      | "ZeSheng" -> ZeSheng
      | "PingSheng" -> PingSheng
      | "ShangSheng" -> ShangSheng
      | "QuSheng" -> QuSheng
      | "RuSheng" -> RuSheng
      | _ -> ZeSheng
    in
    let group = match group_str with
      | "HuiRhyme" -> HuiRhyme
      | _ -> HuiRhyme
    in
    (char, category, group)
  
  let load_character_series series_name =
    try
      let data_file = find_data_file () in
      let json = Yojson.Basic.from_file data_file in
      let open Yojson.Basic.Util in
      let series = json |> member "character_series" |> member series_name in
      let characters = series |> member "characters" |> to_list in
      List.map parse_character characters
    with
    | Not_found ->
        Printf.eprintf "警告: 无法找到灰韵组数据文件\n";
        []
    | Sys_error msg ->
        Printf.eprintf "警告: 无法加载灰韵组数据文件: %s\n" msg;
        []
    | Yojson.Json_error msg ->
        Printf.eprintf "警告: JSON解析错误: %s\n" msg;
        []
end

(** 灰韵组剩余字符：从JSON文件加载的传统生僻字符 *)
let hui_yun_remaining_chars = DataLoader.load_character_series "remaining_chars"

(** {1 灰韵组完整数据} *)

(** 灰韵组完整数据：模块化重构后的合成函数 *)
let hui_yun_ze_sheng =
  hui_yun_core_chars @ hui_yun_dai_series @ hui_yun_mai_series @ hui_yun_pai_series
  @ hui_yun_chai_series @ hui_yun_cai_series @ hui_yun_lai_series @ hui_yun_hai_series
  @ hui_yun_sui_series @ hui_yun_zong_series @ hui_yun_song_series @ hui_yun_cong_series
  @ hui_yun_chong_series @ hui_yun_dong_series @ hui_yun_feng_series @ hui_yun_traditional_series
  @ hui_yun_remaining_chars

(** {1 数据接口函数} *)

(** 获取灰韵组所有字符数据 *)
let get_hui_rhyme_data () = hui_yun_ze_sheng

(** 获取灰韵组字符数量 *)
let get_hui_rhyme_count () = List.length hui_yun_ze_sheng

(** 检查字符是否属于灰韵组 *)
let is_hui_rhyme_char char = List.exists (fun (c, _, _) -> c = char) hui_yun_ze_sheng

(** 获取灰韵组所有字符列表 *)
let get_hui_rhyme_chars () = List.map (fun (c, _, _) -> c) hui_yun_ze_sheng
