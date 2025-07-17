(* 对仗分析模块测试 *)

open Poetry.Parallelism_analysis
open Poetry.Rhyme_analysis

let test_word_class_detection () =
  let char_tests = [
    ('天', Noun);
    ('人', Noun);
    ('来', Verb);
    ('去', Verb);
    ('大', Adjective);
    ('小', Adjective);
    ('一', Numeral);
    ('二', Numeral);
    ('个', Classifier);
    ('只', Classifier);
  ] in
  List.iter (fun (char, expected_class) ->
    let actual_class = detect_word_class char in
    if actual_class <> expected_class then
      failwith (Printf.sprintf "词性检测失败: %c 期望 %s" char 
        (match expected_class with
         | Noun -> "名词"
         | Verb -> "动词"
         | Adjective -> "形容词"
         | Numeral -> "数词"
         | Classifier -> "量词"
         | _ -> "其他"))
  ) char_tests

let test_parallelism_analysis () =
  let line1 = "天对地" in
  let line2 = "山对水" in
  let report = generate_parallelism_report line1 line2 in
  assert (String.length report.line1 > 0);
  assert (String.length report.line2 > 0);
  assert (List.length report.word_class_pairs > 0);
  assert (List.length report.rhyme_pairs > 0)

let test_parallelism_quality () =
  let line1 = "天对地" in
  let line2 = "山对水" in
  let quality = analyze_parallelism_quality line1 line2 in
  assert (quality <> NoParallelism)

let test_regulated_verse_parallelism () =
  let verses = [
    "天对地"; "山对水"; "红对绿"; "东对西";
    "花对草"; "鸟对鱼"; "月对星"; "风对雨";
  ] in
  let (second_report, third_report, overall_quality) = 
    validate_regulated_verse_parallelism verses in
  assert (String.length second_report.line1 > 0);
  assert (String.length third_report.line1 > 0);
  assert (overall_quality >= 0.0 && overall_quality <= 1.0)

let test_parallelism_improvements () =
  let line1 = "天对地" in
  let line2 = "山对水" in
  let report = generate_parallelism_report line1 line2 in
  let suggestions = suggest_parallelism_improvements report in
  assert (List.length suggestions > 0)

let run_tests () =
  Printf.printf "运行对仗分析测试...\n";
  
  test_word_class_detection ();
  Printf.printf "✓ 词性检测测试通过\n";
  
  test_parallelism_analysis ();
  Printf.printf "✓ 对仗分析测试通过\n";
  
  test_parallelism_quality ();
  Printf.printf "✓ 对仗质量测试通过\n";
  
  test_regulated_verse_parallelism ();
  Printf.printf "✓ 律诗对仗测试通过\n";
  
  test_parallelism_improvements ();
  Printf.printf "✓ 对仗改进建议测试通过\n";
  
  Printf.printf "所有对仗分析测试通过! ✓\n"

let () = run_tests ()