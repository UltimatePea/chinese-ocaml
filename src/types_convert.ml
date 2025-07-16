(** 骆言类型系统 - 类型转换模块 *)

open Ast
open Core_types
(** 初始化模块日志器 *)
let _, _log_info, _, _log_error = Logger.init_module_logger "Types.Convert"

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

(** 从模式中提取变量绑定 *)
let rec extract_pattern_bindings pattern =
  match pattern with
  | WildcardPattern -> []
  | VarPattern var_name -> [ (var_name, TypeScheme ([], new_type_var ())) ]
  | LitPattern _ -> []
  | ConstructorPattern (_, sub_patterns) ->
      List.flatten (List.map extract_pattern_bindings sub_patterns)
  | TuplePattern patterns -> List.flatten (List.map extract_pattern_bindings patterns)
  | ListPattern patterns -> List.flatten (List.map extract_pattern_bindings patterns)
  | ConsPattern (head_pattern, tail_pattern) ->
      extract_pattern_bindings head_pattern @ extract_pattern_bindings tail_pattern
  | EmptyListPattern -> []
  | OrPattern (pattern1, pattern2) ->
      extract_pattern_bindings pattern1 @ extract_pattern_bindings pattern2
  | ExceptionPattern (_, pattern_opt) -> (
      match pattern_opt with Some pattern -> extract_pattern_bindings pattern | None -> [])
  | PolymorphicVariantPattern (_, pattern_opt) -> (
      match pattern_opt with Some pattern -> extract_pattern_bindings pattern | None -> [])

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
            (label,
             match type_opt with Some t -> Some (convert_type_expr_to_typ t) | None -> None))
          variants
      in
      PolymorphicVariantType_T converted_variants

(** 类型转换为中文字符串（用于错误消息） *)
let rec type_to_chinese_string typ =
  match typ with
  | IntType_T -> "整数"
  | FloatType_T -> "浮点数"
  | StringType_T -> "字符串"
  | BoolType_T -> "布尔值"
  | UnitType_T -> "单元"
  | FunType_T (param_type, return_type) ->
      type_to_chinese_string param_type ^ " -> " ^ type_to_chinese_string return_type
  | TupleType_T type_list ->
      "(" ^ String.concat " * " (List.map type_to_chinese_string type_list) ^ ")"
  | ListType_T elem_type -> type_to_chinese_string elem_type ^ " 列表"
  | TypeVar_T name -> "'" ^ name
  | ConstructType_T (name, []) -> name
  | ConstructType_T (name, type_list) ->
      name ^ "(" ^ String.concat ", " (List.map type_to_chinese_string type_list) ^ ")"
  | RefType_T inner_type -> type_to_chinese_string inner_type ^ " 引用"
  | RecordType_T fields ->
      "{ " ^ String.concat "; " (List.map (fun (name, typ) -> name ^ ": " ^ type_to_chinese_string typ) fields) ^ " }"
  | ArrayType_T elem_type -> type_to_chinese_string elem_type ^ " 数组"
  | ClassType_T (name, methods) ->
      "类 " ^ name ^ " { " ^ String.concat "; " (List.map (fun (method_name, method_type) -> method_name ^ ": " ^ type_to_chinese_string method_type) methods) ^ " }"
  | ObjectType_T methods ->
      "对象 { " ^ String.concat "; " (List.map (fun (method_name, method_type) -> method_name ^ ": " ^ type_to_chinese_string method_type) methods) ^ " }"
  | PrivateType_T (name, _underlying_type) -> "私有类型 " ^ name
  | PolymorphicVariantType_T variants ->
      "[ " ^ String.concat " | " (List.map (fun (label, typ_opt) -> 
        match typ_opt with 
        | Some t -> "`" ^ label ^ " of " ^ type_to_chinese_string t 
        | None -> "`" ^ label
      ) variants) ^ " ]"