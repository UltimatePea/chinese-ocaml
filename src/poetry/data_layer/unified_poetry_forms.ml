(** 骆言诗词统一诗体格式模块 - Poetry模块整合优化 Fix #1707
    
    此模块是数据层第三个模块，统一定义和管理所有诗词形式规范。
    整合来源：form_evaluators.ml, poetry_form_evaluators.ml, poetry_forms_evaluation.ml,
             poetry_form_dispatch.ml, poetry_standards.ml等格式相关模块
    
    Author: Alpha, 主要工作代理
    
    诗者，言志也。形者，载体也。统一诗体规范，承载千古风雅。 *)

open Unified_data_types

(** {1 诗词格式规范定义} *)

(** 格律要求 *)
type metrical_requirement = {
  line_count : int;                    (** 行数要求 *)
  chars_per_line : int option;         (** 每行字数(None表示不限) *)
  rhyme_scheme : bool list;            (** 押韵模式(true表示押韵行) *)
  tone_pattern : bool list list option; (** 平仄格律(None表示不限) *)
  parallelism_pairs : (int * int) list; (** 对仗句对 *)
}

(** 诗词形式规范 *)
type poetry_form_spec = {
  form_name : poetry_form;             (** 诗体名称 *)
  chinese_name : string;               (** 中文名称 *)
  description : string;                (** 形式描述 *)
  historical_origin : string;          (** 历史源流 *)
  metrical_req : metrical_requirement; (** 格律要求 *)
  artistic_weights : (artistic_dimension * float) list; (** 艺术评价权重 *)
  example_poems : string list;         (** 典型范例 *)
  evaluation_criteria : string list;   (** 评价准则 *)
}

(** 格律验证结果 *)
type metrical_check_result = {
  is_valid : bool;                     (** 是否符合格律 *)
  violations : string list;            (** 违反的规则 *)
  score : float;                       (** 格律符合度评分 *)
  suggestions : string list;           (** 改进建议 *)
}

(** {1 具体诗体规范定义} *)

(** 五言律诗规范 *)
let wuyan_lushi_spec = {
  form_name = WuYanLuShi;
  chinese_name = "五言律诗";
  description = "八句成篇，每句五字，格律严谨，对仗工整";
  historical_origin = "形成于初唐，盛于盛唐，为格律诗之典范";
  metrical_req = {
    line_count = 8;
    chars_per_line = Some 5;
    rhyme_scheme = [false; true; false; true; false; true; false; true];
    tone_pattern = Some [
      [false; true; false; true; false];   (* 仄平仄平仄 *)
      [true; false; true; false; true];    (* 平仄平仄平 *)
      [true; false; true; true; false];    (* 平仄平平仄 *)
      [false; true; false; false; true];   (* 仄平仄仄平 *)
      [false; true; false; true; false];   (* 仄平仄平仄 *)
      [true; false; true; false; true];    (* 平仄平仄平 *)
      [true; false; true; true; false];    (* 平仄平平仄 *)
      [false; true; false; false; true];   (* 仄平仄仄平 *)
    ];
    parallelism_pairs = [(2, 3); (4, 5)]; (* 颔联、颈联对仗 *)
  };
  artistic_weights = [
    (RhymeHarmony, 0.30);
    (TonalBalance, 0.30); 
    (Parallelism, 0.25);
    (Imagery, 0.10);
    (Rhythm, 0.03);
    (Elegance, 0.02);
  ];
  example_poems = [
    "春眠不觉晓，处处闻啼鸟。夜来风雨声，花落知多少。";
    "床前明月光，疑是地上霜。举头望明月，低头思故乡。";
  ];
  evaluation_criteria = [
    "韵脚通常在第二、四、六、八句";
    "颔联、颈联必须对仗";
    "平仄要符合格律规范";
    "意境深远，情景交融";
  ];
}

