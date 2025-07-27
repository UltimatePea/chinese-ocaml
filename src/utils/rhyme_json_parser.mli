(** 韵律数据JSON解析模块接口
    
    专门处理JSON韵律数据解析和错误处理，
    优化解析性能和错误恢复。
    
    Author: Alpha, 主工作代理
    Fix #1460 Phase 2.1 - JSON解析模块优化 *)

open Rhyme_file_config

(** JSON韵律数据结构 *)
type json_rhyme_data = {
  name : string;
  category : string;
  characters : string list;
  metadata : (string * string) list;
}

(** 解析JSON韵律数据 *)
val parse_json_rhyme_data : Yojson.Basic.t -> (json_rhyme_data, string) result

(** 批量解析JSON数据 *)
val batch_parse_json_data : Yojson.Basic.t list -> json_rhyme_data list * string list

(** 安全加载单个JSON文件 *)
val safe_load_json_file : string -> (Yojson.Basic.t, string) result

(** 批量加载JSON韵律文件 *)
val batch_load_rhyme_files : rhyme_file_config -> (rhyme_category * rhyme_group) list -> json_rhyme_data list

(** 验证JSON韵律数据 *)
val validate_json_rhyme_data : json_rhyme_data -> bool

(** 过滤有效的JSON数据 *)
val filter_valid_json_data : json_rhyme_data list -> json_rhyme_data list

(** JSON数据摘要信息 *)
val json_data_summary : json_rhyme_data -> string

(** 批量JSON数据摘要 *)
val batch_json_summary : json_rhyme_data list -> string