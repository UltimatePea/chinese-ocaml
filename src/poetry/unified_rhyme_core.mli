(** 统一韵律数据核心模块 - 解决代码重复问题
    
    作者：Alpha Agent，技术债务专员
    日期：2025年7月28日
    目标：Fix #1538 - 统一Poetry模块中的韵律数据类型定义和功能
    
    此模块取代以下重复的类型定义：
    - src/utils/rhyme_data_utils.mli 中的类型定义
    - src/poetry/poetry_rhyme_data.mli 中的类型定义  
    - src/poetry/rhyme_json_types.mli 中的类型定义
    - 以及其他33个文件中的重复定义
    
    设计原则：
    1. 单一真相源 - 所有韵律类型定义都在此模块
    2. 简洁接口 - 提供最小但完整的API
    3. 高性能 - 支持缓存和延迟加载
    4. 可扩展 - 为未来功能留出空间 *)

(** {1 核心类型定义} *)

(** 韵类 - 声调分类 *)
type rhyme_category =
  | PingSheng   (** 平声韵 *)
  | ZeSheng     (** 仄声韵 *)
  | ShangSheng  (** 上声韵 *) 
  | QuSheng     (** 去声韵 *)
  | RuSheng     (** 入声韵 *)

(** 韵组 - 诗词韵脚分组 *)
type rhyme_group =
  | AnRhyme     (** 安韵 *)
  | SiRhyme     (** 思韵 *)
  | TianRhyme   (** 天韵 *)
  | WangRhyme   (** 王韵 *)
  | QuRhyme     (** 趋韵 *)
  | YuRhyme     (** 语韵 *)
  | HuaRhyme    (** 华韵 *)
  | FengRhyme   (** 风韵 *)
  | YueRhyme    (** 月韵 *)
  | XueRhyme    (** 学韵 *)
  | JiangRhyme  (** 江韵 *)
  | HuiRhyme    (** 辉韵 *)
  | UnknownRhyme (** 未知韵 *)

(** 韵律数据条目 *)
type rhyme_entry = {
  character : string;          (** 汉字字符 *)
  category : rhyme_category;   (** 韵类 *)
  group : rhyme_group;        (** 韵组 *)
  tone_mark : int option;     (** 声调标记 (1-4) *)
  traditional_variant : string option; (** 繁体字变体 *)
  notes : string option;      (** 使用说明 *)
}

(** {1 异常类型} *)

exception Rhyme_data_error of string
exception Invalid_character of string
exception Rhyme_not_found of string

(** {1 类型转换} *)

val string_of_rhyme_category : rhyme_category -> string
(** 韵类转字符串 *)

val string_of_rhyme_group : rhyme_group -> string  
(** 韵组转字符串 *)

val rhyme_category_of_string : string -> rhyme_category
(** 字符串转韵类
    @raise Invalid_argument 如果字符串无法识别 *)

val rhyme_group_of_string : string -> rhyme_group
(** 字符串转韵组
    @raise Invalid_argument 如果字符串无法识别 *)

(** {1 核心查询接口} *)

val lookup_rhyme : string -> rhyme_entry option
(** 查询单个字符的韵律信息
    @param char 汉字字符
    @return 韵律信息，未找到则返回None *)

val lookup_batch : string list -> rhyme_entry list
(** 批量查询韵律信息
    @param chars 字符列表
    @return 找到的韵律信息列表 *)

val get_rhyme_group_chars : rhyme_group -> string list
(** 获取韵组包含的所有字符
    @param group 韵组
    @return 字符列表 *)

val get_category_chars : rhyme_category -> string list
(** 获取韵类包含的所有字符
    @param category 韵类
    @return 字符列表 *)

(** {1 数据管理} *)

val initialize : unit -> unit
(** 初始化韵律数据库 - 从数据文件加载 *)

val reload : unit -> unit  
(** 重新加载数据 *)

val is_initialized : unit -> bool
(** 检查是否已初始化 *)

val get_stats : unit -> (string * int) list
(** 获取数据统计信息
    @return [("total_entries", n); ("categories", m); ...] *)

(** {1 验证和检查} *)

val validate_character : string -> bool
(** 验证字符是否为有效汉字 *)

val is_rhyme_match : string -> string -> bool
(** 检查两个字符是否押韵
    @param char1 第一个字符
    @param char2 第二个字符
    @return 押韵返回true *)

val find_rhyme_conflicts : unit -> (string * string) list
(** 查找数据中的韵律冲突
    @return 冲突字符对列表 *)

(** {1 高级功能} *)

module Cache : sig
  val enable : unit -> unit
  (** 启用查询缓存 *)
  
  val disable : unit -> unit
  (** 禁用查询缓存 *)
  
  val clear : unit -> unit
  (** 清除缓存 *)
  
  val stats : unit -> int * int * float
  (** 缓存统计：命中数、总查询数、命中率 *)
end

module Export : sig
  val to_json : rhyme_entry list -> string
  (** 导出为JSON格式 *)
  
  val from_json : string -> rhyme_entry list
  (** 从JSON导入
      @raise Rhyme_data_error 如果JSON格式无效 *)
  
  val to_csv : rhyme_entry list -> string
  (** 导出为CSV格式 *)
end