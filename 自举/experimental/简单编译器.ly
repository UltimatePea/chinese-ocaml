(* 骆言自举编译器 - 最简化版本 *)

让 生成C代码 = 函数 程序名 ->
  字符串连接 "#include <stdio.h>\nint main() {\n    printf(\"你好，骆言编译器！\\n\");\n    return 0;\n}\n" ""

让 编译结果 = 生成C代码 "hello"
打印 编译结果