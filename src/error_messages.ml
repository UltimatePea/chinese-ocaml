(** 骆言错误消息模块 - Chinese Programming Language Error Messages *)

open Types

(** 将英文类型错误转换为中文 *)
let chinese_type_error_message msg =
  let replacements = [
    ("Cannot unify types:", "无法统一类型:");
    ("with", "与");
    ("Occurs check failure:", "循环类型检查失败:");
    ("occurs in", "出现在");
    ("Type list length mismatch", "类型列表长度不匹配");
    ("Undefined variable:", "未定义的变量:");
    ("Match expression must have at least one branch", "匹配表达式必须至少有一个分支");
    ("Macro calls not yet supported", "暂不支持宏调用");
    ("Async expressions not yet supported", "暂不支持异步表达式");
    ("Expected function type but got:", "期望函数类型，但得到:");
    ("IntType_T", "整数类型");
    ("FloatType_T", "浮点数类型");
    ("StringType_T", "字符串类型");
    ("BoolType_T", "布尔类型");
    ("UnitType_T", "单元类型");
    ("FunType_T", "函数类型");
    ("ListType_T", "列表类型");
    ("TypeVar_T", "类型变量");
    ("TupleType_T", "元组类型");
  ] in
  let rec apply_replacements msg replacements =
    match replacements with
    | [] -> msg
    | (old_str, new_str) :: rest ->
      let new_msg = Str.global_replace (Str.regexp_string old_str) new_str msg in
      apply_replacements new_msg rest
  in
  apply_replacements msg replacements

(** 将运行时错误转换为中文 *)
let chinese_runtime_error_message msg =
  let replacements = [
    ("Runtime error:", "运行时错误:");
    ("Undefined variable:", "未定义的变量:");
    ("Function parameter count mismatch", "函数参数数量不匹配");
    ("Cannot call non-function value", "尝试调用非函数值");
    ("Division by zero", "除零错误");
    ("Type mismatch in operation", "操作中的类型不匹配");
    ("Pattern matching exhausted", "模式匹配未能覆盖所有情况");
    ("List index out of bounds", "列表索引超出范围");
    ("Invalid arithmetic operation", "无效的算术运算");
    ("Expected integer but got", "期望整数但得到");
    ("Expected string but got", "期望字符串但得到");
    ("Expected boolean but got", "期望布尔值但得到");
    ("Expected list but got", "期望列表但得到");
  ] in
  let rec apply_replacements msg replacements =
    match replacements with
    | [] -> msg
    | (old_str, new_str) :: rest ->
      let new_msg = Str.global_replace (Str.regexp_string old_str) new_str msg in
      apply_replacements new_msg rest
  in
  apply_replacements msg replacements

(** 生成详细的类型不匹配错误消息 *)
let type_mismatch_error expected_type actual_type =
  Printf.sprintf "类型不匹配: 期望 %s，但得到 %s" 
    (type_to_chinese_string expected_type)
    (type_to_chinese_string actual_type)

(** 生成未定义变量的建议错误消息 *)
let undefined_variable_error var_name available_vars =
  let base_msg = Printf.sprintf "未定义的变量: %s" var_name in
  if List.length available_vars = 0 then
    base_msg ^ "（当前作用域中没有可用变量）"
  else if List.length available_vars <= 5 then
    base_msg ^ Printf.sprintf "（可用变量: %s）" (String.concat "、" available_vars)
  else
    let rec take n lst = if n <= 0 then [] else match lst with [] -> [] | h::t -> h :: take (n-1) t in
    let first_five = take 5 available_vars in
    base_msg ^ Printf.sprintf "（可用变量包括: %s 等）" (String.concat "、" first_five)

(** 生成函数调用参数不匹配的详细错误消息 *)  
let function_arity_error expected_count actual_count =
  Printf.sprintf "函数参数数量不匹配: 期望 %d 个参数，但提供了 %d 个参数" 
    expected_count actual_count

(** 生成模式匹配失败的详细错误消息 *)
let pattern_match_error value_type =
  Printf.sprintf "模式匹配失败: 无法匹配类型为 %s 的值" 
    (type_to_chinese_string value_type)

(** 生成AI友好的错误建议 *)
let generate_error_suggestions error_type _context =
  match error_type with
  | "type_mismatch" ->
    "建议: 检查变量类型是否正确，或使用类型转换功能"
  | "undefined_variable" ->
    "建议: 检查变量名拼写，或确保变量已在当前作用域中定义"
  | "function_arity" ->
    "建议: 检查函数调用的参数数量，或使用参数适配功能"
  | "pattern_match" ->
    "建议: 确保模式匹配覆盖所有可能的情况"
  | _ ->
    "建议: 查看文档或使用 -types 选项查看类型信息"