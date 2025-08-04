(** 预定义诗体格律模式
    
    此模块包含常用诗体的格律模式定义，支持律诗、绝句等传统诗体。
    从原 meter_engine.ml 中提取，专门负责诗体模式管理。
    
    @author Alpha, 主要开发代理
    @version 1.0
    @since 2025-07-30
    @refactor_from meter_engine.ml (解决issue #1775技术债务) *)

(* 简化类型引用 *)
open Meter_types

(** {1 律诗格律模式} *)

(** 五言律诗格律模式 *)
let wuyan_lushi_pattern =
  {
    form = LuShi 5;
    required_lines = 8;
    line_lengths = [ 5; 5; 5; 5; 5; 5; 5; 5 ];
    rhyme_scheme =
      [ None; Some "YuRhyme"; None; Some "YuRhyme"; None; Some "YuRhyme"; None; Some "YuRhyme" ];
    tonal_pattern =
      [
        [ "ZeSheng"; "ZeSheng"; "PingSheng"; "PingSheng"; "ZeSheng" ];
        [ "PingSheng"; "PingSheng"; "ZeSheng"; "ZeSheng"; "PingSheng" ];
        [ "PingSheng"; "PingSheng"; "ZeSheng"; "ZeSheng"; "PingSheng" ];
        [ "ZeSheng"; "ZeSheng"; "PingSheng"; "PingSheng"; "ZeSheng" ];
        [ "ZeSheng"; "ZeSheng"; "PingSheng"; "PingSheng"; "ZeSheng" ];
        [ "PingSheng"; "PingSheng"; "ZeSheng"; "ZeSheng"; "PingSheng" ];
        [ "PingSheng"; "PingSheng"; "ZeSheng"; "ZeSheng"; "PingSheng" ];
        [ "ZeSheng"; "ZeSheng"; "PingSheng"; "PingSheng"; "ZeSheng" ];
      ];
    parallelism_requirements = [ (3, 4); (5, 6) ];
  }

(** 七言律诗格律模式 *)
let qiyan_lushi_pattern =
  {
    form = LuShi 7;
    required_lines = 8;
    line_lengths = [ 7; 7; 7; 7; 7; 7; 7; 7 ];
    rhyme_scheme =
      [ None; Some YuRhyme; None; Some YuRhyme; None; Some YuRhyme; None; Some YuRhyme ];
    tonal_pattern =
      [
        [ PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng ];
        [ ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng ];
        [ ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng ];
        [ PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng ];
        [ PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng ];
        [ ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng ];
        [ ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng ];
        [ PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng ];
      ];
    parallelism_requirements = [ (3, 4); (5, 6) ];
  }

(** {1 绝句格律模式} *)

(** 五言绝句格律模式 *)
let wuyan_jueju_pattern =
  {
    form = JueJu 5;
    required_lines = 4;
    line_lengths = [ 5; 5; 5; 5 ];
    rhyme_scheme = [ None; Some YuRhyme; None; Some YuRhyme ];
    tonal_pattern =
      [
        [ "ZeSheng"; "ZeSheng"; "PingSheng"; "PingSheng"; "ZeSheng" ];
        [ "PingSheng"; "PingSheng"; "ZeSheng"; "ZeSheng"; "PingSheng" ];
        [ "PingSheng"; "PingSheng"; "ZeSheng"; "ZeSheng"; "PingSheng" ];
        [ "ZeSheng"; "ZeSheng"; "PingSheng"; "PingSheng"; "ZeSheng" ];
      ];
    parallelism_requirements = [];
  }

(** 七言绝句格律模式 *)
let qiyan_jueju_pattern =
  {
    form = JueJu 7;
    required_lines = 4;
    line_lengths = [ 7; 7; 7; 7 ];
    rhyme_scheme = [ None; Some YuRhyme; None; Some YuRhyme ];
    tonal_pattern =
      [
        [ PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng ];
        [ ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng ];
        [ ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng ];
        [ PingSheng; PingSheng; ZeSheng; ZeSheng; PingSheng; PingSheng; ZeSheng ];
      ];
    parallelism_requirements = [];
  }

(** {1 其他诗体模式} *)

(** 古体诗格律模式 (较宽松) *)
let guti_pattern =
  {
    form = GuTi;
    required_lines = 0;
    (* 不限行数 *)
    line_lengths = [];
    (* 不限字数 *)
    rhyme_scheme = [];
    (* 不限韵式 *)
    tonal_pattern = [];
    (* 不限平仄 *)
    parallelism_requirements = [];
  }

(** 自由体诗格律模式 (最宽松) *)
let ziyou_pattern =
  {
    form = ZiYou;
    required_lines = 0;
    line_lengths = [];
    rhyme_scheme = [];
    tonal_pattern = [];
    parallelism_requirements = [];
  }

(** {1 模式管理功能} *)

(** 获取所有预定义模式 *)
let get_all_patterns () =
  [
    wuyan_lushi_pattern;
    qiyan_lushi_pattern;
    wuyan_jueju_pattern;
    qiyan_jueju_pattern;
    guti_pattern;
    ziyou_pattern;
  ]

(** 根据诗体类型获取对应模式 *)
let get_pattern_by_form = function
  | LuShi 5 -> Some wuyan_lushi_pattern
  | LuShi 7 -> Some qiyan_lushi_pattern
  | JueJu 5 -> Some wuyan_jueju_pattern
  | JueJu 7 -> Some qiyan_jueju_pattern
  | GuTi -> Some guti_pattern
  | ZiYou -> Some ziyou_pattern
  | _ -> None

(** 根据诗句特征推荐合适的模式 *)
let recommend_patterns verses =
  let line_count = List.length verses in
  let avg_length =
    if line_count = 0 then 0
    else List.fold_left (fun acc line -> acc + String.length line) 0 verses / line_count
  in
  match (line_count, avg_length) with
  | 8, 5 -> [ wuyan_lushi_pattern ]
  | 8, 7 -> [ qiyan_lushi_pattern ]
  | 4, 5 -> [ wuyan_jueju_pattern ]
  | 4, 7 -> [ qiyan_jueju_pattern ]
  | _, _ when line_count > 8 -> [ guti_pattern; ziyou_pattern ]
  | _ -> [ guti_pattern; ziyou_pattern ]
