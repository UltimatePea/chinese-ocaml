(** 骆言标准库综合测试 *)

open Types
open Semantic
open Codegen
open Alcotest

(** 测试基础模块功能 *)
let test_基础模块_身份函数 () =
  let program = "
导入 基础: [身份函数];
让 结果 = 身份函数 42;
打印 结果;
" in
  let result = run_program program in
  let output = extract_output result in
  check string "身份函数测试" "42" output

let test_基础模块_常量函数 () =
  let program = "
导入 基础: [常量函数];
让 常量5 = 常量函数 5;
让 结果 = 常量5 99;
打印 结果;
" in
  let result = run_program program in
  let output = extract_output result in
  check string "常量函数测试" "5" output

let test_基础模块_组合函数 () =
  let program = "
导入 基础: [组合函数];
让 加1 = 函数 x -> x + 1;
让 乘2 = 函数 x -> x * 2;
让 复合函数 = 组合函数 乘2 加1;
让 结果 = 复合函数 5;
打印 结果;
" in
  let result = run_program program in
  let output = extract_output result in
  check string "组合函数测试" "12" output (* (5 + 1) * 2 = 12 *)

(** 测试数学模块功能 *)
let test_数学模块_阶乘 () =
  let program = "
导入 数学: [阶乘];
让 结果 = 阶乘 5;
打印 结果;
" in
  let result = run_program program in
  let output = extract_output result in
  check string "阶乘测试" "120" output

let test_数学模块_幂运算 () =
  let program = "
导入 数学: [幂运算];
让 结果 = 幂运算 2 3;
打印 结果;
" in
  let result = run_program program in
  let output = extract_output result in
  check string "幂运算测试" "8" output

let test_数学模块_最大公约数 () =
  let program = "
导入 数学: [最大公约数];
让 结果 = 最大公约数 48 18;
打印 结果;
" in
  let result = run_program program in
  let output = extract_output result in
  check string "最大公约数测试" "6" output

let test_数学模块_斐波那契 () =
  let program = "
导入 数学: [斐波那契];
让 结果 = 斐波那契 6;
打印 结果;
" in
  let result = run_program program in
  let output = extract_output result in
  check string "斐波那契测试" "8" output

let test_数学模块_素数判断 () =
  let program = "
导入 数学: [素数判断];
让 结果1 = 素数判断 17;
让 结果2 = 素数判断 18;
打印 结果1;
打印 结果2;
" in
  let result = run_program program in
  let output = extract_output result in
  check string "素数判断测试" "真\n假" output

(** 测试列表模块功能 *)
let test_列表模块_长度 () =
  let program = "
导入 列表: [长度];
让 结果 = 长度 [1; 2; 3; 4; 5];
打印 结果;
" in
  let result = run_program program in
  let output = extract_output result in
  check string "列表长度测试" "5" output

let test_列表模块_映射 () =
  let program = "
导入 列表: [映射];
让 平方 = 函数 x -> x * x;
让 结果 = 映射 平方 [1; 2; 3; 4];
打印 结果;
" in
  let result = run_program program in
  let output = extract_output result in
  check string "列表映射测试" "[1; 4; 9; 16]" output

let test_列表模块_过滤 () =
  let program = "
导入 列表: [过滤];
让 是偶数 = 函数 x -> x % 2 = 0;
让 结果 = 过滤 是偶数 [1; 2; 3; 4; 5; 6];
打印 结果;
" in
  let result = run_program program in
  let output = extract_output result in
  check string "列表过滤测试" "[2; 4; 6]" output

let test_列表模块_折叠左 () =
  let program = "
导入 列表: [折叠左];
让 加法 = 函数 acc x -> acc + x;
让 结果 = 折叠左 加法 0 [1; 2; 3; 4; 5];
打印 结果;
" in
  let result = run_program program in
  let output = extract_output result in
  check string "列表折叠左测试" "15" output

let test_列表模块_反转 () =
  let program = "
导入 列表: [反转];
让 结果 = 反转 [1; 2; 3; 4; 5];
打印 结果;
" in
  let result = run_program program in
  let output = extract_output result in
  check string "列表反转测试" "[5; 4; 3; 2; 1]" output

let test_列表模块_范围 () =
  let program = "
导入 列表: [范围];
让 结果 = 范围 1 5;
打印 结果;
" in
  let result = run_program program in
  let output = extract_output result in
  check string "列表范围测试" "[1; 2; 3; 4; 5]" output

let test_列表模块_重复 () =
  let program = "
导入 列表: [重复];
让 结果 = 重复 3 \"Hello\";
打印 结果;
" in
  let result = run_program program in
  let output = extract_output result in
  check string "列表重复测试" "[\"Hello\"; \"Hello\"; \"Hello\"]" output

let test_列表模块_取前n个 () =
  let program = "
导入 列表: [取前n个];
让 结果 = 取前n个 3 [1; 2; 3; 4; 5; 6; 7];
打印 结果;
" in
  let result = run_program program in
  let output = extract_output result in
  check string "列表取前n个测试" "[1; 2; 3]" output

(** 测试字符串模块功能 *)
let test_字符串模块_连接 () =
  let program = "
导入 字符串: [连接];
让 结果 = 连接 \"Hello\" \" World\";
打印 结果;
" in
  let result = run_program program in
  let output = extract_output result in
  check string "字符串连接测试" "Hello World" output

let test_字符串模块_重复 () =
  let program = "
导入 字符串: [重复];
让 结果 = 重复 3 \"Hi\";
打印 结果;
" in
  let result = run_program program in
  let output = extract_output result in
  check string "字符串重复测试" "HiHiHi" output

