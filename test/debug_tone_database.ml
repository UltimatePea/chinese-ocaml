open Poetry.Tone_pattern
open Poetry.Tone_data

let test_char char =
  Printf.printf "Testing character: %s\n" char;
  try
    let tone = List.assoc char tone_database in
    let is_level = match tone with LevelTone -> true | _ -> false in
    Printf.printf "  Found in database: %s (level: %b)\n"
      (match tone with
      | LevelTone -> "LevelTone"
      | RisingTone -> "RisingTone"
      | DepartingTone -> "DepartingTone"
      | EnteringTone -> "EnteringTone"
      | FallingTone -> "FallingTone")
      is_level;
    is_level
  with Not_found ->
    Printf.printf "  NOT FOUND in database\n";
    true (* Default to level tone when not found *)

let () =
  let chars = [ "一"; "天"; "上"; "去" ] in
  let results = List.map test_char chars in
  Printf.printf "\nResults: %s\n" (String.concat "; " (List.map string_of_bool results));
  Printf.printf "Expected: [true; true; false; false]\n";

  (* Also test the actual function *)
  let pattern = analyze_simple_tone_pattern "一天上去" in
  Printf.printf "Function result: %s\n" (String.concat "; " (List.map string_of_bool pattern))
