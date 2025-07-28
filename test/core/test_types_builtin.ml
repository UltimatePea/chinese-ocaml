(** 骆言类型系统 - 内置函数类型环境模块测试 *)

open Alcotest
open Yyocamlc_lib.Core_types
open Yyocamlc_lib.Types_builtin

(** 辅助函数：检查内置函数类型 *)
let check_builtin_function_type name expected_type description =
  match get_builtin_type name with
  | Some (TypeScheme (_, actual_type)) ->
      check (testable pp_typ equal_typ) description expected_type actual_type
  | None -> fail (Printf.sprintf "函数 '%s' 在内置环境中未找到" name)

(** 辅助函数：检查内置函数是否存在 *)
let check_builtin_exists name description = check bool description true (is_builtin_function name)

(** 测试基础IO函数类型定义 *)
let test_basic_io_functions () =
  (* 测试打印函数类型 *)
  check_builtin_function_type "打印" (FunType_T (StringType_T, UnitType_T)) "打印函数应接受字符串参数并返回单位类型";

  (* 测试读取函数类型 *)
  check_builtin_function_type "读取" (FunType_T (UnitType_T, StringType_T)) "读取函数应接受单位类型参数并返回字符串"

(** 测试列表函数类型定义 *)
let test_list_functions () =
  (* 测试长度函数 - 泛型列表到整数 *)
  check_builtin_function_type "长度"
    (FunType_T (ListType_T (TypeVar_T "'a"), IntType_T))
    "长度函数应接受泛型列表并返回整数";

  (* 测试连接函数 - 两个相同类型列表连接 *)
  check_builtin_function_type "连接"
    (FunType_T
       ( ListType_T (TypeVar_T "'a"),
         FunType_T (ListType_T (TypeVar_T "'a"), ListType_T (TypeVar_T "'a")) ))
    "连接函数应接受两个相同类型的列表并返回同类型列表";

  (* 测试过滤函数 - 谓词函数和列表 *)
  check_builtin_function_type "过滤"
    (FunType_T
       ( FunType_T (TypeVar_T "'a", BoolType_T),
         FunType_T (ListType_T (TypeVar_T "'a"), ListType_T (TypeVar_T "'a")) ))
    "过滤函数应接受谓词函数和列表，返回过滤后的列表";

  (* 测试映射函数 - 转换函数和列表 *)
  check_builtin_function_type "映射"
    (FunType_T
       ( FunType_T (TypeVar_T "'a", TypeVar_T "'b"),
         FunType_T (ListType_T (TypeVar_T "'a"), ListType_T (TypeVar_T "'b")) ))
    "映射函数应接受转换函数和列表，返回转换后的列表"

(** 测试数学函数类型定义 *)
let test_math_functions () =
  (* 测试基础数学函数 *)
  check_builtin_function_type "求和" (FunType_T (ListType_T IntType_T, IntType_T)) "求和函数应接受整数列表并返回整数";

  check_builtin_function_type "最大值"
    (FunType_T (ListType_T IntType_T, IntType_T))
    "最大值函数应接受整数列表并返回整数";

  check_builtin_function_type "绝对值" (FunType_T (IntType_T, IntType_T)) "绝对值函数应接受整数并返回整数";

  (* 测试浮点数数学函数 *)
  check_builtin_function_type "平均值"
    (FunType_T (ListType_T IntType_T, FloatType_T))
    "平均值函数应接受整数列表并返回浮点数";

  check_builtin_function_type "幂运算"
    (FunType_T (FloatType_T, FunType_T (FloatType_T, FloatType_T)))
    "幂运算函数应接受两个浮点数参数并返回浮点数";

  check_builtin_function_type "正弦" (FunType_T (FloatType_T, FloatType_T)) "正弦函数应接受浮点数并返回浮点数"

(** 测试扩展数学函数类型定义 *)
let test_extended_math_functions () =
  (* 测试对数函数 *)
  check_builtin_function_type "对数" (FunType_T (FloatType_T, FloatType_T)) "对数函数应接受浮点数并返回浮点数";

  check_builtin_function_type "自然对数" (FunType_T (FloatType_T, FloatType_T)) "自然对数函数应接受浮点数并返回浮点数";

  (* 测试三角函数 *)
  check_builtin_function_type "正切" (FunType_T (FloatType_T, FloatType_T)) "正切函数应接受浮点数并返回浮点数";

  check_builtin_function_type "反正弦" (FunType_T (FloatType_T, FloatType_T)) "反正弦函数应接受浮点数并返回浮点数";

  (* 测试取整函数 *)
  check_builtin_function_type "向上取整" (FunType_T (FloatType_T, IntType_T)) "向上取整函数应接受浮点数并返回整数";

  (* 测试整数运算函数 *)
  check_builtin_function_type "最大公约数"
    (FunType_T (IntType_T, FunType_T (IntType_T, IntType_T)))
    "最大公约数函数应接受两个整数并返回整数"

