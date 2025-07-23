(** 骆言内置常量模块 - Chinese Programming Language Builtin Constants *)

open Value_operations
open Builtin_error
open Utils.Base_formatter

(** 中文数字常量生成函数 *)
let make_chinese_number_constant value =
  BuiltinFunctionValue
    (function
    | [] -> IntValue value
    | _ ->
        runtime_error
          (concat_strings
             [
               (match value with
               | 0 -> "零"
               | 1 -> "一"
               | 2 -> "二"
               | 3 -> "三"
               | 4 -> "四"
               | 5 -> "五"
               | 6 -> "六"
               | 7 -> "七"
               | 8 -> "八"
               | 9 -> "九"
               | _ -> "数字");
               "不需要参数";
             ]))

(** 中文数字常量表 *)
let chinese_number_constants =
  [
    ("零", make_chinese_number_constant 0);
    ("一", make_chinese_number_constant 1);
    ("二", make_chinese_number_constant 2);
    ("三", make_chinese_number_constant 3);
    ("四", make_chinese_number_constant 4);
    ("五", make_chinese_number_constant 5);
    ("六", make_chinese_number_constant 6);
    ("七", make_chinese_number_constant 7);
    ("八", make_chinese_number_constant 8);
    ("九", make_chinese_number_constant 9);
  ]