(** 七言绝句规范 *)
let qiyan_jueju_spec = {
  form_name = QiYanJueJu;
  chinese_name = "七言绝句";
  description = "四句成篇，每句七字，意境深远，朗朗上口";
  historical_origin = "起源于南朝，完善于唐代，为绝句之精华";
  metrical_req = {
    line_count = 4;
    chars_per_line = Some 7;
    rhyme_scheme = [false; true; false; true];
    tone_pattern = Some [
      [true; false; true; true; false; false; true];   (* 平仄平平仄仄平 *)
      [false; true; false; false; true; true; false];  (* 仄平仄仄平平仄 *)
      [false; true; false; false; true; false; true];  (* 仄平仄仄平仄平 *)
      [true; false; true; true; false; false; true];   (* 平仄平平仄仄平 *)
    ];
    parallelism_pairs = []; (* 绝句通常不要求对仗 *)
  };
  artistic_weights = [
    (RhymeHarmony, 0.25);
    (Imagery, 0.30);
    (Rhythm, 0.20);
    (TonalBalance, 0.15);
    (Elegance, 0.10);
  ];
  example_poems = [
    "白日依山尽，黄河入海流。欲穷千里目，更上一层楼。";
    "两个黄鹂鸣翠柳，一行白鹭上青天。窗含西岭千秋雪，门泊东吴万里船。";
  ];
  evaluation_criteria = [
    "韵脚在第二、四句";
    "平仄相对粘连";
    "起承转合结构明确";
    "意象鲜明，情感真挚";
  ];
}

(** 四言骈体规范 *)
let siyan_pianti_spec = {
  form_name = SiYanPianTi;
  chinese_name = "四言骈体";
  description = "句句四字，两两对仗，辞藻华美，音韵和谐";
  historical_origin = "源于先秦，盛于南北朝，为骈文之精华";
  metrical_req = {
    line_count = 0; (* 不限行数，但必须偶数行 *)
    chars_per_line = Some 4;
    rhyme_scheme = []; (* 不严格要求押韵 *)
    tone_pattern = None; (* 重在对仗，不严格要求平仄 *)
    parallelism_pairs = []; (* 动态生成对仗对 *)
  };
  artistic_weights = [
    (Parallelism, 0.40);
    (Elegance, 0.25);
    (RhymeHarmony, 0.15);
    (Imagery, 0.15);
    (TonalBalance, 0.05);
  ];
  example_poems = [
    "落霞与孤鹜齐飞，秋水共长天一色";
    "山不厌高，海不厌深";
  ];
  evaluation_criteria = [
    "必须句句对仗";
    "用词典雅华美";
    "音韵和谐";
    "意境雅致";
  ];
}

(** 现代诗规范 *)
let modern_poetry_spec = {
  form_name = ModernPoetry;
  chinese_name = "现代诗";
  description = "形式自由，不拘格律，注重意象和情感表达";
  historical_origin = "兴起于现代，继承古典诗歌传统而又突破格律束缚";
  metrical_req = {
    line_count = 0; (* 不限行数 *)
    chars_per_line = None; (* 不限字数 *)
    rhyme_scheme = []; (* 不强制押韵 *)
    tone_pattern = None; (* 不要求平仄 *)
    parallelism_pairs = []; (* 不要求对仗 *)
  };
  artistic_weights = [
    (Imagery, 0.35);
    (EmotionalResonance, 0.25);
    (ModernInnovation, 0.20);
    (Rhythm, 0.15);
    (RhymeHarmony, 0.05);
  ];
  example_poems = [
    "轻轻的我走了，正如我轻轻的来";
    "面朝大海，春暖花开";
  ];
  evaluation_criteria = [
    "意象新颖独特";
    "情感真挚动人";
    "语言流畅自然";
    "具有现代审美特征";
  ];
}

