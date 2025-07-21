(** 百分比和置信度常量模块接口 *)

val confidence_multiplier : float
(** 置信度乘数 *)

val full_confidence : float
(** 完全置信度 *)

val zero_confidence : float
(** 零置信度 *)

val default_confidence_threshold : float
(** 默认置信度阈值 *)

val zero_division_fallback : float
(** 零除法后备值 *)

val percentage_multiplier : float
(** 百分比乘数 *)

val precision_decimal_places : int
(** 精度小数位数 *)
