(** 骆言错误消息模块接口 - Chinese Programming Language Error Messages Interface *)

(** 智能错误分析结果类型 *)
type error_analysis = {
  error_type: string;        (** 错误类型分类 *)
  error_message: string;     (** 主要错误消息 *)
  context: string option;    (** 错误上下文信息 *)
  suggestions: string list;  (** 修复建议列表 *)
  fix_hints: string list;    (** 具体修复提示 *)
  confidence: float;         (** 分析结果置信度 *)
}

(** 基础错误消息转换函数 *)

(** 将英文类型错误转换为中文
    @param msg 英文错误消息
    @return 中文错误消息 *)
val chinese_type_error_message : string -> string

(** 将运行时错误转换为中文
    @param msg 英文错误消息
    @return 中文错误消息 *)
val chinese_runtime_error_message : string -> string

(** 特定错误生成函数 *)

(** 生成类型不匹配错误消息
    @param expected_type 期望的类型
    @param actual_type 实际的类型
    @return 中文错误消息 *)
val type_mismatch_error : Types.typ -> Types.typ -> string

(** 生成未定义变量错误消息
    @param var_name 未定义的变量名
    @param available_vars 可用变量列表
    @return 中文错误消息 *)
val undefined_variable_error : string -> string list -> string

(** 生成函数参数数量错误消息
    @param expected 期望的参数数量
    @param actual 实际的参数数量
    @return 中文错误消息 *)
val function_arity_error : int -> int -> string

(** 生成模式匹配错误消息
    @param match_type 匹配表达式的类型
    @return 中文错误消息 *)
val pattern_match_error : Types.typ -> string

(** 智能错误分析功能 *)

(** 计算两个字符串之间的编辑距离
    @param s1 第一个字符串
    @param s2 第二个字符串
    @return 编辑距离 *)
val levenshtein_distance : string -> string -> int

(** 在变量列表中查找与目标变量相似的变量
    @param target 目标变量名
    @param vars 可用变量列表
    @return (变量名, 相似度) 对的列表，按相似度降序排列 *)
val find_similar_variables : string -> string list -> (string * float) list

(** 智能错误分析主函数
    @param error_msg 原始错误消息
    @param context_vars 上下文中的变量列表
    @param source_line 可选的源代码行
    @return 智能错误分析结果 *)
val intelligent_error_analysis : string -> string list -> string option -> error_analysis

(** 生成智能错误报告
    @param analysis 错误分析结果
    @return 格式化的错误报告字符串 *)
val generate_intelligent_error_report : error_analysis -> string

(** 生成错误修复建议
    @param error_type 错误类型
    @param context 错误上下文
    @return 修复建议字符串 *)
val generate_error_suggestions : string -> string -> string