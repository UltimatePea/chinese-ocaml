open Alcotest
open Yyocamlc_lib

let test_current_system_baseline () =
  let sample_programs = [ ("简单算术", "设 「甲」 为 一 加 二") ] in
  List.iter
    (fun (name, program) ->
      try
        let tokens = Lexer.tokenize program ("test_" ^ name ^ ".ly") in
        print_endline ("Success! Got " ^ string_of_int (List.length tokens) ^ " tokens for " ^ name);
        check bool ("baseline_tokenization_" ^ name) true (List.length tokens > 0)
      with exn ->
        print_endline ("Error for " ^ name ^ ": " ^ Printexc.to_string exn);
        fail ("Baseline test failed for " ^ name ^ ": " ^ Printexc.to_string exn))
    sample_programs

let () =
  run "Test Specific"
    [ ("baseline", [ test_case "current system baseline" `Quick test_current_system_baseline ]) ]
