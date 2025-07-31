(** 测试字符识别问题 *)

let test_chars = [
  "加";   (* Should be PlusKeyword *)
  "乙";   (* What should this be? *)
  "点";   (* Should be part of numbers *)
]

let () =
  Printf.printf "=== 测试字符 ===\n";
  List.iter (fun ch ->
    let bytes = [Char.code ch.[0]; Char.code ch.[1]; Char.code ch.[2]] in
    Printf.printf "字符: %s - 字节: [%d; %d; %d]\n" 
      ch (List.nth bytes 0) (List.nth bytes 1) (List.nth bytes 2)
  ) test_chars