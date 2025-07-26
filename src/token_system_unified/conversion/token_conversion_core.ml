(** Token转换核心模块 - Issue #1276 模块化重构

    此模块已重构为模块化架构，原443行代码分解为以下模块：
    - src/token/conversion/identifier_converter.ml (标识符转换)
    - src/token/conversion/literal_converter.ml (字面量转换)
    - src/token/conversion/keyword_converter.ml (关键字转换)
    - src/token/conversion/classical_converter.ml (古典语言转换)
    - src/token/conversion/conversion_registry.ml (转换注册器)
    - src/token/core/token_dispatcher.ml (调度核心)

    通过模块化显著提升代码的可维护性、可测试性和可扩展性。 本文件提供向后兼容性支持，实际实现已委托给新的模块结构。

    @author 骆言技术债务清理团队 Issue #1276
    @version 2.0
    @since 2025-07-25 *)

open Token_dispatcher
(** 新模块化架构导入 *)

(** 向后兼容性保证 - 所有原有接口通过代理提供 *)

exception Unknown_identifier_token = Token_dispatcher.Unknown_identifier_token
(** 异常定义 - 重新导出 *)

exception Unknown_literal_token = Token_dispatcher.Unknown_literal_token
exception Unknown_basic_keyword_token = Token_dispatcher.Unknown_basic_keyword_token
exception Unknown_type_keyword_token = Token_dispatcher.Unknown_type_keyword_token
exception Unknown_classical_token = Token_dispatcher.Unknown_classical_token

(** 主要转换函数 - 通过调度器提供 *)
let convert_identifier_token = Token_dispatcher.Identifiers.convert_identifier_token

let convert_literal_token = Token_dispatcher.Literals.convert_literal_token
let convert_basic_keyword_token = Token_dispatcher.BasicKeywords.convert_basic_keyword_token
let convert_type_keyword_token = Token_dispatcher.TypeKeywords.convert_type_keyword_token

(** 古典语言转换函数 *)
let convert_wenyan_token = Token_dispatcher.Classical.convert_wenyan_token

let convert_natural_language_token = Token_dispatcher.Classical.convert_natural_language_token
let convert_ancient_token = Token_dispatcher.Classical.convert_ancient_token
let convert_classical_token = Token_dispatcher.Classical.convert_classical_token

(** 统一转换接口 *)
let convert_token = Token_dispatcher.convert_token

let convert_token_list = Token_dispatcher.convert_token_list

module Identifiers = Token_dispatcher.Identifiers
(** 向后兼容的模块接口 *)

module Literals = Token_dispatcher.Literals
module BasicKeywords = Token_dispatcher.BasicKeywords
module TypeKeywords = Token_dispatcher.TypeKeywords
module Classical = Token_dispatcher.Classical

(** 统计信息接口 *)
let get_conversion_stats = Token_dispatcher.get_conversion_stats
