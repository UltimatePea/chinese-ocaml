(** 字面量转换器 - Issue #1318 统一转换系统兼容性模块
 *
 *  这个模块提供向后兼容性支持，实际转换逻辑已迁移到统一转换系统
 *
 *  @author 骆言技术债务清理团队 Issue #1276, #1318
 *  @version 3.0 - Issue #1318: 基于统一转换系统的兼容性接口
 *  @since 2025-07-25 *)

open Lexer_tokens

(** 字面量转换异常 - 向后兼容 *)
exception Unknown_literal_token of string

(** 获取规则数量 - 兼容性接口 *)
let get_rule_count () = 5

(** 字面量转换函数 - 通过统一系统提供 *)
let convert_literal_token token =
  try
    Token_conversion_unified.CompatibilityInterface.convert_literal_token token
  with
  | Token_conversion_unified.Unified_conversion_failed (`Literal, msg) ->
      raise (Unknown_literal_token msg)
  | Token_conversion_unified.Unified_conversion_failed (_, msg) ->
      raise (Unknown_literal_token ("Non-literal token passed to literal converter: " ^ msg))