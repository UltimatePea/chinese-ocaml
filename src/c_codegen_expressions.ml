(** 骆言C代码生成器表达式模块 (重构版) - Chinese Programming Language C Code Generator Expression Module
    (Refactored) *)

open Ast
open C_codegen_context
open Error_utils

(* 导入分拆后的模块 *)
open C_codegen_literals
open C_codegen_operations
open C_codegen_collections
open C_codegen_structured
open C_codegen_control
open C_codegen_patterns
open C_codegen_exceptions

(** 初始化模块日志器 *)
let log_info = Logger_utils.init_info_logger "CCodegenExpr"

(** 获取表达式描述，用于日志记录 *)
let get_expr_description = function
  | LitExpr (IntLit _) -> "整数字面量"
  | LitExpr (FloatLit _) -> "浮点数字面量"
  | LitExpr (StringLit _) -> "字符串字面量"
  | LitExpr (BoolLit _) -> "布尔字面量"
  | LitExpr UnitLit -> "单元字面量"
  | VarExpr _ -> "变量表达式"
  | BinaryOpExpr _ -> "二元运算表达式"
  | UnaryOpExpr _ -> "一元运算表达式"
  | FunCallExpr _ -> "函数调用表达式"
  | FunExpr _ -> "函数定义表达式"
  | CondExpr _ -> "条件表达式"
  | LetExpr _ -> "let表达式"
  | MatchExpr _ -> "匹配表达式"
  | ListExpr _ -> "列表表达式"
  | ArrayExpr _ -> "数组表达式"
  | TupleExpr _ -> "元组表达式"
  | RecordExpr _ -> "记录表达式"
  | FieldAccessExpr _ -> "字段访问表达式"
  | ArrayAccessExpr _ -> "数组访问表达式"
  | RefExpr _ -> "引用表达式"
  | DerefExpr _ -> "解引用表达式"
  | AssignExpr _ -> "赋值表达式"
  | TryExpr _ -> "try表达式"
  | RaiseExpr _ -> "raise表达式"
  | _ -> "其他"

(** 主要的表达式生成分发函数 *)
let rec dispatch_expr_generation ctx = function
  | (LitExpr _ | VarExpr _) as expr -> C_codegen_literals.gen_literal_and_vars ctx expr
  | (BinaryOpExpr _ | UnaryOpExpr _) as expr ->
      C_codegen_operations.gen_operations gen_expr ctx expr
  | (RefExpr _ | DerefExpr _ | AssignExpr _) as expr ->
      C_codegen_operations.gen_memory_operations gen_expr ctx expr
  | (ListExpr _ | ArrayExpr _ | ArrayAccessExpr _) as expr ->
      C_codegen_collections.gen_collections gen_expr ctx expr
  | (TupleExpr _ | RecordExpr _ | FieldAccessExpr _) as expr ->
      C_codegen_structured.gen_structured_data gen_expr ctx expr
  | (FunCallExpr _ | FunExpr _ | CondExpr _ | LetExpr _ | MatchExpr _) as expr ->
      C_codegen_control.gen_control_flow gen_expr gen_pattern_check ctx expr
  | (TryExpr _ | RaiseExpr _) as expr ->
      C_codegen_exceptions.gen_exception_handling gen_expr ctx expr
  | CombineExpr _ as expr -> C_codegen_exceptions.gen_advanced_control_flow gen_expr ctx expr
  | ModuleExpr _ -> fail_unsupported_expression_detailed "gen_expr" GeneralExpression "模块表达式"
  | _ -> fail_unsupported_expression_detailed "gen_expr" GeneralExpression "未知表达式"

(** 主要的表达式生成函数 *)
and gen_expr ctx expr =
  log_info (Printf.sprintf "正在生成表达式代码: %s" (get_expr_description expr));
  dispatch_expr_generation ctx expr

(** 生成模式检查代码 (重新导出以保持兼容性) *)
and gen_pattern_check ctx expr_var pattern =
  C_codegen_patterns.gen_pattern_check ctx expr_var pattern
