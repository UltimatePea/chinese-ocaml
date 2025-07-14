let () =
  let chars = [ "设"; "数"; "值"; "为"; "42" ] in
  List.iter
    (fun ch ->
      Printf.printf "'%s' -> " ch;
      for i = 0 to String.length ch - 1 do
        Printf.printf "%02X " (Char.code ch.[i])
      done;
      Printf.printf "-> %s\n" (if String.length ch = 3 then "中文字符" else "其他"))
    chars;

  (* 测试UTF-8解码 *)
  let test_str = "为" in
  Printf.printf "\n测试字符串: %s\n" test_str;
  match Uutf.decode (Uutf.decoder (`String test_str)) with
  | `Uchar u ->
      let code = Uchar.to_int u in
      Printf.printf "Unicode: U+%04X\n" code;
      Printf.printf "是否为中文字符: %b\n" (code >= 0x4E00 && code <= 0x9FFF)
  | _ -> Printf.printf "UTF-8解码失败\n"
