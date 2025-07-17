(* 音韵分析模块接口 - 骆言诗词编程特性 *)

(* 韵母分类类型 *)
type rhyme_category =
  | PingSheng  (* 平声韵 *)
  | ZeSheng    (* 仄声韵 *)
  | ShangSheng (* 上声韵 *)
  | QuSheng    (* 去声韵 *)
  | RuSheng    (* 入声韵 *)

(* 韵组类型 *)
type rhyme_group = 
  | AnRhyme    (* 安韵组 *)
  | SiRhyme    (* 思韵组 *)
  | TianRhyme  (* 天韵组 *)
  | WangRhyme  (* 望韵组 *)
  | QuRhyme    (* 去韵组 *)
  | UnknownRhyme (* 未知韵组 *)

(* 韵律分析报告类型 *)
type rhyme_analysis_report = {
  verse : string;
  rhyme_ending : char option;
  rhyme_group : rhyme_group;
  rhyme_category : rhyme_category;
  char_analysis : (char * rhyme_category * rhyme_group) list;
}

(* 检测字符的韵母分类 *)
val detect_rhyme_category : char -> rhyme_category

(* 检测字符的韵组 *)
val detect_rhyme_group : char -> rhyme_group

(* 从字符串中提取韵脚字符 *)
val extract_rhyme_ending : string -> char option

(* 验证韵脚一致性 *)
val validate_rhyme_consistency : string list -> bool

(* 验证韵律方案 *)
val validate_rhyme_scheme : string list -> char list -> bool

(* 分析诗句的韵律信息 *)
val analyze_rhyme_pattern : string -> (char * rhyme_category * rhyme_group) list

(* 建议韵脚字符 *)
val suggest_rhyme_characters : rhyme_group -> string list

(* 检查两个字符是否押韵 *)
val chars_rhyme : char -> char -> bool

(* 生成韵律分析报告 *)
val generate_rhyme_report : string -> rhyme_analysis_report

(* 韵律美化建议 *)
val suggest_rhyme_improvements : string -> rhyme_group -> string list