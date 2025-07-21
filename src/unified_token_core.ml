(** 统一Token核心系统 - 模块化重构版本 作为协调器和向后兼容层，委派给专门的子模块 *)

(* 重新导出核心类型 *)
include Token_types_core

(* 向后兼容的模块别名 *)
module TokenCategoryChecker = struct
  include Token_category_checker
end

(* 重新导出函数以保持向后兼容性 *)
let get_token_category = Token_category_checker.get_token_category

(* 重新导出字符串转换函数 *)
let string_of_token = Token_string_converter.string_of_token

(* 重新导出工具函数以保持向后兼容性 *)
let make_positioned_token = Token_utils_core.make_positioned_token
let make_simple_token = Token_utils_core.make_simple_token
let get_token_priority = Token_utils_core.get_token_priority
let default_position = Token_utils_core.default_position
let equal_token = Token_utils_core.equal_token