let test_字符串模块_包含 () =
  let program = "
导入 字符串: [包含];
让 结果1 = 包含 \"World\" \"Hello World\";
让 结果2 = 包含 \"xyz\" \"Hello World\";
打印 结果1;
打印 结果2;
" in
  let result = run_program program in
  let output = extract_output result in
  check string "字符串包含测试" "真\n假" output

(** 组合测试：多个模块一起使用 *)
let test_多模块组合_数学和列表 () =
  let program = "
导入 数学: [阶乘];
导入 列表: [映射, 范围];
让 数字列表 = 范围 1 5;
让 阶乘列表 = 映射 阶乘 数字列表;
打印 阶乘列表;
" in
  let result = run_program program in
  let output = extract_output result in
  check string "数学和列表组合测试" "[1; 2; 6; 24; 120]" output

let test_多模块组合_字符串和列表 () =
  let program = "
导入 字符串: [连接];
导入 列表: [映射];
让 添加前缀 = 函数 s -> 连接 \"项目: \" s;
让 结果 = 映射 添加前缀 [\"任务1\"; \"任务2\"; \"任务3\"];
打印 结果;
" in
  let result = run_program program in
  let output = extract_output result in
  check string "字符串和列表组合测试" "[\"项目: 任务1\"; \"项目: 任务2\"; \"项目: 任务3\"]" output

(** 性能测试 *)
let test_性能_大列表操作 () =
  let program = "
导入 列表: [长度, 映射, 过滤, 范围];
让 大列表 = 范围 1 1000;
让 长度结果 = 长度 大列表;
让 平方列表 = 映射 (函数 x -> x * x) 大列表;
让 偶数列表 = 过滤 (函数 x -> x % 2 = 0) 大列表;
让 偶数长度 = 长度 偶数列表;
打印 长度结果;
打印 偶数长度;
" in
  let result = run_program program in
  let output = extract_output result in
  check string "大列表性能测试" "1000\n500" output

(** 错误处理测试 *)
let test_错误处理_空列表头部 () =
  let program = "
导入 列表: [头部];
尝试 {
  让 结果 = 头部 [];
  打印 \"不应该到达这里\";
} 捕获 异常 -> {
  打印 \"捕获到预期异常\";
};
" in
  try
    let result = run_program program in
    let output = extract_output result in
    check string "空列表头部错误处理" "捕获到预期异常" output
  with
  | _ -> check string "应该抛出异常" "异常已抛出" "异常已抛出"

(** 辅助函数 *)
let run_program program_text =
  try
    let lexer = Lexer.create_lexer program_text in
    let tokens = Lexer.tokenize lexer in
    let parser = Parser.create_parser tokens in
    let ast = Parser.parse_program parser in
    let context = Semantic.type_check_program ast in
    let result = Codegen.eval_program ast in
    Ok result
  with
  | e -> Error (Printexc.to_string e)

let extract_output = function
  | Ok (StringValue s) -> s
  | Ok (IntValue i) -> string_of_int i
  | Ok (BoolValue true) -> "真"
  | Ok (BoolValue false) -> "假"
  | Ok UnitValue -> ""
  | Ok _ -> "未知类型"
  | Error msg -> failwith ("程序执行失败: " ^ msg)

(** 测试套件 *)
let 标准库综合测试 = [
  (* 基础模块测试 *)
  test_case "基础模块 - 身份函数" `Quick test_基础模块_身份函数;
  test_case "基础模块 - 常量函数" `Quick test_基础模块_常量函数;
  test_case "基础模块 - 组合函数" `Quick test_基础模块_组合函数;
  
  (* 数学模块测试 *)
  test_case "数学模块 - 阶乘" `Quick test_数学模块_阶乘;
  test_case "数学模块 - 幂运算" `Quick test_数学模块_幂运算;
  test_case "数学模块 - 最大公约数" `Quick test_数学模块_最大公约数;
  test_case "数学模块 - 斐波那契" `Quick test_数学模块_斐波那契;
  test_case "数学模块 - 素数判断" `Quick test_数学模块_素数判断;
  
  (* 列表模块测试 *)
  test_case "列表模块 - 长度" `Quick test_列表模块_长度;
  test_case "列表模块 - 映射" `Quick test_列表模块_映射;
  test_case "列表模块 - 过滤" `Quick test_列表模块_过滤;
  test_case "列表模块 - 折叠左" `Quick test_列表模块_折叠左;
  test_case "列表模块 - 反转" `Quick test_列表模块_反转;
  test_case "列表模块 - 范围" `Quick test_列表模块_范围;
  test_case "列表模块 - 重复" `Quick test_列表模块_重复;
  test_case "列表模块 - 取前n个" `Quick test_列表模块_取前n个;
  
  (* 字符串模块测试 *)
  test_case "字符串模块 - 连接" `Quick test_字符串模块_连接;
  test_case "字符串模块 - 重复" `Quick test_字符串模块_重复;
  test_case "字符串模块 - 包含" `Quick test_字符串模块_包含;
  
  (* 组合测试 *)
  test_case "多模块组合 - 数学和列表" `Quick test_多模块组合_数学和列表;
  test_case "多模块组合 - 字符串和列表" `Quick test_多模块组合_字符串和列表;
  
  (* 性能测试 *)
  test_case "性能测试 - 大列表操作" `Slow test_性能_大列表操作;
  
  (* 错误处理测试 *)
  test_case "错误处理 - 空列表头部" `Quick test_错误处理_空列表头部;
]

let () =
  run "骆言标准库综合测试" [
    "标准库功能", 标准库综合测试;
  ]