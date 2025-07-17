(* 声调数据库模块 - 骆言诗词编程特性
   夫诗词之道，平仄为纲。平声如流水，仄声如敲玉。
   此模块专司声调数据存储，为平仄检测提供数据基础。
   凡作诗词，必明平仄，后成佳篇。
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

(** 平声字符 - 音平而长，如江河流水 *)
let ping_sheng_chars = [
  ("一", LevelTone);
  ("天", LevelTone);
  ("年", LevelTone);
  ("先", LevelTone);
  ("田", LevelTone);
  ("言", LevelTone);
  ("然", LevelTone);
  ("连", LevelTone);
  ("边", LevelTone);
  ("山", LevelTone);
  ("间", LevelTone);
  ("闲", LevelTone);
  ("安", LevelTone);
  ("函", LevelTone);
  ("参", LevelTone);
  ("算", LevelTone);
  ("变", LevelTone);
  ("量", LevelTone);
  ("状", LevelTone);
  ("常", LevelTone);
  ("长", LevelTone);
  ("程", LevelTone);
  ("成", LevelTone);
  ("整", LevelTone);
  ("清", LevelTone);
  ("同", LevelTone);
  ("中", LevelTone);
  ("东", LevelTone);
  ("冬", LevelTone);
  ("终", LevelTone);
  ("钟", LevelTone);
  ("重", LevelTone);
  ("充", LevelTone);
  ("冲", LevelTone);
  ("虫", LevelTone);
  ("崇", LevelTone);
  ("匆", LevelTone);
  ("从", LevelTone);
  ("丛", LevelTone);
  ("聪", LevelTone);
  ("葱", LevelTone);
  ("囱", LevelTone);
  ("松", LevelTone);
  ("嵩", LevelTone);
  ("送", LevelTone);
  ("宋", LevelTone);
  ("颂", LevelTone);
  ("诵", LevelTone);
  ("耸", LevelTone);
  ("怂", LevelTone);
  ("悚", LevelTone);
]

(** 上声字符 - 音上扬，如询问之声 *)
let shang_sheng_chars = [
  ("上", RisingTone);
  ("想", RisingTone);
  ("两", RisingTone);
  ("有", RisingTone);
  ("所", RisingTone);
  ("者", RisingTone);
  ("也", RisingTone);
  ("可", RisingTone);
  ("我", RisingTone);
  ("你", RisingTone);
  ("好", RisingTone);
  ("很", RisingTone);
  ("小", RisingTone);
  ("老", RisingTone);
  ("早", RisingTone);
  ("晚", RisingTone);
  ("少", RisingTone);
  ("多", RisingTone);
  ("大", RisingTone);
  ("高", RisingTone);
]

(** 去声字符 - 音下降，如叹息之音 *)
let qu_sheng_chars = [
  ("去", DepartingTone);
  ("路", DepartingTone);
  ("度", DepartingTone);
  ("故", DepartingTone);
  ("步", DepartingTone);
  ("处", DepartingTone);
  ("住", DepartingTone);
  ("数", DepartingTone);
  ("组", DepartingTone);
  ("序", DepartingTone);
  ("述", DepartingTone);
  ("树", DepartingTone);
  ("注", DepartingTone);
  ("助", DepartingTone);
  ("主", DepartingTone);
  ("著", DepartingTone);
  ("驻", DepartingTone);
  ("柱", DepartingTone);
  ("筑", DepartingTone);
  ("竹", DepartingTone);
  ("逐", DepartingTone);
  ("烛", DepartingTone);
  ("族", DepartingTone);
  ("足", DepartingTone);
  ("阻", DepartingTone);
  ("租", DepartingTone);
  ("祖", DepartingTone);
  ("诅", DepartingTone);
  ("做", DepartingTone);
  ("坐", DepartingTone);
  ("座", DepartingTone);
  ("作", DepartingTone);
  ("昨", DepartingTone);
  ("最", DepartingTone);
  ("罪", DepartingTone);
  ("醉", DepartingTone);
  ("嘴", DepartingTone);
  ("左", DepartingTone);
  ("右", DepartingTone);
]

(** 入声字符 - 音促而急，如鼓点之节 *)
let ru_sheng_chars = [
  ("国", EnteringTone);
  ("确", EnteringTone);
  ("却", EnteringTone);
  ("鹊", EnteringTone);
  ("雀", EnteringTone);
  ("缺", EnteringTone);
  ("阙", EnteringTone);
  ("瘸", EnteringTone);
  ("炔", EnteringTone);
  ("曲", EnteringTone);
  ("屈", EnteringTone);
  ("驱", EnteringTone);
  ("区", EnteringTone);
  ("躯", EnteringTone);
  ("渠", EnteringTone);
  ("蛆", EnteringTone);
  ("蠕", EnteringTone);
  ("如", EnteringTone);
  ("儒", EnteringTone);
  ("乳", EnteringTone);
  ("辱", EnteringTone);
  ("入", EnteringTone);
  ("日", EnteringTone);
  ("肉", EnteringTone);
  ("柔", EnteringTone);
  ("揉", EnteringTone);
  ("若", EnteringTone);
  ("弱", EnteringTone);
  ("锐", EnteringTone);
  ("瑞", EnteringTone);
  ("睿", EnteringTone);
  ("蕊", EnteringTone);
  ("芮", EnteringTone);
  ("闰", EnteringTone);
  ("润", EnteringTone);
  ("软", EnteringTone);
  ("白", EnteringTone);
  ("黑", EnteringTone);
  ("红", EnteringTone);
  ("绿", EnteringTone);
  ("蓝", EnteringTone);
  ("黄", EnteringTone);
  ("紫", EnteringTone);
  ("灰", EnteringTone);
]

(** {1 声调数据库合成} *)

(** 声调数据库 - 合并所有声调分组的完整数据库
    
    通过组合各声调数据，形成完整的声调数据库。
    此设计使数据结构清晰，便于维护和扩展。
    各声调数据相互独立，符合模块化设计原则。
*)
let tone_database = 
  ping_sheng_chars @ 
  shang_sheng_chars @ 
  qu_sheng_chars @
  ru_sheng_chars