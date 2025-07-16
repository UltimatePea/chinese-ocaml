(** 骆言类型系统 - 类型替换模块 *)

open Core_types
(** 初始化模块日志器 *)
let _, _log_info, _, _log_error = Logger.init_module_logger "Types.Subst"

(** 类型替换应用 *)
let rec apply_subst subst typ =
  match typ with
  | IntType_T | FloatType_T | StringType_T | BoolType_T | UnitType_T -> typ
  | TypeVar_T var_name -> (
      try SubstMap.find var_name subst
      with Not_found -> typ)
  | FunType_T (param_type, return_type) ->
      FunType_T (apply_subst subst param_type, apply_subst subst return_type)
  | TupleType_T type_list -> TupleType_T (List.map (apply_subst subst) type_list)
  | ListType_T elem_type -> ListType_T (apply_subst subst elem_type)
  | ConstructType_T (name, type_list) -> ConstructType_T (name, List.map (apply_subst subst) type_list)
  | RefType_T inner_type -> RefType_T (apply_subst subst inner_type)
  | RecordType_T fields -> RecordType_T (List.map (fun (name, typ) -> (name, apply_subst subst typ)) fields)
  | ArrayType_T elem_type -> ArrayType_T (apply_subst subst elem_type)
  | ClassType_T (name, methods) ->
      ClassType_T (name, List.map (fun (method_name, method_type) -> (method_name, apply_subst subst method_type)) methods)
  | ObjectType_T methods ->
      ObjectType_T (List.map (fun (method_name, method_type) -> (method_name, apply_subst subst method_type)) methods)
  | PrivateType_T (name, underlying_type) -> PrivateType_T (name, apply_subst subst underlying_type)
  | PolymorphicVariantType_T variants ->
      PolymorphicVariantType_T (List.map (fun (label, typ_opt) -> (label, Option.map (apply_subst subst) typ_opt)) variants)

(** 对类型方案应用替换 *)
let apply_subst_to_scheme subst (TypeScheme (vars, typ)) =
  let filtered_subst = SubstMap.filter (fun var _ -> not (List.mem var vars)) subst in
  TypeScheme (vars, apply_subst filtered_subst typ)

(** 对类型环境应用替换 *)
let apply_subst_to_env subst env = TypeEnv.map (apply_subst_to_scheme subst) env

(** 替换合成 *)
let compose_subst subst1 subst2 =
  (* 对subst2中的每个替换，先应用subst1 *)
  let composed_subst2 = SubstMap.map (apply_subst subst1) subst2 in
  (* 合并两个替换，优先使用subst1中的替换 *)
  SubstMap.fold SubstMap.add subst1 composed_subst2

(** 获取类型方案的自由变量 *)
let scheme_free_vars (TypeScheme (vars, typ)) =
  List.filter (fun var -> not (List.mem var vars)) (free_vars typ)

(** 获取类型环境的自由变量 *)
let env_free_vars env = TypeEnv.fold (fun _ scheme acc -> scheme_free_vars scheme @ acc) env []

(** 泛化类型 *)
let generalize env typ =
  let env_free_vars = env_free_vars env in
  let type_vars = free_vars typ in
  let quantified_vars = List.filter (fun var -> not (List.mem var env_free_vars)) type_vars in
  TypeScheme (quantified_vars, typ)

(** 实例化类型方案 *)
let instantiate (TypeScheme (quantified_vars, typ)) =
  let fresh_vars = List.map (fun _ -> new_type_var ()) quantified_vars in
  let subst = List.fold_left2 (fun acc old_var new_var ->
    SubstMap.add old_var new_var acc
  ) empty_subst quantified_vars fresh_vars in
  apply_subst subst typ