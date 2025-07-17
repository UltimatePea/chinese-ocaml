(* 对仗分析模块 - 骆言诗词编程特性
   夫诗词对仗，乃文学之精华，音韵之美感。
   出句对句，词性相对，声律相谐，意境相宜。
   此模块专司对仗分析，验证对仗工整，评估对仗质量。
   既遵古制，又开新风，为诗词编程提供完整的对仗支持。
*)

open Rhyme_analysis

(* 简单的UTF-8字符列表转换函数 *)
let utf8_to_char_list s =
  let rec aux acc i =
    if i >= String.length s then List.rev acc
    else aux (String.make 1 s.[i] :: acc) (i + 1)
  in
  aux [] 0

(* 词性分类：依传统诗词理论分类词性
   名词实词，动词虚词，形容词状语，各有所归。
   此分类用于对仗分析，确保词性相对。
*)
type word_class =
  | Noun          (* 名词 - 人物地名等实体 *)
  | Verb          (* 动词 - 动作行为等 *)
  | Adjective     (* 形容词 - 性质状态等 *)
  | Adverb        (* 副词 - 修饰动词形容词 *)
  | Numeral       (* 数词 - 一二三等数量 *)
  | Classifier    (* 量词 - 个只条等单位 *)
  | Pronoun       (* 代词 - 我你他等称谓 *)
  | Preposition   (* 介词 - 在于从等关系 *)
  | Conjunction   (* 连词 - 和与或等连接 *)
  | Particle      (* 助词 - 之乎者也等 *)
  | Interjection  (* 叹词 - 啊哎呀等感叹 *)
  | Unknown       (* 未知词性 - 待分析 *)

(* 对仗类型：按传统诗词理论分类对仗
   工对正对，宽对邻对，失对无对，各有等级。
*)
type parallelism_type =
  | PerfectParallelism    (* 工对 - 词性声律完全相对 *)
  | GoodParallelism       (* 正对 - 词性相对声律和谐 *)
  | LooseParallelism      (* 宽对 - 词性相近声律可容 *)
  | WeakParallelism       (* 邻对 - 词性相邻声律不完全 *)
  | NoParallelism         (* 无对 - 词性声律皆不相对 *)

(* 对仗位置：标识对仗在诗词中的位置
   首联颔联，颈联尾联，各有对仗要求。
*)
type parallelism_position =
  | FirstCouplet    (* 首联 - 诗词开头联 *)
  | SecondCouplet   (* 颔联 - 诗词第二联 *)
  | ThirdCouplet    (* 颈联 - 诗词第三联 *)
  | LastCouplet     (* 尾联 - 诗词结尾联 *)
  | MiddleCouplet   (* 中联 - 其他位置联 *)

