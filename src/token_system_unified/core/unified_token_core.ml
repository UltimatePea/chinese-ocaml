(** 统一Token核心系统 - 模块化重构版本 作为协调器和向后兼容层，委派给专门的子模块 *)

(* 重新导出核心类型 *)
include Token_types

(* 向后兼容的模块别名 *)
module TokenCategoryChecker = struct
  include Token_category_checker
end

(* 重新导出函数以保持向后兼容性 *)
let get_token_category = Token_category_checker.get_token_category

(* 重新导出字符串转换函数 *)
let string_of_token = Token_types.TokenUtils.token_to_string

(* 重新导出工具函数以保持向后兼容性 *)
let make_positioned_token token position = (token, position)
let default_position = { line = 1; column = 1; filename = "unknown" }
let equal_token = Token_types.equal_token
