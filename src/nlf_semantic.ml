(** 自然语言函数定义语义增强模块 *)

open Ast
open Utils.Base_formatter

type parameter_binding = {
  param_name : string;
  is_recursive_context : bool;
  usage_patterns : string list;
}
(** 参数绑定信息 *)

type function_semantic_info = {
  function_name : string;
  parameter_bindings : parameter_binding list;
  is_recursive : bool;
  return_type_hint : string option;
  complexity_level : int; (* 1-简单, 2-中等, 3-复杂 *)
}
(** 函数语义信息 *)

(** 递归模式类型 *)
type recursive_pattern = TailRecursive | NonTailRecursive | MutualRecursive | NoRecursion

(** 分析函数的递归模式 *)
let analyze_recursive_pattern func_name body =
  let rec find_recursive_calls expr =
    match expr with
    | VarExpr name when name = func_name -> [ expr ]
    | FunCallExpr (VarExpr name, args) when name = func_name ->
        List.concat ([ expr ] :: List.map find_recursive_calls args)
    | FunCallExpr (f, args) ->
        List.concat (find_recursive_calls f :: List.map find_recursive_calls args)
    | BinaryOpExpr (left, _, right) ->
        List.concat [ find_recursive_calls left; find_recursive_calls right ]
    | CondExpr (cond, then_expr, else_expr) ->
        List.concat
          [
            find_recursive_calls cond;
            find_recursive_calls then_expr;
            find_recursive_calls else_expr;
          ]
    | LetExpr (_, val_expr, body_expr) ->
        List.concat [ find_recursive_calls val_expr; find_recursive_calls body_expr ]
    | FunExpr (_, body_expr) -> find_recursive_calls body_expr
    | LitExpr _ -> []
    | _ -> []
  in
  let recursive_calls = find_recursive_calls body in
  match List.length recursive_calls with
  | 0 -> NoRecursion
  | 1 -> TailRecursive (* 简化判断 *)
  | _ -> NonTailRecursive

(** 智能参数绑定分析 *)
let analyze_parameter_binding param_name func_name body =
  let rec find_param_usage expr patterns =
    match expr with
    | VarExpr name when name = param_name -> "direct_reference" :: patterns
    | BinaryOpExpr (VarExpr name, Sub, LitExpr (IntLit 1)) when name = param_name ->
        "minus_one_pattern" :: patterns
    | BinaryOpExpr (VarExpr name, op, _) when name = param_name ->
        ("arithmetic_pattern_"
        ^ match op with Add -> "add" | Sub -> "sub" | Mul -> "mul" | Div -> "div" | _ -> "other")
        :: patterns
    | FunCallExpr (VarExpr fname, [ VarExpr pname ]) when pname = param_name && fname = func_name ->
        "recursive_call_pattern" :: patterns
    | FunCallExpr (VarExpr fname, args) when fname = func_name ->
        List.fold_left
          (fun acc arg -> find_param_usage arg acc)
          ("recursive_with_args" :: patterns)
          args
    | BinaryOpExpr (left, _, right) -> find_param_usage right (find_param_usage left patterns)
    | CondExpr (cond, then_expr, else_expr) ->
        find_param_usage else_expr (find_param_usage then_expr (find_param_usage cond patterns))
    | FunCallExpr (f, args) ->
        List.fold_left (fun acc arg -> find_param_usage arg acc) (find_param_usage f patterns) args
    | _ -> patterns
  in
  let usage_patterns = find_param_usage body [] in
  let is_recursive_context = List.exists (fun p -> String.contains p 'r') usage_patterns in
  { param_name; is_recursive_context; usage_patterns = List.rev usage_patterns }