(* 词性数据库：收录常用汉字词性
   依《现代汉语词典》、《古汉语常用字字典》等典籍，
   结合诗词用字特点，分类整理。
*)
let word_class_database = [
  (* 名词 *)
  ("人", Noun); ("天", Noun); ("地", Noun); ("山", Noun); ("水", Noun);
  ("日", Noun); ("月", Noun); ("星", Noun); ("云", Noun); ("风", Noun);
  ("雨", Noun); ("雪", Noun); ("花", Noun); ("草", Noun); ("木", Noun);
  ("树", Noun); ("林", Noun); ("石", Noun); ("土", Noun); ("火", Noun);
  ("光", Noun); ("影", Noun); ("声", Noun); ("音", Noun); ("色", Noun);
  ("春", Noun); ("夏", Noun); ("秋", Noun); ("冬", Noun); ("年", Noun);
  ("时", Noun); ("刻", Noun); ("分", Noun); ("秒", Noun); ("钟", Noun);
  ("心", Noun); ("意", Noun); ("情", Noun); ("思", Noun); ("念", Noun);
  ("梦", Noun); ("愿", Noun); ("望", Noun); ("爱", Noun); ("恨", Noun);
  ("道", Noun); ("路", Noun); ("门", Noun); ("窗", Noun); ("房", Noun);
  ("家", Noun); ("国", Noun); ("城", Noun); ("村", Noun); ("镇", Noun);
  ("江", Noun); ("河", Noun); ("湖", Noun); ("海", Noun); ("川", Noun);
  ("峰", Noun); ("岭", Noun); ("谷", Noun); ("沟", Noun); ("原", Noun);
  ("野", Noun); ("田", Noun); ("园", Noun); ("林", Noun); ("竹", Noun);
  ("梅", Noun); ("兰", Noun); ("竹", Noun); ("菊", Noun); ("松", Noun);
  ("柏", Noun); ("桃", Noun); ("李", Noun); ("杏", Noun); ("梨", Noun);
  
  (* 动词 *)
  ("是", Verb); ("有", Verb); ("来", Verb); ("去", Verb); ("看", Verb);
  ("听", Verb); ("说", Verb); ("想", Verb); ("知", Verb); ("会", Verb);
  ("能", Verb); ("行", Verb); ("走", Verb); ("跑", Verb); ("飞", Verb);
  ("游", Verb); ("坐", Verb); ("立", Verb); ("躺", Verb); ("睡", Verb);
  ("醒", Verb); ("起", Verb); ("落", Verb); ("升", Verb); ("降", Verb);
  ("开", Verb); ("关", Verb); ("进", Verb); ("出", Verb); ("入", Verb);
  ("回", Verb); ("归", Verb); ("返", Verb); ("达", Verb); ("到", Verb);
  ("过", Verb); ("经", Verb); ("历", Verb); ("遇", Verb); ("遭", Verb);
  ("得", Verb); ("失", Verb); ("成", Verb); ("败", Verb); ("胜", Verb);
  ("负", Verb); ("赢", Verb); ("输", Verb); ("胜", Verb); ("败", Verb);
  ("爱", Verb); ("恨", Verb); ("喜", Verb); ("怒", Verb); ("悲", Verb);
  ("欢", Verb); ("乐", Verb); ("愁", Verb); ("忧", Verb); ("思", Verb);
  ("望", Verb); ("盼", Verb); ("等", Verb); ("待", Verb); ("求", Verb);
  ("问", Verb); ("答", Verb); ("教", Verb); ("学", Verb); ("读", Verb);
  ("写", Verb); ("画", Verb); ("唱", Verb); ("跳", Verb); ("笑", Verb);
  ("哭", Verb); ("叫", Verb); ("喊", Verb); ("呼", Verb); ("唤", Verb);
  
  (* 形容词 *)
  ("大", Adjective); ("小", Adjective); ("长", Adjective); ("短", Adjective);
  ("高", Adjective); ("低", Adjective); ("深", Adjective); ("浅", Adjective);
  ("宽", Adjective); ("窄", Adjective); ("厚", Adjective); ("薄", Adjective);
  ("粗", Adjective); ("细", Adjective); ("重", Adjective); ("轻", Adjective);
  ("快", Adjective); ("慢", Adjective); ("早", Adjective); ("晚", Adjective);
  ("新", Adjective); ("旧", Adjective); ("老", Adjective); ("少", Adjective);
  ("多", Adjective); ("少", Adjective); ("好", Adjective); ("坏", Adjective);
  ("美", Adjective); ("丑", Adjective); ("亮", Adjective); ("暗", Adjective);
  ("明", Adjective); ("暗", Adjective); ("清", Adjective); ("浊", Adjective);
  ("净", Adjective); ("脏", Adjective); ("干", Adjective); ("湿", Adjective);
  ("热", Adjective); ("冷", Adjective); ("温", Adjective); ("凉", Adjective);
  ("暖", Adjective); ("寒", Adjective); ("苦", Adjective); ("甜", Adjective);
  ("酸", Adjective); ("辣", Adjective); ("咸", Adjective); ("淡", Adjective);
  ("香", Adjective); ("臭", Adjective); ("香", Adjective); ("臭", Adjective);
  ("硬", Adjective); ("软", Adjective); ("脆", Adjective); ("韧", Adjective);
  ("滑", Adjective); ("粗", Adjective); ("光", Adjective); ("毛", Adjective);
  ("尖", Adjective); ("钝", Adjective); ("锋", Adjective); ("利", Adjective);
  ("圆", Adjective); ("方", Adjective); ("直", Adjective); ("弯", Adjective);
  ("平", Adjective); ("斜", Adjective); ("正", Adjective); ("歪", Adjective);
  ("真", Adjective); ("假", Adjective); ("实", Adjective); ("虚", Adjective);
  ("空", Adjective); ("满", Adjective); ("穷", Adjective); ("富", Adjective);
  ("贫", Adjective); ("贵", Adjective); ("贱", Adjective); ("雅", Adjective);
  ("俗", Adjective); ("古", Adjective); ("今", Adjective); ("新", Adjective);
  
  (* 数词 *)
  ("一", Numeral); ("二", Numeral); ("三", Numeral); ("四", Numeral);
  ("五", Numeral); ("六", Numeral); ("七", Numeral); ("八", Numeral);
  ("九", Numeral); ("十", Numeral); ("百", Numeral); ("千", Numeral);
  ("万", Numeral); ("亿", Numeral); ("零", Numeral); ("半", Numeral);
  ("双", Numeral); ("单", Numeral); ("首", Numeral); ("第", Numeral);
  
  (* 量词 *)
  ("个", Classifier); ("只", Classifier); ("条", Classifier); ("根", Classifier);
  ("支", Classifier); ("枝", Classifier); ("片", Classifier); ("张", Classifier);
  ("块", Classifier); ("颗", Classifier); ("粒", Classifier); ("滴", Classifier);
  ("杯", Classifier); ("盘", Classifier); ("碗", Classifier); ("瓶", Classifier);
  ("袋", Classifier); ("包", Classifier); ("箱", Classifier); ("车", Classifier);
  ("船", Classifier); ("架", Classifier); ("台", Classifier); ("座", Classifier);
  ("栋", Classifier); ("层", Classifier); ("间", Classifier); ("套", Classifier);
  ("副", Classifier); ("双", Classifier); ("对", Classifier); ("群", Classifier);
  ("队", Classifier); ("班", Classifier); ("组", Classifier); ("批", Classifier);
  ("种", Classifier); ("类", Classifier); ("样", Classifier); ("回", Classifier);
  ("次", Classifier); ("遍", Classifier); ("趟", Classifier); ("场", Classifier);
  ("局", Classifier); ("轮", Classifier); ("阵", Classifier); ("阵", Classifier);
  
  (* 代词 *)
  ("我", Pronoun); ("你", Pronoun); ("他", Pronoun); ("她", Pronoun);
  ("它", Pronoun); ("这", Pronoun); ("那", Pronoun); ("哪", Pronoun);
  ("什", Pronoun); ("么", Pronoun); ("谁", Pronoun); ("何", Pronoun);
  ("此", Pronoun); ("彼", Pronoun); ("其", Pronoun); ("自", Pronoun);
  
  (* 介词 *)
  ("在", Preposition); ("从", Preposition); ("到", Preposition); ("向", Preposition);
  ("往", Preposition); ("于", Preposition); ("为", Preposition); ("对", Preposition);
  ("给", Preposition); ("替", Preposition); ("按", Preposition); ("照", Preposition);
  ("依", Preposition); ("据", Preposition); ("凭", Preposition); ("靠", Preposition);
  ("关", Preposition); ("由", Preposition); ("因", Preposition); ("为", Preposition);
  ("被", Preposition); ("让", Preposition); ("叫", Preposition); ("使", Preposition);
  ("令", Preposition); ("把", Preposition); ("将", Preposition); ("拿", Preposition);
  
  (* 连词 *)
  ("和", Conjunction); ("与", Conjunction); ("或", Conjunction); ("及", Conjunction);
  ("以", Conjunction); ("而", Conjunction); ("且", Conjunction); ("并", Conjunction);
  ("又", Conjunction); ("还", Conjunction); ("也", Conjunction); ("都", Conjunction);
  ("既", Conjunction); ("即", Conjunction); ("就", Conjunction); ("便", Conjunction);
  ("则", Conjunction); ("然", Conjunction); ("但", Conjunction); ("可", Conjunction);
  ("却", Conjunction); ("不", Conjunction); ("非", Conjunction); ("无", Conjunction);
  ("若", Conjunction); ("如", Conjunction); ("似", Conjunction); ("像", Conjunction);
  ("虽", Conjunction); ("尽", Conjunction); ("纵", Conjunction); ("假", Conjunction);
  ("设", Conjunction); ("倘", Conjunction); ("若", Conjunction); ("要", Conjunction);
  
  (* 助词 *)
  ("的", Particle); ("了", Particle); ("着", Particle); ("过", Particle);
  ("呢", Particle); ("吗", Particle); ("呀", Particle); ("吧", Particle);
  ("啊", Particle); ("哎", Particle); ("嗯", Particle); ("哦", Particle);
  ("之", Particle); ("乎", Particle); ("者", Particle); ("也", Particle);
  ("焉", Particle); ("哉", Particle); ("矣", Particle); ("耳", Particle);
  
  (* 叹词 *)
  ("啊", Interjection); ("哎", Interjection); ("呀", Interjection); ("嗯", Interjection);
  ("哦", Interjection); ("哇", Interjection); ("嘿", Interjection); ("嗨", Interjection);
  ("唉", Interjection); ("咦", Interjection); ("咋", Interjection); ("哟", Interjection);
  ("呦", Interjection); ("嘘", Interjection); ("嗬", Interjection); ("嚯", Interjection);
]

