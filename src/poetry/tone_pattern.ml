(* 平仄检测模块 - 骆言诗词编程特性
   夫诗词之道，平仄为纲。平声如流水，仄声如敲玉。
   此模块专司平仄检测，验声调之和谐，审格律之严整。
   凡作诗词，必明平仄，后成佳篇。
*)

open Yyocamlc_lib

(* 声调类型定义：依中古音韵系统分类声调
   古之音韵，分平上去入四声。平声悠扬，仄声急促。
   今承古制，以明声调之别，为诗词创作提供准绳。
*)
type tone_type =
  | LevelTone (* 平声 *)
  | FallingTone (* 仄声 *)
  | RisingTone (* 上声 *)
  | DepartingTone (* 去声 *)
  | EnteringTone (* 入声 *)

(* 声调数据库：汇集常用汉字之声调
   依《康熙字典》、《说文解字》等典籍，收录常用汉字声调。
   一字一音，一音一调。声调分明，方能成诗。
*)
let tone_database =
  [
    (* 平声字符 *)
    ("一", LevelTone);
    ("天", LevelTone);
    ("年", LevelTone);
    ("先", LevelTone);
    ("田", LevelTone);
    ("言", LevelTone);
    ("然", LevelTone);
    ("连", LevelTone);
    ("边", LevelTone);
    ("山", LevelTone);
    ("间", LevelTone);
    ("闲", LevelTone);
    ("安", LevelTone);
    ("函", LevelTone);
    ("参", LevelTone);
    ("算", LevelTone);
    ("变", LevelTone);
    ("量", LevelTone);
    ("状", LevelTone);
    ("常", LevelTone);
    ("长", LevelTone);
    ("程", LevelTone);
    ("成", LevelTone);
    ("整", LevelTone);
    ("清", LevelTone);
    ("同", LevelTone);
    ("中", LevelTone);
    ("诗", LevelTone);
    ("时", LevelTone);
    ("知", LevelTone);
    ("思", LevelTone);
    ("之", LevelTone);
    ("真", LevelTone);
    ("新", LevelTone);
    ("春", LevelTone);
    ("分", LevelTone);
    ("云", LevelTone);
    ("文", LevelTone);
    ("闻", LevelTone);
    ("问", LevelTone);
    (* 仄声字符 (上声、去声、入声) *)
    ("上", RisingTone);
    ("想", RisingTone);
    ("两", RisingTone);
    ("有", RisingTone);
    ("所", RisingTone);
    ("者", RisingTone);
    ("也", RisingTone);
    ("可", RisingTone);
    ("我", RisingTone);
    ("你", RisingTone);
    ("好", RisingTone);
    ("小", RisingTone);
    ("老", RisingTone);
    ("早", RisingTone);
    ("少", RisingTone);
    ("了", RisingTone);
    ("去", DepartingTone);
    ("路", DepartingTone);
    ("度", DepartingTone);
    ("故", DepartingTone);
    ("步", DepartingTone);
    ("处", DepartingTone);
    ("住", DepartingTone);
    ("数", DepartingTone);
    ("组", DepartingTone);
    ("序", DepartingTone);
    ("述", DepartingTone);
    ("用", DepartingTone);
    ("动", DepartingTone);
    ("等", DepartingTone);
    ("定", DepartingTone);
    ("令", DepartingTone);
    ("命", DepartingTone);
    ("类", DepartingTone);
    ("比", DepartingTone);
    ("值", DepartingTone);
    ("置", DepartingTone);
    ("望", DepartingTone);
    ("放", DepartingTone);
    ("向", DepartingTone);
    ("让", DepartingTone);
    ("当", DepartingTone);
    ("于", DepartingTone);
    ("但", DepartingTone);
    ("到", DepartingTone);
    ("道", DepartingTone);
    ("要", DepartingTone);
    ("在", DepartingTone);
    ("再", DepartingTone);
    ("对", DepartingTone);
    ("却", DepartingTone);
    ("就", DepartingTone);
    ("是", DepartingTone);
    ("为", DepartingTone);
    ("做", DepartingTone);
    ("作", DepartingTone);
    ("个", DepartingTone);
    ("这", DepartingTone);
    ("那", DepartingTone);
    ("下", DepartingTone);
    ("不", DepartingTone);
    ("没", DepartingTone);
    ("会", DepartingTone);
    ("能", DepartingTone);
    ("还", DepartingTone);
    ("已", DepartingTone);
    ("经", DepartingTone);
    ("过", DepartingTone);
    ("自", DepartingTone);
    ("从", DepartingTone);
    ("很", DepartingTone);
    ("多", DepartingTone);
    ("大", DepartingTone);
    ("高", DepartingTone);
    ("低", DepartingTone);
    ("快", DepartingTone);
    ("慢", DepartingTone);
    ("坏", DepartingTone);
    ("旧", DepartingTone);
    ("美", DepartingTone);
    ("丑", DepartingTone);
    ("入", EnteringTone);
    ("出", EnteringTone);
    ("得", EnteringTone);
    ("结", EnteringTone);
    ("法", EnteringTone);
    ("达", EnteringTone);
    ("合", EnteringTone);
    ("接", EnteringTone);
    ("切", EnteringTone);
    ("别", EnteringTone);
    ("说", EnteringTone);
    ("读", EnteringTone);
    ("写", EnteringTone);
    ("学", EnteringTone);
    ("实", EnteringTone);
    ("识", EnteringTone);
    ("极", EnteringTone);
    ("力", EnteringTone);
    ("立", EnteringTone);
    ("及", EnteringTone);
    ("级", EnteringTone);
    ("集", EnteringTone);
    ("急", EnteringTone);
    ("即", EnteringTone);
    ("则", EnteringTone);
    ("测", EnteringTone);
    ("策", EnteringTone);
    ("册", EnteringTone);
    ("色", EnteringTone);
    ("索", EnteringTone);
    ("搜", EnteringTone);
    ("收", EnteringTone);
    ("白", EnteringTone);
    ("黑", EnteringTone);
    ("红", EnteringTone);
    ("绿", EnteringTone);
    ("蓝", EnteringTone);
    ("黄", EnteringTone);
    ("紫", EnteringTone);
    ("灰", EnteringTone);
  ]

