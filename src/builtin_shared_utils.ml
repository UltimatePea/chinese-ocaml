(*
 * 内置函数公共工具模块
 * 提供内置函数模块间共享的工具函数，消除代码重复
 * Phase 15.3: 内置函数重构的核心组件
 *)

open Value_operations
open Builtin_error

(** 字符串处理工具函数 *)

(** 字符串反转工具函数 - 消除重复实现 原重复位置：
    - builtin_string.ml:46-50 (string_reverse_function)
    - builtin_collections.ml:76-79 (reverse_function中的字符串处理部分) *)
let reverse_string (s : string) : string =
  let chars = List.of_seq (String.to_seq s) in
  let reversed_chars = List.rev chars in
  String.of_seq (List.to_seq reversed_chars)

(** 参数验证助手函数 - 消除重复验证模式 目标：减少 check_single_arg + expect_type 的重复调用模式 *)

(** 单参数验证助手 *)
let validate_single_param (expect_func : runtime_value -> string -> 'a) args func_name =
  expect_func (check_single_arg args func_name) func_name

(** 双参数验证助手 *)
let validate_double_params expect_func1 expect_func2 args func_name =
  let arg1, arg2 = check_double_args args func_name in
  (expect_func1 arg1 func_name, expect_func2 arg2 func_name)

(** 通用长度计算函数 - 统一所有长度相关操作 *)
let get_length_value = function
  | StringValue s -> IntValue (String.length s)
  | ListValue lst -> IntValue (List.length lst)
  | ArrayValue arr -> IntValue (Array.length arr)
  | _ -> runtime_error "不支持的长度操作类型"

(** 柯里化函数包装器 - 减少高阶函数重复包装模式 *)
let create_binary_function validate1 validate2 impl_func func_name =
 fun args ->
  let param1 = validate1 (check_single_arg args func_name) func_name in
  BuiltinFunctionValue
    (fun args2 ->
      let param2 = validate2 (check_single_arg args2 func_name) func_name in
      impl_func param1 param2)

type collection_type =
  [ `String of string | `List of runtime_value list | `Array of runtime_value array ]
(** 集合操作模板 - 支持多种集合类型的统一操作 *)

let apply_to_collection operation = function
  | StringValue s -> operation (`String s)
  | ListValue lst -> operation (`List lst)
  | ArrayValue arr -> operation (`Array arr)
  | _ -> runtime_error "不支持的集合类型"

(** 数值聚合器模板 - 创建通用的聚合操作 *)
let create_aggregator operation initial_value collection =
  List.fold_left operation initial_value collection
