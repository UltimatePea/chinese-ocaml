(** Token转换 - 标识符专门模块 (重定向到统一系统)

    原从token_conversion_core.ml中提取的标识符转换逻辑，现已整合到统一token系统。
    本模块提供向后兼容性，将调用重定向到Token_dispatcher统一实现。

    Phase 4B Token系统整合：消除重复实现，统一到token_system_unified
    
    @author 骆言技术债务清理团队 Issue #1256, #1423
    @version 2.0 (Phase 4B 整合版本)
    @since 2025-07-25, 重构于2025-07-27 *)

open Token_dispatcher
(** 导入统一token调度器 *)

(** 向后兼容性 - 重新导出异常 *)
exception Unknown_identifier_token = Token_dispatcher.Unknown_identifier_token

(** 转换标识符tokens - 重定向到统一实现 *)
let convert_identifier_token = Token_dispatcher.Identifiers.convert_identifier_token

(** 检查是否为标识符token - 简化实现使用统一系统 *)
let is_identifier_token token =
  try 
    let _ = Token_dispatcher.Identifiers.convert_identifier_token token in
    true
  with Unknown_identifier_token _ -> false

(** 安全转换标识符token（返回Option类型） - 重定向到统一实现 *)
let convert_identifier_token_safe token =
  try Some (convert_identifier_token token) with Unknown_identifier_token _ -> None
