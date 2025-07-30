(* 艺术数据向后兼容模块 *)

open Artistic_core_types

(** {1 默认数据定义} *)

let default_imagery_words =
  [
    "山";
    "水";
    "月";
    "风";
    "花";
    "鸟";
    "云";
    "雨";
    "雪";
    "霜";
    "春";
    "夏";
    "秋";
    "冬";
    "朝";
    "暮";
    "日";
    "星";
    "天";
    "地";
    "江";
    "河";
    "湖";
    "海";
    "松";
    "竹";
    "梅";
    "兰";
    "菊";
    "莲";
  ]

let default_elegant_words =
  [
    "之";
    "者";
    "也";
    "矣";
    "乎";
    "哉";
    "焉";
    "夫";
    "其";
    "若";
    "兮";
    "惟";
    "唯";
    "斯";
    "是";
    "谓";
    "盖";
    "且";
    "犹";
    "尚";
    "方";
    "将";
    "能";
    "可";
    "足";
    "得";
    "所";
    "于";
    "以";
    "为";
    "而";
    "与";
    "从";
    "自";
    "由";
  ]

(** {1 兼容性接口实现} *)

let load_imagery_data () : string list =
  match Artistic_query_engine.get_words_by_category Imagery with
  | Found words -> words
  | _ -> default_imagery_words

let load_elegant_data () : string list =
  match Artistic_query_engine.get_words_by_category Elegant with
  | Found words -> words
  | _ -> default_elegant_words

let check_word_availability (word : string) : bool =
  match Artistic_query_engine.get_word_info word with
  | Found _ -> true
  | _ -> List.mem word default_imagery_words || List.mem word default_elegant_words

(** {1 专用接口的向后兼容实现} *)

let get_imagery_keywords () : string list query_result =
  match Artistic_query_engine.get_words_by_category Imagery with
  | Found words -> Found words
  | NotFound -> Found default_imagery_words
  | QueryError err -> QueryError err

let get_elegant_words () : string list query_result =
  match Artistic_query_engine.get_words_by_category Elegant with
  | Found words -> Found words
  | NotFound -> Found default_elegant_words
  | QueryError err -> QueryError err

let get_classical_expressions () : string list query_result =
  match Artistic_query_engine.get_words_by_category Classical with
  | Found words -> Found words
  | NotFound ->
      let take n lst =
        let rec aux acc n = function
          | [] -> List.rev acc
          | x :: xs when n > 0 -> aux (x :: acc) (n - 1) xs
          | _ -> List.rev acc
        in
        aux [] n lst
      in
      Found (take 15 default_elegant_words)
  | QueryError err -> QueryError err

let get_formal_particles () : string list query_result =
  let particles = [ "之"; "乎"; "者"; "也"; "矣"; "焉"; "哉"; "兮" ] in
  Found particles
