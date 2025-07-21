(* 声调数据库模块 - 骆言诗词编程特性
   夫诗词之道，平仄为纲。平声如流水，仄声如敲玉。
   此模块专司声调数据存储，为平仄检测提供数据基础。
   凡作诗词，必明平仄，后成佳篇。
   
   重构说明：将大量硬编码数据提取到独立的数据存储模块中，
   提高代码可维护性和编译性能。
*)

(* 声调类型定义：依中古音韵系统分类声调
   古之音韵，分平上去入四声。平声悠扬，仄声急促。
   今承古制，以明声调之别，为诗词创作提供准绳。
*)
type tone_type =
  | LevelTone (* 平声 *)
  | FallingTone (* 仄声 *)
  | RisingTone (* 上声 *)
  | DepartingTone (* 去声 *)
  | EnteringTone (* 入声 *)

(** {1 声调数据分组} *)

module ExternalizedTone = Poetry_data.Externalized_data_loader
(** 引入外化数据加载器模块 *)

(** 平声字符 - 音平而长，如江河流水 重构：从硬编码数据改为JSON外化数据 *)
let ping_sheng_chars =
  List.map (fun char -> (char, LevelTone)) (ExternalizedTone.get_ping_sheng_list ())

(** 上声字符 - 音上扬，如询问之声 重构：从硬编码数据改为JSON外化数据 *)
let shang_sheng_chars =
  List.map (fun char -> (char, RisingTone)) (ExternalizedTone.get_shang_sheng_list ())

(** 去声字符 - 音下降，如叹息之音 重构：从硬编码数据改为JSON外化数据 *)
let qu_sheng_chars =
  List.map (fun char -> (char, DepartingTone)) (ExternalizedTone.get_qu_sheng_list ())

(** 入声字符 - 音促而急，如鼓点之节 重构：从硬编码数据改为JSON外化数据 *)
let ru_sheng_chars =
  List.map (fun char -> (char, EnteringTone)) (ExternalizedTone.get_ru_sheng_list ())

(** {1 声调数据库合成} *)

(** 声调数据库 - 合并所有声调分组的完整数据库

    通过组合各声调数据，形成完整的声调数据库。 此设计使数据结构清晰，便于维护和扩展。 各声调数据相互独立，符合模块化设计原则。 *)
let tone_database = ping_sheng_chars @ shang_sheng_chars @ qu_sheng_chars @ ru_sheng_chars
