(* 诗词艺术性评价器模块接口 - 核心评价算法 *)

open Artistic_types

(** 评价韵律和谐度 *)
val evaluate_rhyme_harmony : string -> float

(** 评价声调平衡度 *)
val evaluate_tonal_balance : string -> bool list option -> float

(** 评价对仗工整度 *)
val evaluate_parallelism : string -> string -> float

(** 评价意象深度 *)
val evaluate_imagery : string -> float

(** 评价节奏感 *)
val evaluate_rhythm : string -> float

(** 评价雅致程度 *)
val evaluate_elegance : string -> float

(** 确定整体评级 *)
val determine_overall_grade : artistic_scores -> evaluation_grade