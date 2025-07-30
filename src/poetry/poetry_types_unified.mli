(** 统一诗韵类型定义模块接口 *)

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
  | XueRhyme    (** 雪韵 *)

(** 韵字条目 *)
type rhyme_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  variants : string list;
  usage_frequency : float;
}

(** 韵组数据结构 *)
type rhyme_group_data = {
  group_name : rhyme_group;
  group_description : string;
  ping_sheng_chars : string list;
  ze_sheng_chars : string list;
  entries : rhyme_entry list;
  example_poems : string list;
}

(** 韵组数据库 *)
type rhyme_database = {
  groups : rhyme_group_data list;
  index : (string, rhyme_entry) Hashtbl.t;
  group_index : (rhyme_group, rhyme_group_data) Hashtbl.t;
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
val rhyme_group_to_string : rhyme_group -> string

(** 韵类别到字符串转换 *)
val rhyme_category_to_string : rhyme_category -> string

(** 创建韵字条目 *)
val make_rhyme_entry : 
  string -> rhyme_category -> rhyme_group -> 
  ?variants:string list -> ?usage_frequency:float -> unit -> rhyme_entry

(** 创建韵组数据 *)
val make_rhyme_group_data : 
  rhyme_group -> string -> string list -> string list -> rhyme_group_data