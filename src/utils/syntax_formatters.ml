(** 骆言编译器语法元素格式化模块

    此模块专门处理Token、语法结构、函数调用、模块访问等语法元素的格式化。

    设计原则:
    - 语法一致性：遵循骆言语言的语法规范
    - 可读性：生成易读的语法元素表示
    - 完整性：覆盖所有主要语法结构
    - C代码生成友好：支持代码生成阶段的格式化需求

    用途：为语法分析、代码生成、语法树显示提供格式化服务 *)

open Base_string_ops

(** 语法元素格式化工具模块 *)
module Syntax_formatters = struct
  (** Token模式: TokenType(value) *)
  let token_pattern token_type value = concat_strings [ token_type; "("; value; ")" ]

  (** Token模式: TokenType('char') *)
  let char_token_pattern token_type char =
    concat_strings [ token_type; "('"; char_to_string char; "')" ]

  (** 函数调用格式化: FunctionName(arg1, arg2, ...) *)
  let function_call_format func_name args =
    concat_strings [ func_name; "("; join_with_separator ", " args; ")" ]

  (** 模块访问格式化: Module.member *)
  let module_access_format module_name member_name =
    concat_strings [ module_name; "."; member_name ]

  (** 双参数函数模式: func_name(param1, param2) *)
  let binary_function_pattern func_name param1 param2 =
    concat_strings [ func_name; "("; param1; ", "; param2; ")" ]

  (** C代码生成模式: luoyan_function_name(args) *)
  let luoyan_function_pattern func_name args =
    concat_strings [ "luoyan_"; func_name; "("; args; ")" ]

  (** C环境绑定模式: luoyan_env_bind(env, "var", expr); *)
  let luoyan_env_bind_pattern var_name expr =
    concat_strings [ "luoyan_env_bind(env, \""; var_name; "\", "; expr; ");" ]

  (** C代码结构模式: includes + functions + main *)
  let c_code_structure_pattern includes functions main =
    concat_strings [ includes; "\n\n"; functions; "\n\n"; main; "\n" ]

  (** Luoyan字符串相等检查模式: luoyan_equals(expr, luoyan_string("str")) *)
  let luoyan_string_equality_pattern expr_var str =
    concat_strings [ "luoyan_equals("; expr_var; ", luoyan_string(\""; str; "\"))" ]

  (** C类型转换模式: (type)expr *)
  let c_type_cast_pattern target_type expr = concat_strings [ "("; target_type; ")"; expr ]

  (** C记录字段格式: {"field_name", expr} *)
  let c_record_field_pattern field_name expr =
    concat_strings [ "{\""; field_name; "\", "; expr; "}" ]

  (** C记录构造模式: luoyan_record(count, (luoyan_field_t[]){fields}) *)
  let c_record_constructor_pattern count fields =
    concat_strings [ "luoyan_record("; int_to_string count; ", (luoyan_field_t[]){"; fields; "})" ]

  (** C记录访问模式: luoyan_record_get(record, "field") *)
  let c_record_get_pattern record field =
    concat_strings [ "luoyan_record_get("; record; ", \""; field; "\")" ]

  (** C记录更新模式: luoyan_record_update(record, count, (luoyan_field_t[]){updates}) *)
  let c_record_update_pattern record count updates =
    concat_strings
      [
        "luoyan_record_update(";
        record;
        ", ";
        int_to_string count;
        ", (luoyan_field_t[]){";
        updates;
        "})";
      ]

  (** C构造器模式: luoyan_constructor("name", count, args) *)
  let c_constructor_pattern name count args =
    concat_strings [ "luoyan_constructor(\""; name; "\", "; int_to_string count; ", "; args; ")" ]

  (** C值数组模式: (luoyan_value_t[]){values} *)
  let c_value_array_pattern values = concat_strings [ "(luoyan_value_t[]){"; values; "}" ]

  (** C变量命名模式: luoyan_var_prefix_id *)
  let c_var_name_pattern prefix id = concat_strings [ "luoyan_var_"; prefix; "_"; int_to_string id ]

  (** C标签命名模式: luoyan_label_prefix_id *)
  let c_label_name_pattern prefix id =
    concat_strings [ "luoyan_label_"; prefix; "_"; int_to_string id ]

  (** ASCII转义模式: _asciiNUM_ *)
  let ascii_escape_pattern ascii_code = concat_strings [ "_ascii"; int_to_string ascii_code; "_" ]

  (** C类型模式: luoyan_type_name_t* *)
  let c_type_pointer_pattern type_name = concat_strings [ "luoyan_"; type_name; "_t*" ]

  (** C用户类型模式: luoyan_user_name_t* *)
  let c_user_type_pattern name = concat_strings [ "luoyan_user_"; name; "_t*" ]

  (** C类模式: luoyan_class_name_t* *)
  let c_class_type_pattern name = concat_strings [ "luoyan_class_"; name; "_t*" ]

  (** C私有类型模式: luoyan_private_name_t* *)
  let c_private_type_pattern name = concat_strings [ "luoyan_private_"; name; "_t*" ]

  (** 类型转换日志模式: 将source_type转换为target_type *)
  let type_conversion_log_pattern source_type target_type =
    concat_strings [ "将"; source_type; "转换为"; target_type ]

  (** 浮点数整数转换模式: 将浮点数X转换为整数Y *)
  let float_to_int_conversion_pattern float_val int_val =
    concat_strings [ "将浮点数"; float_to_string float_val; "转换为整数"; int_to_string int_val ]

  (** 字符串整数转换模式: 将字符串"X"转换为整数Y *)
  let string_to_int_conversion_pattern string_val int_val =
    concat_strings [ "将字符串\""; string_val; "\"转换为整数"; int_to_string int_val ]

  (** 布尔值整数转换模式: 将布尔值X转换为整数Y *)
  let bool_to_int_conversion_pattern bool_val int_val =
    concat_strings [ "将布尔值"; (if bool_val then "真" else "假"); "转换为整数"; int_to_string int_val ]

  (** 整数浮点数转换模式: 将整数X转换为浮点数Y *)
  let int_to_float_conversion_pattern int_val float_val =
    concat_strings [ "将整数"; int_to_string int_val; "转换为浮点数"; float_to_string float_val ]

  (** 字符串浮点数转换模式: 将字符串"X"转换为浮点数Y *)
  let string_to_float_conversion_pattern string_val float_val =
    concat_strings [ "将字符串\""; string_val; "\"转换为浮点数"; float_to_string float_val ]

  (** 值到字符串转换模式: 将X转换为字符串"Y" *)
  let value_to_string_conversion_pattern value_type string_val =
    concat_strings [ "将"; value_type; "转换为字符串\""; string_val; "\"" ]
end

include Syntax_formatters
(** 导出语法格式化函数到顶层，便于使用 *)