(** C代码生成格式化模块
    
    本模块专门处理C代码生成时的字符串格式化，
    提供统一的C代码生成工具函数。
    
    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #708 重构 *)

(** 函数调用格式 *)
let function_call func_name args =
  let args_str = String.concat ", " args in
  Printf.sprintf "%s(%s)" func_name args_str

(** 双参数函数调用 *)
let binary_function_call func_name e1_code e2_code =
  Printf.sprintf "%s(%s, %s)" func_name e1_code e2_code

(** 字符串相等性检查 *)
let string_equality_check expr_var escaped_string =
  Printf.sprintf "luoyan_equals(%s, luoyan_string(\"%s\"))" expr_var escaped_string

(** 类型转换 *)
let type_conversion target_type expr = Printf.sprintf "(%s)%s" target_type expr

(* 环境绑定格式化 - 在测试文件中使用，但测试可能未包含在构建中 *)
[@@@warning "-32"]
let env_bind var_name expr_code =
  Printf.sprintf "luoyan_env_bind(env, \"%s\", %s);" var_name expr_code

(* 为未来C代码生成重构准备的工具函数 *)
[@@@warning "-32"]
let env_lookup var_name =
  Printf.sprintf "luoyan_env_lookup(env, \"%s\")" var_name
  
(* 运行时类型包装 - 为统一重复实现准备 *)
[@@@warning "-32"]
let luoyan_int i = Printf.sprintf "luoyan_int(%dL)" i
[@@@warning "-32"]  
let luoyan_float f = Printf.sprintf "luoyan_float(%g)" f  
[@@@warning "-32"]
let luoyan_string s = Printf.sprintf "luoyan_string(\"%s\")" s
[@@@warning "-32"]
let luoyan_bool b = Printf.sprintf "luoyan_bool(%s)" (if b then "true" else "false")
[@@@warning "-32"]
let luoyan_unit () = "luoyan_unit()"

(* 包含文件格式化 - 为C代码生成模块重构准备 *)
[@@@warning "-32"]
let include_header header = Printf.sprintf "#include <%s>" header
[@@@warning "-32"]
let include_local_header header = Printf.sprintf "#include \"%s\"" header

(* 递归函数特殊处理 - 为复杂代码生成场景准备 *)
[@@@warning "-32"]
let recursive_binding var_name expr_code =
  Printf.sprintf 
    "luoyan_env_bind(env, \"%s\", luoyan_unit()); luoyan_env_bind(env, \"%s\", %s);" 
    var_name var_name expr_code

(* C语言控制结构 - 为条件表达式生成准备 *)
[@@@warning "-32"]
let if_statement condition then_code else_code_opt =
  match else_code_opt with
  | Some else_code -> 
      Printf.sprintf "if (%s) { %s } else { %s }" condition then_code else_code
  | None -> 
      Printf.sprintf "if (%s) { %s }" condition then_code

(* C语言表达式格式化 - 为统一代码生成格式准备 *)
[@@@warning "-32"]
let assignment var_name expr = Printf.sprintf "%s = %s;" var_name expr
[@@@warning "-32"]
let return_statement expr = Printf.sprintf "return %s;" expr
[@@@warning "-32"]
let function_declaration return_type func_name params =
  let params_str = String.concat ", " params in
  Printf.sprintf "%s %s(%s)" return_type func_name params_str