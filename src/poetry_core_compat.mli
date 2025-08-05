(** Poetry_core兼容性模块接口

    此模块提供与原始Poetry_core模块的兼容性接口。

    Author: Whisky, PR Worker Issue: #1999 - Poetry韵律模块统一整合

    @since 2025-08-04 *)

(** {1 兼容性类型定义} *)
module Types : sig
  type rhyme_category = PingSheng | ShangSheng | QuSheng | RuSheng | ZeSheng

  type rhyme_group =
    | AnRhyme
    | SiRhyme
    | TianRhyme
    | WangRhyme
    | QuRhyme
    | YuRhyme
    | HuaRhyme
    | FengRhyme
    | YueRhyme
    | JiangRhyme
    | HuiRhyme
    | UnknownRhyme

  type rhyme_character_data = {
    character : string;
    category : rhyme_category;
    group : rhyme_group;
    metadata : (string * string) list;
  }

  type rhyme_data_file = {
    version : string;
    description : string;
    characters : rhyme_character_data list;
    rhyme_groups : rhyme_group list;
    last_updated : string;
  }

  type evaluation_grade = Excellent | Good | Average | Poor | VeryPoor

  type artistic_scores = {
    rhythm_score : float;
    rhyme_score : float;
    parallelism_score : float;
    overall_score : float;
    grade : evaluation_grade;
  }

  exception RhymeException of string

  type multi_verse_analysis = {
    verses : string list;
    rhythm_patterns : string list;
    parallelism_score : float;
    overall_rating : evaluation_grade;
  }

  val get_rhyme_data_safe : ?force_reload:bool -> unit -> rhyme_data_file option
  (** 安全获取韵律数据函数接口 *)

  val rhyme_category_to_string : rhyme_category -> string
  (** 韵律类别转字符串函数接口 *)

  val rhyme_group_to_string : rhyme_group -> string
  (** 韵组转字符串函数接口 *)
end

module Poetry_types : module type of Types
module Rhyme_core_types : module type of Types

module Rhyme_core_api : sig
  include module type of Types

  val query_rhyme_category : string -> Types.rhyme_category
  (** 查询韵律类别 *)

  val query_rhyme_group : string -> Types.rhyme_group
  (** 查询韵组 *)
end

val print_statistics : unit -> unit

module Io : sig
  val safe_read_file : string -> (string, string) result
end

module Parser : sig
  exception Json_parse_error of string

  val parse_rhyme_json : string -> Types.rhyme_data_file
end

module Poetry_errors : sig
  type data_error = DataSourceError of string | ValidationError of string | LoadingError of string

  exception DataSourceError of string
end
