(** 骆言语义分析内置函数 - comprehensive测试 *)

open Alcotest
open Yyocamlc_lib.Types
open Yyocamlc_lib.Semantic_context
open Yyocamlc_lib.Semantic_builtins

(** ========== 测试辅助函数 ========== *)

(** 创建测试用的类型变量 *)
let create_type_var name = TypeVar_T name

(** 创建测试用的函数类型 *)
let create_fun_type param ret = FunType_T (param, ret)

(** 创建测试用的列表类型 *)
let create_list_type elem = ListType_T elem

(** 创建测试用的数组类型 *)
let create_array_type elem = ArrayType_T elem

(** 类型相等性测试 *)
let type_testable = testable (fun fmt t -> Fmt.string fmt (type_to_chinese_string t)) ( = )

(** 检查上下文中是否包含指定的内置函数 *)
let check_builtin_function context name expected_type =
  match context.scope_stack with
  | builtin_scope :: _ -> (
      match SymbolTable.find_opt name builtin_scope with
      | Some entry -> entry.symbol_type = expected_type
      | None -> false)
  | [] -> false

(** ========== I/O函数测试 ========== *)

(** 测试I/O函数的添加 *)
let test_add_io_functions () =
  let empty_symbols = SymbolTable.empty in
  let io_symbols = add_io_functions empty_symbols in

  (* 检查打印函数 *)
  let print_entry = SymbolTable.find "打印" io_symbols in
  check type_testable "打印函数类型"
    (create_fun_type (create_type_var "'a") UnitType_T)
    print_entry.symbol_type;

  (* 检查读取函数 *)
  let read_entry = SymbolTable.find "读取" io_symbols in
  check type_testable "读取函数类型" (create_fun_type UnitType_T StringType_T) read_entry.symbol_type

(** 测试I/O函数完整性 *)
let test_io_functions_completeness () =
  let empty_symbols = SymbolTable.empty in
  let io_symbols = add_io_functions empty_symbols in

  (* 确保所有I/O函数都被添加 *)
  check bool "打印函数存在" true (SymbolTable.mem "打印" io_symbols);
  check bool "读取函数存在" true (SymbolTable.mem "读取" io_symbols);

  (* 确保函数数量正确 *)
  let function_count = SymbolTable.cardinal io_symbols in
  check int "I/O函数数量" 2 function_count

(** ========== 列表函数测试 ========== *)

(** 测试列表函数的添加 *)
let test_add_list_functions () =
  let empty_symbols = SymbolTable.empty in
  let list_symbols = add_list_functions empty_symbols in

  (* 检查长度函数 *)
  let length_entry = SymbolTable.find "长度" list_symbols in
  check type_testable "长度函数类型"
    (create_fun_type (create_list_type (create_type_var "'a")) IntType_T)
    length_entry.symbol_type;

  (* 检查连接函数 *)
  let concat_entry = SymbolTable.find "连接" list_symbols in
  let expected_concat_type =
    create_fun_type
      (create_list_type (create_type_var "'a"))
      (create_fun_type
         (create_list_type (create_type_var "'a"))
         (create_list_type (create_type_var "'a")))
  in
  check type_testable "连接函数类型" expected_concat_type concat_entry.symbol_type

(** 测试高阶列表函数 *)
let test_list_higher_order_functions () =
  let empty_symbols = SymbolTable.empty in
  let list_symbols = add_list_functions empty_symbols in

  (* 检查过滤函数 *)
  let filter_entry = SymbolTable.find "过滤" list_symbols in
  let expected_filter_type =
    create_fun_type
      (create_fun_type (create_type_var "'a") BoolType_T)
      (create_fun_type
         (create_list_type (create_type_var "'a"))
         (create_list_type (create_type_var "'a")))
  in
  check type_testable "过滤函数类型" expected_filter_type filter_entry.symbol_type;

  (* 检查映射函数 *)
  let map_entry = SymbolTable.find "映射" list_symbols in
  let expected_map_type =
    create_fun_type
      (create_fun_type (create_type_var "'a") (create_type_var "'b"))
      (create_fun_type
         (create_list_type (create_type_var "'a"))
         (create_list_type (create_type_var "'b")))
  in
  check type_testable "映射函数类型" expected_map_type map_entry.symbol_type

