(** 骆言类型系统 - 类型合一模块 *)

open Core_types
open Types_errors

(** 初始化模块日志器 *)
let _ = Logger.init_module_logger "Types.Unify"

(** 类型合一 *)
let rec unify typ1 typ2 =
  match (typ1, typ2) with
  | t1, t2 when t1 = t2 -> empty_subst
  | TypeVar_T name, t -> var_unify name t
  | t, TypeVar_T name -> var_unify name t
  | FunType_T (param1, return1), FunType_T (param2, return2) ->
      let subst1 = unify param1 param2 in
      let subst2 = unify (apply_subst subst1 return1) (apply_subst subst1 return2) in
      compose_subst subst1 subst2
  | TupleType_T type_list1, TupleType_T type_list2 -> unify_list type_list1 type_list2
  | ListType_T elem1, ListType_T elem2 -> unify elem1 elem2
  | ConstructType_T (name1, type_list1), ConstructType_T (name2, type_list2) when name1 = name2 ->
      unify_list type_list1 type_list2
  | RecordType_T fields1, RecordType_T fields2 -> unify_record_fields fields1 fields2
  | ArrayType_T elem1, ArrayType_T elem2 -> unify elem1 elem2
  | PrivateType_T (name1, typ1), PrivateType_T (name2, typ2) when name1 = name2 -> unify typ1 typ2
  | PolymorphicVariantType_T variants1, PolymorphicVariantType_T variants2 ->
      unify_polymorphic_variants variants1 variants2
  | _ -> raise (TypeError ("无法统一类型: " ^ show_typ typ1 ^ " 与 " ^ show_typ typ2))

(** 统一多态变体类型 *)
and unify_polymorphic_variants variants1 variants2 =
  let rec unify_variant_lists subst v1 v2 =
    match (v1, v2) with
    | [], [] -> subst
    | (label1, typ_opt1) :: rest1, (label2, typ_opt2) :: rest2 when label1 = label2 ->
        let subst' =
          match (typ_opt1, typ_opt2) with
          | Some typ1, Some typ2 -> compose_subst subst (unify typ1 typ2)
          | None, None -> subst
          | _ -> raise (TypeError ("多态变体标签类型不匹配: " ^ label1))
        in
        unify_variant_lists subst' rest1 rest2
    | _ -> raise (TypeError "多态变体类型不匹配")
  in
  unify_variant_lists empty_subst variants1 variants2

(** 变量合一 *)
and var_unify var_name typ =
  if typ = TypeVar_T var_name then empty_subst
  else if List.mem var_name (free_vars typ) then
    raise (TypeError ("循环类型检查失败: " ^ var_name ^ " 出现在 " ^ show_typ typ))
  else single_subst var_name typ

(** 合一类型列表 *)
and unify_list type_list1 type_list2 =
  match (type_list1, type_list2) with
  | [], [] -> empty_subst
  | t1 :: ts1, t2 :: ts2 ->
      let subst1 = unify t1 t2 in
      let subst2 =
        unify_list (List.map (apply_subst subst1) ts1) (List.map (apply_subst subst1) ts2)
      in
      compose_subst subst1 subst2
  | _ -> raise (TypeError "类型列表长度不匹配")

(** 合一记录字段 *)
and unify_record_fields fields1 fields2 =
  let sorted_fields1 =
    List.sort (fun (name1, _) (name2, _) -> String.compare name1 name2) fields1
  in
  let sorted_fields2 =
    List.sort (fun (name1, _) (name2, _) -> String.compare name1 name2) fields2
  in
  let rec unify_sorted_fields fs1 fs2 =
    match (fs1, fs2) with
    | [], [] -> empty_subst
    | (name1, typ1) :: rest1, (name2, typ2) :: rest2 when name1 = name2 ->
        let subst1 = unify typ1 typ2 in
        let subst2 =
          unify_sorted_fields
            (List.map (fun (n, t) -> (n, apply_subst subst1 t)) rest1)
            (List.map (fun (n, t) -> (n, apply_subst subst1 t)) rest2)
        in
        compose_subst subst1 subst2
    | _ -> raise (TypeError "记录类型字段不匹配")
  in
  unify_sorted_fields sorted_fields1 sorted_fields2

(** 需要从types.ml中导入的函数 *)
and apply_subst subst typ =
  match typ with
  | IntType_T | FloatType_T | StringType_T | BoolType_T | UnitType_T -> typ
  | TypeVar_T var_name -> ( try SubstMap.find var_name subst with Not_found -> typ)
  | FunType_T (param_type, return_type) ->
      FunType_T (apply_subst subst param_type, apply_subst subst return_type)
  | TupleType_T type_list -> TupleType_T (List.map (apply_subst subst) type_list)
  | ListType_T elem_type -> ListType_T (apply_subst subst elem_type)
  | ConstructType_T (name, type_list) ->
      ConstructType_T (name, List.map (apply_subst subst) type_list)
  | RefType_T inner_type -> RefType_T (apply_subst subst inner_type)
  | RecordType_T fields ->
      RecordType_T (List.map (fun (name, typ) -> (name, apply_subst subst typ)) fields)
  | ArrayType_T elem_type -> ArrayType_T (apply_subst subst elem_type)
  | ClassType_T (name, methods) ->
      ClassType_T
        ( name,
          List.map
            (fun (method_name, method_type) -> (method_name, apply_subst subst method_type))
            methods )
  | ObjectType_T methods ->
      ObjectType_T
        (List.map
           (fun (method_name, method_type) -> (method_name, apply_subst subst method_type))
           methods)
  | PrivateType_T (name, underlying_type) -> PrivateType_T (name, apply_subst subst underlying_type)
  | PolymorphicVariantType_T variants ->
      PolymorphicVariantType_T
        (List.map
           (fun (label, typ_opt) -> (label, Option.map (apply_subst subst) typ_opt))
           variants)

and compose_subst subst1 subst2 =
  (* 对subst2中的每个替换，先应用subst1 *)
  let composed_subst2 = SubstMap.map (apply_subst subst1) subst2 in
  (* 合并两个替换，优先使用subst1中的替换 *)
  SubstMap.fold SubstMap.add subst1 composed_subst2
