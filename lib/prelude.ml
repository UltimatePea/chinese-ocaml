(** 骆言标准库前言

    将中文名称的 luo__hex 标识符绑定到对应的 OCaml 函数。
    此模块由转换器在编译时自动前置，用户无需手动引入。

    用法示例：
      用户写  「打印行」 『你好』
      转换为  luo__e68993e58db0e8a18c "你好"
      前言有  let luo__e68993e58db0e8a18c = print_endline
*)

(** 中文名称 → OCaml 表达式的绑定表 *)
let bindings = [
  (* ── 输入输出 ── *)
  "打印",         "print_string";
  "打印行",       "print_endline";
  "打印整数",     "print_int";
  "打印浮点",     "print_float";
  "打印换行",     "print_newline";
  "格式化输出",   "Printf.printf";
  "格式化字符串", "Printf.sprintf";
  "读行",         "read_line";
  (* ── 类型转换 ── *)
  "整数转字符串", "string_of_int";
  "浮点转字符串", "string_of_float";
  "字符串转整数", "int_of_string";
  "字符串转浮点", "float_of_string";
  (* ── 字符串操作 ── *)
  "字符串长度", "String.length";
  "字符串拼接", "String.concat";
  "字符串截取", "String.sub";
  (* ── 列表操作 ── *)
  "列表长度", "List.length";
  "列表映射", "List.map";
  "列表过滤", "List.filter";
  "左折叠",   "List.fold_left";
  "右折叠",   "List.fold_right";
  "列表反转", "List.rev";
  "列表拼接", "List.append";
  "列表迭代", "List.iter";
  "列表查找", "List.find";
  "列表排序", "List.sort";
  (* ── 数组操作 ── *)
  "数组创建", "Array.make";
  "数组长度", "Array.length";
  "数组映射", "Array.map";
  "数组迭代", "Array.iter";
  (* ── 数学与比较 ── *)
  "最大值", "max";
  "最小值", "min";
  "绝对值", "abs";
  "比较",   "compare";
  (* ── 杂项 ── *)
  "引用",   "ref";
  "忽略",   "ignore";
]

let generate () =
  let buf = Buffer.create 2048 in
  Buffer.add_string buf "(* === 骆言标准库 === *)\n";
  List.iter (fun (zh, en) ->
    Printf.bprintf buf "let %s = %s\n" (Trans.mangle zh) en
  ) bindings;
  Buffer.add_string buf "(* === 用户代码 === *)\n\n";
  Buffer.contents buf
