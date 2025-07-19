(** 骆言类型系统核心类型定义 - Core Type Definitions *)

(** ========== 类型定义区域 ========== *)

(** 类型定义 *)
type typ =
  | IntType_T
  | FloatType_T
  | StringType_T
  | BoolType_T
  | UnitType_T
  | FunType_T of typ * typ
  | TupleType_T of typ list
  | ListType_T of typ
  | TypeVar_T of string
  | ConstructType_T of string * typ list
  | RefType_T of typ
  | RecordType_T of (string * typ) list (* 记录类型: [(field_name, field_type); ...] *)
  | ArrayType_T of typ (* 数组类型: [|element_type|] *)
  | ClassType_T of string * (string * typ) list (* 类类型: 类名 和方法类型列表 *)
  | ObjectType_T of (string * typ) list (* 对象类型: 方法类型列表 *)
  | PrivateType_T of string * typ (* 私有类型: 类型名 和底层类型 *)
  | PolymorphicVariantType_T of (string * typ option) list (* 多态变体类型: [(标签, 类型); ...] *)
[@@deriving show, eq]

(** 类型方案 *)
type type_scheme = TypeScheme of string list * typ

(** ========== 模块定义区域 ========== *)

module TypeEnv = Map.Make (String)
(** 类型环境模块 *)

module OverloadMap = Map.Make (String)
(** 函数重载表模块 *)

module SubstMap = Map.Make (String)
(** 类型替换模块 *)

(** ========== 依赖模块的类型定义区域 ========== *)

type env = type_scheme TypeEnv.t
(** 类型环境 *)

type overload_env = type_scheme list OverloadMap.t
(** 函数重载环境 - 存储同名函数的不同类型签名 *)

type type_subst = typ SubstMap.t
(** 类型替换 *)

(** ========== 全局状态区域 ========== *)

(** 类型变量计数器 *)
let type_var_counter = ref 0

(** ========== 实用函数区域 ========== *)

(** 生成新的类型变量 *)
let new_type_var () =
  incr type_var_counter;
  TypeVar_T ("'a" ^ string_of_int !type_var_counter)

(** 空替换 *)
let empty_subst = SubstMap.empty

(** 单一替换 *)
let single_subst var_name typ = SubstMap.singleton var_name typ

(** 类型显示函数 *)
let rec string_of_typ = function
  | IntType_T -> "整数"
  | FloatType_T -> "浮点数"
  | StringType_T -> "字符串"
  | BoolType_T -> "布尔值"
  | UnitType_T -> "空值"
  | FunType_T (param, ret) -> Printf.sprintf "(%s -> %s)" (string_of_typ param) (string_of_typ ret)
  | TupleType_T types -> "(" ^ String.concat " * " (List.map string_of_typ types) ^ ")"
  | ListType_T typ -> Printf.sprintf "[%s]" (string_of_typ typ)
  | TypeVar_T name -> name
  | ConstructType_T (name, []) -> name
  | ConstructType_T (name, args) ->
      Printf.sprintf "%s<%s>" name (String.concat ", " (List.map string_of_typ args))
  | RefType_T typ -> Printf.sprintf "ref<%s>" (string_of_typ typ)
  | RecordType_T fields ->
      let field_strs = List.map (fun (name, typ) -> name ^ ": " ^ string_of_typ typ) fields in
      "{" ^ String.concat "; " field_strs ^ "}"
  | ArrayType_T typ -> Printf.sprintf "[|%s|]" (string_of_typ typ)
  | ClassType_T (name, methods) ->
      let method_strs = List.map (fun (name, typ) -> name ^ ": " ^ string_of_typ typ) methods in
      Printf.sprintf "class %s {%s}" name (String.concat "; " method_strs)
  | ObjectType_T methods ->
      let method_strs = List.map (fun (name, typ) -> name ^ ": " ^ string_of_typ typ) methods in
      "{" ^ String.concat "; " method_strs ^ "}"
  | PrivateType_T (name, _) -> name
  | PolymorphicVariantType_T variants ->
      let variant_strs =
        List.map
          (fun (tag, typ_opt) ->
            match typ_opt with
            | None -> "`" ^ tag
            | Some typ -> "`" ^ tag ^ " of " ^ string_of_typ typ)
          variants
      in
      "[" ^ String.concat " | " variant_strs ^ "]"

(** 获取类型中的自由变量 *)
let rec free_vars = function
  | IntType_T | FloatType_T | StringType_T | BoolType_T | UnitType_T -> []
  | FunType_T (param, ret) -> List.rev_append (free_vars param) (free_vars ret)
  | TupleType_T types -> List.concat (List.map free_vars types)
  | ListType_T typ -> free_vars typ
  | TypeVar_T name -> [ name ]
  | ConstructType_T (_, args) -> List.concat (List.map free_vars args)
  | RefType_T typ -> free_vars typ
  | RecordType_T fields -> List.concat (List.map (fun (_, typ) -> free_vars typ) fields)
  | ArrayType_T typ -> free_vars typ
  | ClassType_T (_, methods) -> List.concat (List.map (fun (_, typ) -> free_vars typ) methods)
  | ObjectType_T methods -> List.concat (List.map (fun (_, typ) -> free_vars typ) methods)
  | PrivateType_T (_, typ) -> free_vars typ
  | PolymorphicVariantType_T variants ->
      List.concat
        (List.map
           (fun (_, typ_opt) -> match typ_opt with None -> [] | Some typ -> free_vars typ)
           variants)

(** 检查类型是否包含类型变量 *)
let rec contains_type_var var_name = function
  | TypeVar_T name -> name = var_name
  | FunType_T (param, ret) -> contains_type_var var_name param || contains_type_var var_name ret
  | TupleType_T types -> List.exists (contains_type_var var_name) types
  | ListType_T typ -> contains_type_var var_name typ
  | ConstructType_T (_, args) -> List.exists (contains_type_var var_name) args
  | RefType_T typ -> contains_type_var var_name typ
  | RecordType_T fields -> List.exists (fun (_, typ) -> contains_type_var var_name typ) fields
  | ArrayType_T typ -> contains_type_var var_name typ
  | ClassType_T (_, methods) -> List.exists (fun (_, typ) -> contains_type_var var_name typ) methods
  | ObjectType_T methods -> List.exists (fun (_, typ) -> contains_type_var var_name typ) methods
  | PrivateType_T (_, typ) -> contains_type_var var_name typ
  | PolymorphicVariantType_T variants ->
      List.exists
        (fun (_, typ_opt) ->
          match typ_opt with None -> false | Some typ -> contains_type_var var_name typ)
        variants
  | _ -> false

(** 检查类型是否是基础类型 *)
let is_base_type = function
  | IntType_T | FloatType_T | StringType_T | BoolType_T | UnitType_T -> true
  | _ -> false

(** 检查类型是否是复合类型 *)
let is_compound_type = function
  | FunType_T _ | TupleType_T _ | ListType_T _ | ConstructType_T _ | RefType_T _ | RecordType_T _
  | ArrayType_T _ | ClassType_T _ | ObjectType_T _ | PrivateType_T _ | PolymorphicVariantType_T _ ->
      true
  | _ -> false
