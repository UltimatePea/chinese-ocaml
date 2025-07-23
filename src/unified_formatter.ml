(** 骆言编译器统一格式化工具 - 兼容性包装器

    本模块作为兼容性包装器，重新导出所有拆分后的子模块功能。 确保原有的API接口完全兼容，实现渐进式模块化重构。

    重构目的：大型模块细化 - Fix #893
    @author 骆言AI代理
    @version 2.0 (重构版)
    @since 2025-07-22 *)

(* 导入所有子模块 *)
(* 注意：使用模块别名不需要open，直接引用即可 *)

module ErrorMessages = Formatter_errors.ErrorMessages
(** 重新导出错误消息格式化模块 *)

module ErrorHandling = Formatter_errors.ErrorHandling
module EnhancedErrorMessages = Formatter_errors.EnhancedErrorMessages
module ErrorHandlingFormatter = Formatter_errors.ErrorHandlingFormatter

module CCodegen = Formatter_codegen.CCodegen
(** 重新导出C代码生成格式化模块 *)

module EnhancedCCodegen = Formatter_codegen.EnhancedCCodegen

module LogMessages = Formatter_logging.LogMessages
(** 重新导出日志格式化模块 *)

module CompilerMessages = Formatter_logging.CompilerMessages
module EnhancedLogMessages = Formatter_logging.EnhancedLogMessages
module LoggingFormatter = Formatter_logging.LoggingFormatter

module Position = Formatter_tokens.Position
(** 重新导出Token和位置格式化模块 *)

module TokenFormatting = Formatter_tokens.TokenFormatting
module EnhancedPosition = Formatter_tokens.EnhancedPosition

module PoetryFormatting = Formatter_poetry.PoetryFormatting
(** 重新导出诗词格式化模块 *)

module General = Formatter_core.General
(** 重新导出核心格式化模块 *)

module Collections = Formatter_core.Collections
module Conversions = Formatter_core.Conversions
module TypeFormatter = Formatter_core.TypeFormatter
module ReportFormatting = Formatter_core.ReportFormatting
module StringProcessingFormatter = Formatter_core.StringProcessingFormatter

(** 为了完全兼容性，还需要提供任何可能被直接使用的函数 *)

(* 如果有任何模块外直接导出的函数，在这里重新导出 *)
(* 例如： *)
(* let some_direct_function = SomeModule.some_function *)

(* 根据原始unified_formatter.ml的使用模式，重新导出主要接口 *)

(** 兼容性检查：确保所有原始模块都有对应的导出 *)
(* 
  原始模块列表:
  - ErrorMessages ✓
  - CompilerMessages ✓ 
  - CCodegen ✓
  - LogMessages ✓
  - Position ✓
  - General ✓
  - Collections ✓
  - Conversions ✓
  - ErrorHandling ✓
  - TokenFormatting ✓
  - EnhancedErrorMessages ✓
  - EnhancedPosition ✓
  - EnhancedCCodegen ✓
  - PoetryFormatting ✓
  - EnhancedLogMessages ✓
  - ReportFormatting ✓
  - TypeFormatter ✓
  - ErrorHandlingFormatter ✓
  - LoggingFormatter ✓
  - StringProcessingFormatter ✓
*)
