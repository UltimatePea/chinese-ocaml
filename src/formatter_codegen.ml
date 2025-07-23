(** 骆言编译器C代码生成格式化模块

    本模块专注于C代码生成的格式化功能，从unified_formatter.ml中拆分出来。 提供类型安全的C代码格式化接口，消除Printf.sprintf依赖。

    重构目的：大型模块细化 - Fix #893
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-22 *)

(* 引入基础格式化器，实现零Printf.sprintf依赖 *)
open Utils.Base_formatter

(** C代码生成格式化 *)
module CCodegen = struct
  (** 函数调用 *)
  let function_call func_name args = function_call_format func_name args

  let binary_function_call func_name left right = function_call_format func_name [ left; right ]
  let unary_function_call func_name operand = function_call_format func_name [ operand ]

  (** 骆言特定格式 *)
  let luoyan_call func_code arg_count args_code =
    function_call_format "luoyan_call" [ func_code; int_to_string arg_count; args_code ]

  let luoyan_bind_var var_name value =
    concat_strings [ "luoyan_bind_var(\""; var_name; "\", "; value; ")" ]

  let luoyan_string s = concat_strings [ "luoyan_string(\""; String.escaped s; "\")" ]
  let luoyan_int i = function_call_format "luoyan_int" [ int_to_string i ]
  let luoyan_float f = function_call_format "luoyan_float" [ float_to_string f ]
  let luoyan_bool b = function_call_format "luoyan_bool" [ (if b then "true" else "false") ]
  let luoyan_unit () = "luoyan_unit()"
  let luoyan_equals expr_var value = function_call_format "luoyan_equals" [ expr_var; value ]

  let luoyan_let var_name value_code body_code =
    function_call_format "luoyan_let" [ "\"" ^ var_name ^ "\""; value_code; body_code ]

  let luoyan_function_create func_name first_param =
    concat_strings
      [ "luoyan_function_create("; func_name; "_impl_"; first_param; ", env, \""; func_name; "\")" ]

  let luoyan_pattern_match expr_var = function_call_format "luoyan_pattern_match" [ expr_var ]

  let luoyan_var_expr expr_var expr_code =
    concat_strings
      [ "({ luoyan_value_t* "; expr_var; " = "; expr_code; "; luoyan_match("; expr_var; "); })" ]

  (** 环境绑定格式化 *)
  let luoyan_env_bind var_name expr_code = luoyan_env_bind_pattern var_name expr_code

  let luoyan_function_create_with_args func_code func_name =
    concat_strings
      [ "luoyan_function_create("; func_code; ", env, \""; String.escaped func_name; "\")" ]

  (** 字符串相等性检查 *)
  let luoyan_string_equality_check expr_var escaped_string =
    concat_strings [ "luoyan_equals("; expr_var; ", luoyan_string(\""; escaped_string; "\"))" ]

  (** 编译日志消息 *)
  let compilation_start_message output_file = concat_strings [ "开始编译为C代码，输出文件："; output_file ]

  let compilation_status_message action details = context_message_pattern action details

  (** 异常处理格式化 - Phase 3 新增 *)
  let luoyan_catch branch_code = function_call_format "luoyan_catch" [ branch_code ]

  let luoyan_try_catch try_code catch_code finally_code =
    function_call_format "luoyan_try_catch" [ try_code; catch_code; finally_code ]

  let luoyan_raise expr_code = function_call_format "luoyan_raise" [ expr_code ]

  (** 组合表达式格式化 - Phase 3 新增 *)
  let luoyan_combine expr_codes =
    function_call_format "luoyan_combine" [ join_with_separator ", " expr_codes ]

  (** 模式匹配格式化 - Phase 3 新增 *)
  let luoyan_match_constructor expr_var constructor_name =
    function_call_format "luoyan_match_constructor" [ expr_var; "\"" ^ constructor_name ^ "\"" ]

  (** 模块操作格式化 - Phase 3 新增 *)
  let luoyan_include_module module_code =
    concat_strings [ "luoyan_include_module("; module_code; ");" ]

  (** C语句格式化 - Phase 3 新增 *)
  let c_statement expr_code = concat_strings [ expr_code; ";" ]

  let c_statement_sequence stmt1 stmt2 = concat_strings [ stmt1; "; "; stmt2 ]
  let c_statement_block statements_with_newlines = join_with_separator "\n" statements_with_newlines

  (** C模板格式化 *)
  let c_template_with_includes include_part main_part footer_part =
    concat_strings [ include_part; "\n\n"; main_part; "\n\n"; footer_part ]

  (** 变量声明 *)
  let c_variable_declaration var_type var_name initial_value =
    concat_strings [ var_type; " "; var_name; " = "; initial_value; ";" ]

  let c_const_declaration var_type var_name value =
    concat_strings [ "const "; var_type; " "; var_name; " = "; value; ";" ]

  (** 控制流结构 *)
  let c_if_statement condition then_block =
    concat_strings [ "if ("; condition; ") {\n"; then_block; "\n}" ]

  let c_if_else_statement condition then_block else_block =
    concat_strings [ "if ("; condition; ") {\n"; then_block; "\n} else {\n"; else_block; "\n}" ]

  let c_while_loop condition body = concat_strings [ "while ("; condition; ") {\n"; body; "\n}" ]

  let c_for_loop init condition increment body =
    concat_strings [ "for ("; init; "; "; condition; "; "; increment; ") {\n"; body; "\n}" ]

  (** 函数定义 *)
  let c_function_declaration return_type func_name params =
    concat_strings [ return_type; " "; func_name; "("; join_with_separator ", " params; ")" ]

  let c_function_definition return_type func_name params body =
    concat_strings
      [ return_type; " "; func_name; "("; join_with_separator ", " params; ") {\n"; body; "\n}" ]

  (** 结构体和类型定义 *)
  let c_struct_definition struct_name fields =
    let formatted_fields =
      List.map
        (fun (field_type, field_name) ->
          concat_strings [ "    "; field_type; " "; field_name; ";" ])
        fields
    in
    concat_strings
      [ "typedef struct {\n"; join_with_separator "\n" formatted_fields; "\n} "; struct_name; ";" ]

  let c_enum_definition enum_name values =
    concat_strings
      [ "typedef enum {\n    "; join_with_separator ",\n    " values; "\n} "; enum_name; ";" ]
