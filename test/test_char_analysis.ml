let analyze_char c =
  Printf.printf "Character: %s\n" c;
  Printf.printf "Byte length: %d\n" (String.length c);
  for i = 0 to String.length c - 1 do
    Printf.printf "Byte %d: 0x%02X (%d)\n" i (Char.code c.[i]) (Char.code c.[i])
  done;
  Printf.printf "\n"

let () =
  analyze_char "为";
  analyze_char "４";
  analyze_char "２"
