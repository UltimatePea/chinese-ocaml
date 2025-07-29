(** 字面量转换器接口 - Issue #1318 统一转换系统兼容性模块
 *
 *  这个模块提供向后兼容性支持，实际转换逻辑已迁移到统一转换系统
 *
 *  @author 骆言技术债务清理团队 Issue #1276, #1318
 *  @version 3.0 - Issue #1318: 基于统一转换系统的兼容性接口
 *  @since 2025-07-25 *)

(** 字面量转换异常 - 向后兼容 *)
exception Unknown_literal_token of string

(** 获取规则数量 - 兼容性接口 *)
val get_rule_count : unit -> int

(** 字面量转换函数 - 通过统一系统提供 *)
val convert_literal_token : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token