(* 检测词性：根据字符判断词性 *)
let detect_word_class char =
  let char_str = String.make 1 char in
  try
    let _, word_class = List.find (fun (ch, _) -> ch = char_str) word_class_database in
    word_class
  with Not_found -> Unknown

(* 检测词性相对性：判断两个词性是否相对
   工对要求词性完全相同，宽对允许相近词性。
*)
let word_classes_match class1 class2 match_level =
  match match_level with
  | PerfectParallelism -> class1 = class2
  | GoodParallelism -> 
      class1 = class2 || 
      (class1 = Noun && class2 = Pronoun) ||
      (class1 = Pronoun && class2 = Noun) ||
      (class1 = Adjective && class2 = Verb) ||
      (class1 = Verb && class2 = Adjective)
  | LooseParallelism ->
      class1 = class2 ||
      (class1 = Noun && (class2 = Pronoun || class2 = Classifier)) ||
      (class1 = Pronoun && (class2 = Noun || class2 = Classifier)) ||
      (class1 = Classifier && (class2 = Noun || class2 = Pronoun)) ||
      (class1 = Adjective && (class2 = Verb || class2 = Adverb)) ||
      (class1 = Verb && (class2 = Adjective || class2 = Adverb)) ||
      (class1 = Adverb && (class2 = Adjective || class2 = Verb))
  | WeakParallelism ->
      class1 <> Unknown && class2 <> Unknown
  | NoParallelism -> false

