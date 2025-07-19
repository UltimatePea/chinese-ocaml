(** 骆言诗词格律标准定义模块
    从artistic_evaluation.ml重构而来，集中管理各种诗词形式的评价标准 *)

open Artistic_types

(** 四言骈体标准 *)
let siyan_standards =
  {
    char_count = 4;
    tone_pattern = [ true; true; false; false ];
    parallelism_required = true;
    rhythm_weight = 0.3;
  }

(** 五言律诗标准定义 *)
let wuyan_lushi_standards : wuyan_lushi_standards =
  {
    line_count = 8;
    char_per_line = 5;
    rhyme_scheme = [|false; true; false; true; false; true; false; true|];
    parallelism_required = [|false; false; true; true; true; true; false; false|];
    tone_pattern = [
      [ true; true; false; false; true ];   (* 首联起句 *)
      [ false; false; true; true; false ];  (* 首联对句 *)
      [ false; false; true; true; false ];  (* 颔联起句 *)
      [ true; true; false; false; true ];   (* 颔联对句 *)
      [ true; true; false; false; true ];   (* 颈联起句 *)
      [ false; false; true; true; false ];  (* 颈联对句 *)
      [ false; false; true; true; false ];  (* 尾联起句 *)
      [ true; true; false; false; true ];   (* 尾联对句 *)
    ];
    rhythm_weight = 0.4;
  }

(** 七言绝句标准定义 *)
let qiyan_jueju_standards : qiyan_jueju_standards =
  {
    line_count = 4;
    char_per_line = 7;
    rhyme_scheme = [|false; true; false; true|];
    parallelism_required = [|false; false; true; true|];
    tone_pattern = [
      [ true; true; false; false; true; true; false ];   (* 起句 *)
      [ false; false; true; true; false; false; true ];  (* 承句 *)
      [ false; false; true; true; false; false; true ];  (* 转句 *)
      [ true; true; false; false; true; true; false ];   (* 合句 *)
    ];
    rhythm_weight = 0.35;
  }

(** 根据诗词形式获取对应的评价标准 *)
let get_standards_for_form = function
  | SiYanPianTi -> Some (`SiYan siyan_standards)
  | WuYanLuShi -> Some (`WuYan wuyan_lushi_standards)
  | QiYanJueJu -> Some (`QiYan qiyan_jueju_standards)
  | CiPai _ -> None (* 词牌格律需要专门的实现 *)
  | ModernPoetry -> None (* 现代诗没有固定格律 *)
  | SiYanParallelProse -> Some (`SiYan siyan_standards) (* 四言骈体文，使用四言格律标准 *)

(** 验证诗句是否符合指定形式的基本要求 *)
module StandardsValidator = struct
  (** 验证四言骈体格式 *)
  let validate_siyan_format verses =
    let verse_lengths = List.map String.length verses in
    List.for_all (fun len -> len = 4) verse_lengths

  (** 验证五言律诗格式 *)
  let validate_wuyan_lushi_format verses =
    List.length verses = 8 &&
    List.for_all (fun verse -> String.length verse = 5) verses

  (** 验证七言绝句格式 *)
  let validate_qiyan_jueju_format verses =
    List.length verses = 4 &&
    List.for_all (fun verse -> String.length verse = 7) verses

  (** 根据形式验证诗词格式 *)
  let validate_format form verses =
    match form with
    | SiYanPianTi -> validate_siyan_format verses
    | WuYanLuShi -> validate_wuyan_lushi_format verses
    | QiYanJueJu -> validate_qiyan_jueju_format verses
    | CiPai _ -> true (* 词牌格律比较复杂，暂时返回true *)
    | ModernPoetry -> true (* 现代诗没有固定格式要求 *)
    | SiYanParallelProse -> validate_siyan_format verses (* 四言骈体文使用四言验证 *)
end

