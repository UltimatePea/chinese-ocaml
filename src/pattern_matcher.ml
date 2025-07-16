(** 骆言解释器模式匹配模块 - Chinese Programming Language Interpreter Pattern Matcher *)

open Ast
open Value_operations
open Interpreter_utils

(** 模式匹配 *)
let rec match_pattern pattern value env =
  match (pattern, value) with
  | WildcardPattern, _ -> Some env
  | VarPattern var_name, value -> Some (bind_var env var_name value)
  | LitPattern (IntLit n1), IntValue n2 when n1 = n2 -> Some env
  | LitPattern (FloatLit f1), FloatValue f2 when f1 = f2 -> Some env
  | LitPattern (StringLit s1), StringValue s2 when s1 = s2 -> Some env
  | LitPattern (BoolLit b1), BoolValue b2 when b1 = b2 -> Some env
  | LitPattern UnitLit, UnitValue -> Some env
  | EmptyListPattern, ListValue [] -> Some env
  | ConsPattern (head_pattern, tail_pattern), ListValue (head_value :: tail_values) -> (
      match match_pattern head_pattern head_value env with
      | Some new_env -> match_pattern tail_pattern (ListValue tail_values) new_env
      | None -> None)
  | ConstructorPattern (name, patterns), ExceptionValue (exc_name, payload_opt) when name = exc_name
    -> (
      (* 匹配异常构造器 *)
      match (patterns, payload_opt) with
      | [], None -> Some env (* 无参数异常 *)
      | [ pattern ], Some payload -> match_pattern pattern payload env (* 单参数异常 *)
      | _ -> None (* 参数数量不匹配 *))
  | ConstructorPattern (name, patterns), ConstructorValue (ctor_name, args) when name = ctor_name ->
      (* 匹配用户定义的构造器 *)
      if List.length patterns = List.length args then
        (* 参数数量匹配，递归匹配每个参数 *)
        let rec match_args patterns args env =
          match (patterns, args) with
          | [], [] -> Some env
          | p :: ps, v :: vs -> (
              match match_pattern p v env with
              | Some new_env -> match_args ps vs new_env
              | None -> None)
          | _ -> None (* 不应该到达这里，因为长度已经检查过 *)
        in
        match_args patterns args env
      else None (* 参数数量不匹配 *)
  | PolymorphicVariantPattern (tag_name, pattern_opt), PolymorphicVariantValue (tag_val, value_opt)
    ->
      (* 匹配多态变体 *)
      if tag_name = tag_val then
        match (pattern_opt, value_opt) with
        | None, None -> Some env (* 无值的变体 *)
        | Some pattern, Some value -> match_pattern pattern value env (* 有值的变体 *)
        | _ -> None (* 模式和值不匹配 *)
      else None (* 标签不匹配 *)
  | _ -> None

(** 执行模式匹配 *)
let rec execute_match env value branch_list eval_expr_func =
  match branch_list with
  | [] -> raise (RuntimeError "模式匹配失败：没有匹配的分支")
  | branch :: rest_branches -> (
      match match_pattern branch.pattern value env with
      | Some new_env -> (
          (* 检查guard条件 *)
          match branch.guard with
          | None -> eval_expr_func new_env branch.expr (* 没有guard，直接执行 *)
          | Some guard_expr -> (
              (* 有guard，需要评估guard条件 *)
              let guard_result = eval_expr_func new_env guard_expr in
              match guard_result with
              | BoolValue true -> eval_expr_func new_env branch.expr (* guard通过 *)
              | BoolValue false ->
                  execute_match env value rest_branches eval_expr_func (* guard失败，尝试下一个分支 *)
              | _ -> raise (RuntimeError "guard条件必须返回布尔值")))
      | None -> execute_match env value rest_branches eval_expr_func)

(** 执行异常匹配 *)
let rec execute_exception_match env exc_val catch_branches eval_expr_func =
  match catch_branches with
  | [] -> raise (Value_operations.ExceptionRaised exc_val) (* 没有匹配的分支，重新抛出异常 *)
  | branch :: rest_branches -> (
      match match_pattern branch.pattern exc_val env with
      | Some new_env -> (
          (* 检查guard条件 *)
          match branch.guard with
          | None -> eval_expr_func new_env branch.expr (* 没有guard，直接执行 *)
          | Some guard_expr -> (
              (* 有guard，需要评估guard条件 *)
              let guard_result = eval_expr_func new_env guard_expr in
              match guard_result with
              | BoolValue true -> eval_expr_func new_env branch.expr (* guard通过 *)
              | BoolValue false ->
                  execute_exception_match env exc_val rest_branches
                    eval_expr_func (* guard失败，尝试下一个分支 *)
              | _ -> raise (RuntimeError "异常guard条件必须返回布尔值")))
      | None -> execute_exception_match env exc_val rest_branches eval_expr_func)

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
  | PolymorphicVariantTypeDef variants ->
      (* 为多态变体类型注册标签构造器 *)
      List.fold_left
        (fun acc_env (tag_name, _type_opt) ->
          let tag_func =
            BuiltinFunctionValue
              (fun args ->
                match args with
                | [] -> PolymorphicVariantValue (tag_name, None)
                | [ arg ] -> PolymorphicVariantValue (tag_name, Some arg)
                | _ -> raise (RuntimeError ("多态变体标签 " ^ tag_name ^ " 只能接受0或1个参数")))
          in
          bind_var acc_env tag_name tag_func)
        env variants
  | _ -> env
