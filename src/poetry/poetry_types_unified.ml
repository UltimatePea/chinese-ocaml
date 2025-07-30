(** 统一诗韵类型定义模块
    
    此模块整合并统一了所有诗韵数据相关的类型定义，
    解决重复类型定义问题，提供一致的API接口。
    
    修复：技术债务整合 Issue #1807 Phase 1
    整合来源：
    - src/poetry/rhyme_data/rhyme_data_core.ml  
    - src/poetry/data/rhyme_data_core.ml
    - 多个分散的类型定义
    
    @author Alpha, 主要工作代理
    @version 1.0 - 统一类型定义
    @since 2025-07-30
    @issue #1807 *)

(** {1 核心韵律类型} *)

(** 韵母类别 *)
type rhyme_category = 
  | PingSheng   (** 平声 *)
  | ShangSheng  (** 上声 *)
  | QuSheng     (** 去声 *)
  | RuSheng     (** 入声 *)

(** 韵组类型 *)
type rhyme_group = 
  | AnRhyme     (** 安韵 *)
  | FengRhyme   (** 风韵 *)
  | HuaRhyme    (** 花韵 *)
  | HuiRhyme    (** 灰韵 *)
  | JiangRhyme  (** 江韵 *)
  | QuRhyme     (** 去韵 *)
  | SiRhyme     (** 思韵 *)
  | TianRhyme   (** 天韵 *)
  | WangRhyme   (** 王韵 *)
  | YuRhyme     (** 鱼韵 *)
  | YueRhyme    (** 月韵 *)
  | XueRhyme    (** 雪韵（已修复重复问题）*)

(** 韵字条目 *)
type rhyme_entry = {
  character : string;           (** 韵字 *)
  category : rhyme_category;    (** 韵类别 *)
  group : rhyme_group;          (** 韵组 *)
  variants : string list;       (** 变体形式 *)
  usage_frequency : float;      (** 使用频率 *)
}

(** 韵组数据结构 *)
type rhyme_group_data = {
  group_name : rhyme_group;           (** 韵组名称 *)
  group_description : string;         (** 韵组描述 *)
  ping_sheng_chars : string list;     (** 平声字列表 *)
  ze_sheng_chars : string list;       (** 仄声字列表 *)
  entries : rhyme_entry list;         (** 详细条目列表 *)
  example_poems : string list;        (** 示例诗句 *)
}

(** 韵组数据库 *)
type rhyme_database = {
  groups : rhyme_group_data list;     (** 所有韵组数据 *)
  index : (string, rhyme_entry) Hashtbl.t;  (** 字符到条目的索引 *)
  group_index : (rhyme_group, rhyme_group_data) Hashtbl.t;  (** 韵组索引 *)
}

(** {1 辅助类型} *)

(** 查询结果类型 *)
type query_result = 
  | Found of rhyme_entry
  | NotFound
  | Ambiguous of rhyme_entry list

(** 韵律验证结果 *)
type validation_result = {
  is_valid : bool;
  violations : string list;
  suggestions : string list;
}

(** {1 辅助函数} *)

(** 韵组到字符串转换 *)
let rhyme_group_to_string = function
  | AnRhyme -> "安韵"
  | FengRhyme -> "风韵"
  | HuaRhyme -> "花韵" 
  | HuiRhyme -> "灰韵"
  | JiangRhyme -> "江韵"
  | QuRhyme -> "去韵"
  | SiRhyme -> "思韵"
  | TianRhyme -> "天韵"
  | WangRhyme -> "王韵"
  | YuRhyme -> "鱼韵"
  | YueRhyme -> "月韵"
  | XueRhyme -> "雪韵"

(** 韵类别到字符串转换 *)
let rhyme_category_to_string = function
  | PingSheng -> "平声"
  | ShangSheng -> "上声"
  | QuSheng -> "去声"
  | RuSheng -> "入声"

(** 创建韵字条目 *)
let make_rhyme_entry character category group ?(variants = []) ?(usage_frequency = 1.0) () =
  { character; category; group; variants; usage_frequency }

(** 创建韵组数据 *)
let make_rhyme_group_data group_name group_description ping_sheng_chars ze_sheng_chars =
  let make_entries chars category = 
    List.map (fun char -> make_rhyme_entry char category group_name ()) chars
  in
  let ping_entries = make_entries ping_sheng_chars PingSheng in
  let ze_entries = make_entries ze_sheng_chars QuSheng in
  let entries = ping_entries @ ze_entries in
  {
    group_name;
    group_description;
    ping_sheng_chars;
    ze_sheng_chars;
    entries;
    example_poems = [];
  }