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
let process_string_with_skip = String_processing.Core_string_ops.process_string_with_skip
let block_comment_skip_logic = String_processing.Core_string_ops.block_comment_skip_logic
let luoyan_string_skip_logic = String_processing.Core_string_ops.luoyan_string_skip_logic
let english_string_skip_logic = String_processing.Core_string_ops.english_string_skip_logic
let remove_double_slash_comment = String_processing.Core_string_ops.remove_double_slash_comment
let remove_hash_comment = String_processing.Core_string_ops.remove_hash_comment
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
  let index_out_of_bounds_error = String_processing.Error_templates.index_out_of_bounds_error
  let file_operation_error = String_processing.Error_templates.file_operation_error
  let generic_function_error = String_processing.Error_templates.generic_function_error
  let unsupported_feature = String_processing.Error_templates.unsupported_feature
  let unexpected_state = String_processing.Error_templates.unexpected_state
  let invalid_character = String_processing.Error_templates.invalid_character
  let syntax_error = String_processing.Error_templates.syntax_error
  let semantic_error = String_processing.Error_templates.semantic_error
  let poetry_char_count_mismatch = String_processing.Error_templates.poetry_char_count_mismatch
  let poetry_verse_count_warning = String_processing.Error_templates.poetry_verse_count_warning
  let poetry_rhyme_mismatch = String_processing.Error_templates.poetry_rhyme_mismatch
  let poetry_tone_pattern_error = String_processing.Error_templates.poetry_tone_pattern_error
  let data_loading_error = String_processing.Error_templates.data_loading_error
  let data_validation_error = String_processing.Error_templates.data_validation_error
  let data_format_error = String_processing.Error_templates.data_format_error
end

(** 重新导出位置格式化模块 *)
module PositionFormatting = struct
  let format_position_with_fields = String_processing.Position_formatting.format_position_with_fields
  let format_position_with_extractor = String_processing.Position_formatting.format_position_with_extractor
  let format_compiler_error_position_from_fields = String_processing.Position_formatting.format_compiler_error_position_from_fields
  let format_optional_position_with_extractor = String_processing.Position_formatting.format_optional_position_with_extractor
  let error_with_position_extractor = String_processing.Position_formatting.error_with_position_extractor
end

(** 重新导出C代码生成格式化模块 *)
module CCodegenFormatting = struct
  let function_call = String_processing.C_codegen_formatting.function_call
  let binary_function_call = String_processing.C_codegen_formatting.binary_function_call
  let string_equality_check = String_processing.C_codegen_formatting.string_equality_check
  let type_conversion = String_processing.C_codegen_formatting.type_conversion
  let env_bind = String_processing.C_codegen_formatting.env_bind
  let env_lookup = String_processing.C_codegen_formatting.env_lookup
  let luoyan_int = String_processing.C_codegen_formatting.luoyan_int
  let luoyan_float = String_processing.C_codegen_formatting.luoyan_float
  let luoyan_string = String_processing.C_codegen_formatting.luoyan_string
  let luoyan_bool = String_processing.C_codegen_formatting.luoyan_bool
  let luoyan_unit = String_processing.C_codegen_formatting.luoyan_unit
  let include_header = String_processing.C_codegen_formatting.include_header
  let include_local_header = String_processing.C_codegen_formatting.include_local_header
  let recursive_binding = String_processing.C_codegen_formatting.recursive_binding
  let if_statement = String_processing.C_codegen_formatting.if_statement
  let assignment = String_processing.C_codegen_formatting.assignment
  let return_statement = String_processing.C_codegen_formatting.return_statement
  let function_declaration = String_processing.C_codegen_formatting.function_declaration
end

(** 重新导出集合格式化模块 *)
module CollectionFormatting = struct
  let join_chinese = String_processing.Collection_formatting.join_chinese
  let join_english = String_processing.Collection_formatting.join_english
  let join_semicolon = String_processing.Collection_formatting.join_semicolon
  let join_newline = String_processing.Collection_formatting.join_newline
  let indented_list = String_processing.Collection_formatting.indented_list
  let array_format = String_processing.Collection_formatting.array_format
  let tuple_format = String_processing.Collection_formatting.tuple_format
  let type_signature_format = String_processing.Collection_formatting.type_signature_format
end

(** 重新导出报告格式化模块 *)
module ReportFormatting = struct
  let stats_line = String_processing.Report_formatting.stats_line
  let analysis_result_line = String_processing.Report_formatting.analysis_result_line
  let context_line = String_processing.Report_formatting.context_line
  let suggestion_line = String_processing.Report_formatting.suggestion_line
  let similarity_suggestion = String_processing.Report_formatting.similarity_suggestion
end

(** 重新导出样式格式化模块 *)
module StyleFormatting = struct
  let with_color = String_processing.Style_formatting.with_color
  let red_text = String_processing.Style_formatting.red_text
  let green_text = String_processing.Style_formatting.green_text
  let yellow_text = String_processing.Style_formatting.yellow_text
  let blue_text = String_processing.Style_formatting.blue_text
  let bold_text = String_processing.Style_formatting.bold_text
end

(** 重新导出Buffer辅助模块 *)
module BufferHelpers = struct
  let add_formatted_string = String_processing.Buffer_helpers.add_formatted_string
  let add_stats_batch = String_processing.Buffer_helpers.add_stats_batch
  let add_error_with_context = String_processing.Buffer_helpers.add_error_with_context
end