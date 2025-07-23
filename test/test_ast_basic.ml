(** AST基础测试模块

    简化版测试，专注于基本类型验证

    @author 骆言测试团队
    @version 1.0
    @since 2025-07-23 Fix #915 测试覆盖率提升 *)

open Alcotest
open Yyocamlc_lib.Ast

let test_poetry_form_construction () =
  (* 测试诗词形式类型能够正常构造 *)
  let forms = [ FourCharPoetry; FiveCharPoetry; SevenCharPoetry; ParallelProse ] in
  check int "诗词形式类型数量" 4 (List.length forms);
  check bool "诗词形式应该相等" true (FourCharPoetry = FourCharPoetry)

let test_rhyme_info_construction () =
  (* 测试韵律信息结构构造 *)
  let rhyme = { rhyme_category = "一东"; rhyme_position = 2; rhyme_pattern = "AABA" } in
  check string "韵部应该正确" "一东" rhyme.rhyme_category;
  check int "韵脚位置应该正确" 2 rhyme.rhyme_position

let test_tone_types () =
  (* 测试声调类型 *)
  let tones = [ LevelTone; FallingTone; RisingTone; DepartingTone; EnteringTone ] in
  check int "声调类型数量" 5 (List.length tones);
  check bool "声调类型应该相等" true (LevelTone = LevelTone)

let test_tone_constraints () =
  (* 测试声调约束 *)
  let constraints = [ AlternatingTones; ParallelTones ] in
  check int "声调约束数量" 2 (List.length constraints);

  let specific_pattern = SpecificPattern [ LevelTone; FallingTone ] in
  match specific_pattern with
  | SpecificPattern pattern -> check int "特定模式长度" 2 (List.length pattern)
  | _ -> fail "应该是特定模式约束"

let () =
  run "AST_basic tests"
    [
      ("poetry_forms", [ test_case "诗词形式构造" `Quick test_poetry_form_construction ]);
      ("rhyme_info", [ test_case "韵律信息构造" `Quick test_rhyme_info_construction ]);
      ("tone_types", [ test_case "声调类型" `Quick test_tone_types ]);
      ("tone_constraints", [ test_case "声调约束" `Quick test_tone_constraints ]);
    ]