(* 分析对仗质量：评估两句诗的对仗程度
   综合考虑词性对仗、声律对仗、意境对仗等因素。
*)
let analyze_parallelism_quality line1 line2 =
  let chars1 = utf8_to_char_list line1 in
  let chars2 = utf8_to_char_list line2 in
  
  if List.length chars1 <> List.length chars2 then
    NoParallelism
  else
    let char_pairs = List.combine chars1 chars2 in
    let word_class_pairs = List.map (fun (c1_str, c2_str) ->
      let c1 = if String.length c1_str > 0 then c1_str.[0] else '?' in
      let c2 = if String.length c2_str > 0 then c2_str.[0] else '?' in
      (detect_word_class c1, detect_word_class c2)
    ) char_pairs in
    
    let rhyme_pairs = List.map (fun (c1_str, c2_str) ->
      let c1 = if String.length c1_str > 0 then c1_str.[0] else '?' in
      let c2 = if String.length c2_str > 0 then c2_str.[0] else '?' in
      (detect_rhyme_category c1, detect_rhyme_category c2)
    ) char_pairs in
    
    let total_pairs = List.length word_class_pairs in
    let perfect_matches = List.length (List.filter (fun (c1, c2) -> 
      word_classes_match c1 c2 PerfectParallelism) word_class_pairs) in
    let good_matches = List.length (List.filter (fun (c1, c2) -> 
      word_classes_match c1 c2 GoodParallelism) word_class_pairs) in
    let loose_matches = List.length (List.filter (fun (c1, c2) -> 
      word_classes_match c1 c2 LooseParallelism) word_class_pairs) in
    let weak_matches = List.length (List.filter (fun (c1, c2) -> 
      word_classes_match c1 c2 WeakParallelism) word_class_pairs) in
    
    let rhyme_matches = List.length (List.filter (fun (r1, r2) -> 
      (r1 = PingSheng && r2 = ZeSheng) || (r1 = ZeSheng && r2 = PingSheng)) rhyme_pairs) in
    
    let perfect_ratio = float_of_int perfect_matches /. float_of_int total_pairs in
    let good_ratio = float_of_int good_matches /. float_of_int total_pairs in
    let loose_ratio = float_of_int loose_matches /. float_of_int total_pairs in
    let weak_ratio = float_of_int weak_matches /. float_of_int total_pairs in
    let rhyme_ratio = float_of_int rhyme_matches /. float_of_int total_pairs in
    
    if perfect_ratio >= 0.8 && rhyme_ratio >= 0.6 then PerfectParallelism
    else if good_ratio >= 0.7 && rhyme_ratio >= 0.5 then GoodParallelism
    else if loose_ratio >= 0.6 && rhyme_ratio >= 0.4 then LooseParallelism
    else if weak_ratio >= 0.5 then WeakParallelism
    else NoParallelism

