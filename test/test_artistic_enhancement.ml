open Alcotest
open Poetry.Artistic_evaluation
open Poetry.Artistic_types
open Poetry.Poetry_standards

let test_poetry_forms () =
  let forms = [
    SiYanPianTi;
    WuYanLuShi;
    QiYanJueJu;
    CiPai "水调歌头";
    ModernPoetry;
  ] in
  check int "诗词形式数量" 5 (List.length forms)

let test_wuyan_lushi_standards () =
  let standards = wuyan_lushi_standards in
  check int "五言律诗句数" 8 standards.line_count;
  check int "五言律诗每句字数" 5 standards.char_per_line;
  check int "五言律诗韵脚数量" 8 (Array.length standards.rhyme_scheme);
  check int "五言律诗对仗数量" 8 (Array.length standards.parallelism_required);
  check int "五言律诗声调模式数量" 8 (List.length standards.tone_pattern)

let test_qiyan_jueju_standards () =
  let standards = qiyan_jueju_standards in
  check int "七言绝句句数" 4 standards.line_count;
  check int "七言绝句每句字数" 7 standards.char_per_line;
  check int "七言绝句韵脚数量" 4 (Array.length standards.rhyme_scheme);
  check int "七言绝句对仗数量" 4 (Array.length standards.parallelism_required);
  check int "七言绝句声调模式数量" 4 (List.length standards.tone_pattern)

let test_evaluate_wuyan_lushi () =
  let verses = [|
    "春风花草香";
    "夜雨竹林深";
    "明月照高楼";
    "清风拂碧波";
    "山鸟啼声远";
    "江鱼跃水欢";
    "此情应长久";
    "千里共婵娟";
  |] in
  let result = evaluate_wuyan_lushi verses in
  check bool "韵律得分应该非负" true (result.rhyme_score >= 0.0);
  check bool "声调得分应该非负" true (result.tone_score >= 0.0);
  check bool "对仗得分应该非负" true (result.parallelism_score >= 0.0);
  check bool "应该有建议" true (List.length result.suggestions > 0)

let test_evaluate_qiyan_jueju () =
  let verses = [|
    "春江潮水连海平";
    "海上明月共潮生";
    "滟滟随波千万里";
    "何处春江无月明";
  |] in
  let result = evaluate_qiyan_jueju verses in
  check bool "韵律得分应该非负" true (result.rhyme_score >= 0.0);
  check bool "声调得分应该非负" true (result.tone_score >= 0.0);
  check bool "对仗得分应该非负" true (result.parallelism_score >= 0.0);
  check bool "应该有建议" true (List.length result.suggestions > 0)

let test_evaluate_poetry_by_form () =
  let wuyan_verses = [|
    "春风花草香";
    "夜雨竹林深";
    "明月照高楼";
    "清风拂碧波";
    "山鸟啼声远";
    "江鱼跃水欢";
    "此情应长久";
    "千里共婵娟";
  |] in
  let qiyan_verses = [|
    "春江潮水连海平";
    "海上明月共潮生";
    "滟滟随波千万里";
    "何处春江无月明";
  |] in
  let modern_verses = [|
    "代码如诗";
    "逻辑似画";
    "程序员的浪漫";
    "在键盘上绽放";
  |] in
  
  let wuyan_result = evaluate_poetry_by_form WuYanLuShi wuyan_verses in
  let qiyan_result = evaluate_poetry_by_form QiYanJueJu qiyan_verses in
  let modern_result = evaluate_poetry_by_form ModernPoetry modern_verses in
  
  check bool "五言律诗应该有评价结果" true (wuyan_result.rhyme_score >= 0.0);
  check bool "七言绝句应该有评价结果" true (qiyan_result.rhyme_score >= 0.0);
  check bool "现代诗应该有评价结果" true (modern_result.imagery_score >= 0.0)

let test_wrong_line_count () =
  (* 测试错误的句数 *)
  let wrong_verses = [|
    "春风花草香";
    "夜雨竹林深";
    "明月照高楼";
  |] in
  let result = evaluate_wuyan_lushi wrong_verses in
  check bool "句数错误应该评价为Poor" true (result.overall_grade = Poor);
  check bool "应该有错误提示" true (List.length result.suggestions > 0)

let suite = [
  "诗词艺术性评价测试", [
    "test_poetry_forms", `Quick, test_poetry_forms;
    "test_wuyan_lushi_standards", `Quick, test_wuyan_lushi_standards;
    "test_qiyan_jueju_standards", `Quick, test_qiyan_jueju_standards;
    "test_evaluate_wuyan_lushi", `Quick, test_evaluate_wuyan_lushi;
    "test_evaluate_qiyan_jueju", `Quick, test_evaluate_qiyan_jueju;
    "test_evaluate_poetry_by_form", `Quick, test_evaluate_poetry_by_form;
    "test_wrong_line_count", `Quick, test_wrong_line_count;
  ]
]

let () = run "诗词艺术性评价测试" suite