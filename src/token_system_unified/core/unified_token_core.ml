(** 统一Token核心系统 - 桥接和重新导出现有系统 *)

(* 重新导出核心类型 *)
include Token_types

(** Token优先级定义 *)
type token_priority =
  | HighPriority  (** 高优先级：关键字、保留字 *)
  | MediumPriority  (** 中优先级：运算符、分隔符 *)
  | LowPriority  (** 低优先级：标识符、字面量 *)

(** 统一Token类型 - 重新导出现有的token类型 *)
type unified_token = token

(** 简化版本的positioned_token *)
type positioned_token = {
  token : unified_token;
  position : position;
  metadata : token_metadata option;
}

(** 向后兼容的模块别名 *)
module TokenCategoryChecker = struct
  include Token_category_checker
end

(** 基础工具函数 *)
let string_of_token = Token_types.TokenUtils.token_to_string
let get_token_category = Token_category_checker.get_token_category
let equal_token = Token_types.equal_token

(** 创建positioned token *)
let make_positioned_token token position metadata = 
  { token; position; metadata }

(** 创建简单positioned token *)
let make_simple_token token filename line column = 
  let position = { line; column; filename } in
  make_positioned_token token position None

(** 获取token的默认优先级 *)
let get_token_priority token =
  match token with
  | KeywordToken _ -> HighPriority
  | OperatorToken _ -> MediumPriority
  | DelimiterToken _ -> MediumPriority
  | LiteralToken _ -> LowPriority
  | IdentifierToken _ -> LowPriority
  | SpecialToken _ -> LowPriority

(** 创建默认位置 *)
let default_position filename = { line = 1; column = 1; filename }

(** Token相等性比较 *)
let equal_positioned_token t1 t2 = 
  equal_token t1.token t2.token