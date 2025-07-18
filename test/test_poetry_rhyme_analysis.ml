(* 音韵分析模块测试 *)

open Poetry.Rhyme_analysis

let test_detect_rhyme_category () =
  Alcotest.(check (testable (fun ppf -> function
    | PingSheng -> Format.pp_print_string ppf "平声"
    | ZeSheng -> Format.pp_print_string ppf "仄声"
    | RuSheng -> Format.pp_print_string ppf "入声"
  ) (=))) "detect_rhyme_category works" PingSheng (detect_rhyme_category "安");
  Alcotest.(check (testable (fun ppf -> function
    | PingSheng -> Format.pp_print_string ppf "平声"
    | ZeSheng -> Format.pp_print_string ppf "仄声"
    | RuSheng -> Format.pp_print_string ppf "入声"
  ) (=))) "detect_rhyme_category works" PingSheng (detect_rhyme_category "天");
  Alcotest.(check (testable (fun ppf -> function
    | PingSheng -> Format.pp_print_string ppf "平声"
    | ZeSheng -> Format.pp_print_string ppf "仄声"
    | RuSheng -> Format.pp_print_string ppf "入声"
  ) (=))) "detect_rhyme_category works" ZeSheng (detect_rhyme_category "上");
  Alcotest.(check (testable (fun ppf -> function
    | PingSheng -> Format.pp_print_string ppf "平声"
    | ZeSheng -> Format.pp_print_string ppf "仄声"
    | RuSheng -> Format.pp_print_string ppf "入声"
  ) (=))) "detect_rhyme_category works" ZeSheng (detect_rhyme_category "去");
  Alcotest.(check (testable (fun ppf -> function
    | PingSheng -> Format.pp_print_string ppf "平声"
    | ZeSheng -> Format.pp_print_string ppf "仄声"
    | RuSheng -> Format.pp_print_string ppf "入声"
  ) (=))) "detect_rhyme_category works" RuSheng (detect_rhyme_category "入")

let test_detect_rhyme_group () =
  Alcotest.(check (testable (fun ppf -> function
    | AnRhyme -> Format.pp_print_string ppf "安韵"
    | TianRhyme -> Format.pp_print_string ppf "天韵"
    | QuRhyme -> Format.pp_print_string ppf "去韵"
    | _ -> Format.pp_print_string ppf "其他韵"
  ) (=))) "detect_rhyme_group works" AnRhyme (detect_rhyme_group "安");
  Alcotest.(check (testable (fun ppf -> function
    | AnRhyme -> Format.pp_print_string ppf "安韵"
    | TianRhyme -> Format.pp_print_string ppf "天韵"
    | QuRhyme -> Format.pp_print_string ppf "去韵"
    | _ -> Format.pp_print_string ppf "其他韵"
  ) (=))) "detect_rhyme_group works" AnRhyme (detect_rhyme_group "山");
  Alcotest.(check (testable (fun ppf -> function
    | AnRhyme -> Format.pp_print_string ppf "安韵"
    | TianRhyme -> Format.pp_print_string ppf "天韵"
    | QuRhyme -> Format.pp_print_string ppf "去韵"
    | _ -> Format.pp_print_string ppf "其他韵"
  ) (=))) "detect_rhyme_group works" TianRhyme (detect_rhyme_group "天");
  Alcotest.(check (testable (fun ppf -> function
    | AnRhyme -> Format.pp_print_string ppf "安韵"
    | TianRhyme -> Format.pp_print_string ppf "天韵"
    | QuRhyme -> Format.pp_print_string ppf "去韵"
    | _ -> Format.pp_print_string ppf "其他韵"
  ) (=))) "detect_rhyme_group works" TianRhyme (detect_rhyme_group "年");
  Alcotest.(check (testable (fun ppf -> function
    | AnRhyme -> Format.pp_print_string ppf "安韵"
    | TianRhyme -> Format.pp_print_string ppf "天韵"
    | QuRhyme -> Format.pp_print_string ppf "去韵"
    | _ -> Format.pp_print_string ppf "其他韵"
  ) (=))) "detect_rhyme_group works" QuRhyme (detect_rhyme_group "去");
  Alcotest.(check (testable (fun ppf -> function
    | AnRhyme -> Format.pp_print_string ppf "安韵"
    | TianRhyme -> Format.pp_print_string ppf "天韵"
    | QuRhyme -> Format.pp_print_string ppf "去韵"
    | _ -> Format.pp_print_string ppf "其他韵"
  ) (=))) "detect_rhyme_group works" QuRhyme (detect_rhyme_group "路")

let test_extract_rhyme_ending () =
  Alcotest.(check (option string)) "extract_rhyme_ending works" (Some "安") (extract_rhyme_ending "平安");
  Alcotest.(check (option string)) "extract_rhyme_ending works" (Some "天") (extract_rhyme_ending "春天");
  Alcotest.(check (option string)) "extract_rhyme_ending works" None (extract_rhyme_ending "")

let test_validate_rhyme_consistency () =
  Alcotest.(check bool) "validate_rhyme_consistency works" true (validate_rhyme_consistency ["平安"; "泰山"]);  (* 同为安韵 *)
  Alcotest.(check bool) "validate_rhyme_consistency works" true (validate_rhyme_consistency ["春天"; "今年"]);  (* 同为天韵 *)
  Alcotest.(check bool) "validate_rhyme_consistency works" false (validate_rhyme_consistency ["平安"; "春天"]) (* 不同韵组 *)

let test_chars_rhyme () =
  Alcotest.(check bool) "chars_rhyme works" true (chars_rhyme "安" "山");   (* 同为安韵 *)
  Alcotest.(check bool) "chars_rhyme works" true (chars_rhyme "天" "年");   (* 同为天韵 *)
  Alcotest.(check bool) "chars_rhyme works" false (chars_rhyme "安" "天");  (* 不同韵组 *)

let test_generate_rhyme_report () =
  let report = generate_rhyme_report "平安" in
  Alcotest.(check string) "generate_rhyme_report works" "平安" report.verse;
  Alcotest.(check (option string)) "generate_rhyme_report works" (Some "安") report.rhyme_ending;
  Alcotest.(check (testable (fun ppf -> function
    | AnRhyme -> Format.pp_print_string ppf "安韵"
    | TianRhyme -> Format.pp_print_string ppf "天韵"
    | QuRhyme -> Format.pp_print_string ppf "去韵"
    | _ -> Format.pp_print_string ppf "其他韵"
  ) (=))) "generate_rhyme_report works" AnRhyme report.rhyme_group;
  Alcotest.(check (testable (fun ppf -> function
    | PingSheng -> Format.pp_print_string ppf "平声"
    | ZeSheng -> Format.pp_print_string ppf "仄声"
    | RuSheng -> Format.pp_print_string ppf "入声"
  ) (=))) "generate_rhyme_report works" PingSheng report.rhyme_category;
  ()

let () =
  let open Alcotest in
  run "Poetry Rhyme Analysis Tests" [
    "detect_rhyme_category", [test_case "basic" `Quick test_detect_rhyme_category];
    "detect_rhyme_group", [test_case "basic" `Quick test_detect_rhyme_group];
    "extract_rhyme_ending", [test_case "basic" `Quick test_extract_rhyme_ending];
    "validate_rhyme_consistency", [test_case "basic" `Quick test_validate_rhyme_consistency];
    "chars_rhyme", [test_case "basic" `Quick test_chars_rhyme];
    "generate_rhyme_report", [test_case "basic" `Quick test_generate_rhyme_report];
  ]