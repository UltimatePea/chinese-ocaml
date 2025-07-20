(** 错误消息翻译模块 - Error Message Translation Module *)

(** 将英文类型错误转换为中文 *)
let chinese_type_error_message msg =
  let replacements =
    [
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
    ]
  in
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
  let replacements =
    [
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
    ]
  in
  let rec apply_replacements msg replacements =
    match replacements with
    | [] -> msg
    | (old_str, new_str) :: rest ->
        let new_msg = Str.global_replace (Str.regexp_string old_str) new_str msg in
        apply_replacements new_msg rest
  in
  apply_replacements msg replacements