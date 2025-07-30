(** 行数和字数检查器接口
    
    @author Alpha, 主要开发代理
    @version 1.0
    @since 2025-07-30 *)

open Meter_types

(** 行检查结果类型 *)
type line_check_result = {
  line_count_compliance : bool;
  line_length_compliance : bool list;
  line_count_violations : string list;
  line_length_violations : string list;
}

(** {1 行数检查} *)

(** 检查诗句行数是否符合要求 *)
val check_line_count : string list -> meter_pattern -> bool * string list

(** {1 字数检查} *)

(** 计算单行字符数 (考虑中文字符) *)
val count_chinese_chars : string -> int

(** 检查各行字数是否符合要求 *)
val check_line_lengths : string list -> meter_pattern -> bool list * string list

(** {1 综合行检查} *)

(** 执行所有行相关检查 *)
val check_all_line_requirements : string list -> meter_pattern -> line_check_result

(** {1 辅助功能} *)

(** 生成行数相关的改进建议 *)
val generate_line_suggestions : string list -> string list -> string list

(** 计算行检查的符合度得分 *)
val calculate_line_compliance_score : bool -> bool list -> float