(** 百分比和置信度常量模块接口 *)

(** 置信度乘数 *)
val confidence_multiplier : float

(** 完全置信度 *)
val full_confidence : float

(** 零置信度 *)
val zero_confidence : float

(** 默认置信度阈值 *)
val default_confidence_threshold : float

(** 零除法后备值 *)
val zero_division_fallback : float

(** 百分比乘数 *)
val percentage_multiplier : float

(** 精度小数位数 *)
val precision_decimal_places : int