(* 对仗分析报告类型 *)
type parallelism_analysis_report = {
  line1 : string;
  line2 : string;
  parallelism_type : parallelism_type;
  word_class_pairs : (word_class * word_class) list;
  rhyme_pairs : (rhyme_category * rhyme_category) list;
  perfect_match_ratio : float;
  good_match_ratio : float;
  rhyme_match_ratio : float;
  overall_score : float;
}

(* 生成对仗分析报告：详细分析两句诗的对仗情况 *)
let generate_parallelism_report line1 line2 =
  let chars1 = utf8_to_char_list line1 in
  let chars2 = utf8_to_char_list line2 in
  
  let char_pairs = List.combine chars1 chars2 in
  let word_class_pairs = List.map (fun (c1_str, c2_str) ->
    let c1 = if String.length c1_str > 0 then c1_str.[0] else '?' in
    let c2 = if String.length c2_str > 0 then c2_str.[0] else '?' in
    (detect_word_class c1, detect_word_class c2)
  ) char_pairs in
  
  let rhyme_pairs = List.map (fun (c1_str, c2_str) ->
    let c1 = if String.length c1_str > 0 then c1_str.[0] else '?' in
    let c2 = if String.length c2_str > 0 then c2_str.[0] else '?' in
    (detect_rhyme_category c1, detect_rhyme_category c2)
  ) char_pairs in
  
  let total_pairs = List.length word_class_pairs in
  let perfect_matches = List.length (List.filter (fun (c1, c2) -> 
    word_classes_match c1 c2 PerfectParallelism) word_class_pairs) in
  let good_matches = List.length (List.filter (fun (c1, c2) -> 
    word_classes_match c1 c2 GoodParallelism) word_class_pairs) in
  let rhyme_matches = List.length (List.filter (fun (r1, r2) -> 
    (r1 = PingSheng && r2 = ZeSheng) || (r1 = ZeSheng && r2 = PingSheng)) rhyme_pairs) in
  
  let perfect_match_ratio = float_of_int perfect_matches /. float_of_int total_pairs in
  let good_match_ratio = float_of_int good_matches /. float_of_int total_pairs in
  let rhyme_match_ratio = float_of_int rhyme_matches /. float_of_int total_pairs in
  
  let parallelism_type = analyze_parallelism_quality line1 line2 in
  let overall_score = (perfect_match_ratio +. good_match_ratio +. rhyme_match_ratio) /. 3.0 in
  
  {
    line1 = line1;
    line2 = line2;
    parallelism_type = parallelism_type;
    word_class_pairs = word_class_pairs;
    rhyme_pairs = rhyme_pairs;
    perfect_match_ratio = perfect_match_ratio;
    good_match_ratio = good_match_ratio;
    rhyme_match_ratio = rhyme_match_ratio;
    overall_score = overall_score;
  }

