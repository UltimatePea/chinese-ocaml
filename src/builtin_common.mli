(** 骆言内置函数通用导入模块接口
 * 
 * 统一管理所有内置函数模块的共同依赖，减少重复导入语句
 * 
 * @author 骆言技术债务清理团队 Issue #1298
 * @version 1.0
 * @since 2025-07-25 *)

(** 重新导出Value_operations模块 *)
include module type of Value_operations

(** 重新导出Builtin_error模块 *)
include module type of Builtin_error

(** 导出辅助函数模块 *)
module Helpers : module type of Builtin_function_helpers