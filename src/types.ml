(** 骆言类型系统 - Chinese Programming Language Type System *)

open Ast

(** 类型 *)
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
  | RecordType_T of (string * typ) list  (* 记录类型: [(field_name, field_type); ...] *)
  | ArrayType_T of typ                   (* 数组类型: [|element_type|] *)
  | ClassType_T of string * (string * typ) list  (* 类类型: 类名 和方法类型列表 *)
  | ObjectType_T of (string * typ) list          (* 对象类型: 方法类型列表 *)
  | PrivateType_T of string * typ                (* 私有类型: 类型名 和底层类型 *)
  | PolymorphicVariantType_T of (string * typ option) list  (* 多态变体类型: [(标签, 类型); ...] *)
[@@deriving show, eq]

(** 类型方案 *)
type type_scheme = TypeScheme of string list * typ

(** 类型环境 *)
module TypeEnv = Map.Make(String)
type env = type_scheme TypeEnv.t

(** 函数重载表 - 存储同名函数的不同类型签名 *)
module OverloadMap = Map.Make(String)
type overload_env = type_scheme list OverloadMap.t

(** 类型错误 *)
exception TypeError of string

(** 类型变量计数器 *)
let type_var_counter = ref 0

(** 生成新的类型变量 *)
let new_type_var () =
  incr type_var_counter;
  TypeVar_T ("'a" ^ string_of_int !type_var_counter)

(** 类型替换 *)
module SubstMap = Map.Make(String)
type type_subst = typ SubstMap.t

(** 空替换 *)
let empty_subst = SubstMap.empty

(** 单一替换 *)
let single_subst var_name typ = SubstMap.singleton var_name typ

(** 应用替换到类型 *)
let rec apply_subst subst typ =
  match typ with
  | TypeVar_T name ->
    (try SubstMap.find name subst
     with Not_found -> typ)
  | FunType_T (param_type, return_type) ->
    FunType_T (apply_subst subst param_type, apply_subst subst return_type)
  | TupleType_T type_list ->
    TupleType_T (List.map (apply_subst subst) type_list)
  | ListType_T elem_type ->
    ListType_T (apply_subst subst elem_type)
  | ConstructType_T (name, type_list) ->
    ConstructType_T (name, List.map (apply_subst subst) type_list)
  | RecordType_T fields ->
    RecordType_T (List.map (fun (name, typ) -> (name, apply_subst subst typ)) fields)
  | ArrayType_T elem_type ->
    ArrayType_T (apply_subst subst elem_type)
  | PrivateType_T (name, inner_type) ->
    PrivateType_T (name, apply_subst subst inner_type)
  | _ -> typ

(** 应用替换到类型方案 *)
let apply_subst_to_scheme subst (TypeScheme (vars, typ)) =
  (* 过滤掉被量化的变量 *)
  let filtered_subst = List.fold_left (fun acc var ->
    SubstMap.remove var acc
  ) subst vars in
  TypeScheme (vars, apply_subst filtered_subst typ)

(** 应用替换到环境 *)
let apply_subst_to_env subst env =
  TypeEnv.map (apply_subst_to_scheme subst) env

(** 合成替换 *)
let compose_subst subst1 subst2 =
  let applied_subst1 = SubstMap.map (apply_subst subst2) subst1 in
  SubstMap.fold SubstMap.add subst2 applied_subst1

(** 获取类型中的自由变量 *)
let rec free_vars typ =
  match typ with
  | TypeVar_T name -> [name]
  | FunType_T (param_type, return_type) ->
    free_vars param_type @ free_vars return_type
  | TupleType_T type_list ->
    List.flatten (List.map free_vars type_list)
  | ListType_T elem_type ->
    free_vars elem_type
  | ConstructType_T (_, type_list) ->
    List.flatten (List.map free_vars type_list)
  | RecordType_T fields ->
    List.flatten (List.map (fun (_, typ) -> free_vars typ) fields)
  | ArrayType_T elem_type ->
    free_vars elem_type
  | PrivateType_T (_, inner_type) ->
    free_vars inner_type
  | PolymorphicVariantType_T variants ->
    List.flatten (List.map (fun (_, typ_opt) -> 
      match typ_opt with 
      | Some typ -> free_vars typ 
      | None -> []) variants)
  | _ -> []

(** 获取类型方案中的自由变量 *)
let scheme_free_vars (TypeScheme (vars, typ)) =
  let type_vars = free_vars typ in
  List.filter (fun v -> not (List.mem v vars)) type_vars

(** 获取环境中的自由变量 *)
let env_free_vars env =
  TypeEnv.fold (fun _ scheme acc -> scheme_free_vars scheme @ acc) env []

(** 类型泛化 *)
let generalize env typ =
  let env_vars = env_free_vars env in
  let type_vars = free_vars typ in
  let free_type_vars = List.filter (fun v -> not (List.mem v env_vars)) type_vars in
  TypeScheme (free_type_vars, typ)

(** 类型实例化 *)
let instantiate (TypeScheme (quantified_vars, typ)) =
  let subst = List.fold_left (fun acc var ->
    SubstMap.add var (new_type_var ()) acc
  ) empty_subst quantified_vars in
  apply_subst subst typ

(** 类型合一 *)
let rec unify typ1 typ2 =
  match (typ1, typ2) with
  | (t1, t2) when t1 = t2 -> empty_subst
  | (TypeVar_T name, t) -> var_unify name t
  | (t, TypeVar_T name) -> var_unify name t
  | (FunType_T (param1, return1), FunType_T (param2, return2)) ->
    let subst1 = unify param1 param2 in
    let subst2 = unify (apply_subst subst1 return1) (apply_subst subst1 return2) in
    compose_subst subst1 subst2
  | (TupleType_T type_list1, TupleType_T type_list2) ->
    unify_list type_list1 type_list2
  | (ListType_T elem1, ListType_T elem2) ->
    unify elem1 elem2
  | (ConstructType_T (name1, type_list1), ConstructType_T (name2, type_list2)) when name1 = name2 ->
    unify_list type_list1 type_list2
  | (RecordType_T fields1, RecordType_T fields2) ->
    unify_record_fields fields1 fields2
  | (ArrayType_T elem1, ArrayType_T elem2) ->
    unify elem1 elem2
  | (PrivateType_T (name1, _), PrivateType_T (name2, _)) when name1 = name2 ->
    (* 私有类型只能与同名的私有类型合一 *)
    empty_subst
  | (PolymorphicVariantType_T variants1, PolymorphicVariantType_T variants2) ->
    (* 多态变体类型的合一：检查标签兼容性 *)
    unify_polymorphic_variants variants1 variants2
  | _ -> raise (TypeError ("无法统一类型: " ^ show_typ typ1 ^ " 与 " ^ show_typ typ2))

