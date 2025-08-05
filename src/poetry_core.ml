(** Poetry_core module alias

    此模块为Poetry_core_compat模块提供直接访问别名，确保现有代码 无需修改即可继续使用Poetry_core.*模块路径。

    Author: Whisky, PR Worker Issue: #1999 - Poetry韵律模块统一整合

    @since 2025-08-04 *)

include Poetry_core_compat
(** 直接重新导出Poetry_core_compat模块的所有内容 *)
