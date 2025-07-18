(** 骆言类型系统 - 类型转换模块 *)

open Ast
open Core_types

(** 初始化模块日志器 *)
let () = Logger_utils.init_no_logger "Types.Convert"

(** 从基础类型转换 *)
let from_base_type base_type =
  match base_type with
  | IntType -> IntType_T
  | FloatType -> FloatType_T
  | StringType -> StringType_T
  | BoolType -> BoolType_T
  | UnitType -> UnitType_T

(** 从类型表达式转换为类型 *)
let rec type_expr_to_typ type_expr =
  match type_expr with
  | BaseTypeExpr base_type -> from_base_type base_type
  | TypeVar var_name -> TypeVar_T var_name
  | FunType (param_type, return_type) ->
      FunType_T (type_expr_to_typ param_type, type_expr_to_typ return_type)
  | TupleType type_list -> TupleType_T (List.map type_expr_to_typ type_list)
  | ListType elem_type -> ListType_T (type_expr_to_typ elem_type)
  | ConstructType (name, type_list) -> ConstructType_T (name, List.map type_expr_to_typ type_list)
  | RefType inner_type -> RefType_T (type_expr_to_typ inner_type)
  | PolymorphicVariantType variants ->
      PolymorphicVariantType_T
        (List.map
           (fun (tag, type_opt) ->
             match type_opt with
             | Some type_expr -> (tag, Some (type_expr_to_typ type_expr))
             | None -> (tag, None))
           variants)

(** 从字面量推断类型 *)
let literal_type literal =
  match literal with
  | IntLit _ -> IntType_T
  | FloatLit _ -> FloatType_T
  | StringLit _ -> StringType_T
  | BoolLit _ -> BoolType_T
  | UnitLit -> UnitType_T

(** 从二元运算符推断类型 *)
let binary_op_type op =
  match op with
  | Add | Sub | Mul | Div | Mod -> (IntType_T, IntType_T, IntType_T) (* (左操作数, 右操作数, 结果) *)
  | Concat -> (StringType_T, StringType_T, StringType_T) (* 字符串连接 *)
  | Eq | Neq ->
      let var = new_type_var () in
      (var, var, BoolType_T)
  | Lt | Le | Gt | Ge -> (IntType_T, IntType_T, BoolType_T)
  | And | Or -> (BoolType_T, BoolType_T, BoolType_T)

(** 从一元运算符推断类型 *)
let unary_op_type op =
  match op with Neg -> (IntType_T, IntType_T) (* (操作数, 结果) *) | Not -> (BoolType_T, BoolType_T)

(** 从模式中提取变量绑定 - 优化版本，使用尾递归避免重复的List.rev操作 *)
let extract_pattern_bindings pattern =
  let rec collect_bindings pattern acc =
    match pattern with
    | WildcardPattern -> acc
    | VarPattern var_name -> (var_name, TypeScheme ([], new_type_var ())) :: acc
    | LitPattern _ -> acc
    | ConstructorPattern (_, sub_patterns) ->
        List.fold_left (fun acc p -> collect_bindings p acc) acc sub_patterns
    | TuplePattern patterns -> List.fold_left (fun acc p -> collect_bindings p acc) acc patterns
    | ListPattern patterns -> List.fold_left (fun acc p -> collect_bindings p acc) acc patterns
    | ConsPattern (head_pattern, tail_pattern) ->
        let acc1 = collect_bindings head_pattern acc in
        collect_bindings tail_pattern acc1
    | EmptyListPattern -> acc
    | OrPattern (pattern1, pattern2) ->
        let acc1 = collect_bindings pattern1 acc in
        collect_bindings pattern2 acc1
    | ExceptionPattern (_, pattern_opt) -> (
        match pattern_opt with Some pattern -> collect_bindings pattern acc | None -> acc)
    | PolymorphicVariantPattern (_, pattern_opt) -> (
        match pattern_opt with Some pattern -> collect_bindings pattern acc | None -> acc)
  in
  collect_bindings pattern []

(** 模块类型转换为类型表示 *)
let rec convert_module_type_to_typ = function
  | Signature signature_items ->
      (* 将签名转换为对象类型：每个签名项对应一个方法 *)
      let rec convert_sig_items items acc_methods =
        match items with
        | [] -> ObjectType_T (List.rev acc_methods)
        | SigValue (name, type_expr) :: rest ->
            let typ = convert_type_expr_to_typ type_expr in
            convert_sig_items rest ((name, typ) :: acc_methods)
        | SigTypeDecl (name, _type_def_opt) :: rest ->
            (* 类型声明转换为类型变量 *)
            let typ = TypeVar_T name in
            convert_sig_items rest ((name, typ) :: acc_methods)
        | SigModule (name, module_type) :: rest ->
            let module_typ = convert_module_type_to_typ module_type in
            convert_sig_items rest ((name, module_typ) :: acc_methods)
        | SigException (name, type_expr_opt) :: rest ->
            let exception_typ =
              match type_expr_opt with
              | Some type_expr -> convert_type_expr_to_typ type_expr
              | None -> UnitType_T
            in
            convert_sig_items rest ((name, exception_typ) :: acc_methods)
      in
      convert_sig_items signature_items []
  | ModuleTypeName name ->
      (* 命名模块类型：尝试查找定义，否则创建新的类型变量 *)
      (* 在完整的实现中，这里应该查找模块类型环境 *)
      (* 目前创建一个命名的类型变量来保持类型信息 *)
      TypeVar_T ("'" ^ name ^ "_module_type")
  | FunctorType (_param_name, param_type, return_type) ->
      (* 函子类型转换为函数类型 *)
      let param_typ = convert_module_type_to_typ param_type in
      let return_typ = convert_module_type_to_typ return_type in
      FunType_T (param_typ, return_typ)