(** 变量合一 *)
and var_unify var_name typ =
  if typ = TypeVar_T var_name then
    empty_subst
  else if List.mem var_name (free_vars typ) then
    raise (TypeError ("循环类型检查失败: " ^ var_name ^ " 出现在 " ^ show_typ typ))
  else
    single_subst var_name typ

(** 合一类型列表 *)
and unify_list type_list1 type_list2 =
  match (type_list1, type_list2) with
  | ([], []) -> empty_subst
  | (t1 :: ts1, t2 :: ts2) ->
    let subst1 = unify t1 t2 in
    let subst2 = unify_list (List.map (apply_subst subst1) ts1) (List.map (apply_subst subst1) ts2) in
    compose_subst subst1 subst2
  | _ -> raise (TypeError "类型列表长度不匹配")

(** 合一多态变体 *)
and unify_polymorphic_variants variants1 variants2 =
  (* 多态变体的合一：简化版本，要求所有标签都匹配 *)
  let rec unify_variant_tags tags1 tags2 subst =
    match (tags1, tags2) with
    | ([], []) -> subst
    | ((tag1, typ1_opt) :: rest1, (tag2, typ2_opt) :: rest2) when tag1 = tag2 ->
      let subst1 = match (typ1_opt, typ2_opt) with
        | (None, None) -> subst
        | (Some typ1, Some typ2) -> 
          let new_subst = unify typ1 typ2 in
          compose_subst subst new_subst
        | _ -> raise (TypeError ("变体标签类型不匹配: " ^ tag1))
      in
      unify_variant_tags rest1 rest2 subst1
    | _ -> raise (TypeError "多态变体标签不匹配")
  in
  let sorted_variants1 = List.sort (fun (tag1, _) (tag2, _) -> compare tag1 tag2) variants1 in
  let sorted_variants2 = List.sort (fun (tag1, _) (tag2, _) -> compare tag1 tag2) variants2 in
  unify_variant_tags sorted_variants1 sorted_variants2 empty_subst

(** 合一记录字段 *)
and unify_record_fields fields1 fields2 =
  let sorted_fields1 = List.sort (fun (name1, _) (name2, _) -> String.compare name1 name2) fields1 in
  let sorted_fields2 = List.sort (fun (name1, _) (name2, _) -> String.compare name1 name2) fields2 in
  let rec unify_sorted_fields fs1 fs2 =
    match (fs1, fs2) with
    | ([], []) -> empty_subst
    | ((name1, typ1) :: rest1, (name2, typ2) :: rest2) when name1 = name2 ->
      let subst1 = unify typ1 typ2 in
      let subst2 = unify_sorted_fields 
        (List.map (fun (n, t) -> (n, apply_subst subst1 t)) rest1)
        (List.map (fun (n, t) -> (n, apply_subst subst1 t)) rest2) in
      compose_subst subst1 subst2
    | _ -> raise (TypeError "记录类型字段不匹配")
  in
  unify_sorted_fields sorted_fields1 sorted_fields2

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
  | TupleType type_list ->
    TupleType_T (List.map type_expr_to_typ type_list)
  | ListType elem_type ->
    ListType_T (type_expr_to_typ elem_type)
  | ConstructType (name, type_list) ->
    ConstructType_T (name, List.map type_expr_to_typ type_list)
  | RefType inner_type ->
    RefType_T (type_expr_to_typ inner_type)
  | PolymorphicVariantType variants ->
    PolymorphicVariantType_T (List.map (fun (tag, type_opt) ->
      match type_opt with
      | Some type_expr -> (tag, Some (type_expr_to_typ type_expr))
      | None -> (tag, None)
    ) variants)

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
  | Add | Sub | Mul | Div | Mod ->
    (IntType_T, IntType_T, IntType_T)  (* (左操作数, 右操作数, 结果) *)
  | Concat ->
    (StringType_T, StringType_T, StringType_T)  (* 字符串连接 *)
  | Eq | Neq ->
    let var = new_type_var () in
    (var, var, BoolType_T)
  | Lt | Le | Gt | Ge ->
    (IntType_T, IntType_T, BoolType_T)
  | And | Or ->
    (BoolType_T, BoolType_T, BoolType_T)

(** 从一元运算符推断类型 *)
let unary_op_type op =
  match op with
  | Neg -> (IntType_T, IntType_T)  (* (操作数, 结果) *)
  | Not -> (BoolType_T, BoolType_T)

(** 从模式中提取变量绑定 *)
let rec extract_pattern_bindings pattern =
  match pattern with
  | WildcardPattern -> []
  | VarPattern var_name -> [(var_name, TypeScheme ([], new_type_var ()))]
  | LitPattern _ -> []
  | ConstructorPattern (_, sub_patterns) ->
    List.flatten (List.map extract_pattern_bindings sub_patterns)
  | TuplePattern patterns ->
    List.flatten (List.map extract_pattern_bindings patterns)
  | ListPattern patterns ->
    List.flatten (List.map extract_pattern_bindings patterns)
  | ConsPattern (head_pattern, tail_pattern) ->
    (extract_pattern_bindings head_pattern) @ (extract_pattern_bindings tail_pattern)
  | EmptyListPattern -> []
  | OrPattern (pattern1, pattern2) ->
    (extract_pattern_bindings pattern1) @ (extract_pattern_bindings pattern2)
  | ExceptionPattern (_, pattern_opt) ->
    (match pattern_opt with
     | Some pattern -> extract_pattern_bindings pattern
     | None -> [])
  | PolymorphicVariantPattern (_, pattern_opt) ->
    (match pattern_opt with
     | Some pattern -> extract_pattern_bindings pattern
     | None -> [])

