let () =
  let test_keywords = ["设"; "为"; "让"; "of"] in
  List.iter (fun kw ->
    Printf.printf "关键字: '%s'\n" kw;
    Printf.printf "  长度: %d\n" (String.length kw);
    Printf.printf "  字节: ";
    for i = 0 to String.length kw - 1 do
      Printf.printf "%02X(%d) " (Char.code kw.[i]) (Char.code kw.[i])
    done;
    Printf.printf "\n";
    let is_chinese = String.for_all (fun c -> Char.code c >= 128) kw in
    Printf.printf "  全为高位字节? %b\n" is_chinese;
    Printf.printf "\n"
  ) test_keywords