end

(** 增强C代码生成模块 *)
module EnhancedCCodegen = struct
  (** 类型转换 *)
  let type_cast target_type expr = concat_strings [ "("; target_type; ")"; expr ]

  (** 构造器匹配 *)
  let constructor_match expr_var constructor =
    concat_strings
      [ "luoyan_match_constructor("; expr_var; ", \""; String.escaped constructor; "\")" ]

  (** 字符串相等性检查（转义版本）*)
  let string_equality_escaped expr_var escaped_string =
    concat_strings [ "luoyan_equals("; expr_var; ", luoyan_string(\""; escaped_string; "\"))" ]

  (** 扩展的骆言函数调用 *)
  let luoyan_call_with_cast func_name cast_type args =
    concat_strings [ "("; cast_type; ")"; function_call_format func_name args ]

  (** 复合C代码模式 *)
  let luoyan_conditional_binding var_name condition true_expr false_expr =
    concat_strings
      [ "luoyan_value_t* "; var_name; " = "; condition; " ? "; true_expr; " : "; false_expr; ";" ]

  (** 高级函数调用 *)
  let luoyan_dynamic_call func_expr args_array =
    function_call_format "luoyan_dynamic_call" [ func_expr; args_array ]

  let luoyan_partial_application func_expr partial_args =
    function_call_format "luoyan_partial_application" [ func_expr; partial_args ]

  (** 内存管理 *)
  let luoyan_alloc size = function_call_format "luoyan_alloc" [ int_to_string size ]

  let luoyan_free ptr = function_call_format "luoyan_free" [ ptr ]
  let luoyan_gc_collect () = "luoyan_gc_collect()"

  (** 数据结构操作 *)
  let luoyan_array_create size = function_call_format "luoyan_array_create" [ int_to_string size ]

  let luoyan_array_get array index =
    function_call_format "luoyan_array_get" [ array; int_to_string index ]

  let luoyan_array_set array index value =
    function_call_format "luoyan_array_set" [ array; int_to_string index; value ]

  let luoyan_record_create field_count =
    function_call_format "luoyan_record_create" [ int_to_string field_count ]

  let luoyan_record_get record field_name =
    function_call_format "luoyan_record_get" [ record; "\"" ^ field_name ^ "\"" ]

  let luoyan_record_set record field_name value =
    function_call_format "luoyan_record_set" [ record; "\"" ^ field_name ^ "\""; value ]

  (** 类型检查 *)
  let luoyan_type_check value expected_type =
    function_call_format "luoyan_type_check" [ value; "\"" ^ expected_type ^ "\"" ]

  let luoyan_is_type value type_name =
    function_call_format "luoyan_is_type" [ value; "\"" ^ type_name ^ "\"" ]

  (** 错误处理 *)
  let luoyan_error_throw error_code message =
    function_call_format "luoyan_error_throw" [ int_to_string error_code; "\"" ^ message ^ "\"" ]

  let luoyan_error_propagate error = function_call_format "luoyan_error_propagate" [ error ]
  let luoyan_error_check result = function_call_format "luoyan_error_check" [ result ]

  (** 调试和性能 *)
  let luoyan_debug_trace function_name args =
    function_call_format "luoyan_debug_trace" [ "\"" ^ function_name ^ "\""; args ]

  let luoyan_profile_start label =
    function_call_format "luoyan_profile_start" [ "\"" ^ label ^ "\"" ]

  let luoyan_profile_end label = function_call_format "luoyan_profile_end" [ "\"" ^ label ^ "\"" ]
end

(** C代码生成工具模块 *)
module CodeGenUtilities = struct
  (** 代码注释 *)
  let c_line_comment text = concat_strings [ "// "; text ]

  let c_block_comment text = concat_strings [ "/* "; text; " */" ]
  let c_doc_comment text = concat_strings [ "/** "; text; " */" ]

  (** 代码格式化 *)
  let c_indent_block block indent_level =
    let indent_str = String.make (indent_level * 4) ' ' in
    let lines = String.split_on_char '\n' block in
    let indented_lines =
      List.map
        (fun line -> if String.trim line = "" then line else concat_strings [ indent_str; line ])
        lines
    in
    join_with_separator "\n" indented_lines

  let c_format_parameter_list params =
    if List.length params = 0 then "void" else join_with_separator ", " params

  (** 预处理器指令 *)
  let c_include_system header = concat_strings [ "#include <"; header; ">" ]

  let c_include_local header = concat_strings [ "#include \""; header; "\"" ]
  let c_define macro_name value = concat_strings [ "#define "; macro_name; " "; value ]
  let c_ifdef condition = concat_strings [ "#ifdef "; condition ]
  let c_ifndef condition = concat_strings [ "#ifndef "; condition ]
  let c_endif () = "#endif"

  (** 代码块管理 *)
  let c_scope_block statements =
    concat_strings [ "{\n"; join_with_separator "\n" statements; "\n}" ]

  let c_namespace_block namespace_name content =
    concat_strings [ "namespace "; namespace_name; " {\n"; content; "\n}" ]
end
