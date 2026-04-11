(** 骆言编译器入口 — 中文OCaml语言 *)

let usage =
  {|骆言 — 中文OCaml语言

用法：
  luo <文件.ly>             转换并用 ocaml 运行
  luo --print <文件.ly>     显示生成的OCaml代码（不运行）
  luo --ast <文件.ly>       显示词法Token序列（AST转储）
  luo --compile <文件.ly>   用 ocamlopt 编译为本地可执行文件

示例：
  luo 你好.ly
  luo --print 斐波那契.ly
  luo --ast 斐波那契.ly
  luo --compile 程序.ly
|}

let read_file path =
  let ic = open_in_bin path in
  let n  = in_channel_length ic in
  let s  = Bytes.create n in
  really_input ic s 0 n;
  close_in ic;
  Bytes.to_string s

let write_temp content =
  let path = Filename.temp_file "luoyan_" ".ml" in
  let oc = open_out path in
  output_string oc content;
  close_out oc;
  path

let () =
  let argv = Sys.argv in
  let argc = Array.length argv in
  if argc < 2 then (print_string usage; exit 0);

  let mode, filename =
    match argv.(1) with
    | "--print"   when argc >= 3 -> `Print,   argv.(2)
    | "--ast"     when argc >= 3 -> `Ast,     argv.(2)
    | "--compile" when argc >= 3 -> `Compile, argv.(2)
    | "--help" | "-h"            -> print_string usage; exit 0
    | f                          -> `Run,     f
  in

  let src =
    try read_file filename
    with Sys_error msg ->
      Printf.eprintf "错误：无法读取文件 %s\n%s\n" filename msg;
      exit 1
  in

  let basedir = Filename.dirname filename in
  let ocaml_src = Luoyan_lib.Prelude.generate ()
                  ^ Luoyan_lib.Trans.transpile ~basedir src in

  match mode with
  | `Ast ->
    let tokens = Luoyan_lib.Trans.tokenize ~basedir src in
    print_string (Luoyan_lib.Trans.print_tokens tokens)

  | `Print ->
    print_string ocaml_src

  | `Run ->
    let tmp = write_temp ocaml_src in
    let ret = Sys.command (Printf.sprintf "ocaml %s" (Filename.quote tmp)) in
    (try Sys.remove tmp with Sys_error _ -> ());
    exit ret

  | `Compile ->
    let out_name = Filename.chop_extension filename in
    let tmp = write_temp ocaml_src in
    let ret = Sys.command (Printf.sprintf "ocamlopt -o %s %s"
                             (Filename.quote out_name)
                             (Filename.quote tmp)) in
    (try Sys.remove tmp with Sys_error _ -> ());
    exit ret
