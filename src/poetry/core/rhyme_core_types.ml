(** 韵律核心类型定义模块 - 骆言诗词编程特性

    盖古之诗者，音韵为要。声韵调谐，方称佳构。 此模块统一定义所有音韵类型，为整个诗词系统提供基础类型支撑。 消除项目中30+文件的类型重复定义问题。

    重构目标：
    - 统一所有韵律相关类型定义
    - 消除rhyme_types.ml、poetry_types_consolidated.ml等文件的重复
    - 为整个诗词模块提供单一权威类型源

    @author 骆言诗词编程团队
    @version 3.0 - 核心重构版本
    @since 2025-07-25 *)

(** {1 基础音韵类型} *)

(** 声韵分类：依古韵书分平仄入声 承袭《广韵》、《集韵》等韵书传统分类法 *)
type rhyme_category =
  | PingSheng  (** 平声韵 - 音平而长，如天籁之响 *)
  | ZeSheng  (** 仄声韵 - 音仄而促，如金石之声 *)
  | ShangSheng  (** 上声韵 - 音上扬，如询问之态 *)
  | QuSheng  (** 去声韵 - 音下降，如叹息之音 *)
  | RuSheng  (** 入声韵 - 音促而急，如鼓点之节 *)

(** 韵组分类：按韵书传统分组，同组字可相押 基于古代韵书的韵组划分，包含常用诗词韵组 *)
type rhyme_group =
  (* 传统经典韵组 *)
  | AnRhyme  (** 安韵组 - 含山、间、闲等字，音韵和谐 *)
  | SiRhyme  (** 思韵组 - 含时、诗、知等字，情思绵绵 *)
  | TianRhyme  (** 天韵组 - 含年、先、田等字，天籁之音 *)
  | WangRhyme  (** 望韵组 - 含放、向、响等字，远望之意 *)
  | QuRhyme  (** 去韵组 - 含路、度、步等字，去声之韵 *)
  (* 扩展韵组 - Phase 1 Enhancement *)
  | YuRhyme  (** 鱼韵组 - 含鱼、书、居等字，渔樵江渚 *)
  | HuaRhyme  (** 花韵组 - 含花、霞、家等字，春花秋月 *)
  | FengRhyme  (** 风韵组 - 含风、送、中等字，秋风萧瑟 *)
  | YueRhyme  (** 月韵组 - 含月、雪、节等字，秋月如霜 *)
  | XueRhyme  (** 雪韵组 - 含雪、绝、切等字，雪花飞舞 *)
  | JiangRhyme  (** 江韵组 - 含江、窗、双等字，大江东去 *)
  | HuiRhyme  (** 灰韵组 - 含灰、回、推等字，灰飞烟灭 *)
  | UnknownRhyme  (** 未知韵组 - 韵书未载，待考证者 *)

(** {2 分析报告类型} *)

type char_rhyme_info = {
  character : string;  (** 字符内容 *)
  rhyme_category : rhyme_category;  (** 声韵分类 *)
  rhyme_group : rhyme_group;  (** 所属韵组 *)
  confidence : float;  (** 分析置信度 0.0-1.0 *)
}
(** 单个字符的韵律分析结果 *)

type verse_rhyme_analysis = {
  verse_text : string;  (** 诗句原文 *)
  rhyme_ending : string option;  (** 韵脚字符 *)
  dominant_rhyme_group : rhyme_group;  (** 主要韵组 *)
  dominant_rhyme_category : rhyme_category;  (** 主要声韵类别 *)
  char_analysis : char_rhyme_info list;  (** 逐字韵律分析 *)
  rhyme_quality_score : float;  (** 韵律质量评分 *)
}
(** 诗句韵律分析报告：详细记录诗句的音韵特征 包含韵脚、韵组、韵类及逐字分析，为诗词创作提供全面指导 *)

type poem_rhyme_analysis = {
  verses : string list;  (** 诗句列表 *)
  verse_analyses : verse_rhyme_analysis list;  (** 各句分析结果 *)
  overall_rhyme_groups : rhyme_group list;  (** 全诗使用的韵组 *)
  overall_rhyme_categories : rhyme_category list;  (** 全诗使用的声韵类别 *)
  rhyme_consistency_score : float;  (** 韵律一致性评分 *)
  artistic_quality_score : float;  (** 艺术质量评分 *)
  suggestions : string list;  (** 改进建议 *)
}
(** 整体诗篇韵律分析报告 *)

(** {3 数据结构类型} *)

type rhyme_data_entry = {
  character : string;  (** 字符 *)
  category : rhyme_category;  (** 声韵类别 *)
  group : rhyme_group;  (** 韵组 *)
  variants : string list;  (** 异体字或相关字 *)
  usage_frequency : float;  (** 使用频度 *)
}
(** 韵律数据条目：基础数据单元 *)

type rhyme_group_data = {
  group_name : rhyme_group;  (** 韵组名称 *)
  group_description : string;  (** 韵组描述 *)
  entries : rhyme_data_entry list;  (** 该韵组所有条目 *)
  example_poems : string list;  (** 典型用例诗句 *)
}
(** 韵组数据：某个韵组的完整信息 *)

(** {3 兼容性类型定义} *)

(** 兼容rhyme_types.ml的数据结构 *)
type rhyme_data_item = {
  character : string;  (** 字符 *)
  category : rhyme_category;  (** 韵类 *)
  group : rhyme_group;  (** 韵组 *)
  tone_value : int option;  (** 声调值（可选） *)
  frequency : float option;  (** 使用频率（可选） *)
  source : string;  (** 数据来源 *)
}