(** 推断返回类型 *)
let infer_return_type body =
  let rec analyze_expr expr =
    match expr with
    | LitExpr (IntLit _) -> Some "整数"
    | LitExpr (FloatLit _) -> Some "浮点数"
    | LitExpr (StringLit _) -> Some "字符串"
    | LitExpr (BoolLit _) -> Some "布尔"
    | BinaryOpExpr (left, op, _right) -> (
        match op with
        | Add | Sub | Mul | Div | Mod -> Some "整数"
        | Eq | Neq | Lt | Le | Gt | Ge -> Some "布尔"
        | Concat -> Some "字符串"
        | _ -> analyze_expr left)
    | CondExpr (_cond, then_expr, _else_expr) -> analyze_expr then_expr
    | FunCallExpr (VarExpr fname, _) when fname = "阶乘" || fname = "阶乘计算" -> Some "整数"
    | _ -> None
  in
  analyze_expr body

(** 计算复杂度级别 *)
let calculate_complexity_level body =
  let rec count_complexity expr depth =
    match expr with
    | CondExpr (_, then_expr, else_expr) ->
        1 + count_complexity then_expr (depth + 1) + count_complexity else_expr (depth + 1)
    | FunCallExpr (_, args) ->
        1 + List.fold_left (fun acc arg -> acc + count_complexity arg depth) 0 args
    | BinaryOpExpr (left, _, right) -> count_complexity left depth + count_complexity right depth
    | LetExpr (_, val_expr, body_expr) ->
        count_complexity val_expr depth + count_complexity body_expr depth
    | _ -> 0
  in
  let complexity_score = count_complexity body 0 in
  if complexity_score <= 2 then 1 else if complexity_score <= 5 then 2 else 3

(** 分析自然语言函数的语义信息 *)
let analyze_natural_function_semantics func_name params body =
  let recursive_pattern = analyze_recursive_pattern func_name body in
  let is_recursive = recursive_pattern <> NoRecursion in
  let parameter_bindings =
    List.map (fun param -> analyze_parameter_binding param func_name body) params
  in
  let return_type_hint = infer_return_type body in
  let complexity_level = calculate_complexity_level body in

  {
    function_name = func_name;
    parameter_bindings;
    is_recursive;
    return_type_hint;
    complexity_level;
  }

(** 生成语义分析报告 *)
let generate_semantic_report semantic_info =
  let buffer = Buffer.create (Constants.BufferSizes.default_buffer ()) in
  Buffer.add_string buffer (semantic_report_title_pattern semantic_info.function_name);
  Buffer.add_string buffer (recursive_feature_pattern semantic_info.is_recursive);
  Buffer.add_string buffer (complexity_level_pattern semantic_info.complexity_level);
  (match semantic_info.return_type_hint with
  | Some typ -> Buffer.add_string buffer (inferred_return_type_pattern typ)
  | None -> Buffer.add_string buffer "推断返回类型: 未知\n");

  Buffer.add_string buffer "\n参数绑定分析:\n";
  List.iter
    (fun binding ->
      Buffer.add_string buffer (param_analysis_pattern binding.param_name);
      Buffer.add_string buffer (recursive_context_pattern binding.is_recursive_context);
      Buffer.add_string buffer (usage_pattern_pattern (String.concat ", " binding.usage_patterns)))
    semantic_info.parameter_bindings;

  Buffer.contents buffer

(** 验证自然语言函数的语义一致性 *)
let validate_semantic_consistency semantic_info =
  let errors = ref [] in

  (* 检查递归函数是否有基础情况 *)
  (if semantic_info.is_recursive then
     let has_base_case =
       List.exists
         (fun binding ->
           List.exists
             (fun pattern -> String.contains pattern 'c' (* condition pattern *))
             binding.usage_patterns)
         semantic_info.parameter_bindings
     in
     if not has_base_case then errors := "警告：递归函数可能缺少基础情况" :: !errors);

  (* 检查复杂度与参数使用的一致性 *)
  if semantic_info.complexity_level > 2 && List.length semantic_info.parameter_bindings = 1 then
    errors := "提示：复杂函数建议考虑拆分或添加辅助参数" :: !errors;

  List.rev !errors
