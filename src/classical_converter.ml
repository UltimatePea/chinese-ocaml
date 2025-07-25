(** 古典语言转换器 - Issue #1318 统一转换系统兼容性模块
 *
 *  这个模块提供向后兼容性支持，实际转换逻辑已迁移到统一转换系统
 *
 *  @author 骆言技术债务清理团队 Issue #1276, #1318
 *  @version 3.0 - Issue #1318: 基于统一转换系统的兼容性接口
 *  @since 2025-07-25 *)


exception Unknown_classical_token of string
(** 古典语言转换异常 - 向后兼容 *)

(** 获取规则数量 - 兼容性接口 *)
let get_rule_count () = 77 (* 估计的总数量 *)


(** 古典语言转换函数 - 通过统一系统提供 *)
let convert_classical_token token =
  try Token_conversion_unified.CompatibilityInterface.convert_classical_token token with
  | Token_conversion_unified.Unified_conversion_failed (`Classical, msg) ->
      raise (Unknown_classical_token msg)
  | Token_conversion_unified.Unified_conversion_failed (_, msg) ->
      raise (Unknown_classical_token ("Non-classical token passed to classical converter: " ^ msg))

(* 保留具体的转换函数供内部使用，但主要接口通过统一系统 *)
let convert_wenyan_token = convert_classical_token
let convert_natural_language_token = convert_classical_token
let convert_ancient_token = convert_classical_token