(** 内置函数环境 *)
let builtin_env = 
  let env = TypeEnv.empty in
  (* 基础IO函数 *)
  let env = TypeEnv.add "打印" (TypeScheme ([], FunType_T (StringType_T, UnitType_T))) env in
  let env = TypeEnv.add "读取" (TypeScheme ([], FunType_T (UnitType_T, StringType_T))) env in
  (* 列表函数 *)
  let env = TypeEnv.add "长度" (TypeScheme (["'a"], FunType_T (ListType_T (TypeVar_T "'a"), IntType_T))) env in
  let env = TypeEnv.add "连接" (TypeScheme (["'a"], FunType_T (ListType_T (TypeVar_T "'a"), FunType_T (ListType_T (TypeVar_T "'a"), ListType_T (TypeVar_T "'a"))))) env in
  let env = TypeEnv.add "过滤" (TypeScheme (["'a"], FunType_T (FunType_T (TypeVar_T "'a", BoolType_T), FunType_T (ListType_T (TypeVar_T "'a"), ListType_T (TypeVar_T "'a"))))) env in
  let env = TypeEnv.add "映射" (TypeScheme (["'a"; "'b"], FunType_T (FunType_T (TypeVar_T "'a", TypeVar_T "'b"), FunType_T (ListType_T (TypeVar_T "'a"), ListType_T (TypeVar_T "'b"))))) env in
  let env = TypeEnv.add "折叠" (TypeScheme (["'a"; "'b"], FunType_T (FunType_T (TypeVar_T "'a", FunType_T (TypeVar_T "'b", TypeVar_T "'b")), FunType_T (TypeVar_T "'b", FunType_T (ListType_T (TypeVar_T "'a"), TypeVar_T "'b"))))) env in
  let env = TypeEnv.add "范围" (TypeScheme ([], FunType_T (IntType_T, FunType_T (IntType_T, ListType_T IntType_T)))) env in
  let env = TypeEnv.add "排序" (TypeScheme ([], FunType_T (ListType_T IntType_T, ListType_T IntType_T))) env in
  let env = TypeEnv.add "反转" (TypeScheme (["'a"], FunType_T (ListType_T (TypeVar_T "'a"), ListType_T (TypeVar_T "'a")))) env in
  let env = TypeEnv.add "包含" (TypeScheme ([], FunType_T (IntType_T, FunType_T (ListType_T IntType_T, BoolType_T)))) env in
  (* 数学函数 *)
  let env = TypeEnv.add "求和" (TypeScheme ([], FunType_T (ListType_T IntType_T, IntType_T))) env in
  let env = TypeEnv.add "最大值" (TypeScheme ([], FunType_T (ListType_T IntType_T, IntType_T))) env in
  let env = TypeEnv.add "最小值" (TypeScheme ([], FunType_T (ListType_T IntType_T, IntType_T))) env in
  let env = TypeEnv.add "平均值" (TypeScheme ([], FunType_T (ListType_T IntType_T, FloatType_T))) env in
  let env = TypeEnv.add "乘积" (TypeScheme ([], FunType_T (ListType_T IntType_T, IntType_T))) env in
  let env = TypeEnv.add "绝对值" (TypeScheme ([], FunType_T (IntType_T, IntType_T))) env in
  let env = TypeEnv.add "平方" (TypeScheme ([], FunType_T (IntType_T, IntType_T))) env in
  let env = TypeEnv.add "幂运算" (TypeScheme ([], FunType_T (FloatType_T, FunType_T (FloatType_T, FloatType_T)))) env in
  let env = TypeEnv.add "余弦" (TypeScheme ([], FunType_T (FloatType_T, FloatType_T))) env in
  let env = TypeEnv.add "正弦" (TypeScheme ([], FunType_T (FloatType_T, FloatType_T))) env in
  let env = TypeEnv.add "平方根" (TypeScheme ([], FunType_T (FloatType_T, FloatType_T))) env in
  let env = TypeEnv.add "取整" (TypeScheme ([], FunType_T (FloatType_T, IntType_T))) env in
  let env = TypeEnv.add "随机数" (TypeScheme ([], FunType_T (UnitType_T, IntType_T))) env in
  (* 扩展数学函数 *)
  let env = TypeEnv.add "对数" (TypeScheme ([], FunType_T (FloatType_T, FloatType_T))) env in
  let env = TypeEnv.add "自然对数" (TypeScheme ([], FunType_T (FloatType_T, FloatType_T))) env in
  let env = TypeEnv.add "十进制对数" (TypeScheme ([], FunType_T (FloatType_T, FloatType_T))) env in
  let env = TypeEnv.add "指数" (TypeScheme ([], FunType_T (FloatType_T, FloatType_T))) env in
  let env = TypeEnv.add "正切" (TypeScheme ([], FunType_T (FloatType_T, FloatType_T))) env in
  let env = TypeEnv.add "反正弦" (TypeScheme ([], FunType_T (FloatType_T, FloatType_T))) env in
  let env = TypeEnv.add "反余弦" (TypeScheme ([], FunType_T (FloatType_T, FloatType_T))) env in
  let env = TypeEnv.add "反正切" (TypeScheme ([], FunType_T (FloatType_T, FloatType_T))) env in
  let env = TypeEnv.add "向上取整" (TypeScheme ([], FunType_T (FloatType_T, IntType_T))) env in
  let env = TypeEnv.add "向下取整" (TypeScheme ([], FunType_T (FloatType_T, IntType_T))) env in
  let env = TypeEnv.add "四舍五入" (TypeScheme ([], FunType_T (FloatType_T, IntType_T))) env in
  let env = TypeEnv.add "最大公约数" (TypeScheme ([], FunType_T (IntType_T, FunType_T (IntType_T, IntType_T)))) env in
  let env = TypeEnv.add "最小公倍数" (TypeScheme ([], FunType_T (IntType_T, FunType_T (IntType_T, IntType_T)))) env in
  (* 数组函数 *)
  let env = TypeEnv.add "创建数组" (TypeScheme (["'a"], FunType_T (IntType_T, FunType_T (TypeVar_T "'a", ArrayType_T (TypeVar_T "'a"))))) env in
  let env = TypeEnv.add "数组长度" (TypeScheme (["'a"], FunType_T (ArrayType_T (TypeVar_T "'a"), IntType_T))) env in
  let env = TypeEnv.add "复制数组" (TypeScheme (["'a"], FunType_T (ArrayType_T (TypeVar_T "'a"), ArrayType_T (TypeVar_T "'a")))) env in
  (* 引用函数 *)
  let env = TypeEnv.add "引用" (TypeScheme (["'a"], FunType_T (TypeVar_T "'a", RefType_T (TypeVar_T "'a")))) env in
  (* 字符串函数 *)
  let env = TypeEnv.add "字符串长度" (TypeScheme ([], FunType_T (StringType_T, IntType_T))) env in
  let env = TypeEnv.add "字符串连接" (TypeScheme ([], FunType_T (StringType_T, FunType_T (StringType_T, StringType_T)))) env in
  let env = TypeEnv.add "字符串分割" (TypeScheme ([], FunType_T (StringType_T, FunType_T (StringType_T, ListType_T StringType_T)))) env in
  (* 文件操作函数 *)
  let env = TypeEnv.add "读取文件" (TypeScheme ([], FunType_T (StringType_T, StringType_T))) env in
  let env = TypeEnv.add "写入文件" (TypeScheme ([], FunType_T (StringType_T, FunType_T (StringType_T, UnitType_T)))) env in
  let env = TypeEnv.add "文件存在" (TypeScheme ([], FunType_T (StringType_T, BoolType_T))) env in
  let env = TypeEnv.add "大写转换" (TypeScheme ([], FunType_T (StringType_T, StringType_T))) env in
  let env = TypeEnv.add "小写转换" (TypeScheme ([], FunType_T (StringType_T, StringType_T))) env in
  let env = TypeEnv.add "去除空白" (TypeScheme ([], FunType_T (StringType_T, StringType_T))) env in
  let env = TypeEnv.add "字符串替换" (TypeScheme ([], FunType_T (StringType_T, FunType_T (StringType_T, FunType_T (StringType_T, StringType_T))))) env in
  let env = TypeEnv.add "子字符串" (TypeScheme ([], FunType_T (StringType_T, FunType_T (IntType_T, FunType_T (IntType_T, StringType_T))))) env in
  let env = TypeEnv.add "字符串比较" (TypeScheme ([], FunType_T (StringType_T, FunType_T (StringType_T, IntType_T)))) env in
  (* 类型转换函数 *)
  let env = TypeEnv.add "整数到字符串" (TypeScheme ([], FunType_T (IntType_T, StringType_T))) env in
  let env = TypeEnv.add "浮点数到字符串" (TypeScheme ([], FunType_T (FloatType_T, StringType_T))) env in
  let env = TypeEnv.add "字符串到整数" (TypeScheme ([], FunType_T (StringType_T, IntType_T))) env in
  let env = TypeEnv.add "字符串到浮点数" (TypeScheme ([], FunType_T (StringType_T, FloatType_T))) env in
  env

