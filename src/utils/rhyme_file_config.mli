(** 韵律数据文件配置模块接口
    
    专门处理韵律数据文件路径配置、查找和加载逻辑，
    使用查找表优化性能。
    
    Author: Alpha, 主工作代理
    Fix #1460 Phase 2.1 - 韵律配置模块优化 *)

(** 韵律分类 *)
type rhyme_category =
  | PingSheng  (* 平声韵 *)
  | ZeSheng    (* 仄声韵 *)
  | ShangSheng (* 上声韵 *)
  | QuSheng    (* 去声韵 *)
  | RuSheng    (* 入声韵 *)

(** 韵律组 *)
type rhyme_group =
  | AnRhyme     (* 安韵组 *)
  | SiRhyme     (* 思韵组 *)
  | TianRhyme   (* 天韵组 *)
  | WangRhyme   (* 望韵组 *)
  | QuRhyme     (* 去韵组 *)
  | YuRhyme     (* 鱼韵组 *)
  | HuaRhyme    (* 花韵组 *)
  | FengRhyme   (* 风韵组 *)
  | YueRhyme    (* 月韵组 *)
  | XueRhyme    (* 雪韵组 *)
  | JiangRhyme  (* 江韵组 *)
  | HuiRhyme    (* 灰韵组 *)
  | UnknownRhyme (* 未知韵组 *)

(** 韵律数据文件路径配置 *)
type rhyme_file_config = {
  base_path : string;
  ping_sheng_path : string;
  ze_sheng_path : string;
  fallback_paths : string list;
}

(** 默认韵律文件配置 *)
val default_rhyme_config : rhyme_file_config

(** 韵律分类名称转换 *)
val string_of_rhyme_category : rhyme_category -> string

(** 韵律组名称转换 *)
val string_of_rhyme_group : rhyme_group -> string

(** 获取韵律组文件名 *)
val get_rhyme_group_filename : rhyme_group -> string

(** 获取分类路径 *)
val get_category_path : rhyme_file_config -> rhyme_category -> string

(** 构建文件路径 *)
val build_rhyme_file_path : rhyme_file_config -> rhyme_category -> rhyme_group -> string

(** 查找韵律数据文件 *)
val find_rhyme_data_file : rhyme_file_config -> rhyme_category -> rhyme_group -> string option

(** 批量构建文件路径 *)
val batch_build_file_paths : rhyme_file_config -> (rhyme_category * rhyme_group) list -> (rhyme_category * rhyme_group * string) list

(** 验证配置 *)
val validate_config : rhyme_file_config -> bool

(** 配置信息摘要 *)
val config_summary : rhyme_file_config -> string