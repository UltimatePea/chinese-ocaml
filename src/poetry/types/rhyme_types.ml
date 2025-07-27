(** 韵律类型统一定义模块 - Single Source of Truth
    
    此模块是Poetry系统所有韵律类型的唯一权威来源。
    所有其他模块必须通过此模块引用韵律类型，禁止重复定义。
    
    技术债务修复：消除31个文件中的重复类型定义，建立统一类型系统。
    
    @author Alpha, 主要开发代理 - Poetry模块重构团队
    @version 2.0 (统一架构版)
    @since 2025-07-27
    @fix_issue #1501 *)

(** {1 核心韵律类型} *)

(** 韵类：按声调分类的基本韵律类别 *)
type rhyme_category =
  | PingSheng    (** 平声韵 - 音调平和，韵味悠长 *)
  | ZeSheng      (** 仄声韵 - 音调起伏，韵律跌宕 *)
  | ShangSheng   (** 上声韵 - 音调上扬，韵感清雅 *)
  | QuSheng      (** 去声韵 - 音调下降，韵律沉稳 *)
  | RuSheng      (** 入声韵 - 音调急促，韵味刚劲 *)

(** 韵组：按韵母分类的具体韵律组别 *)
type rhyme_group =
  | AnRhyme      (** 安韵组 - 安然自若，韵味平和 *)
  | SiRhyme      (** 思韵组 - 深思熟虑，韵致深远 *)
  | TianRhyme    (** 天韵组 - 天高云淡，韵律高远 *)
  | WangRhyme    (** 望韵组 - 望眼欲穿，韵情悠长 *)
  | QuRhyme      (** 去韵组 - 去留无意，韵味淡泊 *)
  | YuRhyme      (** 鱼韵组 - 鱼游春水，韵趣盎然 *)
  | HuaRhyme     (** 花韵组 - 花开花落，韵华天成 *)
  | FengRhyme    (** 风韵组 - 风流韵事，韵致飘逸 *)
  | YueRhyme     (** 月韵组 - 月圆月缺，韵律圆融 *)
  | XueRhyme     (** 雪韵组 - 雪花飞舞，韵味清冽 *)
  | JiangRhyme   (** 江韵组 - 大江东去，韵流不息 *)
  | HuiRhyme     (** 灰韵组 - 灰飞烟灭，韵意苍茫 *)
  | UnknownRhyme (** 未知韵组 - 待考证分类 *)

(** 韵律数据项：字符与其韵律属性的关联 *)
type rhyme_data_item = {
  character: string;           (** 字符 *)
  category: rhyme_category;    (** 韵类 *)
  group: rhyme_group;         (** 韵组 *)
  tone_value: int option;     (** 声调值（可选） *)
  frequency: float option;    (** 使用频率（可选） *)
  source: string;             (** 数据来源 *)
}

(** {1 数据容器类型} *)

(** 韵组数据容器 *)
type rhyme_group_data = {
  group: rhyme_group;
  items: rhyme_data_item list;
  metadata: (string * string) list;
}

(** 完整韵律数据库 *)
type rhyme_database = {
  groups: rhyme_group_data list;
  version: string;
  last_updated: string;
  sources: string list;
}

(** {1 工具函数} *)

(** 韵类转字符串 *)
let rhyme_category_to_string = function
  | PingSheng -> "平声"
  | ZeSheng -> "仄声"
  | ShangSheng -> "上声"
  | QuSheng -> "去声"
  | RuSheng -> "入声"

(** 字符串转韵类 *)
let string_to_rhyme_category = function
  | "平声" -> Some PingSheng
  | "仄声" -> Some ZeSheng
  | "上声" -> Some ShangSheng
  | "去声" -> Some QuSheng
  | "入声" -> Some RuSheng
  | _ -> None

(** 韵组转字符串 *)
let rhyme_group_to_string = function
  | AnRhyme -> "安韵"
  | SiRhyme -> "思韵"
  | TianRhyme -> "天韵"
  | WangRhyme -> "望韵"
  | QuRhyme -> "去韵"
  | YuRhyme -> "鱼韵"
  | HuaRhyme -> "花韵"
  | FengRhyme -> "风韵"
  | YueRhyme -> "月韵"
  | XueRhyme -> "雪韵"
  | JiangRhyme -> "江韵"
  | HuiRhyme -> "灰韵"
  | UnknownRhyme -> "未知韵"

(** 字符串转韵组 *)
let string_to_rhyme_group = function
  | "安韵" -> Some AnRhyme
  | "思韵" -> Some SiRhyme
  | "天韵" -> Some TianRhyme
  | "望韵" -> Some WangRhyme
  | "去韵" -> Some QuRhyme
  | "鱼韵" -> Some YuRhyme
  | "花韵" -> Some HuaRhyme
  | "风韵" -> Some FengRhyme
  | "月韵" -> Some YueRhyme
  | "雪韵" -> Some XueRhyme
  | "江韵" -> Some JiangRhyme
  | "灰韵" -> Some HuiRhyme
  | "未知韵" -> Some UnknownRhyme
  | _ -> None

(** 创建韵律数据项 *)
let create_rhyme_item character category group =
  {
    character;
    category;
    group;
    tone_value = None;
    frequency = None;
    source = "unified_system";
  }

(** 创建增强韵律数据项 *)
let create_enhanced_rhyme_item character category group ?tone_value ?frequency ~source () =
  {
    character;
    category;
    group;
    tone_value;
    frequency;
    source;
  }

(** 韵律数据项比较 *)
let compare_rhyme_items item1 item2 =
  let cmp_char = String.compare item1.character item2.character in
  if cmp_char <> 0 then cmp_char
  else
    let cmp_cat = compare item1.category item2.category in
    if cmp_cat <> 0 then cmp_cat
    else compare item1.group item2.group

(** 创建空韵律数据库 *)
let create_empty_database () =
  {
    groups = [];
    version = "2.0";
    last_updated = "2025-07-27";
    sources = ["unified_system"];
  }

(** 创建韵组数据容器 *)
let create_rhyme_group_data group items metadata =
  { group; items; metadata }

(** 获取韵组中的所有字符 *)
let get_characters_from_group group_data =
  List.map (fun item -> item.character) group_data.items

(** 过滤韵律数据项 *)
let filter_by_category category items =
  List.filter (fun item -> item.category = category) items

let filter_by_group group items =
  List.filter (fun item -> item.group = group) items

(** 统计函数 *)
let count_items_by_category database category =
  database.groups
  |> List.map (fun group_data -> group_data.items)
  |> List.flatten
  |> List.filter (fun item -> item.category = category)
  |> List.length

let count_items_by_group database group =
  database.groups
  |> List.find_opt (fun group_data -> group_data.group = group)
  |> Option.map (fun group_data -> List.length group_data.items)
  |> Option.value ~default:0

(** 查找函数 *)
let find_character_in_database database character =
  database.groups
  |> List.map (fun group_data -> group_data.items)
  |> List.flatten
  |> List.find_opt (fun item -> item.character = character)

(** 验证函数 *)
let validate_rhyme_data_item item =
  String.length item.character > 0 &&
  item.source <> ""

let validate_rhyme_database database =
  database.version <> "" &&
  database.last_updated <> "" &&
  List.length database.sources > 0 &&
  List.for_all (fun group_data ->
    List.for_all validate_rhyme_data_item group_data.items
  ) database.groups