(** Poetry Core Consolidated Module - Issue #1999 
 * 
 * 核心类型和基础API统一模块
 * Author: Whisky, PR Worker
 * 
 * 整合以下模块的功能：
 * - poetry_types_*.ml (类型定义)
 * - poetry_recommended_api.ml (推荐API)
 * - core/types.ml (核心类型)
 * - poetry_standards.ml (标准定义)
 * 
 * 目标：提供统一的类型系统和基础API接口
 *)

(** {1 核心类型定义} *)

(** 韵律分类 *)
type rhyme_category = 
  | PingSheng    (** 平声 *)
  | ShangSheng   (** 上声 *)
  | QuSheng      (** 去声 *)
  | RuSheng      (** 入声 *)

(** 韵部分组 *)
type rhyme_group = 
  | Feng | Hua | Yu | Hui | Jiang | Yue
  | Other of string

(** 韵律信息 *)
type rhyme_info = {
  category: rhyme_category;
  group: rhyme_group;
  tone_pattern: int option;  (** 声调模式 *)
  char: string;             (** 字符 *)
}

(** 诗词格式类型 *)
type poetry_form = 
  | WuYanLushi    (** 五言律诗 *)
  | QiYanLushi    (** 七言律诗 *)
  | WuYanJueju    (** 五言绝句 *)
  | QiYanJueju    (** 七言绝句 *)
  | Custom of string

(** 评价维度 *)
type evaluation_dimension = 
  | Rhyme       (** 韵律 *)
  | Artistic    (** 艺术性 *)
  | Form        (** 格律 *)
  | Content     (** 内容 *)
  | Sound       (** 音韵 *)

(** 评价结果 *)
type evaluation_result = {
  overall_score: float;                                    (** 总体分数 0.0-1.0 *)
  dimension_scores: (evaluation_dimension * float) list;   (** 各维度分数 *)
  rhyme_quality: float;                                   (** 韵律质量 *)
  artistic_quality: float;                                (** 艺术质量 *)
  form_compliance: float;                                 (** 格律符合度 *)
  recommendations: string list;                           (** 改进建议 *)
}

(** 韵律匹配结果 *)
type rhyme_match_result = {
  is_match: bool;           (** 是否匹配 *)
  confidence: float;        (** 匹配置信度 *)
  match_type: string;       (** 匹配类型 *)
  suggestions: string list; (** 改进建议 *)
}

(** {1 核心API函数} *)

(** 韵律信息缓存 *)
let rhyme_info_cache = Hashtbl.create 1000

(** 预定义韵律数据 - 简化版本用于快速查询 *)
let basic_rhyme_data = [
  ("风", { category = PingSheng; group = Feng; tone_pattern = Some 1; char = "风" });
  ("花", { category = PingSheng; group = Hua; tone_pattern = Some 1; char = "花" });
  ("语", { category = ShangSheng; group = Yu; tone_pattern = Some 3; char = "语" });
  ("雨", { category = ShangSheng; group = Yu; tone_pattern = Some 3; char = "雨" });
  ("江", { category = PingSheng; group = Jiang; tone_pattern = Some 1; char = "江" });
  ("月", { category = RuSheng; group = Yue; tone_pattern = Some 4; char = "月" });
  ("回", { category = PingSheng; group = Hui; tone_pattern = Some 2; char = "回" });
]

(** 初始化韵律数据缓存 *)
let initialize_rhyme_cache () =
  List.iter (fun (char, info) -> 
    Hashtbl.replace rhyme_info_cache char info
  ) basic_rhyme_data

(** 查找字符的韵律信息 *)
let find_rhyme_info (char_str: string) : rhyme_info option =
  try
    Some (Hashtbl.find rhyme_info_cache char_str)
  with Not_found -> None

(** 检测韵律类型 *)
let detect_rhyme_category (char_str: string) : rhyme_category =
  match find_rhyme_info char_str with
  | Some info -> info.category
  | None -> PingSheng  (* 默认平声 *)