(** 测试列表函数完整性 *)
let test_list_functions_completeness () =
  let empty_symbols = SymbolTable.empty in
  let list_symbols = add_list_functions empty_symbols in

  (* 确保所有列表函数都被添加 *)
  check bool "长度函数存在" true (SymbolTable.mem "长度" list_symbols);
  check bool "连接函数存在" true (SymbolTable.mem "连接" list_symbols);
  check bool "过滤函数存在" true (SymbolTable.mem "过滤" list_symbols);
  check bool "映射函数存在" true (SymbolTable.mem "映射" list_symbols);
  check bool "折叠函数存在" true (SymbolTable.mem "折叠" list_symbols);

  (* 确保函数数量正确 *)
  let function_count = SymbolTable.cardinal list_symbols in
  check int "列表函数数量" 5 function_count

(** ========== 数组函数测试 ========== *)

(** 测试数组函数的添加 *)
let test_add_array_functions () =
  let empty_symbols = SymbolTable.empty in
  let array_symbols = add_array_functions empty_symbols in

  (* 检查数组长度函数 *)
  let length_entry = SymbolTable.find "数组长度" array_symbols in
  check type_testable "数组长度函数类型"
    (create_fun_type (create_array_type (create_type_var "'a")) IntType_T)
    length_entry.symbol_type;

  (* 检查创建数组函数 *)
  let create_entry = SymbolTable.find "创建数组" array_symbols in
  let expected_create_type =
    create_fun_type IntType_T
      (create_fun_type (create_type_var "'a") (create_array_type (create_type_var "'a")))
  in
  check type_testable "创建数组函数类型" expected_create_type create_entry.symbol_type

(** 测试数组函数完整性 *)
let test_array_functions_completeness () =
  let empty_symbols = SymbolTable.empty in
  let array_symbols = add_array_functions empty_symbols in

  (* 确保所有数组函数都被添加 *)
  check bool "数组长度函数存在" true (SymbolTable.mem "数组长度" array_symbols);
  check bool "创建数组函数存在" true (SymbolTable.mem "创建数组" array_symbols);
  check bool "复制数组函数存在" true (SymbolTable.mem "复制数组" array_symbols);

  (* 确保函数数量正确 *)
  let function_count = SymbolTable.cardinal array_symbols in
  check int "数组函数数量" 3 function_count

(** ========== 数学函数测试 ========== *)

(** 测试数学函数的添加 *)
let test_add_math_functions () =
  let empty_symbols = SymbolTable.empty in
  let math_symbols = add_math_functions empty_symbols in

  (* 检查绝对值函数 *)
  let abs_entry = SymbolTable.find "绝对值" math_symbols in
  check type_testable "绝对值函数类型" (create_fun_type IntType_T IntType_T) abs_entry.symbol_type;

  (* 检查平方根函数 *)
  let sqrt_entry = SymbolTable.find "平方根" math_symbols in
  check type_testable "平方根函数类型" (create_fun_type FloatType_T FloatType_T) sqrt_entry.symbol_type;

  (* 检查次方函数 *)
  let pow_entry = SymbolTable.find "次方" math_symbols in
  let expected_pow_type = create_fun_type FloatType_T (create_fun_type FloatType_T FloatType_T) in
  check type_testable "次方函数类型" expected_pow_type pow_entry.symbol_type

(** 测试数学函数完整性 *)
let test_math_functions_completeness () =
  let empty_symbols = SymbolTable.empty in
  let math_symbols = add_math_functions empty_symbols in

  (* 确保所有数学函数都被添加 *)
  check bool "绝对值函数存在" true (SymbolTable.mem "绝对值" math_symbols);
  check bool "平方根函数存在" true (SymbolTable.mem "平方根" math_symbols);
  check bool "次方函数存在" true (SymbolTable.mem "次方" math_symbols);

  (* 确保函数数量正确 *)
  let function_count = SymbolTable.cardinal math_symbols in
  check int "数学函数数量" 3 function_count

(** ========== 字符串函数测试 ========== *)