(* 查找字符声调：从数据库中检索字符的声调信息
   如寻星于天，如觅珠于海。一字一查，声调自明。
*)
let find_tone_info_by_char char =
  let char_str = String.make 1 char in
  try
    let tone = List.assoc char_str tone_database in
    Some tone
  with Not_found -> None

(* 查找字符串声调：从数据库中检索UTF-8字符串的声调信息 *)
let find_tone_info char_str =
  try
    let tone = List.assoc char_str tone_database in
    Some tone
  with Not_found -> None

(* 检测字符声调：识别字符的声调类型
   辨音识调，为诗词创作之根本。平仄分明，方显音律之美。
*)
let detect_tone_by_char char =
  match find_tone_info_by_char char with Some tone -> tone | None -> LevelTone (* 默认为平声 *)

let detect_tone_by_string char_str =
  match find_tone_info char_str with Some tone -> tone | None -> LevelTone (* 默认为平声 *)

(* 兼容旧接口 *)
let detect_tone = detect_tone_by_char

(* 检测平声：判断字符是否为平声
   平声如水，音调悠扬。识别平声，以供诗词平仄搭配。
*)
let is_level_tone char = match detect_tone_by_char char with LevelTone -> true | _ -> false

(* 检测仄声：判断字符是否为仄声
   仄声如石，音调急促。上去入皆仄，与平声相对。
*)
let is_oblique_tone char =
  match detect_tone_by_char char with
  | FallingTone | RisingTone | DepartingTone | EnteringTone -> true
  | LevelTone -> false

(* 分析声调序列：逐字分析诗句的声调模式
   一句之中，声调起伏。逐字分析，方知平仄之妙。
*)
let analyze_tone_sequence verse =
  let chars = Utf8_utils.StringUtils.utf8_to_char_list verse in
  List.map detect_tone_by_string chars

(* 简化平仄模式：将复杂声调简化为平仄二元
   平仄二分，简而明了。true为平，false为仄，便于程序处理。
*)
let tone_to_simple_pattern tone = match tone with LevelTone -> true | _ -> false

(* 分析简化平仄模式：将诗句转换为平仄序列
   化繁为简，以平仄二元表示声调。便于格律检验。
*)
let analyze_simple_tone_pattern verse =
  let chars = Utf8_utils.StringUtils.utf8_to_char_list verse in
  List.map (fun char_str -> tone_to_simple_pattern (detect_tone_by_string char_str)) chars

(* 七言绝句标准平仄模式：传统七绝格律
   七言绝句，起承转合。平仄相间，声调和谐。
   首句平仄平仄平仄平，承句仄平仄平仄平仄。
   此为千古传承之格律，不可轻易更改。
*)
let qijue_tone_patterns =
  [
    (* 首句 *)
    [ true; false; true; false; true; false; true ];
    (* 平仄平仄平仄平 *)
    (* 承句 *)
    [ false; true; false; true; false; true; false ];
    (* 仄平仄平仄平仄 *)
    (* 转句 *)
    [ false; true; false; true; true; false; false ];
    (* 仄平仄平平仄仄 *)
    (* 合句 *)
    [ true; false; true; false; true; false; true ];
    (* 平仄平仄平仄平 *)
  ]

