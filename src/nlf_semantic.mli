(** 自然语言函数定义语义增强模块 *)

(** 参数绑定信息 *)
type parameter_binding = {
  param_name : string;
  is_recursive_context : bool;
  usage_patterns : string list;
}

(** 函数语义信息 *)
type function_semantic_info = {
  function_name : string;
  parameter_bindings : parameter_binding list;
  is_recursive : bool;
  return_type_hint : string option;
  complexity_level : int; (** 1-简单, 2-中等, 3-复杂 *)
}

(** 递归模式类型 *)
type recursive_pattern = TailRecursive | NonTailRecursive | MutualRecursive | NoRecursion

(** {1 分析函数} *)

(** 分析函数的递归模式 *)
val analyze_recursive_pattern : string -> Ast.expr -> recursive_pattern

(** 智能参数绑定分析 *)
val analyze_parameter_binding : string -> string -> Ast.expr -> parameter_binding

(** 推断函数返回类型 *)
val infer_return_type : Ast.expr -> string option

(** 计算复杂度级别 *)
val calculate_complexity_level : Ast.expr -> int

(** {1 主要语义分析} *)

(** 分析自然语言函数的语义信息 *)
val analyze_natural_function_semantics : string -> string list -> Ast.expr -> function_semantic_info

(** {1 报告和验证} *)

(** 生成语义分析报告 *)
val generate_semantic_report : function_semantic_info -> string

(** 验证自然语言函数的语义一致性 *)
val validate_semantic_consistency : function_semantic_info -> string list