(** 类型表达式转换为内部类型表示 *)
and convert_type_expr_to_typ = function
  | TypeVar name -> TypeVar_T name
  | BaseTypeExpr base_type -> (
      match base_type with
      | IntType -> IntType_T
      | FloatType -> FloatType_T
      | StringType -> StringType_T
      | BoolType -> BoolType_T
      | UnitType -> UnitType_T)
  | FunType (param_type, return_type) ->
      let param_typ = convert_type_expr_to_typ param_type in
      let return_typ = convert_type_expr_to_typ return_type in
      FunType_T (param_typ, return_typ)
  | TupleType type_list ->
      let typ_list = List.map convert_type_expr_to_typ type_list in
      TupleType_T typ_list
  | ListType elem_type ->
      let elem_typ = convert_type_expr_to_typ elem_type in
      ListType_T elem_typ
  | ConstructType (name, type_args) ->
      let typ_args = List.map convert_type_expr_to_typ type_args in
      ConstructType_T (name, typ_args)
  | RefType inner_type ->
      let inner_typ = convert_type_expr_to_typ inner_type in
      RefType_T inner_typ
  | PolymorphicVariantType variants ->
      let converted_variants =
        List.map
          (fun (label, type_opt) ->
            (label, match type_opt with Some t -> Some (convert_type_expr_to_typ t) | None -> None))
          variants
      in
      PolymorphicVariantType_T converted_variants

(** 基础类型转换为中文字符串 *)
let basic_type_to_chinese = function
  | IntType_T -> "整数"
  | FloatType_T -> "浮点数"
  | StringType_T -> "字符串"
  | BoolType_T -> "布尔值"
  | UnitType_T -> "单元"
  | _ -> failwith "不是基础类型"

(** 容器类型转换为中文字符串 *)
let container_type_to_chinese to_chinese = function
  | ListType_T elem_type -> to_chinese elem_type ^ " 列表"
  | ArrayType_T elem_type -> to_chinese elem_type ^ " 数组"
  | RefType_T inner_type -> to_chinese inner_type ^ " 引用"
  | TupleType_T type_list ->
      "(" ^ String.concat " * " (List.map to_chinese type_list) ^ ")"
  | _ -> failwith "不是容器类型"

(** 构造类型转换为中文字符串 *)
let construct_type_to_chinese to_chinese = function
  | ConstructType_T (name, []) -> name
  | ConstructType_T (name, type_list) ->
      name ^ "(" ^ String.concat ", " (List.map to_chinese type_list) ^ ")"
  | TypeVar_T name -> "'" ^ name
  | _ -> failwith "不是构造类型"

(** 函数类型转换为中文字符串 *)
let function_type_to_chinese to_chinese = function
  | FunType_T (param_type, return_type) ->
      to_chinese param_type ^ " -> " ^ to_chinese return_type
  | _ -> failwith "不是函数类型"

(** 记录类型转换为中文字符串 *)
let record_type_to_chinese to_chinese = function
  | RecordType_T fields ->
      "{ "
      ^ String.concat "; "
          (List.map (fun (name, typ) -> name ^ ": " ^ to_chinese typ) fields)
      ^ " }"
  | _ -> failwith "不是记录类型"

(** 方法列表转换为中文字符串 *)
let format_methods to_chinese methods =
  String.concat "; "
    (List.map
       (fun (method_name, method_type) ->
         method_name ^ ": " ^ to_chinese method_type)
       methods)

(** 对象和类类型转换为中文字符串 *)
let object_class_type_to_chinese to_chinese = function
  | ClassType_T (name, methods) ->
      "类 " ^ name ^ " { " ^ format_methods to_chinese methods ^ " }"
  | ObjectType_T methods ->
      "对象 { " ^ format_methods to_chinese methods ^ " }"
  | _ -> failwith "不是对象或类类型"

(** 多态变体类型转换为中文字符串 *)
let variant_type_to_chinese to_chinese = function
  | PolymorphicVariantType_T variants ->
      "[ "
      ^ String.concat " | "
          (List.map
             (fun (label, typ_opt) ->
               match typ_opt with
               | Some t -> "`" ^ label ^ " of " ^ to_chinese t
               | None -> "`" ^ label)
             variants)
      ^ " ]"
  | _ -> failwith "不是多态变体类型"

(** 私有类型转换为中文字符串 *)
let private_type_to_chinese = function
  | PrivateType_T (name, _underlying_type) -> "私有类型 " ^ name
  | _ -> failwith "不是私有类型"

(** 类型转换为中文字符串（用于错误消息） - 重构后的主函数 *)
let rec type_to_chinese_string typ =
  try
    match typ with
    | IntType_T | FloatType_T | StringType_T | BoolType_T | UnitType_T ->
        basic_type_to_chinese typ
    | ListType_T _ | ArrayType_T _ | RefType_T _ | TupleType_T _ ->
        container_type_to_chinese type_to_chinese_string typ
    | ConstructType_T _ | TypeVar_T _ ->
        construct_type_to_chinese type_to_chinese_string typ
    | FunType_T _ ->
        function_type_to_chinese type_to_chinese_string typ
    | RecordType_T _ ->
        record_type_to_chinese type_to_chinese_string typ
    | ClassType_T _ | ObjectType_T _ ->
        object_class_type_to_chinese type_to_chinese_string typ
    | PolymorphicVariantType_T _ ->
        variant_type_to_chinese type_to_chinese_string typ
    | PrivateType_T _ ->
        private_type_to_chinese typ
  with
  | Failure _ -> "未知类型"
