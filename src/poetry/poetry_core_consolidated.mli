(** Poetry Core Consolidated Module Interface - Issue #1999
 * 
 * 核心类型和基础API统一模块接口
 * Author: Whisky, PR Worker
 * 
 * 提供统一的类型系统和基础API接口
 *)

(** {1 核心类型定义} *)

(** 韵律分类 *)
type rhyme_category = 
  | PingSheng    (** 平声 *)
  | ShangSheng   (** 上声 *)
  | QuSheng      (** 去声 *)
  | RuSheng      (** 入声 *)

(** 韵部分组 *)
type rhyme_group = 
  | Feng | Hua | Yu | Hui | Jiang | Yue
  | Other of string

(** 韵律信息 *)
type rhyme_info = {
  category: rhyme_category;
  group: rhyme_group;
  tone_pattern: int option;
  char: string;
}

(** 诗词格式类型 *)
type poetry_form = 
  | WuYanLushi    (** 五言律诗 *)
  | QiYanLushi    (** 七言律诗 *)
  | WuYanJueju    (** 五言绝句 *)
  | QiYanJueju    (** 七言绝句 *)
  | Custom of string

(** 评价维度 *)
type evaluation_dimension = 
  | Rhyme | Artistic | Form | Content | Sound

(** 评价结果 *)
type evaluation_result = {
  overall_score: float;
  dimension_scores: (evaluation_dimension * float) list;
  rhyme_quality: float;
  artistic_quality: float;
  form_compliance: float;
  recommendations: string list;
}

(** 韵律匹配结果 *)
type rhyme_match_result = {
  is_match: bool;
  confidence: float;
  match_type: string;
  suggestions: string list;
}

(** {1 核心API函数} *)

(** 查找字符的韵律信息 *)
val find_rhyme_info : string -> rhyme_info option

(** 检测韵律类型 *)
val detect_rhyme_category : string -> rhyme_category

(** 验证两个字符是否押韵 *)
val check_rhyme_match : string -> string -> bool

(** 获取韵部分组名称 *)
val get_rhyme_group_name : rhyme_group -> string

(** 获取韵律分类名称 *)
val get_rhyme_category_name : rhyme_category -> string

(** 分析诗句的韵律模式 *)
val analyze_line_rhyme : string -> rhyme_info list

(** 基础诗词评价函数 *)
val evaluate_poem_basic : string list -> evaluation_result

(** 预加载韵律数据 *)
val preload_rhyme_data : unit -> unit

(** 清理缓存数据 *)
val cleanup_cache : unit -> unit

(** {1 字符串转换函数} *)

(** 韵类转字符串 *)
val rhyme_category_to_string : rhyme_category -> string

(** 韵组转字符串 *)
val rhyme_group_to_string : rhyme_group -> string

(** {1 兼容性函数} *)

val find_rhyme_info_compat : string -> rhyme_info option
val detect_rhyme_category_compat : string -> rhyme_category
val check_rhyme_match_compat : string -> string -> bool

(** {1 内部数据访问} *)

(** 韵律信息缓存 - 供其他模块访问 *)
val rhyme_info_cache : (string, rhyme_info) Hashtbl.t