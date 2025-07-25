(** 骆言内置函数通用导入模块
 * 
 * 统一管理所有内置函数模块的共同依赖，减少重复导入语句
 * 
 * @author 骆言技术债务清理团队 Issue #1298
 * @version 1.0
 * @since 2025-07-25 *)

(** 重新导出常用模块，为内置函数提供统一接口 *)
include Value_operations
include Builtin_error

(** 导出辅助函数模块（如果存在） *)
module Helpers = Builtin_function_helpers