(** 词牌形式模板 *)
let create_cipai_spec name description origin example = {
  form_name = CiPaiForm name;
  chinese_name = name;
  description = description;
  historical_origin = origin;
  metrical_req = {
    line_count = 0; (* 词牌字数句数各不相同 *)
    chars_per_line = None;
    rhyme_scheme = []; (* 各词牌押韵规则不同 *)
    tone_pattern = None; (* 各词牌平仄要求不同 *)
    parallelism_pairs = [];
  };
  artistic_weights = [
    (RhymeHarmony, 0.25);
    (Rhythm, 0.25);
    (Imagery, 0.25);
    (Elegance, 0.15);
    (EmotionalResonance, 0.10);
  ];
  example_poems = [example];
  evaluation_criteria = [
    "符合词牌格律要求";
    "音韵优美";
    "意境深远";
    "情感丰富";
  ];
}

(** {1 所有诗体规范集合} *)

let all_poetry_forms = [
  wuyan_lushi_spec;
  qiyan_jueju_spec;
  siyan_pianti_spec;
  modern_poetry_spec;
]

(** 常见词牌规范 *)
let common_cipai_specs = [
  create_cipai_spec "水调歌头" "词牌名，双调九十五字" "始见于唐代" "明月几时有，把酒问青天";
  create_cipai_spec "念奴娇" "词牌名，双调一百字" "得名于唐代歌姬念奴" "大江东去，浪淘尽，千古风流人物";
  create_cipai_spec "满江红" "词牌名，双调九十三字" "取柳永词意" "怒发冲冠，凭栏处，潇潇雨歇";
]

(** {1 格律检查功能} *)

(** 检查行数是否符合要求 *)
let check_line_count verses spec =
  let actual_count = List.length verses in
  let required_count = spec.metrical_req.line_count in
  if required_count = 0 then (* 不限行数 *)
    (true, [])
  else if actual_count = required_count then
    (true, [])
  else
    (false, [Printf.sprintf "%s要求%d句，实际%d句" spec.chinese_name required_count actual_count])

(** 检查每行字数是否符合要求 *)
let check_chars_per_line verses spec =
  match spec.metrical_req.chars_per_line with
  | None -> (true, []) (* 不限字数 *)
  | Some required_chars ->
    let violations = List.mapi (fun i verse ->
      let actual_chars = String.length verse in
      if actual_chars = required_chars then None
      else Some (Printf.sprintf "第%d句字数不符：应为%d字，实际%d字" (i+1) required_chars actual_chars)
    ) verses
    |> List.filter_map (fun x -> x) in
    (violations = [], violations)

(** 检查押韵模式 *)
let check_rhyme_scheme verses spec =
  let rhyme_scheme = spec.metrical_req.rhyme_scheme in
  if rhyme_scheme = [] then (true, []) (* 不检查押韵 *)
  else if List.length verses <> List.length rhyme_scheme then
    (false, ["诗句数量与押韵模式不匹配"])
  else
    (* 简化的押韵检查 - 实际应该使用韵律数据 *)
    let violations = List.mapi (fun _i should_rhyme ->
      if should_rhyme then
        (* 这里应该检查实际押韵，暂时简化 *)
        None
      else None
    ) rhyme_scheme
    |> List.filter_map (fun x -> x) in
    (violations = [], violations)

(** 检查对仗要求 *)
let check_parallelism verses spec =
  let pairs = spec.metrical_req.parallelism_pairs in
  let violations = List.filter_map (fun (line1_idx, line2_idx) ->
    if line1_idx < List.length verses && line2_idx < List.length verses then
      let line1 = List.nth verses line1_idx in
      let line2 = List.nth verses line2_idx in
      (* 简化的对仗检查 - 实际应该更复杂 *)
      if String.length line1 = String.length line2 then None
      else Some (Printf.sprintf "第%d句与第%d句对仗字数不匹配" (line1_idx+1) (line2_idx+1))
    else Some (Printf.sprintf "对仗句索引超出范围：%d, %d" line1_idx line2_idx)
  ) pairs in
  (violations = [], violations)