(** 标准配置工具 *)
module StandardsConfig = struct
  (** 获取形式的默认节奏权重 *)
  let get_default_rhythm_weight = function
    | SiYanPianTi -> siyan_standards.rhythm_weight
    | WuYanLuShi -> wuyan_lushi_standards.rhythm_weight
    | QiYanJueJu -> qiyan_jueju_standards.rhythm_weight
    | CiPai _ -> 0.3 (* 词牌的默认权重 *)
    | ModernPoetry -> 0.2 (* 现代诗的节奏权重较低 *)
    | SiYanParallelProse -> siyan_standards.rhythm_weight (* 四言骈体文使用四言权重 *)

  (** 获取形式的标准句数 *)
  let get_expected_line_count = function
    | SiYanPianTi -> None (* 四言骈体句数不固定 *)
    | WuYanLuShi -> Some wuyan_lushi_standards.line_count
    | QiYanJueJu -> Some qiyan_jueju_standards.line_count
    | CiPai _ -> None (* 词牌句数根据具体词牌而定 *)
    | ModernPoetry -> None (* 现代诗句数不固定 *)
    | SiYanParallelProse -> None (* 四言骈体文句数不固定 *)

  (** 获取形式的标准字数（每句） *)
  let get_expected_chars_per_line = function
    | SiYanPianTi -> Some siyan_standards.char_count
    | WuYanLuShi -> Some wuyan_lushi_standards.char_per_line
    | QiYanJueJu -> Some qiyan_jueju_standards.char_per_line
    | CiPai _ -> None (* 词牌每句字数不固定 *)
    | ModernPoetry -> None (* 现代诗每句字数不固定 *)
    | SiYanParallelProse -> Some siyan_standards.char_count (* 四言骈体文使用四言字数 *)

  (** 检查形式是否要求对仗 *)
  let requires_parallelism = function
    | SiYanPianTi -> siyan_standards.parallelism_required
    | WuYanLuShi -> true (* 律诗颔联、颈联要求对仗 *)
    | QiYanJueJu -> true (* 绝句后两句通常要求对仗 *)
    | CiPai _ -> false (* 词不严格要求对仗 *)
    | ModernPoetry -> false (* 现代诗不要求对仗 *)
    | SiYanParallelProse -> true (* 骈体文要求对仗 *)
end

(** 标准创建器 - 用于创建自定义标准 *)
module StandardsBuilder = struct
  (** 创建自定义四言骈体标准 *)
  let create_siyan_standards ~char_count ~tone_pattern ~parallelism_required ~rhythm_weight =
    { char_count; tone_pattern; parallelism_required; rhythm_weight }

  (** 创建自定义五言律诗标准 *)
  let create_wuyan_lushi_standards 
      ~line_count ~char_per_line ~rhyme_scheme ~parallelism_required ~tone_pattern ~rhythm_weight : wuyan_lushi_standards =
    { line_count; char_per_line; rhyme_scheme; parallelism_required; tone_pattern; rhythm_weight }

  (** 创建自定义七言绝句标准 *)
  let create_qiyan_jueju_standards 
      ~line_count ~char_per_line ~rhyme_scheme ~parallelism_required ~tone_pattern ~rhythm_weight : qiyan_jueju_standards =
    { line_count; char_per_line; rhyme_scheme; parallelism_required; tone_pattern; rhythm_weight }

end

(** 标准比较器 *)
module StandardsComparator = struct
  (** 比较两个四言骈体标准的相似度 *)
  let compare_siyan_standards std1 std2 =
    let char_match = if std1.char_count = std2.char_count then 1.0 else 0.0 in
    let pattern_match = if std1.tone_pattern = std2.tone_pattern then 1.0 else 0.0 in
    let parallelism_match = if std1.parallelism_required = std2.parallelism_required then 1.0 else 0.0 in
    let weight_diff = abs_float (std1.rhythm_weight -. std2.rhythm_weight) in
    let weight_match = 1.0 -. (weight_diff /. 1.0) in
    (char_match +. pattern_match +. parallelism_match +. weight_match) /. 4.0

  (** 获取标准的严格程度分数 *)
  let get_strictness_score = function
    | SiYanPianTi -> 0.8 (* 四言骈体要求较严格 *)
    | WuYanLuShi -> 0.9 (* 律诗要求最严格 *)
    | QiYanJueJu -> 0.7 (* 绝句要求中等严格 *)
    | CiPai _ -> 0.6 (* 词相对宽松 *)
    | ModernPoetry -> 0.3 (* 现代诗最宽松 *)
    | SiYanParallelProse -> 0.85 (* 四言骈体文要求很严格 *)
end