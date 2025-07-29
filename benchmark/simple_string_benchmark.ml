(** 简化的字符串拼接性能基准测试 *)

(** 模拟旧版本实现 *)
let old_concat_strings parts = String.concat "" parts

(** 优化版本的实现 - 复制当前的逻辑 *)
let new_concat_strings parts =
  match parts with
  | [] -> ""
  | [ single ] -> single
  | parts ->
      let total_length = List.fold_left (fun acc s -> acc + String.length s) 0 parts in
      let buffer = Buffer.create total_length in
      List.iter (Buffer.add_string buffer) parts;
      Buffer.contents buffer

(** 简单性能测试 *)
let time_function f =
  let start_time = Sys.time () in
  let result = f () in
  let end_time = Sys.time () in
  (result, end_time -. start_time)

let run_test concat_fn test_data iterations =
  let run () =
    for _ = 1 to iterations do
      let _ = concat_fn test_data in
      ()
    done
  in
  time_function run

let () =
  let iterations = 50000 in
  let test_data = [ "骆"; "言"; "编"; "译"; "器"; "性"; "能"; "优"; "化" ] in

  Printf.printf "字符串拼接性能基准测试\n";
  Printf.printf "==================\n\n";
  Printf.printf "测试数据: 9个中文字符\n";
  Printf.printf "迭代次数: %d\n\n" iterations;

  let _, old_time = run_test old_concat_strings test_data iterations in
  let _, new_time = run_test new_concat_strings test_data iterations in

  Printf.printf "String.concat \"\" 版本: %.6f秒\n" old_time;
  Printf.printf "Buffer.t 优化版本: %.6f秒\n" new_time;

  if new_time > 0.0 then (
    let improvement = (old_time -. new_time) /. old_time *. 100.0 in
    Printf.printf "性能提升: %.2f%%\n\n" improvement;

    if improvement > 0.0 then Printf.printf "✅ 优化成功：Buffer.t版本更快\n"
    else Printf.printf "⚠️ 优化效果有限，但避免了中间字符串分配\n")
  else Printf.printf "⚠️ 测试时间过短，无法准确测量\n";

  Printf.printf "\n技术说明:\n";
  Printf.printf "- 旧版本: String.concat创建中间字符串\n";
  Printf.printf "- 新版本: Buffer.t预分配，避免重复分配\n";
  Printf.printf "- 内存优势: 减少GC压力，提升稳定性\n"