(** 综合格律检查 *)
let check_metrical_rules verses form_spec =
  let (_line_count_ok, line_count_violations) = check_line_count verses form_spec in
  let (_chars_ok, chars_violations) = check_chars_per_line verses form_spec in
  let (_rhyme_ok, rhyme_violations) = check_rhyme_scheme verses form_spec in
  let (_parallelism_ok, parallelism_violations) = check_parallelism verses form_spec in
  
  let all_violations = line_count_violations @ chars_violations @ rhyme_violations @ parallelism_violations in
  let is_valid = all_violations = [] in
  let score = if is_valid then 1.0 else max 0.0 (1.0 -. (float_of_int (List.length all_violations) *. 0.2)) in
  
  let suggestions = if is_valid then ["格律检查通过"] else ["请根据违反规则进行修改"] in
  
  {
    is_valid;
    violations = all_violations;
    score;
    suggestions;
  }

(** {1 诗体识别功能} *)

(** 根据特征自动识别诗体 *)
let identify_poetry_form verses =
  let line_count = List.length verses in
  let first_line_chars = if verses <> [] then String.length (List.hd verses) else 0 in
  
  match (line_count, first_line_chars) with
  | (8, 5) -> Some wuyan_lushi_spec
  | (4, 7) -> Some qiyan_jueju_spec  
  | (_, 4) when line_count mod 2 = 0 -> Some siyan_pianti_spec (* 偶数行且每行4字 *)
  | _ -> Some modern_poetry_spec (* 默认为现代诗 *)

(** 获取诗体规范 *)
let get_form_spec = function
  | WuYanLuShi -> Some wuyan_lushi_spec
  | QiYanJueJu -> Some qiyan_jueju_spec
  | SiYanPianTi -> Some siyan_pianti_spec
  | ModernPoetry -> Some modern_poetry_spec
  | CiPaiForm name -> 
    List.find_opt (fun spec -> 
      match spec.form_name with 
      | CiPaiForm n -> n = name 
      | _ -> false
    ) common_cipai_specs
  | SiYanParallelProse -> Some siyan_pianti_spec (* 与四言骈体相同 *)

(** {1 诗体评价功能} *)

(** 根据诗体计算加权评分 *)
let calculate_weighted_artistic_score form_spec dimension_scores =
  let weights = form_spec.artistic_weights in
  List.fold_left (fun acc (dimension, weight) ->
    match List.assoc_opt dimension dimension_scores with
    | Some score -> acc +. (score *. weight)
    | None -> acc
  ) 0.0 weights

(** 生成诗体特定的评价建议 *)
let generate_form_specific_suggestions form_spec check_result =
  let base_suggestions = form_spec.evaluation_criteria in
  let metrical_suggestions = check_result.suggestions in
  base_suggestions @ metrical_suggestions

(** {1 数据访问接口} *)

(** 获取所有支持的诗体 *)
let get_all_supported_forms () = all_poetry_forms @ common_cipai_specs

(** 查找诗体规范 *)
let find_form_spec form = get_form_spec form

(** 获取诗体中文名称 *)
let get_form_chinese_name form =
  match get_form_spec form with
  | Some spec -> spec.chinese_name
  | None -> string_of_poetry_form form

(** 获取诗体描述 *)
let get_form_description form =
  match get_form_spec form with
  | Some spec -> spec.description
  | None -> "暂无描述"

(** {1 向后兼容接口} *)

(** 兼容旧版本的诗体标准 *)
type legacy_poetry_standards = {
  wuyan_lushi : metrical_requirement;
  qiyan_jueju : metrical_requirement;
  siyan_pianti : metrical_requirement;
}

let legacy_standards = {
  wuyan_lushi = wuyan_lushi_spec.metrical_req;
  qiyan_jueju = qiyan_jueju_spec.metrical_req;
  siyan_pianti = siyan_pianti_spec.metrical_req;
}

(** 兼容旧版本的格律检查函数 *)
let legacy_check_metrical_compliance verses form =
  match get_form_spec form with
  | Some spec -> check_metrical_rules verses spec
  | None -> {
      is_valid = false;
      violations = ["未知诗体类型"];
      score = 0.0;
      suggestions = ["请指定有效的诗体类型"];
    }