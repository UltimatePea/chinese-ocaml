(** Token转换器注册和调度模块 - Issue #1318 统一重构
 *
 *  从token_conversion_core.ml重构而来，现在基于统一Token转换系统
 *  
 *  ## API设计说明  
 *  - 基于新的统一转换系统 (Token_conversion_unified)
 *  - 保持向后兼容性，现有接口不变
 *  - 消除了对20+个分散转换模块的依赖
 *  - 统一的异常处理和错误信息
 *  
 *  @author 骆言技术债务清理团队 Issue #1276, #1278, #1284, #1318
 *  @version 3.0 - Issue #1318: 基于统一转换系统重构
 *  @since 2025-07-25 *)

exception Token_conversion_failed of string
(** 聚合所有转换器的异常 *)

(** 统一的Token转换接口 - 基于统一转换系统 *)
let convert_token token = Token_conversion_unified.convert_token token

(** 批量转换Token列表 - 基于统一转换系统 *)
let convert_token_list tokens =
  try Token_conversion_unified.convert_token_list tokens
  with Token_conversion_unified.Unified_conversion_failed (conv_type, msg) ->
    let conv_type_str =
      match conv_type with
      | `Identifier -> "标识符"
      | `Literal -> "字面量"
      | `BasicKeyword -> "基础关键字"
      | `TypeKeyword -> "类型关键字"
      | `Classical -> "古典语言"
    in
    let error_msg = Printf.sprintf "Token转换失败: %s转换器 - %s" conv_type_str msg in
    raise (Token_conversion_failed error_msg)

(** 转换统计信息 - 基于统一转换系统 *)
let get_conversion_stats () = Token_conversion_unified.get_conversion_stats ()
