(** 智能错误处理器接口 - Intelligent Error Handler Interface *)

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
  | AutoFix of string * string  (** 自动修复：旧代码 -> 新代码 *)
  | SuggestPattern of string * string  (** 建议模式：模式描述 -> 代码模板 *)
  | RefactorHint of string list  (** 重构提示：步骤列表 *)
  | ExampleCode of string * string  (** 示例代码：描述 -> 代码 *)

type intelligent_explanation = {
  chinese_message : string;  (** 中文错误消息 *)
  technical_detail : string;  (** 技术细节 *)
  cause_analysis : string list;  (** 原因分析 *)
  impact_assessment : string;  (** 影响评估 *)
  learning_note : string option;  (** 学习笔记 *)
}
(** 智能错误解释 *)

(** 主要功能函数 *)

val diagnose_error_with_ai : string -> error_context -> string
(** 使用AI诊断错误
    @param error_msg 错误消息
    @param error_context 错误上下文
    @return 诊断报告字符串 *)

val generate_fix_strategies : Error_messages.error_analysis -> error_context -> fix_strategy list
(** 生成修复策略
    @param error_analysis 错误分析结果
    @param error_context 错误上下文
    @return 修复策略列表 *)

val generate_intelligent_explanation : string -> string -> string option -> intelligent_explanation
(** 生成智能错误解释
    @param error_type 错误类型
    @param error_msg 错误消息
    @param context 错误上下文
    @return 智能错误解释 *)

val generate_ai_error_report : string -> string list -> string option -> string
(** 生成AI错误报告
    @param error_type 错误类型
    @param error_details 错误详情列表
    @param context 错误上下文（可选）
    @return 错误报告字符串 *)

val test_intelligent_error_handler : unit -> unit
(** 测试智能错误处理功能 *)
