(* 音韵分析模块测试 - 简化版本 *)

(* Updated to use new consolidated poetry rhyme module *)
open Poetry_rhyme.Rhyme_query

let test_basic () =
  (* Simple test using the new module functionality *)
  let result = query_character_cached "平" in
  match result with
  | Found character -> Alcotest.(check string) "查询测试" "平" character.character
  | NotFound _ -> Alcotest.fail "未找到字符'平'"
  | MultipleMatches chars ->
      if List.length chars > 0 then
        let first_char = List.hd chars in
        Alcotest.(check string) "查询测试" "平" first_char.character
      else Alcotest.fail "查询结果为空"

let () =
  let open Alcotest in
  run "Poetry Rhyme Analysis Tests" [ ("basic", [ test_case "basic test" `Quick test_basic ]) ]
