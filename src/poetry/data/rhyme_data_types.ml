(** 韵律数据核心类型定义 - 技术债务清理Phase 1b
    
    从rhyme_data_unified.ml中提取的核心类型定义，作为独立模块提供
    统一的韵律数据类型系统，消除类型定义重复问题。
                                                           
    @author Alpha, 主要工作代理 - Phase 1b 大文件拆分
    @version 1.0 - 拆分版本
    @since 2025-07-28 - 技术债务清理Phase 1b
    @extracted_from rhyme_data_unified.ml *)

(** {1 韵律数据核心类型} *)

type rhyme_data_item = {
  character : string;
  rhyme_group : Poetry_core.Json_core.rhyme_group;
  rhyme_category : Poetry_core.Json_core.rhyme_category;
  tone : [ `PingSheng | `ShangSheng | `QuSheng | `RuSheng ];
  phonetic_info : (string * string) list;
  source_priority : int;
}
(** 韵律数据条目 - 包含字符及其韵律信息 *)

type rhyme_source =
  | AnYunData
  | FengRhymeData
  | HuaRhymeData
  | YuRhymeData
  | HuiRhymeData
  | JiangRhymeData
  | YueRhymeData
  | UnifiedRhymeDatabase
  | ExpandedRhymeData
  | RhymeDataEngine
  | CustomSource of string
(** 韵律数据源类型 - 支持多种韵律系统 *)

type rhyme_query =
  | QueryByCharacter of string
  | QueryByRhymeGroup of Poetry_core.Json_core.rhyme_group
  | QueryByRhymeCategory of Poetry_core.Json_core.rhyme_category
  | QueryByTone of [ `PingSheng | `ShangSheng | `QuSheng | `RuSheng ]
  | QueryBySource of rhyme_source
  | QueryBySimilarSound of string
  | RhymeCompatibilityQuery of string * string
(** 韵律查询类型 - 支持多种查询方式 *)

type 'a rhyme_result = 
  | RhymeSuccess of 'a 
  | RhymeError of string 
  | RhymeWarning of 'a * string
(** 韵律操作结果类型 - 包含成功、错误和警告 *)

(** {1 性能统计类型} *)

type performance_stats = {
  total_queries : int;
  cache_hits : int;
  index_build_time : float;
  avg_query_time : float;
}
(** 性能统计数据结构 *)