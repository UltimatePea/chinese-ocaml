(** 骆言标准库前言

    生成注入到每个编译单元开头的 OCaml 代码，包含：
    1. 标准库模块（用 module Luo__hex = struct ... end 定义）
    2. 顶层绑定（全局可用的辅助函数）

    模块访问示例：
      用户写  「输出」之「行」 『你好』
      转换为  Luo__e8be93e587ba.luo__e8a18c "你好"
      前言有  module Luo__e8be93e587ba = struct
                let luo__e8a18c = print_endline
              end

    之（U+4E4B）是模块访问符，转换为 OCaml 的 .（点号）。
*)

(** 标准库模块定义：(中文模块名, [(中文函数名, OCaml表达式)]) *)
let stdlib_modules = [
  (* 输出模块：对应 OCaml 的 print_* 与 Printf *)
  ("输出", [
    ("行",    "print_endline");
    ("打印",  "print_string");
    ("整数",  "print_int");
    ("浮点",  "print_float");
    ("换行",  "print_newline");
    ("格式",  "Printf.printf");
    ("格式串","Printf.sprintf");
    ("读行",  "read_line");
  ]);
  (* 列表模块：对应 OCaml 的 List.* *)
  ("列表", [
    ("长度",  "List.length");
    ("映射",  "List.map");
    ("过滤",  "List.filter");
    ("左折",  "List.fold_left");
    ("右折",  "List.fold_right");
    ("反转",  "List.rev");
    ("拼接",  "List.append");
    ("遍历",  "List.iter");
    ("查找",  "List.find");
    ("排序",  "List.sort");
    ("头",    "List.hd");
    ("尾",    "List.tl");
    ("存在",  "List.exists");
    ("全部",  "List.for_all");
    ("组合",  "List.combine");
    ("展开",  "List.concat_map");
  ]);
  (* 数组模块：对应 OCaml 的 Array.* *)
  ("数组", [
    ("创建",  "Array.make");
    ("长度",  "Array.length");
    ("映射",  "Array.map");
    ("遍历",  "Array.iter");
    ("获取",  "Array.get");
    ("设置",  "Array.set");
    ("转列表","Array.to_list");
    ("从列表","Array.of_list");
  ]);
  (* 字符串模块：对应 OCaml 的 String.* *)
  ("字符串", [
    ("长度",  "String.length");
    ("连接",  "String.concat");
    ("截取",  "String.sub");
    ("比较",  "String.compare");
    ("大写",  "String.uppercase_ascii");
    ("小写",  "String.lowercase_ascii");
    ("包含",  "String.contains");
  ]);
]

(** 顶层绑定：全局可用，无需模块前缀 *)
let toplevel_bindings = [
  (* 比较与数学 *)
  ("最大",         "max");
  ("最小",         "min");
  ("绝对值",       "abs");
  ("比较",         "compare");
  (* 引用与副作用 *)
  ("引用",         "ref");
  ("忽略",         "ignore");
  (* 类型转换 *)
  ("整数转字符串", "string_of_int");
  ("浮点转字符串", "string_of_float");
  ("字符串转整数", "int_of_string");
  ("字符串转浮点", "float_of_string");
  ("字符转整数",   "Char.code");
  ("整数转字符",   "Char.chr");
]

let generate () =
  let buf = Buffer.create 4096 in
  Buffer.add_string buf "(* === 骆言标准库 === *)\n";
  (* 生成模块定义 *)
  List.iter (fun (mod_name, fns) ->
    Printf.bprintf buf "module %s = struct\n" (Trans.mangle_module mod_name);
    List.iter (fun (fn_name, ocaml_expr) ->
      Printf.bprintf buf "  let %s = %s\n" (Trans.mangle fn_name) ocaml_expr
    ) fns;
    Buffer.add_string buf "end\n"
  ) stdlib_modules;
  (* 生成顶层绑定 *)
  List.iter (fun (zh, en) ->
    Printf.bprintf buf "let %s = %s\n" (Trans.mangle zh) en
  ) toplevel_bindings;
  Buffer.add_string buf "(* === 用户代码 === *)\n\n";
  Buffer.contents buf
