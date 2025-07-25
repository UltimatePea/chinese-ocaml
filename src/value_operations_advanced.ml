(** 骆言值操作高级类型模块 - Value Operations Advanced Types Module
    
    技术债务改进：大型模块重构优化 Phase 2.2 - value_operations.ml 完整模块化
    本模块负责高级运行时值操作，包括构造器注册、值比较等，从 value_operations.ml 中提取
    
    重构目标：
    1. 专门处理构造器函数的注册和管理
    2. 提供运行时值的相等性比较
    3. 支持高级类型（函数、模块、引用、异常等）的操作
    4. 维护高级类型的操作逻辑完整性
    
    @author 骆言AI代理
    @version 2.2 - 完整模块化第二阶段  
    @since 2025-07-24 Fix #1048
*)

open Value_types
open Ast

(** 初始化模块日志器 *)
let () = Logger_init_helpers.replace_init_no_logger "ValueOperationsAdvanced"

(** 注册构造器函数 *)
let register_constructors env type_def =
  match type_def with
  | AlgebraicType constructors ->
      (* 为每个构造器创建构造器函数 *)
      List.fold_left
        (fun acc_env (constructor_name, _type_opt) ->
          let constructor_func =
            BuiltinFunctionValue (fun args -> ConstructorValue (constructor_name, args))
          in
          bind_var acc_env constructor_name constructor_func)
        env constructors
  | _ -> env

(** 导入基础值比较函数，消除重复代码 *)
open Value_operations_basic

(** 容器类型值相等性比较的辅助函数 *)
let rec compare_container_values v1 v2 =
  match (v1, v2) with
  | ListValue l1, ListValue l2 ->
      List.length l1 = List.length l2 && List.for_all2 runtime_value_equal l1 l2
  | ArrayValue a1, ArrayValue a2 ->
      Array.length a1 = Array.length a2 && Array.for_all2 runtime_value_equal a1 a2
  | TupleValue t1, TupleValue t2 ->
      List.length t1 = List.length t2 && List.for_all2 runtime_value_equal t1 t2
  | RecordValue r1, RecordValue r2 ->
      List.length r1 = List.length r2
      && List.for_all
           (fun (k, v) ->
             match List.assoc_opt k r2 with Some v2 -> runtime_value_equal v v2 | None -> false)
           r1
  | RefValue r1, RefValue r2 -> runtime_value_equal !r1 !r2
  | _ -> false

(** 构造器和异常类型值相等性比较的辅助函数 *)
and compare_constructor_values v1 v2 =
  match (v1, v2) with
  | ConstructorValue (name1, args1), ConstructorValue (name2, args2) ->
      String.equal name1 name2
      && List.length args1 = List.length args2
      && List.for_all2 runtime_value_equal args1 args2
  | ExceptionValue (name1, opt1), ExceptionValue (name2, opt2) -> (
      String.equal name1 name2
      &&
      match (opt1, opt2) with
      | None, None -> true
      | Some v1, Some v2 -> runtime_value_equal v1 v2
      | _ -> false)
  | PolymorphicVariantValue (tag1, opt1), PolymorphicVariantValue (tag2, opt2) -> (
      String.equal tag1 tag2
      &&
      match (opt1, opt2) with
      | None, None -> true
      | Some v1, Some v2 -> runtime_value_equal v1 v2
      | _ -> false)
  | _ -> false

(** 模块类型值相等性比较的辅助函数 *)
and compare_module_values v1 v2 =
  match (v1, v2) with
  | ModuleValue m1, ModuleValue m2 ->
      List.length m1 = List.length m2
      && List.for_all
           (fun (k, v) ->
             match List.assoc_opt k m2 with Some v2 -> runtime_value_equal v v2 | None -> false)
           m1
  | _ -> false

(** 函数类型值相等性比较的辅助函数（函数不可比较） *)
and compare_function_values v1 v2 =
  match (v1, v2) with
  | FunctionValue _, FunctionValue _ -> false (* 函数不可比较 *)
  | BuiltinFunctionValue _, BuiltinFunctionValue _ -> false (* 内置函数不可比较 *)
  | LabeledFunctionValue _, LabeledFunctionValue _ -> false (* 标签函数不可比较 *)
  | _ -> false

(** 运行时值相等性比较 - 重构版本，使用分类比较函数 *)
and runtime_value_equal v1 v2 =
  equals_basic_values v1 v2 ||
  compare_container_values v1 v2 ||
  compare_constructor_values v1 v2 ||
  compare_module_values v1 v2 ||
  compare_function_values v1 v2

(** 检查值是否为可比较类型 *)
let is_comparable_value value =
  match value with
  | FunctionValue _ | BuiltinFunctionValue _ | LabeledFunctionValue _ -> false
  | _ -> true

(** 深度比较运行时值（更严格的比较） *)
let deep_equal v1 v2 =
  if not (is_comparable_value v1 && is_comparable_value v2) then
    false
  else
    runtime_value_equal v1 v2

