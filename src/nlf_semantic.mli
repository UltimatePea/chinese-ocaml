(** 自然语言函数定义语义增强模块接口 - Natural Language Function Semantic Enhancement Interface *)

type parameter_binding = {
  param_name : string;  (** 参数名称 *)
  is_recursive_context : bool;  (** 是否在递归上下文中 *)
  usage_patterns : string list;  (** 使用模式列表 *)
}
(** 参数绑定信息 *)

(** 递归模式类型 *)
type recursive_pattern =
  | TailRecursive  (** 尾递归 *)
  | NonTailRecursive  (** 非尾递归 *)
  | MutualRecursive  (** 相互递归 *)
  | NoRecursion  (** 非递归 *)

type function_semantic_info = {
  function_name : string;  (** 函数名称 *)
  parameter_bindings : parameter_binding list;  (** 参数绑定信息 *)
  is_recursive : bool;  (** 是否递归函数 *)
  return_type_hint : string option;  (** 返回类型提示 *)
  complexity_level : int;  (** 复杂度级别 1-3 *)
}
(** 函数语义信息 *)

(** 主要功能函数 *)

val analyze_natural_function_semantics : string -> string list -> Ast.expr -> function_semantic_info
(** 分析自然语言函数语义
    @param func_name 函数名称
    @param params 参数列表
    @param body 函数体表达式
    @return 函数语义信息 *)

val generate_semantic_report : function_semantic_info -> string
(** 生成语义分析报告
    @param semantic_info 函数语义信息
    @return 格式化的报告字符串 *)

val validate_semantic_consistency : function_semantic_info -> string list
(** 验证语义一致性
    @param semantic_info 函数语义信息
    @return 错误信息列表 *)

val analyze_recursive_pattern : string -> Ast.expr -> recursive_pattern
(** 分析递归模式
    @param func_name 函数名称
    @param body 函数体表达式
    @return 递归模式 *)