(** 验证两个字符是否押韵 *)
let check_rhyme_match (char1_str: string) (char2_str: string) : bool =
  match (find_rhyme_info char1_str, find_rhyme_info char2_str) with
  | Some info1, Some info2 -> info1.group = info2.group
  | _ -> false

(** 获取韵部分组名称 *)
let get_rhyme_group_name = function
  | Feng -> "风韵"
  | Hua -> "花韵"  
  | Yu -> "语韵"
  | Hui -> "回韵"
  | Jiang -> "江韵"
  | Yue -> "月韵"
  | Other s -> s

(** 获取韵律分类名称 *)
let get_rhyme_category_name = function
  | PingSheng -> "平声"
  | ShangSheng -> "上声"
  | QuSheng -> "去声"
  | RuSheng -> "入声"

(** 分析诗句的韵律模式 *)
let analyze_line_rhyme (line: string) : rhyme_info list =
  let chars = List.init (String.length line) (String.get line) in
  let char_strings = List.map (String.make 1) chars in
  List.filter_map find_rhyme_info char_strings

(** 简化的诗词评价函数 *)
let evaluate_poem_basic (poem_lines: string list) : evaluation_result =
  let line_count = List.length poem_lines in
  let total_chars = List.fold_left (fun acc line -> acc + String.length line) 0 poem_lines in
  
  (* 基础韵律分析 *)
  let rhyme_analysis = List.map analyze_line_rhyme poem_lines in
  let rhyme_chars = List.fold_left (@) [] rhyme_analysis in
  let rhyme_score = 
    if total_chars > 0 then 
      float_of_int (List.length rhyme_chars) /. float_of_int total_chars
    else 0.0
  in
  
  (* 基础格律检查 *)
  let form_score = 
    match line_count with
    | 4 -> 0.8  (* 可能是绝句 *)
    | 8 -> 0.9  (* 可能是律诗 *)
    | _ -> 0.6  (* 其他形式 *)
  in
  
  (* 艺术性简单评估 *)
  let artistic_score = 
    let avg_line_length = if line_count > 0 then total_chars / line_count else 0 in
    match avg_line_length with
    | 5 | 7 -> 0.8  (* 典型的五言或七言 *)
    | _ -> 0.6
  in
  
  let overall = (rhyme_score +. form_score +. artistic_score) /. 3.0 in
  
  {
    overall_score = overall;
    dimension_scores = [
      (Rhyme, rhyme_score);
      (Form, form_score);
      (Artistic, artistic_score);
    ];
    rhyme_quality = rhyme_score;
    artistic_quality = artistic_score;
    form_compliance = form_score;
    recommendations = [
      "使用更多押韵字符提升韵律效果";
      "保持规范的诗词格式";
      "增强诗词的艺术表现力";
    ];
  }

(** 预加载韵律数据 *)
let preload_rhyme_data () : unit =
  initialize_rhyme_cache ()

(** 清理缓存数据 *)
let cleanup_cache () : unit =
  Hashtbl.clear rhyme_info_cache

(** {1 字符串转换函数} *)

(** 韵类转字符串 *)
let rhyme_category_to_string = function
  | PingSheng -> "平声"
  | ShangSheng -> "上声"
  | QuSheng -> "去声"
  | RuSheng -> "入声"

(** 韵组转字符串 *)
let rhyme_group_to_string = function
  | Feng -> "峰韵"
  | Hua -> "华韵"
  | Yu -> "鱼韵"
  | Hui -> "灰韵"
  | Jiang -> "江韵"
  | Yue -> "月韵"
  | Other s -> s ^ "韵"

(** {1 兼容性函数} *)

(** 向后兼容：模拟旧API *)
let find_rhyme_info_compat = find_rhyme_info
let detect_rhyme_category_compat = detect_rhyme_category
let check_rhyme_match_compat = check_rhyme_match

(** 初始化模块 *)
let () = initialize_rhyme_cache ()