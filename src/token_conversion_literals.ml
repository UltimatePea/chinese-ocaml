(** Token转换 - 字面量专门模块 (重定向到统一系统)

    原从token_conversion_core.ml中提取的字面量转换逻辑，现已整合到统一token系统。 本模块提供向后兼容性，将调用重定向到Token_dispatcher统一实现。

    Phase 4B Token系统整合：消除重复实现，统一到token_system_unified

    @author 骆言技术债务清理团队 Issue #1256, #1423
    @version 2.0 (Phase 4B 整合版本)
    @since 2025-07-25, 重构于2025-07-27 *)

exception Unknown_literal_token = Token_dispatcher.Unknown_literal_token
(** 向后兼容性 - 重新导出异常 *)

(** 转换字面量tokens - 重定向到统一实现 *)
let convert_literal_token = Token_dispatcher.Literals.convert_literal_token

(** 检查是否为字面量token - 简化实现使用统一系统 *)
let is_literal_token token =
  try
    let _ = Token_dispatcher.Literals.convert_literal_token token in
    true
  with Token_dispatcher.Unknown_literal_token _ -> false

(** 安全转换字面量token（返回Option类型） - 重定向到统一实现 *)
let convert_literal_token_safe token =
  try Some (convert_literal_token token) with Token_dispatcher.Unknown_literal_token _ -> None