(** 测试数组函数类型定义 *)
let test_array_functions () =
  (* 测试创建数组函数 *)
  check_builtin_function_type "创建数组"
    (FunType_T (IntType_T, FunType_T (TypeVar_T "'a", ArrayType_T (TypeVar_T "'a"))))
    "创建数组函数应接受长度和初始值，返回相应类型的数组";

  check_builtin_function_type "数组长度"
    (FunType_T (ArrayType_T (TypeVar_T "'a"), IntType_T))
    "数组长度函数应接受任意类型数组并返回整数";

  check_builtin_function_type "复制数组"
    (FunType_T (ArrayType_T (TypeVar_T "'a"), ArrayType_T (TypeVar_T "'a")))
    "复制数组函数应接受数组并返回相同类型的数组"

(** 测试引用函数类型定义 *)
let test_reference_functions () =
  check_builtin_function_type "引用"
    (FunType_T (TypeVar_T "'a", RefType_T (TypeVar_T "'a")))
    "引用函数应接受任意类型值并返回该类型的引用"

(** 测试字符串函数类型定义 *)
let test_string_functions () =
  (* 测试字符串长度函数 *)
  check_builtin_function_type "字符串长度" (FunType_T (StringType_T, IntType_T)) "字符串长度函数应接受字符串并返回整数";

  (* 测试字符串连接函数 *)
  check_builtin_function_type "字符串连接"
    (FunType_T (StringType_T, FunType_T (StringType_T, StringType_T)))
    "字符串连接函数应接受两个字符串并返回字符串"

(** 测试内置函数环境构建 *)
let test_builtin_env_construction () =
  (* 测试主要函数类别存在 *)
  check_builtin_exists "打印" "打印函数应在内置环境中存在";
  check_builtin_exists "长度" "长度函数应在内置环境中存在";
  check_builtin_exists "求和" "求和函数应在内置环境中存在";
  check_builtin_exists "创建数组" "创建数组函数应在内置环境中存在";
  check_builtin_exists "引用" "引用函数应在内置环境中存在"

(** 测试内置函数查询功能 *)
let test_builtin_function_queries () =
  (* 测试获取内置函数类型 *)
  (match get_builtin_type "打印" with
  | Some (TypeScheme ([], actual_type)) ->
      check (testable pp_typ equal_typ) "获取打印函数类型"
        (FunType_T (StringType_T, UnitType_T))
        actual_type
  | Some _ -> fail "打印函数类型 scheme 不正确"
  | None -> fail "无法获取打印函数类型");

  (* 测试不存在的函数 *)
  check bool "不存在的函数应返回None" true (get_builtin_type "不存在的函数" = None);

  (* 测试获取内置函数列表 *)
  let function_list = get_builtin_functions () in
  check bool "内置函数列表不应为空" false (function_list = []);
  check bool "内置函数列表应包含打印函数" true (List.mem "打印" function_list)

(** 测试数学函数类别查询 *)
let test_math_functions_category () =
  let math_functions = get_math_functions () in
  check bool "数学函数列表应包含求和" true (List.mem "求和" math_functions);
  check bool "数学函数列表应包含最大值" true (List.mem "最大值" math_functions);
  check bool "数学函数列表应包含正弦" true (List.mem "正弦" math_functions);
  check bool "数学函数列表应包含对数" true (List.mem "对数" math_functions)

(** 测试列表函数类别查询 *)
let test_list_functions_category () =
  let list_functions = get_list_functions () in
  check bool "列表函数列表应包含长度" true (List.mem "长度" list_functions);
  check bool "列表函数列表应包含连接" true (List.mem "连接" list_functions);
  check bool "列表函数列表应包含过滤" true (List.mem "过滤" list_functions);
  check bool "列表函数列表应包含映射" true (List.mem "映射" list_functions)

(** 测试IO函数类别查询 *)
let test_io_functions_category () =
  let io_functions = get_io_functions () in
  check bool "IO函数列表应包含打印" true (List.mem "打印" io_functions);
  check bool "IO函数列表应包含读取" true (List.mem "读取" io_functions)

