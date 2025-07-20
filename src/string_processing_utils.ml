(** 字符串处理工具统一入口模块 - 重构版本
    
    本模块已重构为模块化架构，原先的358行超长模块
    已拆分为多个专门的子模块，提升了代码的可维护性和可读性。
    
    为保持向后兼容性，本模块重新导出所有功能。
    
    @author 骆言技术债务清理团队
    @version 2.0 (重构版本)
    @since 2025-07-20 Issue #708 重构
    
    新的模块结构：
    - Core_string_ops: 基础字符串处理和代码解析
    - Error_templates: 统一错误消息模板
    - Position_formatting: 位置信息格式化
    - C_codegen_formatting: C代码生成格式化
    - Collection_formatting: 集合格式化
    - Report_formatting: 报告格式化
    - Style_formatting: 颜色和样式格式化
    - Buffer_helpers: Buffer操作辅助 *)

(** 重新导出核心字符串操作 *)
(* 以下函数被直接使用，需要保留顶级绑定 *)
let remove_hash_comment = String_processing.Core_string_ops.remove_hash_comment
let remove_double_slash_comment = String_processing.Core_string_ops.remove_double_slash_comment
let remove_block_comments = String_processing.Core_string_ops.remove_block_comments
let remove_luoyan_strings = String_processing.Core_string_ops.remove_luoyan_strings
let remove_english_strings = String_processing.Core_string_ops.remove_english_strings

(** 重新导出错误消息模板模块 *)
module ErrorMessageTemplates = struct
  let function_param_error = String_processing.Error_templates.function_param_error
  let function_param_type_error = String_processing.Error_templates.function_param_type_error
  let function_single_param_error = String_processing.Error_templates.function_single_param_error
  let function_double_param_error = String_processing.Error_templates.function_double_param_error
  let function_no_param_error = String_processing.Error_templates.function_no_param_error
  let type_mismatch_error = String_processing.Error_templates.type_mismatch_error
  let undefined_variable_error = String_processing.Error_templates.undefined_variable_error
  let generic_function_error = String_processing.Error_templates.generic_function_error
  let file_operation_error = String_processing.Error_templates.file_operation_error
end

(** 重新导出位置格式化模块 *)
module PositionFormatting = struct
  let format_position_with_fields = String_processing.Position_formatting.format_position_with_fields
  let format_optional_position_with_extractor = String_processing.Position_formatting.format_optional_position_with_extractor
end

(** 重新导出C代码生成格式化模块 - 当前未使用，保留为空以备将来使用 *)
module CCodegenFormatting = struct
  (* 所有函数绑定已移除以避免编译警告 *)
end

(** 重新导出集合格式化模块 *)
module CollectionFormatting = struct
  let join_chinese = String_processing.Collection_formatting.join_chinese
end

(** 重新导出报告格式化模块 *)
module ReportFormatting = struct
  let suggestion_line = String_processing.Report_formatting.suggestion_line
  let similarity_suggestion = String_processing.Report_formatting.similarity_suggestion
end

(** 重新导出样式格式化模块 - 当前未使用，保留为空以备将来使用 *)
module StyleFormatting = struct
  (* 所有函数绑定已移除以避免编译警告 *)
end

(** 重新导出Buffer辅助模块 - 当前未使用，保留为空以备将来使用 *)
module BufferHelpers = struct
  (* 所有函数绑定已移除以避免编译警告 *)
end