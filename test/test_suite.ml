(** 骆言测试套件

    对每个示例文件：
      1. 运行 transpile → 生成 OCaml 代码         比对 *.ml
      2. 运行 tokenize  → 生成 Token 序列（AST）    比对 *.ast
      3. 实际运行程序   → 捕获 stdout              比对 *.out

    更新黄金文件：设置环境变量 UPDATE_GOLDEN=1 后运行。
*)

let project_root =
  let rec find dir =
    if Sys.file_exists (Filename.concat dir "dune-project") then dir
    else
      let parent = Filename.dirname dir in
      if parent = dir then Sys.getcwd ()
      else find parent
  in
  find (Sys.getcwd ())

let read_file path =
  let ic = open_in_bin path in
  let n  = in_channel_length ic in
  let s  = Bytes.create n in
  really_input ic s 0 n;
  close_in ic;
  Bytes.to_string s

let write_file path content =
  let oc = open_out path in
  output_string oc content;
  close_out oc

(** 将 OCaml 源码写入临时文件，用 ocaml 运行，返回 stdout 内容。
    运行失败时返回错误信息（带前缀 ERROR:）。 *)
let run_ocaml_src ocaml_src =
  let tmp_ml  = Filename.temp_file "luoyan_test_" ".ml"  in
  let tmp_out = Filename.temp_file "luoyan_out_"  ".txt" in
  write_file tmp_ml ocaml_src;
  let cmd = Printf.sprintf "ocaml %s > %s 2>&1"
              (Filename.quote tmp_ml) (Filename.quote tmp_out) in
  let exit_code = Sys.command cmd in
  let output = read_file tmp_out in
  (try Sys.remove tmp_ml  with Sys_error _ -> ());
  (try Sys.remove tmp_out with Sys_error _ -> ());
  if exit_code = 0 then output
  else "ERROR:\n" ^ output

(** 逐行对比，返回差异描述（无差异时返回 None） *)
let diff_strings ~expected ~actual =
  let exp_lines = String.split_on_char '\n' expected in
  let act_lines = String.split_on_char '\n' actual   in
  let diffs = ref [] in
  let max_len = max (List.length exp_lines) (List.length act_lines) in
  for i = 0 to max_len - 1 do
    let get lst = if i < List.length lst then List.nth lst i else "<缺失>" in
    let e = get exp_lines and a = get act_lines in
    if e <> a then
      diffs := Printf.sprintf "  第%d行\n    预期: %s\n    实际: %s" (i+1) e a :: !diffs
  done;
  if !diffs = [] then None
  else Some (String.concat "\n" (List.rev !diffs))

type test_case = {
  name     : string;
  ly_path  : string;
  ml_gold  : string;
  ast_gold : string;
  out_gold : string;
}

let examples = [
  { name = "你好";     ly_path = "示例/你好.ly";
    ml_gold = "示例/你好.ml";     ast_gold = "示例/你好.ast";     out_gold = "示例/你好.out" };
  { name = "斐波那契"; ly_path = "示例/斐波那契.ly";
    ml_gold = "示例/斐波那契.ml"; ast_gold = "示例/斐波那契.ast"; out_gold = "示例/斐波那契.out" };
  { name = "列表";     ly_path = "示例/列表.ly";
    ml_gold = "示例/列表.ml";     ast_gold = "示例/列表.ast";     out_gold = "示例/列表.out" };
  { name = "模式匹配"; ly_path = "示例/模式匹配.ly";
    ml_gold = "示例/模式匹配.ml"; ast_gold = "示例/模式匹配.ast"; out_gold = "示例/模式匹配.out" };
]

let run_tests update_golden =
  let passed = ref 0 and failed = ref 0 in

  List.iter (fun tc ->
    let ly_abs  = Filename.concat project_root tc.ly_path in
    let src     = read_file ly_abs in
    let basedir = Filename.dirname ly_abs in

    let ml_actual =
      Luoyan_lib.Prelude.generate ()
      ^ Luoyan_lib.Trans.transpile ~basedir src
    in
    let ast_actual =
      Luoyan_lib.Trans.print_tokens (Luoyan_lib.Trans.tokenize src)
    in
    let out_actual = run_ocaml_src ml_actual in

    let abs p = Filename.concat project_root p in

    if update_golden then begin
      write_file (abs tc.ml_gold)  ml_actual;
      write_file (abs tc.ast_gold) ast_actual;
      write_file (abs tc.out_gold) out_actual;
      Printf.printf "更新黄金文件：%s  %s  %s\n" tc.ml_gold tc.ast_gold tc.out_gold
    end else begin
      let check label gold_path actual =
        if Sys.file_exists gold_path then begin
          let expected = read_file gold_path in
          match diff_strings ~expected ~actual with
          | None ->
            Printf.printf "  [通过] %s (%s)\n" tc.name label;
            incr passed
          | Some diff ->
            Printf.printf "  [失败] %s (%s)\n%s\n" tc.name label diff;
            incr failed
        end else begin
          Printf.printf "  [缺失] 黄金文件不存在：%s（运行 UPDATE_GOLDEN=1 生成）\n" gold_path;
          incr failed
        end
      in
      check ".ml"  (abs tc.ml_gold)  ml_actual;
      check ".ast" (abs tc.ast_gold) ast_actual;
      check ".out" (abs tc.out_gold) out_actual
    end
  ) examples;

  if not update_golden then begin
    Printf.printf "\n结果：%d 通过，%d 失败\n" !passed !failed;
    if !failed > 0 then exit 1
  end

let () =
  let update_golden =
    match Sys.getenv_opt "UPDATE_GOLDEN" with
    | Some "1" -> true
    | _ -> false
  in
  Printf.printf "=== 骆言测试套件 ===\n";
  run_tests update_golden
