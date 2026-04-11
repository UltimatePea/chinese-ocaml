(** 骆言测试套件

    对每个示例文件：
      1. 运行 transpile → 生成 OCaml 代码
      2. 运行 tokenize  → 生成 Token 序列（AST转储）
      3. 与 示例/<名称>.ml 和 示例/<名称>.ast 中的黄金文件比对
      4. 不一致时打印差异并以非零退出码退出

    更新黄金文件：设置环境变量 UPDATE_GOLDEN=1 后运行。
*)

let project_root =
  (* 向上查找含有 dune-project 的目录，即为项目根目录 *)
  let rec find dir =
    if Sys.file_exists (Filename.concat dir "dune-project") then dir
    else
      let parent = Filename.dirname dir in
      if parent = dir then Sys.getcwd ()  (* 兜底：使用当前目录 *)
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

(** 将两个字符串逐行对比，返回差异描述（无差异时返回 None） *)
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

(** 单个测试案例记录 *)
type test_case = {
  name     : string;
  ly_path  : string;
  ml_gold  : string;
  ast_gold : string;
}

let examples = [
  { name = "你好";     ly_path = "示例/你好.ly";     ml_gold = "示例/你好.ml";     ast_gold = "示例/你好.ast" };
  { name = "斐波那契"; ly_path = "示例/斐波那契.ly"; ml_gold = "示例/斐波那契.ml"; ast_gold = "示例/斐波那契.ast" };
  { name = "列表";     ly_path = "示例/列表.ly";     ml_gold = "示例/列表.ml";     ast_gold = "示例/列表.ast" };
  { name = "模式匹配"; ly_path = "示例/模式匹配.ly"; ml_gold = "示例/模式匹配.ml"; ast_gold = "示例/模式匹配.ast" };
]

let run_tests update_golden =
  let passed = ref 0 and failed = ref 0 in

  List.iter (fun tc ->
    let ly_abs = Filename.concat project_root tc.ly_path in
    let src    = read_file ly_abs in
    let basedir = Filename.dirname ly_abs in

    (* ── 生成 OCaml 代码 ── *)
    let ml_actual =
      Luoyan_lib.Prelude.generate ()
      ^ Luoyan_lib.Trans.transpile ~basedir src
    in

    (* ── 生成 Token 序列 ── *)
    let ast_actual =
      Luoyan_lib.Trans.print_tokens
        (Luoyan_lib.Trans.tokenize src)
    in

    let ml_gold_abs  = Filename.concat project_root tc.ml_gold in
    let ast_gold_abs = Filename.concat project_root tc.ast_gold in

    if update_golden then begin
      write_file ml_gold_abs  ml_actual;
      write_file ast_gold_abs ast_actual;
      Printf.printf "更新黄金文件：%s, %s\n" tc.ml_gold tc.ast_gold
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
      check ".ml"  ml_gold_abs  ml_actual;
      check ".ast" ast_gold_abs ast_actual
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
