(** 数值常量模块接口 *)

(** 常用数值 *)
val zero : int
val one : int
val two : int
val three : int
val four : int
val five : int
val ten : int
val hundred : int
val thousand : int

(** 浮点数 *)
val zero_float : float
val one_float : float
val half_float : float
val pi : float

(** 比例和百分比 *)
val full_percentage : float
val half_percentage : float
val quarter_percentage : float

(** 类型复杂度常量 *)
val type_complexity_basic : int
val type_complexity_composite : int