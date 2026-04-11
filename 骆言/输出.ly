「：骆言标准库 — 输出模块

    提供终端输入输出函数。
    用法：引入 『骆言/输出.ly』
    访问：「输出」之「行」，「输出」之「格式」，等：」

模块 「输出」 ＝ 结构
  让 「行」    ＝ 《print_endline》
  让 「打印」  ＝ 《print_string》
  让 「整数」  ＝ 《print_int》
  让 「浮点」  ＝ 《print_float》
  让 「换行」  ＝ 《print_newline》
  让 「格式」  ＝ 《Printf.printf》
  让 「格式串」＝ 《Printf.sprintf》
  让 「读行」  ＝ 《read_line》
结束
