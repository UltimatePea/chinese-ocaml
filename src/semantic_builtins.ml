(** 骆言语义分析内置函数 - Chinese Programming Language Semantic Builtins *)

open Types
open Semantic_context

(** 添加基础I/O函数 *)
let add_io_functions builtin_symbols =
  builtin_symbols
  |> SymbolTable.add "打印" (create_symbol_entry "打印" (FunType_T (TypeVar_T "'a", UnitType_T)))
  |> SymbolTable.add "读取" (create_symbol_entry "读取" (FunType_T (UnitType_T, StringType_T)))

(** 添加列表操作函数 *)
let add_list_functions builtin_symbols =
  builtin_symbols
  |> SymbolTable.add "长度"
       (create_symbol_entry "长度" (FunType_T (ListType_T (TypeVar_T "'a"), IntType_T)))
  |> SymbolTable.add "连接"
       (create_symbol_entry "连接"
          (FunType_T
             ( ListType_T (TypeVar_T "'a"),
               FunType_T (ListType_T (TypeVar_T "'a"), ListType_T (TypeVar_T "'a")) )))
  |> SymbolTable.add "过滤"
       (create_symbol_entry "过滤"
          (FunType_T
             ( FunType_T (TypeVar_T "'a", BoolType_T),
               FunType_T (ListType_T (TypeVar_T "'a"), ListType_T (TypeVar_T "'a")) )))
  |> SymbolTable.add "映射"
       (create_symbol_entry "映射"
          (FunType_T
             ( FunType_T (TypeVar_T "'a", TypeVar_T "'b"),
               FunType_T (ListType_T (TypeVar_T "'a"), ListType_T (TypeVar_T "'b")) )))
  |> SymbolTable.add "折叠"
       (create_symbol_entry "折叠"
          (FunType_T
             ( FunType_T (TypeVar_T "'a", FunType_T (TypeVar_T "'b", TypeVar_T "'b")),
               FunType_T (TypeVar_T "'b", FunType_T (ListType_T (TypeVar_T "'a"), TypeVar_T "'b"))
             )))

(** 添加数组操作函数 *)
let add_array_functions builtin_symbols =
  builtin_symbols
  |> SymbolTable.add "数组长度"
       (create_symbol_entry "数组长度" (FunType_T (ArrayType_T (TypeVar_T "'a"), IntType_T)))
  |> SymbolTable.add "创建数组"
       (create_symbol_entry "创建数组"
          (FunType_T (IntType_T, FunType_T (TypeVar_T "'a", ArrayType_T (TypeVar_T "'a")))))
  |> SymbolTable.add "复制数组"
       (create_symbol_entry "复制数组"
          (FunType_T (ArrayType_T (TypeVar_T "'a"), ArrayType_T (TypeVar_T "'a"))))

(** 添加数学函数 *)
let add_math_functions builtin_symbols =
  builtin_symbols
  |> SymbolTable.add "绝对值" (create_symbol_entry "绝对值" (FunType_T (IntType_T, IntType_T)))
  |> SymbolTable.add "平方根" (create_symbol_entry "平方根" (FunType_T (FloatType_T, FloatType_T)))
  |> SymbolTable.add "次方"
       (create_symbol_entry "次方" (FunType_T (FloatType_T, FunType_T (FloatType_T, FloatType_T))))

(** 添加字符串函数 *)
let add_string_functions builtin_symbols =
  builtin_symbols
  |> SymbolTable.add "字符串长度" (create_symbol_entry "字符串长度" (FunType_T (StringType_T, IntType_T)))
  |> SymbolTable.add "字符串连接"
       (create_symbol_entry "字符串连接"
          (FunType_T (StringType_T, FunType_T (StringType_T, StringType_T))))

(** 添加文件函数 *)
let add_file_functions builtin_symbols =
  builtin_symbols
  |> SymbolTable.add "读取文件" (create_symbol_entry "读取文件" (FunType_T (StringType_T, StringType_T)))
  |> SymbolTable.add "写入文件"
       (create_symbol_entry "写入文件" (FunType_T (StringType_T, FunType_T (StringType_T, UnitType_T))))
  |> SymbolTable.add "文件存在" (create_symbol_entry "文件存在" (FunType_T (StringType_T, BoolType_T)))

(** 添加所有内置函数 - 重构后的主函数 *)
let add_builtin_functions context =
  let builtin_symbols = SymbolTable.empty in
  let builtin_symbols =
    builtin_symbols |> add_io_functions |> add_list_functions |> add_array_functions
    |> add_math_functions |> add_string_functions |> add_file_functions
  in
  { context with scope_stack = builtin_symbols :: context.scope_stack }
