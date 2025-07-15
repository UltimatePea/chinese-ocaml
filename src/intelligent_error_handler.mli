(** 骆言智能错误处理器 - AI驱动的错误解释和修复建议系统

    此模块提供了基于AI的智能错误分析、修复建议生成和错误解释功能， 帮助开发者更好地理解和修复编程错误。 *)

type error_context = {
  source_location : string option;  (** 源代码位置 *)
  function_name : string option;  (** 函数名称 *)
  variable_scope : string list;  (** 变量作用域 *)
  expression_type : string option;  (** 表达式类型 *)
  code_snippet : string option;  (** 代码片段 *)
}
(** 错误上下文信息 *)

(** 智能修复建议类型 *)
type fix_strategy =
  | AutoFix of string * string  (** 自动修复：描述 * 修复方案 *)
  | SuggestPattern of string * string  (** 建议模式：描述 * 代码模板 *)
  | RefactorHint of string list  (** 重构提示：步骤列表 *)
  | ExampleCode of string * string  (** 示例代码：描述 * 代码示例 *)

type intelligent_explanation = {
  chinese_message : string;  (** 中文错误消息 *)
  technical_detail : string;  (** 技术细节 *)
  cause_analysis : string list;  (** 原因分析 *)
  impact_assessment : string;  (** 影响评估 *)
  learning_note : string option;  (** 学习提示 *)
}
(** 智能错误解释 *)

val diagnose_error_with_ai : string -> error_context -> string
(** AI辅助错误诊断，分析错误消息并生成诊断报告
    @param error_msg 错误消息
    @param error_context 错误上下文信息
    @return 诊断报告字符串 *)

val generate_fix_strategies : Error_messages.error_analysis -> error_context -> fix_strategy list
(** 生成智能修复策略
    @param error_analysis 错误分析结果
    @param error_context 错误上下文信息
    @return 修复策略列表 *)

val generate_intelligent_explanation : string -> string -> string option -> intelligent_explanation
(** 生成智能错误解释
    @param error_type 错误类型
    @param error_msg 错误消息
    @param context 错误上下文
    @return 智能错误解释 *)

val generate_ai_error_report : string -> string list -> string option -> string
(** 生成完整的AI错误报告
    @param error_type 错误类型
    @param error_details 错误详细信息列表
    @param context 错误上下文
    @return 完整的AI错误报告字符串 *)

val test_intelligent_error_handler : unit -> unit
(** 测试智能错误处理功能 运行一系列测试用例来验证智能错误处理器的功能 *)