(** 测试字符串函数类别查询 *)
let test_string_functions_category () =
  let string_functions = get_string_functions () in
  check bool "字符串函数列表应包含字符串长度" true (List.mem "字符串长度" string_functions);
  check bool "字符串函数列表应包含字符串连接" true (List.mem "字符串连接" string_functions)

(** 测试数组函数类别查询 *)
let test_array_functions_category () =
  let array_functions = get_array_functions () in
  check bool "数组函数列表应包含创建数组" true (List.mem "创建数组" array_functions);
  check bool "数组函数列表应包含数组长度" true (List.mem "数组长度" array_functions);
  check bool "数组函数列表应包含复制数组" true (List.mem "复制数组" array_functions)

(** 测试类型转换函数类别查询 *)
let test_conversion_functions_category () =
  let conversion_functions = get_conversion_functions () in
  check bool "转换函数列表应包含整数到字符串" true (List.mem "整数到字符串" conversion_functions);
  check bool "转换函数列表应包含字符串到整数" true (List.mem "字符串到整数" conversion_functions)

(** 测试中文函数名支持完整性 *)
let test_chinese_function_name_support () =
  (* 验证所有内置函数都使用中文名称 *)
  let all_functions = get_builtin_functions () in

  (* 检查没有英文函数名 *)
  check bool "不应存在英文函数名'print'" false (List.mem "print" all_functions);
  check bool "不应存在英文函数名'length'" false (List.mem "length" all_functions);
  check bool "不应存在英文函数名'map'" false (List.mem "map" all_functions);

  (* 检查中文函数名存在 *)
  check bool "应存在中文函数名'求和'" true (List.mem "求和" all_functions);
  check bool "应存在中文函数名'平方根'" true (List.mem "平方根" all_functions);
  check bool "应存在中文函数名'字符串长度'" true (List.mem "字符串长度" all_functions)

(** 测试类型环境完整性 *)
let test_type_environment_completeness () =
  (* 验证所有类别的函数都在主环境中 *)
  let all_functions = get_builtin_functions () in
  let math_functions = get_math_functions () in
  let list_functions = get_list_functions () in
  let io_functions = get_io_functions () in

  (* 验证数学函数在主环境中 *)
  List.iter
    (fun func ->
      check bool (Printf.sprintf "数学函数'%s'应在主环境中" func) true (List.mem func all_functions))
    math_functions;

  (* 验证列表函数在主环境中 *)
  List.iter
    (fun func ->
      check bool (Printf.sprintf "列表函数'%s'应在主环境中" func) true (List.mem func all_functions))
    list_functions;

  (* 验证IO函数在主环境中 *)
  List.iter
    (fun func ->
      check bool (Printf.sprintf "IO函数'%s'应在主环境中" func) true (List.mem func all_functions))
    io_functions

(** 主测试套件 *)
let () =
  run "Types_builtin模块测试"
    [
      ("基础IO函数类型", [ test_case "基础IO函数类型定义" `Quick test_basic_io_functions ]);
      ("列表函数类型", [ test_case "列表函数类型定义" `Quick test_list_functions ]);
      ( "数学函数类型",
        [
          test_case "基础数学函数类型定义" `Quick test_math_functions;
          test_case "扩展数学函数类型定义" `Quick test_extended_math_functions;
        ] );
      ( "数组和引用函数类型",
        [
          test_case "数组函数类型定义" `Quick test_array_functions;
          test_case "引用函数类型定义" `Quick test_reference_functions;
        ] );
      ("字符串函数类型", [ test_case "字符串函数类型定义" `Quick test_string_functions ]);
      ( "内置环境构建",
        [
          test_case "内置函数环境构建" `Quick test_builtin_env_construction;
          test_case "内置函数查询功能" `Quick test_builtin_function_queries;
        ] );
      ( "函数类别查询",
        [
          test_case "数学函数类别查询" `Quick test_math_functions_category;
          test_case "列表函数类别查询" `Quick test_list_functions_category;
          test_case "IO函数类别查询" `Quick test_io_functions_category;
          test_case "字符串函数类别查询" `Quick test_string_functions_category;
          test_case "数组函数类别查询" `Quick test_array_functions_category;
          test_case "类型转换函数类别查询" `Quick test_conversion_functions_category;
        ] );
      ("中文函数名支持", [ test_case "中文函数名支持完整性" `Quick test_chinese_function_name_support ]);
      ("类型环境完整性", [ test_case "类型环境完整性验证" `Quick test_type_environment_completeness ]);
    ]