(** 测试字符串函数的添加 *)
let test_add_string_functions () =
  let empty_symbols = SymbolTable.empty in
  let string_symbols = add_string_functions empty_symbols in

  (* 检查字符串长度函数 *)
  let length_entry = SymbolTable.find "字符串长度" string_symbols in
  check type_testable "字符串长度函数类型" (create_fun_type StringType_T IntType_T) length_entry.symbol_type;

  (* 检查字符串连接函数 *)
  let concat_entry = SymbolTable.find "字符串连接" string_symbols in
  let expected_concat_type =
    create_fun_type StringType_T (create_fun_type StringType_T StringType_T)
  in
  check type_testable "字符串连接函数类型" expected_concat_type concat_entry.symbol_type

(** 测试字符串函数完整性 *)
let test_string_functions_completeness () =
  let empty_symbols = SymbolTable.empty in
  let string_symbols = add_string_functions empty_symbols in

  (* 确保所有字符串函数都被添加 *)
  check bool "字符串长度函数存在" true (SymbolTable.mem "字符串长度" string_symbols);
  check bool "字符串连接函数存在" true (SymbolTable.mem "字符串连接" string_symbols);

  (* 确保函数数量正确 *)
  let function_count = SymbolTable.cardinal string_symbols in
  check int "字符串函数数量" 2 function_count

(** ========== 文件函数测试 ========== *)

(** 测试文件函数的添加 *)
let test_add_file_functions () =
  let empty_symbols = SymbolTable.empty in
  let file_symbols = add_file_functions empty_symbols in

  (* 检查读取文件函数 *)
  let read_entry = SymbolTable.find "读取文件" file_symbols in
  check type_testable "读取文件函数类型" (create_fun_type StringType_T StringType_T) read_entry.symbol_type;

  (* 检查写入文件函数 *)
  let write_entry = SymbolTable.find "写入文件" file_symbols in
  let expected_write_type =
    create_fun_type StringType_T (create_fun_type StringType_T UnitType_T)
  in
  check type_testable "写入文件函数类型" expected_write_type write_entry.symbol_type;

  (* 检查文件存在函数 *)
  let exists_entry = SymbolTable.find "文件存在" file_symbols in
  check type_testable "文件存在函数类型" (create_fun_type StringType_T BoolType_T) exists_entry.symbol_type

(** 测试文件函数完整性 *)
let test_file_functions_completeness () =
  let empty_symbols = SymbolTable.empty in
  let file_symbols = add_file_functions empty_symbols in

  (* 确保所有文件函数都被添加 *)
  check bool "读取文件函数存在" true (SymbolTable.mem "读取文件" file_symbols);
  check bool "写入文件函数存在" true (SymbolTable.mem "写入文件" file_symbols);
  check bool "文件存在函数存在" true (SymbolTable.mem "文件存在" file_symbols);

  (* 确保函数数量正确 *)
  let function_count = SymbolTable.cardinal file_symbols in
  check int "文件函数数量" 3 function_count

(** ========== 集成测试 ========== *)

(** 测试add_builtin_functions主函数 *)
let test_add_builtin_functions () =
  let initial_context = create_initial_context () in
  let enhanced_context = add_builtin_functions initial_context in

  (* 检查上下文结构 *)
  match enhanced_context.scope_stack with
  | [ builtin_scope; original_scope ] ->
      (* 检查内置函数数量 *)
      let builtin_count = SymbolTable.cardinal builtin_scope in
      check int "内置函数总数" 18 builtin_count;

      (* 2+5+3+3+2+3 = 18 *)

      (* 检查原始作用域保持不变 *)
      let original_count = SymbolTable.cardinal original_scope in
      check int "原始作用域保持空" 0 original_count
  | _ -> fail "作用域栈结构不正确"

(** 测试所有内置函数集成 *)
let test_all_builtin_functions_integration () =
  let initial_context = create_initial_context () in
  let enhanced_context = add_builtin_functions initial_context in

  (* 测试每个类别的代表性函数 *)
  check bool "I/O-打印函数可访问" true
    (check_builtin_function enhanced_context "打印"
       (create_fun_type (create_type_var "'a") UnitType_T));
  check bool "列表-长度函数可访问" true
    (check_builtin_function enhanced_context "长度"
       (create_fun_type (create_list_type (create_type_var "'a")) IntType_T));
  check bool "数组-数组长度函数可访问" true
    (check_builtin_function enhanced_context "数组长度"
       (create_fun_type (create_array_type (create_type_var "'a")) IntType_T));
  check bool "数学-绝对值函数可访问" true
    (check_builtin_function enhanced_context "绝对值" (create_fun_type IntType_T IntType_T));
  check bool "字符串-字符串长度函数可访问" true
    (check_builtin_function enhanced_context "字符串长度" (create_fun_type StringType_T IntType_T));
  check bool "文件-读取文件函数可访问" true
    (check_builtin_function enhanced_context "读取文件" (create_fun_type StringType_T StringType_T))

