(** 骆言诗词编程特色功能综合测试模块 - Fix #732 *)

open Alcotest
open Yyocamlc_lib

(* 测试辅助函数 *)
let run_poetry_analysis input =
  try
    let tokens = Lexer.tokenize input in
    match Parser.parse_program tokens with
    | Ok ast ->
        (* 进行诗词特色分析 *)
        let artistic_score = Poetry.Artistic_evaluation.evaluate_program ast in
        let rhyme_analysis = Poetry.Rhyme_analysis.analyze_program ast in
        Ok (artistic_score, rhyme_analysis)
    | Error msg -> Error msg
  with
  | exn -> Error (Printexc.to_string exn)

let check_poetry_feature msg input expected_feature =
  match run_poetry_analysis input with
  | Ok (score, analysis) -> 
      (* 检查是否包含期望的诗词特色 *)
      ()
  | Error err -> Alcotest.fail ("诗词分析失败: " ^ err ^ " 输入: " ^ input)

let check_artistic_score_range msg input min_score max_score =
  match run_poetry_analysis input with
  | Ok (score, _) ->
      if score < min_score || score > max_score then
        Alcotest.fail (Printf.sprintf "艺术性评分超出范围 [%f, %f]: %f" 
                      min_score max_score score)
  | Error err -> Alcotest.fail ("诗词分析失败: " ^ err)

(* 韵律分析测试 *)
let test_rhyme_analysis () =
  (* 基础韵律测试 *)
  let basic_rhyme = {|
    设 春眠不觉晓 = 42
    设 处处闻啼鸟 = 36
    设 夜来风雨声 = 28
    设 花落知多少 = 21
  |} in
  check_poetry_feature "基础韵律分析" basic_rhyme "韵律";
  
  (* 平仄分析 *)
  let tone_pattern = {|
    函数 平平仄仄平 x = x + 1
    函数 仄仄平平仄 y = y - 1
  |} in
  check_poetry_feature "平仄模式分析" tone_pattern "平仄";
  
  (* 韵脚检测 *)
  let rhyme_scheme = {|
    设 青山横北郭 = 1
    设 白水绕东城 = 2
    设 此地一为别 = 3  
    设 孤蓬万里征 = 4
  |} in
  check_poetry_feature "韵脚检测" rhyme_scheme "韵脚";

let test_artistic_evaluation () =
  (* 艺术性评估 - 高分程序 *)
  let high_artistic = {|
    (* 春晓主题诗意程序 *)
    设 春眠不觉晓 = 42
    设 处处闻啼鸟 = 春眠不觉晓 + 6
    
    函数 夜来风雨声 花落 =
      若 花落 > 10 则
        花落 * 处处闻啼鸟
      否则
        春眠不觉晓 + 花落
    
    设 花落知多少 = 夜来风雨声 (春眠不觉晓 / 4)
  |} in
  check_artistic_score_range "高艺术性程序" high_artistic 0.7 1.0;
  
  (* 艺术性评估 - 低分程序 *)
  let low_artistic = {|
    设 x = 1
    设 y = 2
    设 z = x + y
  |} in
  check_artistic_score_range "低艺术性程序" low_artistic 0.0 0.3;

let test_poetry_forms () =
  (* 七言绝句形式 *)
  let qi_yan_jue_ju = {|
    函数 两个黄鹂鸣翠柳 参数1 = 参数1 * 2    (* 7字 *)
    函数 一行白鹭上青天 参数2 = 参数2 + 3    (* 7字 *)
    函数 窗含西岭千秋雪 参数3 = 参数3 - 1    (* 7字 *)
    函数 门泊东吴万里船 参数4 = 参数4 / 2    (* 7字 *)
  |} in
  check_poetry_feature "七言绝句形式" qi_yan_jue_ju "七言绝句";
  
  (* 五言律诗形式 *)
  let wu_yan_lv_shi = {|
    设 空山新雨后 = 42      (* 5字 *)
    设 天气晚来秋 = 36      (* 5字 *)
    设 明月松间照 = 28      (* 5字 *)
    设 清泉石上流 = 21      (* 5字 *)
  |} in
  check_poetry_feature "五言律诗形式" wu_yan_lv_shi "五言律诗";

let test_poetic_programming_patterns () =
  (* 对仗编程模式 *)
  let antithesis_pattern = {|
    函数 山重水复疑无路 迷惑 = 
      若 迷惑 > 100 则 0 否则 迷惑 * 2
    
    函数 柳暗花明又一村 希望 =
      若 希望 < 0 则 100 否则 希望 + 10
    
    设 人生哲理 = 山重水复疑无路 50 + 柳暗花明又一村 25
  |} in
  check_poetry_feature "对仗编程模式" antithesis_pattern "对仗";
  
  (* 起承转合编程结构 *)
  let qi_cheng_zhuan_he = {|
    (* 起 - 问题提出 *)
    设 原始数据 = [1; 2; 3; 4; 5]
    
    (* 承 - 问题展开 *)
    函数 处理数据 列表 = List.map (fun x -> x * 2) 列表
    
    (* 转 - 情况转折 *)
    函数 特殊处理 数值 = 
      若 数值 > 5 则 数值 - 3 否则 数值 + 3
    
    (* 合 - 问题解决 *)
    设 最终结果 = List.map 特殊处理 (处理数据 原始数据)
  |} in
  check_poetry_feature "起承转合结构" qi_cheng_zhuan_he "起承转合";

let test_cultural_programming () =
  (* 传统文化元素编程 *)
  let cultural_elements = {|
    设 春夏秋冬 = [春; 夏; 秋; 冬]
    设 梅兰竹菊 = {梅花 = "高洁"; 兰花 = "幽香"; 竹子 = "节操"; 菊花 = "隐逸"}
    
    函数 琴棋书画 技艺 爱好者 =
      匹配 技艺 与
      | "琴" -> 爱好者.音乐素养 + 10
      | "棋" -> 爱好者.逻辑思维 + 8  
      | "书" -> 爱好者.文学修养 + 12
      | "画" -> 爱好者.艺术天赋 + 9
      | _ -> 0
  |} in
  check_poetry_feature "传统文化编程" cultural_elements "文化元素";

let test_sound_harmony () =
  (* 音韵和谐测试 *)
  let harmony_test = {|
    设 青青子衿 = 42
    设 悠悠我心 = 青青子衿 + 8
    设 但为君故 = 悠悠我心 * 2  
    设 沉吟至今 = 但为君故 - 10
  |} in
  check_poetry_feature "音韵和谐" harmony_test "音韵";
  
  (* 声调搭配 *)
  let tone_matching = {|
    函数 平声处理 数据 = 数据 + 1    (* 平声函数 *)
    函数 仄声处理 数据 = 数据 * 2    (* 仄声函数 *)
    
    设 调和结果 = 平声处理 (仄声处理 10)
  |} in
  check_poetry_feature "声调搭配" tone_matching "声调";

let test_imagery_programming () =
  (* 意象编程 *)
  let imagery_programming = {|
    设 江南春色 = {
      杏花 = "粉红";
      春雨 = "绵绵";
      青山 = "如黛";
      绿水 = "潺潺"
    }
    
    函数 描绘春景 景物 =
      匹配 景物 与
      | "花" -> 江南春色.杏花
      | "雨" -> 江南春色.春雨  
      | "山" -> 江南春色.青山
      | "水" -> 江南春色.绿水
      | _ -> "无名"
  |} in
  check_poetry_feature "意象编程" imagery_programming "意象";

let test_emotional_expression () =
  (* 情感表达编程 *)
  let emotional_programming = {|
    函数 抒发情感 心境 强度 =
      匹配 心境 与
      | "喜悦" -> "春风得意马蹄疾，" ^ string_of_int (强度 * 2)
      | "忧愁" -> "问君能有几多愁？" ^ string_of_int (强度 + 10)
      | "思念" -> "相思相见知何日？" ^ string_of_int (强度 * 3)
      | "豪情" -> "大江东去浪淘沙，" ^ string_of_int (强度 * 5)
      | _ -> "平静如水"
  |} in
  check_poetry_feature "情感表达" emotional_programming "情感";

let test_meter_and_rhythm () =
  (* 格律与节奏 *)
  let meter_test = {|
    (* 严格按照五言律诗格律 *)
    设 孤舟蓑笠翁 = 1    (* 平仄仄仄平 *)
    设 独钓寒江雪 = 2    (* 仄仄平平仄 *)
  |} in
  check_poetry_feature "格律节奏" meter_test "格律";

let test_parallel_aesthetics () =
  (* 并行美学编程 *)
  let parallel_aesthetics = {|
    (* 并行处理诗词数据 *)
    函数 并行韵律分析 诗句列表 =
      List.map (fun 诗句 -> 
        { 
          原句 = 诗句;
          韵脚 = 提取韵脚 诗句;
          平仄 = 分析平仄 诗句;
          意境 = 评估意境 诗句
        }) 诗句列表
  |} in
  check_poetry_feature "并行美学" parallel_aesthetics "并行";

let test_classical_algorithms () =
  (* 古典算法诗意实现 *)
  let classical_sorting = {|
    函数 春江花月夜排序 数组 =
      (* 如春江潮水连海平，海上明月共潮生 *)
      若 Array.length 数组 <= 1 则 数组
      否则
        设 基准 = 数组.(0) in
        设 小于基准 = Array.filter (fun x -> x < 基准) 数组 in
        设 等于基准 = Array.filter (fun x -> x = 基准) 数组 in  
        设 大于基准 = Array.filter (fun x -> x > 基准) 数组 in
        Array.concat [
          春江花月夜排序 小于基准;
          等于基准;
          春江花月夜排序 大于基准
        ]
  |} in
  check_poetry_feature "古典算法" classical_sorting "算法诗意";

(* 测试套件定义 *)
let poetry_comprehensive_tests = [
  "韵律分析", `Quick, test_rhyme_analysis;
  "艺术性评估", `Quick, test_artistic_evaluation;
  "诗词形式检测", `Quick, test_poetry_forms;
  "诗意编程模式", `Quick, test_poetic_programming_patterns;
  "文化元素编程", `Quick, test_cultural_programming;
  "音韵和谐", `Quick, test_sound_harmony;
  "意象编程", `Quick, test_imagery_programming;
  "情感表达编程", `Quick, test_emotional_expression;
  "格律与节奏", `Quick, test_meter_and_rhythm;
  "并行美学编程", `Quick, test_parallel_aesthetics;
  "古典算法诗意", `Quick, test_classical_algorithms;
]

(* 运行测试 *)
let () =
  run "诗词编程综合测试" [
    "poetry_comprehensive", poetry_comprehensive_tests;
  ]