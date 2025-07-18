(* 声调数据库模块接口 - 骆言诗词编程特性 *)

(* 声调类型定义 *)
type tone_type =
  | LevelTone (* 平声 *)
  | FallingTone (* 仄声 *)
  | RisingTone (* 上声 *)
  | DepartingTone (* 去声 *)
  | EnteringTone (* 入声 *)

(* 声调数据库：汉字声调映射表
   包含常用汉字及其对应的声调信息
*)
val tone_database : (string * tone_type) list
