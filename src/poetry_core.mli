(** Poetry_core module alias interface

    此模块接口为Poetry_core_compat模块提供直接访问别名。

    Author: Whisky, PR Worker Issue: #1999 - Poetry韵律模块统一整合

    @since 2025-08-04 *)

include module type of Poetry_core_compat
(** 重新导出Poetry_core_compat模块的接口 *)