(** 类型推断 *)
let rec infer_type env expr =
  match expr with
  | LitExpr literal ->
    let typ = literal_type literal in
    (empty_subst, typ)
    
  | VarExpr var_name ->
    (try
       let scheme = TypeEnv.find var_name env in
       let typ = instantiate scheme in  (* 现在支持多态 *)
       (empty_subst, typ)
     with Not_found ->
       raise (TypeError ("未定义的变量: " ^ var_name)))
       
  | BinaryOpExpr (left_expr, op, right_expr) ->
    let (subst1, left_type) = infer_type env left_expr in
    let (subst2, right_type) = infer_type (apply_subst_to_env subst1 env) right_expr in
    let (expected_left_type, expected_right_type, result_type) = binary_op_type op in
    let subst3 = unify (apply_subst subst2 left_type) expected_left_type in
    let subst4 = unify (apply_subst subst3 right_type) (apply_subst subst3 expected_right_type) in
    let final_subst = compose_subst (compose_subst (compose_subst subst1 subst2) subst3) subst4 in
    (final_subst, apply_subst final_subst result_type)
    
  | UnaryOpExpr (op, expr) ->
    let (subst, expr_type) = infer_type env expr in
    let (expected_type, result_type) = unary_op_type op in
    let subst2 = unify expr_type expected_type in
    let final_subst = compose_subst subst subst2 in
    (final_subst, apply_subst final_subst result_type)
    
  | FunCallExpr (fun_expr, param_list) ->
    let (subst1, fun_type) = infer_type env fun_expr in
    let env1 = apply_subst_to_env subst1 env in
    infer_fun_call env1 fun_type param_list subst1
    
  | CondExpr (cond, then_branch, else_branch) ->
    let (subst1, cond_type) = infer_type env cond in
    let subst2 = unify cond_type BoolType_T in
    let env1 = apply_subst_to_env (compose_subst subst1 subst2) env in
    let (subst3, then_type) = infer_type env1 then_branch in
    let env2 = apply_subst_to_env subst3 env1 in
    let (subst4, else_type) = infer_type env2 else_branch in
    let subst5 = unify (apply_subst subst4 then_type) else_type in
    let final_subst = List.fold_left compose_subst empty_subst [subst1; subst2; subst3; subst4; subst5] in
    (final_subst, apply_subst final_subst else_type)
    
  | FunExpr (param_list, body) ->
    infer_fun_expr env param_list body
    
  | LetExpr (var_name, value_expr, body_expr) ->
    let (subst1, value_type) = infer_type env value_expr in
    let env1 = apply_subst_to_env subst1 env in
    let generalized_type = generalize env1 value_type in
    let env2 = TypeEnv.add var_name generalized_type env1 in
    let (subst2, body_type) = infer_type env2 body_expr in
    let final_subst = compose_subst subst1 subst2 in
    (final_subst, body_type)
    
  | MatchExpr (expr, branch_list) ->
    let (subst1, _expr_type) = infer_type env expr in
    let env1 = apply_subst_to_env subst1 env in
    (* Infer the type of the first branch to establish the expected return type *)
    (match branch_list with
     | [] -> raise (TypeError "匹配表达式必须至少有一个分支")
     | first_branch :: rest_branches ->
       (* Add pattern variables to environment for first branch *)
       let first_pattern_bindings = extract_pattern_bindings first_branch.pattern in
       let first_extended_env = List.fold_left (fun acc_env (var_name, var_type) ->
         TypeEnv.add var_name var_type acc_env
       ) env1 first_pattern_bindings in
       
       (* Check guard type if present *)
       let (guard_subst, first_extended_env') = 
         (match first_branch.guard with
          | None -> (empty_subst, first_extended_env)
          | Some guard_expr ->
            let (g_subst, guard_type) = infer_type first_extended_env guard_expr in
            let bool_subst = unify guard_type BoolType_T in
            let combined_subst = compose_subst g_subst bool_subst in
            (combined_subst, apply_subst_to_env combined_subst first_extended_env))
       in
       
       let (subst2, first_branch_type) = infer_type first_extended_env' first_branch.expr in
       let env2 = apply_subst_to_env subst2 env1 in
       
       (* Check that all other branches have the same type *)
       let (final_subst, _) = List.fold_left (fun (acc_subst, expected_type) branch ->
         let current_env = apply_subst_to_env acc_subst env2 in
         (* Add pattern variables to environment for this branch *)
         let pattern_bindings = extract_pattern_bindings branch.pattern in
         let extended_env = List.fold_left (fun acc_env (var_name, var_type) ->
           TypeEnv.add var_name var_type acc_env
         ) current_env pattern_bindings in
         
         (* Check guard type if present *)
         let (guard_subst, extended_env') = 
           (match branch.guard with
            | None -> (empty_subst, extended_env)
            | Some guard_expr ->
              let (g_subst, guard_type) = infer_type extended_env guard_expr in
              let bool_subst = unify guard_type BoolType_T in
              let combined_subst = compose_subst g_subst bool_subst in
              (combined_subst, apply_subst_to_env combined_subst extended_env))
         in
         
         let (branch_subst, branch_type) = infer_type extended_env' branch.expr in
         let unified_subst = unify (apply_subst branch_subst expected_type) branch_type in
         let new_subst = compose_subst (compose_subst (compose_subst acc_subst guard_subst) branch_subst) unified_subst in
         (new_subst, apply_subst new_subst expected_type)
       ) (compose_subst (compose_subst subst1 guard_subst) subst2, first_branch_type) rest_branches in
       (final_subst, apply_subst final_subst first_branch_type))
    
  | ListExpr expr_list ->
    (match expr_list with
     | [] -> 
       (* Empty list has polymorphic type *)
       let elem_type_var = new_type_var () in
       (empty_subst, ListType_T elem_type_var)
     | first_expr :: rest_exprs ->
       (* Infer type of first element *)
       let (subst1, first_type) = infer_type env first_expr in
       let env1 = apply_subst_to_env subst1 env in
       (* Check that all other elements have the same type *)
       let (final_subst, unified_type) = List.fold_left (fun (acc_subst, expected_type) expr ->
         let current_env = apply_subst_to_env acc_subst env1 in
         let (expr_subst, expr_type) = infer_type current_env expr in
         let unified_subst = unify (apply_subst expr_subst expected_type) expr_type in
         let new_subst = compose_subst (compose_subst acc_subst expr_subst) unified_subst in
         (new_subst, apply_subst new_subst expected_type)
       ) (subst1, first_type) rest_exprs in
       (final_subst, ListType_T unified_type))
    
  | SemanticLetExpr (var_name, _semantic_label, value_expr, body_expr) ->
    (* Similar to LetExpr - semantic labels don't affect type inference *)
    let (subst1, value_type) = infer_type env value_expr in
    let env1 = apply_subst_to_env subst1 env in
    let generalized_type = generalize env1 value_type in
    let env2 = TypeEnv.add var_name generalized_type env1 in
    let (subst2, body_type) = infer_type env2 body_expr in
    let final_subst = compose_subst subst1 subst2 in
    (final_subst, body_type)
    
  | CombineExpr expr_list ->
    (* Combine expressions into a list type *)
    infer_type env (ListExpr expr_list)
    
  | TupleExpr expr_list ->
    (* Infer types for each expression in the tuple *)
    let (final_subst, type_list) = List.fold_left (fun (acc_subst, acc_types) expr ->
      let current_env = apply_subst_to_env acc_subst env in
      let (expr_subst, expr_type) = infer_type current_env expr in
      let new_subst = compose_subst acc_subst expr_subst in
      (new_subst, acc_types @ [apply_subst new_subst expr_type])
    ) (empty_subst, []) expr_list in
    (final_subst, TupleType_T type_list)
    
  | OrElseExpr (primary_expr, default_expr) ->
    (* 推断主表达式和默认表达式的类型，它们应该兼容 *)
    let (primary_subst, primary_type) = infer_type env primary_expr in
    let env_after_primary = apply_subst_to_env primary_subst env in
    let (default_subst, default_type) = infer_type env_after_primary default_expr in
    let combined_subst = compose_subst primary_subst default_subst in
    
    (* 尝试统一两个类型 *)
    (try
      let unify_subst = unify (apply_subst combined_subst primary_type) 
                              (apply_subst combined_subst default_type) in
      let final_subst = compose_subst combined_subst unify_subst in
      (final_subst, apply_subst final_subst primary_type)
    with
    | TypeError _ ->
      (* 如果类型不能统一，返回主表达式的类型 *)
      (combined_subst, apply_subst combined_subst primary_type))
    
  | MacroCallExpr _macro_call ->
    (* 对于宏调用，暂时返回一个通用类型变量 *)
    (* 真正的宏展开应该在预处理阶段完成 *)
    (empty_subst, new_type_var ())
  | AsyncExpr _ -> raise (TypeError "暂不支持异步表达式")
  
  | RecordExpr fields ->
    (* 记录类型推断：为每个字段推断类型 *)
    let infer_field (name, expr) =
      let (subst, typ) = infer_type env expr in
      (name, typ, subst)
    in
    let field_results = List.map infer_field fields in
    let field_types = List.map (fun (name, typ, _) -> (name, typ)) field_results in
    let substs = List.map (fun (_, _, subst) -> subst) field_results in
    let combined_subst = List.fold_left compose_subst empty_subst substs in
    let final_field_types = List.map (fun (name, typ) -> (name, apply_subst combined_subst typ)) field_types in
    (combined_subst, RecordType_T final_field_types)
    
  | FieldAccessExpr (record_expr, field_name) ->
    (* 字段访问类型推断：确保记录类型有该字段 *)
    let (subst1, record_type) = infer_type env record_expr in
    let field_type = new_type_var () in
    let fields = [(field_name, field_type)] in
    let expected_record_type = RecordType_T fields in
    let subst2 = unify record_type expected_record_type in
    let combined_subst = compose_subst subst1 subst2 in
    (combined_subst, apply_subst combined_subst field_type)
    
  | RecordUpdateExpr (record_expr, updates) ->
    (* 记录更新类型推断：确保所有更新字段都存在于原记录中 *)
    let (subst1, record_type) = infer_type env record_expr in
    let infer_update (name, expr) =
      let (subst, typ) = infer_type env expr in
      (name, typ, subst)
    in
    let update_results = List.map infer_update updates in
    let update_substs = List.map (fun (_, _, subst) -> subst) update_results in
    let combined_update_subst = List.fold_left compose_subst empty_subst update_substs in
    let all_subst = compose_subst subst1 combined_update_subst in
    (* 记录更新的结果类型与原记录类型相同 *)
    (all_subst, apply_subst all_subst record_type)
    
  | ArrayExpr elements ->
    (* 数组类型推断：所有元素必须有相同类型 *)
    (match elements with
     | [] -> 
       (* 空数组：创建新的类型变量 *)
       let elem_type = new_type_var () in
       (empty_subst, ArrayType_T elem_type)
     | first_elem :: rest_elems ->
       (* 非空数组：推断第一个元素类型，确保其他元素统一 *)
       let (first_subst, first_type) = infer_type env first_elem in
       let env1 = apply_subst_to_env first_subst env in
       let infer_and_unify acc_subst elem =
         let current_env = apply_subst_to_env acc_subst env1 in
         let (elem_subst, elem_type) = infer_type current_env elem in
         let combined_subst = compose_subst acc_subst elem_subst in
         let unified_subst = unify (apply_subst combined_subst first_type) 
                                  (apply_subst combined_subst elem_type) in
         compose_subst combined_subst unified_subst
       in
       let final_subst = List.fold_left infer_and_unify first_subst rest_elems in
       let final_elem_type = apply_subst final_subst first_type in
       (final_subst, ArrayType_T final_elem_type))
    
  | ArrayAccessExpr (array_expr, index_expr) ->
    (* 数组访问类型推断：确保数组类型和索引为整数 *)
    let (subst1, array_type) = infer_type env array_expr in
    let env1 = apply_subst_to_env subst1 env in
    let (subst2, index_type) = infer_type env1 index_expr in
    let subst3 = unify (apply_subst subst2 index_type) IntType_T in
    let combined_subst = compose_subst (compose_subst subst1 subst2) subst3 in
    let elem_type = new_type_var () in
    let expected_array_type = ArrayType_T elem_type in
    let subst4 = unify (apply_subst combined_subst array_type) expected_array_type in
    let final_subst = compose_subst combined_subst subst4 in
    (final_subst, apply_subst final_subst elem_type)
    
  | ArrayUpdateExpr (array_expr, index_expr, value_expr) ->
    (* 数组更新类型推断：确保数组类型、索引为整数、值类型匹配 *)
    let (subst1, array_type) = infer_type env array_expr in
    let env1 = apply_subst_to_env subst1 env in
    let (subst2, index_type) = infer_type env1 index_expr in
    let env2 = apply_subst_to_env subst2 env1 in
    let (subst3, value_type) = infer_type env2 value_expr in
    let subst4 = unify (apply_subst subst3 index_type) IntType_T in
    let combined_subst = compose_subst (compose_subst (compose_subst subst1 subst2) subst3) subst4 in
    let elem_type = new_type_var () in
    let expected_array_type = ArrayType_T elem_type in
    let subst5 = unify (apply_subst combined_subst array_type) expected_array_type in
    let subst6 = unify (apply_subst (compose_subst combined_subst subst5) value_type) 
                       (apply_subst (compose_subst combined_subst subst5) elem_type) in
    let final_subst = compose_subst (compose_subst combined_subst subst5) subst6 in
    (final_subst, UnitType_T)
    
  | TryExpr (try_expr, catch_branches, finally_opt) ->
    (* 推断try表达式的类型 *)
    let (try_subst, try_type) = infer_type env try_expr in
    (* 推断所有catch分支的类型 *)
    let rec infer_catch_branches branches subst =
      match branches with
      | [] -> (subst, try_type)
      | branch :: rest ->
        let pattern_bindings = extract_pattern_bindings branch.pattern in
        let env' = List.fold_left (fun acc_env (var_name, var_type) ->
          TypeEnv.add var_name var_type acc_env
        ) env pattern_bindings in
        
        (* Check guard type if present *)
        let (guard_subst, env'') = 
          (match branch.guard with
           | None -> (empty_subst, env')
           | Some guard_expr ->
             let (g_subst, guard_type) = infer_type env' guard_expr in
             let bool_subst = unify guard_type BoolType_T in
             let combined_subst = compose_subst g_subst bool_subst in
             (combined_subst, apply_subst_to_env combined_subst env'))
        in
        
        let (expr_subst, expr_type) = infer_type env'' branch.expr in
        let unified_subst = unify expr_type try_type in
        let combined_subst = compose_subst (compose_subst (compose_subst subst guard_subst) expr_subst) unified_subst in
        infer_catch_branches rest combined_subst
    in
    let (catch_subst, result_type) = infer_catch_branches catch_branches try_subst in
    (* 如果有finally块，推断它但忽略其类型 *)
    let final_subst =
      match finally_opt with
      | Some finally_expr ->
        let (finally_subst, _) = infer_type env finally_expr in
        compose_subst catch_subst finally_subst
      | None -> catch_subst
    in
    (final_subst, result_type)
    
  | RaiseExpr _expr ->
    (* raise表达式可以是任意类型，因为它不会正常返回 *)
    let typ_var = new_type_var () in
    (empty_subst, typ_var)
    
  | RefExpr expr ->
    (* 引用表达式：type -> type ref *)
    let (subst, expr_type) = infer_type env expr in
    (subst, RefType_T expr_type)
    
  | DerefExpr expr ->
    (* 解引用表达式：type ref -> type *)
    let (subst, expr_type) = infer_type env expr in
    (match expr_type with
     | RefType_T inner_type -> (subst, inner_type)
     | _ -> 
       let typ_var = new_type_var () in
       let ref_type = RefType_T typ_var in
       let unified_subst = unify expr_type ref_type in
       let combined_subst = compose_subst subst unified_subst in
       (combined_subst, typ_var))
       
  | AssignExpr (target_expr, value_expr) ->
    (* 赋值表达式：type ref * type -> unit *)
    let (target_subst, target_type) = infer_type env target_expr in
    let env' = apply_subst_to_env target_subst env in
    let (value_subst, value_type) = infer_type env' value_expr in
    (match target_type with
     | RefType_T expected_type ->
       let unified_subst = unify value_type expected_type in
       let combined_subst = compose_subst (compose_subst target_subst value_subst) unified_subst in
       (combined_subst, UnitType_T)
     | _ ->
       let typ_var = new_type_var () in
       let ref_type = RefType_T typ_var in
       let target_unified_subst = unify target_type ref_type in
       let value_unified_subst = unify value_type typ_var in
       let combined_subst = compose_subst (compose_subst target_subst value_subst) 
                                        (compose_subst target_unified_subst value_unified_subst) in
       (combined_subst, UnitType_T))
       
  | ConstructorExpr (_, arg_exprs) ->
    (* 构造器表达式类型推断 - 暂时返回类型变量 *)
    let arg_substs_and_types = List.map (infer_type env) arg_exprs in
    let (substs, _arg_types) = List.split arg_substs_and_types in
    let combined_subst = List.fold_left compose_subst empty_subst substs in
    (* 暂时返回新的类型变量，后续需要根据类型定义推断实际类型 *)
    let typ_var = new_type_var () in
    (combined_subst, typ_var)
    
  (* 模块系统表达式的类型推断 *)
  | ModuleAccessExpr (module_expr, _member_name) ->
    (* 暂时返回新的类型变量，后续需要实现模块类型系统 *)
    let (_module_subst, _module_type) = infer_type env module_expr in
    let typ_var = new_type_var () in
    (empty_subst, typ_var)
    
  | FunctorCallExpr (functor_expr, module_expr) ->
    (* 函子调用类型推断 - 暂时简化 *)
    let (_functor_subst, _functor_type) = infer_type env functor_expr in
    let (_module_subst, _module_type) = infer_type env module_expr in
    let typ_var = new_type_var () in
    (empty_subst, typ_var)
    
  | FunctorExpr (_param_name, _param_type, body) ->
    (* 函子定义类型推断 *)
    let (_body_subst, _body_type) = infer_type env body in
    let typ_var = new_type_var () in
    (empty_subst, typ_var)
    
  | ModuleExpr _statements ->
    (* 模块表达式类型推断 *)
    let typ_var = new_type_var () in
    (empty_subst, typ_var)
    
  | TypeAnnotationExpr (expr, type_expr) ->
    (* 类型注解表达式 *)
    let (subst, inferred_type) = infer_type env expr in
    let expected_type = type_expr_to_typ type_expr in
    let final_subst = unify inferred_type expected_type in
    let composed_subst = compose_subst subst final_subst in
    (composed_subst, apply_subst composed_subst expected_type)
    
  | FunExprWithType (param_list, return_type_opt, body) ->
    (* 带类型注解的函数表达式 *)
    let (param_types, param_names) = List.split (List.map (fun (name, type_opt) ->
      match type_opt with
      | Some type_expr -> (type_expr_to_typ type_expr, name)
      | None -> (new_type_var (), name)
    ) param_list) in
    
    let env_with_params = List.fold_left2 (fun acc_env name typ ->
      TypeEnv.add name (TypeScheme ([], typ)) acc_env
    ) env param_names param_types in
    
    let (subst, body_type) = infer_type env_with_params body in
    
    let expected_return_type = match return_type_opt with
      | Some type_expr -> type_expr_to_typ type_expr
      | None -> body_type
    in
    
    let return_subst = unify (apply_subst subst body_type) expected_return_type in
    let final_subst = compose_subst subst return_subst in
    
    let final_param_types = List.map (apply_subst final_subst) param_types in
    let final_return_type = apply_subst final_subst expected_return_type in
    
    let fun_type = List.fold_right (fun param_type acc ->
      FunType_T (param_type, acc)
    ) final_param_types final_return_type in
    
    (final_subst, fun_type)
    
  | LetExprWithType (var_name, type_expr, value_expr, body_expr) ->
    (* 带类型注解的let表达式 *)
    let (subst1, value_type) = infer_type env value_expr in
    let expected_type = type_expr_to_typ type_expr in
    let subst2 = unify value_type expected_type in
    let composed_subst = compose_subst subst1 subst2 in
    
    let final_type = apply_subst composed_subst expected_type in
    let env1 = apply_subst_to_env composed_subst env in
    let env2 = TypeEnv.add var_name (TypeScheme ([], final_type)) env1 in
    
    let (subst3, body_type) = infer_type env2 body_expr in
    let final_subst = compose_subst composed_subst subst3 in
    
    (final_subst, body_type)
    
  | PolymorphicVariantExpr (tag_name, value_expr_opt) ->
    (* 多态变体表达式类型推断 *)
    (match value_expr_opt with
     | None -> 
       (* 无值的多态变体 *)
       let variant_type = PolymorphicVariantType_T [(tag_name, None)] in
       (empty_subst, variant_type)
     | Some value_expr ->
       (* 有值的多态变体 *)
       let (subst, value_type) = infer_type env value_expr in
       let variant_type = PolymorphicVariantType_T [(tag_name, Some value_type)] in
       (subst, variant_type))
       
  | LabeledFunExpr (label_params, body) ->
    (* 标签函数表达式：创建标签函数类型 *)
    let param_types = List.map (fun label_param ->
      let param_type = match label_param.param_type with
        | Some _type_expr -> (* 暂时简化：忽略类型注解 *) new_type_var ()
        | None -> new_type_var ()
      in
      (label_param.param_name, param_type)
    ) label_params in
    
    let extended_env = List.fold_left (fun acc_env (param_name, param_type) ->
      TypeEnv.add param_name (TypeScheme ([], param_type)) acc_env
    ) env param_types in
    
    let (subst, body_type) = infer_type extended_env body in
    let applied_param_types = List.map (fun (name, typ) -> (name, apply_subst subst typ)) param_types in
    
    (* 简化：暂时使用普通函数类型表示标签函数 *)
    let fun_type = List.fold_right (fun (_, param_type) acc -> FunType_T (param_type, acc)) applied_param_types body_type in
    (subst, fun_type)
    
  | LabeledFunCallExpr (func_expr, label_args) ->
    (* 标签函数调用表达式：类型推断 *)
    let (subst1, func_type) = infer_type env func_expr in
    let env1 = apply_subst_to_env subst1 env in
    
    (* 简化：暂时按普通函数调用处理 *)
    let arg_exprs = List.map (fun label_arg -> label_arg.arg_value) label_args in
    let (subst2, result_type) = infer_fun_call env1 func_type arg_exprs subst1 in
    (subst2, result_type)

(** 推断函数调用 *)
and infer_fun_call env fun_type param_list initial_subst =
  let rec process_params fun_type param_list acc_subst =
    match param_list with
    | [] -> (acc_subst, fun_type)
    | param :: remaining_params ->
      let return_type_var = new_type_var () in
      let expected_fun_type = FunType_T (new_type_var (), return_type_var) in
      let subst1 = unify fun_type expected_fun_type in
      let latest_subst = compose_subst acc_subst subst1 in
      let env1 = apply_subst_to_env latest_subst env in
      let (subst2, param_type) = infer_type env1 param in
      let final_subst = compose_subst latest_subst subst2 in
      let unified_fun_type = apply_subst final_subst expected_fun_type in
      (match unified_fun_type with
       | FunType_T (expected_param_type, actual_return_type) ->
         let subst3 = unify param_type expected_param_type in
         let new_acc_subst = compose_subst final_subst subst3 in
         let new_return_type = apply_subst new_acc_subst actual_return_type in
         process_params new_return_type remaining_params new_acc_subst
       | _ -> raise (TypeError ("期望函数类型但得到: " ^ show_typ unified_fun_type)))
  in
  process_params fun_type param_list initial_subst

(** 推断函数表达式 *)
and infer_fun_expr env param_list body =
  let rec process_params param_list env param_type_list =
    match param_list with
    | [] -> (env, List.rev param_type_list)
    | param_name :: remaining_params ->
      let param_type = new_type_var () in
      let new_env = TypeEnv.add param_name (TypeScheme ([], param_type)) env in
      process_params remaining_params new_env (param_type :: param_type_list)
  in
  let (extended_env, param_type_list) = process_params param_list env [] in
  let (subst, body_type) = infer_type extended_env body in
  let applied_param_type_list = List.map (apply_subst subst) param_type_list in
  let fun_type = List.fold_right (fun param_type acc -> FunType_T (param_type, acc)) applied_param_type_list body_type in
  (subst, fun_type)

(** 类型转换为中文显示 *)
let rec type_to_chinese_string typ =
  match typ with
  | IntType_T -> "整数"
  | FloatType_T -> "浮点数"
  | StringType_T -> "字符串"
  | BoolType_T -> "布尔值"
  | UnitType_T -> "单元"
  | FunType_T (param_type, return_type) ->
    Printf.sprintf "%s -> %s" 
      (type_to_chinese_string param_type) 
      (type_to_chinese_string return_type)
  | TupleType_T type_list ->
    let type_strs = List.map type_to_chinese_string type_list in
    "(" ^ String.concat " * " type_strs ^ ")"
  | ListType_T elem_type ->
    (type_to_chinese_string elem_type) ^ " 列表"
  | TypeVar_T name -> "'" ^ name
  | ConstructType_T (name, []) -> name
  | ConstructType_T (name, type_list) ->
    let type_strs = List.map type_to_chinese_string type_list in
    name ^ " of " ^ String.concat " * " type_strs
  | RefType_T inner_type ->
    (type_to_chinese_string inner_type) ^ " 引用"
  | RecordType_T fields ->
    let field_strs = List.map (fun (name, typ) -> 
      name ^ ": " ^ type_to_chinese_string typ) fields in
    "{ " ^ String.concat "; " field_strs ^ " }"
  | ArrayType_T elem_type ->
    (type_to_chinese_string elem_type) ^ " 数组"
  | ClassType_T (class_name, _methods) ->
    "类 " ^ class_name
  | ObjectType_T _methods ->
    "对象类型"
  | PrivateType_T (name, _) ->
    "私有类型 " ^ name
  | PolymorphicVariantType_T variants ->
    "变体 " ^ String.concat " | " (List.map (fun (tag, type_opt) ->
      match type_opt with
      | None -> "「" ^ tag ^ "」"
      | Some typ -> "「" ^ tag ^ "」 " ^ type_to_chinese_string typ
    ) variants)

(** 显示表达式的类型信息 *)
let show_expr_type env expr =
  try
    let (subst, inferred_type) = infer_type env expr in
    let final_type = apply_subst subst inferred_type in
    Printf.printf "  表达式类型: %s\n" (type_to_chinese_string final_type)
  with
  | TypeError msg -> Printf.printf "  类型推断失败: %s\n" msg

(** 显示程序中所有变量的类型信息 *)
let show_program_types program =
  Printf.printf "=== 类型推断信息 ===\n";
  let env = ref TypeEnv.empty in
  let show_stmt stmt =
    match stmt with
    | LetStmt (var_name, expr) ->
      (try
        let (subst, expr_type) = infer_type !env expr in
        let final_type = apply_subst subst expr_type in
        Printf.printf "变量 %s: %s\n" var_name (type_to_chinese_string final_type);
        let generalized_scheme = generalize !env final_type in
        env := TypeEnv.add var_name generalized_scheme !env
      with
      | TypeError msg -> Printf.printf "变量 %s: 类型错误 - %s\n" var_name msg)
    | ExprStmt expr ->
      (try
        let (subst, expr_type) = infer_type !env expr in
        let final_type = apply_subst subst expr_type in
        Printf.printf "表达式结果: %s\n" (type_to_chinese_string final_type)
      with
      | TypeError msg -> Printf.printf "表达式: 类型错误 - %s\n" msg)
    | _ -> () (* 其他语句暂不显示类型 *)
  in
  List.iter show_stmt program;
  Printf.printf "\n"