(** 检查两个值是否为同一类型 *)
let same_type v1 v2 =
  match (v1, v2) with
  | IntValue _, IntValue _ -> true
  | FloatValue _, FloatValue _ -> true
  | StringValue _, StringValue _ -> true
  | BoolValue _, BoolValue _ -> true
  | UnitValue, UnitValue -> true
  | ListValue _, ListValue _ -> true
  | ArrayValue _, ArrayValue _ -> true
  | TupleValue _, TupleValue _ -> true
  | RecordValue _, RecordValue _ -> true
  | ConstructorValue _, ConstructorValue _ -> true
  | ModuleValue _, ModuleValue _ -> true
  | FunctionValue _, FunctionValue _ -> true
  | BuiltinFunctionValue _, BuiltinFunctionValue _ -> true
  | LabeledFunctionValue _, LabeledFunctionValue _ -> true
  | ExceptionValue _, ExceptionValue _ -> true
  | RefValue _, RefValue _ -> true
  | PolymorphicVariantValue _, PolymorphicVariantValue _ -> true
  | _ -> false

(** 创建引用值 *)
let make_ref_value value = RefValue (ref value)

(** 获取引用的值 *)
let deref_value ref_val =
  match ref_val with
  | RefValue r -> !r
  | _ -> raise (RuntimeError "尝试解引用非引用类型的值")

(** 设置引用的值 *)
let set_ref_value ref_val new_value =
  match ref_val with
  | RefValue r -> r := new_value; UnitValue
  | _ -> raise (RuntimeError "尝试设置非引用类型的值")

(** 创建构造器值 *)
let make_constructor_value name args =
  ConstructorValue (name, args)

(** 获取构造器的名称 *)
let get_constructor_name value =
  match value with
  | ConstructorValue (name, _) -> name
  | _ -> raise (RuntimeError "尝试获取非构造器类型的名称")

(** 获取构造器的参数 *)
let get_constructor_args value =
  match value with
  | ConstructorValue (_, args) -> args
  | _ -> raise (RuntimeError "尝试获取非构造器类型的参数")

(** 创建异常值 *)
let make_exception_value name payload_opt =
  ExceptionValue (name, payload_opt)

(** 获取异常的名称 *)
let get_exception_name value =
  match value with
  | ExceptionValue (name, _) -> name
  | _ -> raise (RuntimeError "尝试获取非异常类型的名称")

(** 获取异常的载荷 *)
let get_exception_payload value =
  match value with
  | ExceptionValue (_, payload) -> payload
  | _ -> raise (RuntimeError "尝试获取非异常类型的载荷")

(** 创建多态变体值 *)
let make_polymorphic_variant tag value_opt =
  PolymorphicVariantValue (tag, value_opt)

(** 获取多态变体的标签 *)
let get_variant_tag value =
  match value with
  | PolymorphicVariantValue (tag, _) -> tag
  | _ -> raise (RuntimeError "尝试获取非多态变体类型的标签")

(** 获取多态变体的值 *)
let get_variant_value value =
  match value with
  | PolymorphicVariantValue (_, value_opt) -> value_opt
  | _ -> raise (RuntimeError "尝试获取非多态变体类型的值")

(** 创建模块值 *)
let make_module_value bindings =
  ModuleValue bindings

(** 获取模块的绑定列表 *)
let get_module_bindings value =
  match value with
  | ModuleValue bindings -> bindings
  | _ -> raise (RuntimeError "尝试获取非模块类型的绑定")

(** 从模块中查找成员 *)
let lookup_module_member module_val member_name =
  match module_val with
  | ModuleValue bindings -> (
      match List.assoc_opt member_name bindings with
      | Some value -> value
      | None -> raise (RuntimeError ("模块中未找到成员: " ^ member_name)))
  | _ -> raise (RuntimeError "尝试在非模块类型中查找成员")

(** 检查模块是否包含指定成员 *)
let module_has_member module_val member_name =
  match module_val with
  | ModuleValue bindings -> List.mem_assoc member_name bindings
  | _ -> false

(** 获取模块的所有成员名称 *)
let get_module_member_names module_val =
  match module_val with
  | ModuleValue bindings -> List.map fst bindings
  | _ -> []

(** 合并两个模块 *)
let merge_modules module1 module2 =
  match (module1, module2) with
  | ModuleValue bindings1, ModuleValue bindings2 ->
      (* 第二个模块的绑定优先 *)
      let combined = bindings2 @ bindings1 in
      (* 移除重复的绑定 *)
      let rec remove_duplicates acc = function
        | [] -> List.rev acc
        | (name, value) :: rest ->
            if List.mem_assoc name acc then
              remove_duplicates acc rest
            else
              remove_duplicates ((name, value) :: acc) rest
      in
      ModuleValue (remove_duplicates [] combined)
  | _ -> raise (RuntimeError "尝试合并非模块类型的值")

(** Alcotest ValueModule - 用于测试 *)
module ValueModule = struct
  type t = runtime_value

  let equal = runtime_value_equal
  let pp = Value_operations_conversion.runtime_value_pp
end