(* 检验律诗对仗：检查律诗的对仗规则
   律诗颔联、颈联必须对仗，首联、尾联一般不对仗。
*)
let validate_regulated_verse_parallelism verses =
  if List.length verses <> 8 then
    failwith "律诗必须是八句"
  else
    let lines = Array.of_list verses in
    let second_couplet_report = generate_parallelism_report lines.(2) lines.(3) in
    let third_couplet_report = generate_parallelism_report lines.(4) lines.(5) in
    
    let second_couplet_quality = 
      match second_couplet_report.parallelism_type with
      | PerfectParallelism -> 1.0
      | GoodParallelism -> 0.8
      | LooseParallelism -> 0.6
      | WeakParallelism -> 0.4
      | NoParallelism -> 0.0
    in
    
    let third_couplet_quality = 
      match third_couplet_report.parallelism_type with
      | PerfectParallelism -> 1.0
      | GoodParallelism -> 0.8
      | LooseParallelism -> 0.6
      | WeakParallelism -> 0.4
      | NoParallelism -> 0.0
    in
    
    let overall_quality = (second_couplet_quality +. third_couplet_quality) /. 2.0 in
    
    (second_couplet_report, third_couplet_report, overall_quality)

(* 建议对仗改进：为不工整的对仗提供改进建议
   分析对仗问题，提供相应的词汇建议。
*)
let suggest_parallelism_improvements report =
  let suggestions = ref [] in
  
  (* 分析词性不对问题 *)
  let word_class_mismatches = List.filter (fun (c1, c2) -> 
    not (word_classes_match c1 c2 LooseParallelism)) report.word_class_pairs in
  
  if List.length word_class_mismatches > 0 then
    suggestions := "词性不对，建议调整词性相对的字词" :: !suggestions;
  
  (* 分析声律不对问题 *)
  let rhyme_mismatches = List.filter (fun (r1, r2) -> 
    not ((r1 = PingSheng && r2 = ZeSheng) || (r1 = ZeSheng && r2 = PingSheng))) report.rhyme_pairs in
  
  if List.length rhyme_mismatches > 0 then
    suggestions := "声律不对，建议调整平仄相对的字词" :: !suggestions;
  
  (* 总体评价 *)
  let overall_suggestion = 
    match report.parallelism_type with
    | PerfectParallelism -> "对仗工整，无需改进"
    | GoodParallelism -> "对仗良好，可适当调整"
    | LooseParallelism -> "对仗宽松，建议加强"
    | WeakParallelism -> "对仗较弱，需要改进"
    | NoParallelism -> "无对仗，需要重新构思"
  in
  
  overall_suggestion :: !suggestions

(* 导出函数：模块接口导出 *)
let () = ()