(** ========== 边界条件和错误处理测试 ========== *)

(** 测试空符号表处理 *)
let test_empty_symbol_table () =
  let empty_symbols = SymbolTable.empty in

  (* 测试每个函数组对空符号表的处理 *)
  let io_result = add_io_functions empty_symbols in
  check bool "空表添加I/O函数成功" true (SymbolTable.cardinal io_result > 0);

  let list_result = add_list_functions empty_symbols in
  check bool "空表添加列表函数成功" true (SymbolTable.cardinal list_result > 0);

  let array_result = add_array_functions empty_symbols in
  check bool "空表添加数组函数成功" true (SymbolTable.cardinal array_result > 0)

(** 测试函数组合顺序 *)
let test_function_composition_order () =
  let empty_symbols = SymbolTable.empty in

  (* 测试不同的组合顺序 *)
  let order1 = empty_symbols |> add_io_functions |> add_list_functions |> add_math_functions in
  let order2 = empty_symbols |> add_math_functions |> add_list_functions |> add_io_functions in

  (* 两种顺序应该产生相同的结果（函数数量相同） *)
  check int "不同组合顺序结果一致" (SymbolTable.cardinal order1) (SymbolTable.cardinal order2)

(** 测试上下文不变性 *)
let test_context_invariants () =
  let initial_context = create_initial_context () in
  let enhanced_context = add_builtin_functions initial_context in

  (* 检查原始上下文的其他字段保持不变 *)
  check (option type_testable) "函数返回类型不变" initial_context.current_function_return_type
    enhanced_context.current_function_return_type;
  check (list string) "错误列表不变" initial_context.error_list enhanced_context.error_list;
  check
    (list (pair string string))
    "宏列表不变"
    (List.map (fun (name, _) -> (name, "macro")) initial_context.macros)
    (List.map (fun (name, _) -> (name, "macro")) enhanced_context.macros)

(** ========== 测试套件定义 ========== *)

let io_function_tests =
  [
    ("I/O函数添加", `Quick, test_add_io_functions); ("I/O函数完整性", `Quick, test_io_functions_completeness);
  ]

let list_function_tests =
  [
    ("列表函数添加", `Quick, test_add_list_functions);
    ("列表高阶函数", `Quick, test_list_higher_order_functions);
    ("列表函数完整性", `Quick, test_list_functions_completeness);
  ]

let array_function_tests =
  [
    ("数组函数添加", `Quick, test_add_array_functions);
    ("数组函数完整性", `Quick, test_array_functions_completeness);
  ]

let math_function_tests =
  [
    ("数学函数添加", `Quick, test_add_math_functions);
    ("数学函数完整性", `Quick, test_math_functions_completeness);
  ]

let string_function_tests =
  [
    ("字符串函数添加", `Quick, test_add_string_functions);
    ("字符串函数完整性", `Quick, test_string_functions_completeness);
  ]

let file_function_tests =
  [
    ("文件函数添加", `Quick, test_add_file_functions);
    ("文件函数完整性", `Quick, test_file_functions_completeness);
  ]

let integration_tests =
  [
    ("内置函数主函数", `Quick, test_add_builtin_functions);
    ("所有内置函数集成", `Quick, test_all_builtin_functions_integration);
  ]

let boundary_tests =
  [
    ("空符号表处理", `Quick, test_empty_symbol_table);
    ("函数组合顺序", `Quick, test_function_composition_order);
    ("上下文不变性", `Quick, test_context_invariants);
  ]

let suite =
  [
    ("I/O函数测试", io_function_tests);
    ("列表函数测试", list_function_tests);
    ("数组函数测试", array_function_tests);
    ("数学函数测试", math_function_tests);
    ("字符串函数测试", string_function_tests);
    ("文件函数测试", file_function_tests);
    ("集成测试", integration_tests);
    ("边界条件测试", boundary_tests);
  ]

(** 运行测试的主函数 *)
let () = run "骆言语义分析内置函数comprehensive测试" suite