(* 五言律诗标准平仄模式：传统五律格律
   五言律诗，格律严整。平仄相对，声调和谐。
   首句平平仄仄平，承句仄仄平平仄。
   此为律诗之正格，诗家必须遵循。
*)
let wuyan_tone_patterns =
  [
    (* 首句 *)
    [ true; true; false; false; true ];
    (* 平平仄仄平 *)
    (* 承句 *)
    [ false; false; true; true; false ];
    (* 仄仄平平仄 *)
    (* 转句 *)
    [ false; false; true; true; true ];
    (* 仄仄平平平 *)
    (* 合句 *)
    [ true; true; false; false; true ];
    (* 平平仄仄平 *)
  ]

(* 四言骈体标准平仄模式：传统四言格律
   四言骈体，简洁有力。平仄相对，声调和谐。
   上句平平仄仄，下句仄仄平平。对仗工整，声律严谨。
*)
let siyan_tone_patterns =
  [ [ true; true; false; false ]; (* 平平仄仄 *) [ false; false; true; true ] (* 仄仄平平 *) ]

(* 验证平仄模式：检查诗句是否符合指定格律
   格律如法，不容违背。验证平仄，以确保诗词之正统。
*)
let validate_tone_pattern verse expected_pattern =
  let actual_pattern = analyze_simple_tone_pattern verse in
  let char_count = List.length actual_pattern in
  let expected_count = List.length expected_pattern in

  if char_count = expected_count then
    let matches = List.map2 ( = ) actual_pattern expected_pattern in
    let correct_count = List.length (List.filter (fun x -> x) matches) in
    let accuracy = float_of_int correct_count /. float_of_int char_count in
    accuracy >= 0.8 (* 允许20%的容错 *)
  else false

(* 验证七言绝句平仄：检查七绝是否符合传统格律
   七绝四句，句句有法。验证平仄，确保格律无误。
*)
let validate_qijue_tone_pattern verses =
  if List.length verses <> 4 then false
  else List.for_all2 validate_tone_pattern verses qijue_tone_patterns

(* 验证五言律诗平仄：检查五律是否符合传统格律
   五律八句，联联相对。验证平仄，确保律诗之正。
*)
let validate_wuyan_tone_pattern verses =
  if List.length verses <> 4 then false
  else List.for_all2 validate_tone_pattern verses wuyan_tone_patterns

(* 验证四言骈体平仄：检查四言是否符合骈体格律
   四言骈体，对仗工整。验证平仄，确保骈体之美。
*)
let validate_siyan_tone_pattern verses =
  if List.length verses <> 2 then false
  else List.for_all2 validate_tone_pattern verses siyan_tone_patterns

(* 声调分析报告：详细记录诗句的声调特征
   包含声调序列、平仄模式、格律匹配及改进建议。
   如医者诊脉，详尽记录，指导诗词创作。
*)
type tone_analysis_report = {
  verse : string;
  tone_sequence : tone_type list;
  simple_pattern : bool list;
  pattern_match : bool;
  suggestions : string list;
}

(* 生成声调分析报告：为诗句提供全面的声调分析
   逐字分析，详细报告。声调模式，一目了然。
*)
let generate_tone_report verse expected_pattern =
  let tone_sequence = analyze_tone_sequence verse in
  let simple_pattern = analyze_simple_tone_pattern verse in
  let pattern_match = validate_tone_pattern verse expected_pattern in
  let suggestions = if pattern_match then [] else [ "请检查平仄搭配"; "建议调整字词选择" ] in
  { verse; tone_sequence; simple_pattern; pattern_match; suggestions }

(* 建议平仄改进：为诗句提供平仄调整建议
   文章不厌百回改，平仄调谐需精心。此函提供改进之策。
*)
let suggest_tone_improvements verse expected_pattern =
  let actual_pattern = analyze_simple_tone_pattern verse in
  let chars = Utf8_utils.StringUtils.utf8_to_char_list verse in

  let rec combine3 l1 l2 l3 =
    match (l1, l2, l3) with
    | [], [], [] -> []
    | h1 :: t1, h2 :: t2, h3 :: t3 -> (h1, h2, h3) :: combine3 t1 t2 t3
    | _ -> []
  in
  let suggestions =
    List.mapi
      (fun i (char_str, actual, expected) ->
        if actual <> expected then
          let needed_tone = if expected then "平声" else "仄声" in
          Some (Printf.sprintf "第%d字'%s'应为%s" (i + 1) char_str needed_tone)
        else None)
      (combine3 chars actual_pattern expected_pattern)
  in

  List.filter_map (fun x -> x) suggestions

(* 获取字符建议：根据声调类型提供用字建议
   平仄搭配，用字有讲究。此函可为诗家提供用字建议。
*)
let get_tone_character_suggestions target_tone =
  let candidates =
    List.filter_map
      (fun (char, tone) -> if tone = target_tone then Some char else None)
      tone_database
  in
  let rec take n lst =
    if n <= 0 then [] else match lst with [] -> [] | h :: t -> h :: take (n - 1) t
  in
  take 10 candidates

(* 导出函数：模块接口导出
   开放接口，供外部调用。平仄检测，皆可得之。
*)
let () = ()
