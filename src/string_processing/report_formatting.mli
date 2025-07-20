(** 报告生成格式化模块
    
    本模块专门处理各种报告和分析结果的格式化，
    提供统一的报告格式和样式。
    
    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #708 重构 *)

(** {1 统计信息格式化} *)

(** [stats_line icon category count] 
    生成统计信息行，格式为 "   icon category: count 个\n" *)
val stats_line : string -> string -> int -> string

(** {1 分析结果格式化} *)

(** [analysis_result_line icon message] 
    生成分析结果行，格式为 "icon message\n\n" *)
val analysis_result_line : string -> string -> string

(** {1 上下文信息格式化} *)

(** [context_line context] 
    生成上下文信息行，格式为 "📍 上下文: context\n\n" *)
val context_line : string -> string

(** {1 建议信息格式化} *)

(** [suggestion_line current suggestion] 
    生成建议信息，显示当前值和建议值 *)
val suggestion_line : string -> string -> string

(** [similarity_suggestion match_name score] 
    生成相似度建议信息，显示匹配名称和相似度百分比 *)
val similarity_suggestion : string -> float -> string