(** C代码生成格式化模块

    本模块专门处理C代码生成时的字符串格式化， 提供统一的C代码生成工具函数。
    
    重构历史：Printf.sprintf统一化第三阶段Phase 3.3完全重构
    - 消除所有Printf.sprintf依赖，使用Base_formatter统一格式化
    - 实现C代码生成格式化的完全统一化和一致性

    @author 骆言技术债务清理团队
    @version 2.0
    @since 2025-07-22 Issue #864 Printf.sprintf统一化完成 *)

(** 函数调用格式 - 使用Base_formatter统一模式 *)
let function_call func_name args = Utils.Base_formatter.function_call_format func_name args

(** 双参数函数调用 - 使用Base_formatter统一模式 *)
let binary_function_call func_name e1_code e2_code = Utils.Base_formatter.binary_function_pattern func_name e1_code e2_code

(** 字符串相等性检查 - 使用Base_formatter统一模式 *)
let string_equality_check expr_var escaped_string = Utils.Base_formatter.luoyan_string_equality_pattern expr_var escaped_string

(** 类型转换 - 使用Base_formatter统一模式 *)
let type_conversion target_type expr = Utils.Base_formatter.c_type_cast_pattern target_type expr