type compat_rhyme_group_data = {
  group : rhyme_group;
  items : rhyme_data_item list;
  metadata : (string * string) list;
}

type rhyme_database = {
  groups : compat_rhyme_group_data list;
  version : string;
  last_updated : string;
  sources : string list;
}

(** {4 配置和选项类型} *)

type analysis_config = {
  strict_mode : bool;  (** 严格模式：严格按古韵书分析 *)
  modern_adaptation : bool;  (** 现代适应：适应现代读音 *)
  confidence_threshold : float;  (** 置信度阈值 *)
  enable_suggestions : bool;  (** 启用改进建议 *)
}
(** 韵律分析配置 *)

type data_config = {
  data_sources : string list;  (** 数据源文件路径 *)
  cache_enabled : bool;  (** 启用缓存 *)
  cache_size_limit : int;  (** 缓存大小限制 *)
  auto_reload : bool;  (** 自动重新加载 *)
}
(** 数据加载配置 *)

(** {5 错误和异常类型} *)

(** 韵律分析错误类型 *)
type rhyme_error =
  | CharacterNotFound of string  (** 字符未在韵书中找到 *)
  | InvalidRhymeGroup of string  (** 无效韵组 *)
  | DataCorruption of string  (** 数据损坏 *)
  | ConfigurationError of string  (** 配置错误 *)
  | AnalysisFailure of string  (** 分析失败 *)

exception RhymeException of rhyme_error
(** 韵律异常 *)

(** {6 辅助类型定义} *)

type rhyme_match_result = {
  is_match : bool;  (** 是否匹配 *)
  match_quality : float;  (** 匹配质量 0.0-1.0 *)
  match_reason : string;  (** 匹配原因说明 *)
}
(** 韵律匹配结果 *)

type rhyme_suggestion = {
  suggestion_type : string;  (** 建议类型 *)
  original_char : string;  (** 原字符 *)
  suggested_chars : string list;  (** 建议字符列表 *)
  reason : string;  (** 建议理由 *)
  improvement_score : float;  (** 改进分数 *)
}
(** 韵律建议类型 *)

(** {7 JSON兼容类型} *)

type json_config = {
  pretty_print : bool;  (** 美化输出 *)
  include_metadata : bool;  (** 包含元数据 *)
  compression_level : int;  (** 压缩级别 *)
}
(** JSON序列化配置 *)

type simple_rhyme_info = { char : string; category : string; group : string }
(** 导出用于JSON的简化类型 *)

(** {8 兼容性工具函数} *)

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
  { character; category; group; tone_value = None; frequency = None; source = "unified_system" }

(** 创建增强韵律数据项 *)
let create_enhanced_rhyme_item character category group ?tone_value ?frequency ~source () =
  { character; category; group; tone_value; frequency; source }

(** 韵律数据项比较 *)
let compare_rhyme_items item1 item2 =
  let cmp_char = String.compare item1.character item2.character in
  if cmp_char <> 0 then cmp_char
  else
    let cmp_cat = compare item1.category item2.category in
    if cmp_cat <> 0 then cmp_cat else compare item1.group item2.group

(** 创建空韵律数据库 *)
let create_empty_database () =
  { groups = []; version = "3.0"; last_updated = "2025-07-28"; sources = [ "unified_system" ] }

(** 创建韵组数据容器 *)
let create_rhyme_group_data group items metadata : compat_rhyme_group_data = { group; items; metadata }

(** 获取韵组中的所有字符 *)
let get_characters_from_group (group_data : compat_rhyme_group_data) = 
  List.map (fun item -> item.character) group_data.items

(** 过滤韵律数据项 *)
let filter_by_category category items = List.filter (fun (item : rhyme_data_item) -> item.category = category) items

let filter_by_group group items = List.filter (fun (item : rhyme_data_item) -> item.group = group) items

(** 统计函数 *)
let count_items_by_category (database : rhyme_database) category =
  let all_items : rhyme_data_item list = 
    database.groups
    |> List.map (fun (group_data : compat_rhyme_group_data) -> group_data.items)
    |> List.flatten
  in
  all_items
  |> List.filter (fun (item : rhyme_data_item) -> item.category = category)
  |> List.length

let count_items_by_group (database : rhyme_database) group =
  let groups : compat_rhyme_group_data list = database.groups in
  groups
  |> List.find_opt (fun (group_data : compat_rhyme_group_data) -> group_data.group = group)
  |> Option.map (fun (group_data : compat_rhyme_group_data) -> List.length group_data.items)
  |> Option.value ~default:0

(** 查找函数 *)
let find_character_in_database (database : rhyme_database) character =
  let groups : compat_rhyme_group_data list = database.groups in
  groups
  |> List.map (fun (group_data : compat_rhyme_group_data) -> group_data.items)
  |> List.flatten
  |> List.find_opt (fun (item : rhyme_data_item) -> item.character = character)

(** 验证函数 *)
let validate_rhyme_data_item (item : rhyme_data_item) = String.length item.character > 0 && item.source <> ""

let validate_rhyme_database (database : rhyme_database) =
  let groups : compat_rhyme_group_data list = database.groups in
  database.version <> "" && database.last_updated <> ""
  && List.length database.sources > 0
  && List.for_all
       (fun (group_data : compat_rhyme_group_data) -> List.for_all validate_rhyme_data_item group_data.items)
       groups
