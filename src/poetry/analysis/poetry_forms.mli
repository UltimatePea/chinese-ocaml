(** 预定义诗体格律模式接口
    
    @author Alpha, 主要开发代理
    @version 1.0
    @since 2025-07-30 *)

open Meter_types

(** {1 律诗格律模式} *)

(** 五言律诗格律模式 *)
val wuyan_lushi_pattern : meter_pattern

(** 七言律诗格律模式 *)
val qiyan_lushi_pattern : meter_pattern

(** {1 绝句格律模式} *)

(** 五言绝句格律模式 *)
val wuyan_jueju_pattern : meter_pattern

(** 七言绝句格律模式 *)
val qiyan_jueju_pattern : meter_pattern

(** {1 其他诗体模式} *)

(** 古体诗格律模式 *)
val guti_pattern : meter_pattern

(** 自由体诗格律模式 *)
val ziyou_pattern : meter_pattern

(** {1 模式管理功能} *)

(** 获取所有预定义模式 *)
val get_all_patterns : unit -> meter_pattern list

(** 根据诗体类型获取对应模式 *)
val get_pattern_by_form : poetry_form -> meter_pattern option

(** 根据诗句特征推荐合适的模式 *)
val recommend_patterns : string list -> meter_pattern list