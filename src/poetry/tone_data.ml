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

(* 声调数据库：汇集常用汉字之声调
   依《康熙字典》、《说文解字》等典籍，收录常用汉字声调。
   一字一音，一音一调。声调分明，方能成诗。
*)
let tone_database =
  [
    (* 平声字符 *)
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
    ("诗", LevelTone);
    ("时", LevelTone);
    ("知", LevelTone);
    ("思", LevelTone);
    ("之", LevelTone);
    ("真", LevelTone);
    ("新", LevelTone);
    ("春", LevelTone);
    ("分", LevelTone);
    ("云", LevelTone);
    ("文", LevelTone);
    ("闻", LevelTone);
    ("问", LevelTone);
    (* 仄声字符 (上声、去声、入声) *)
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
    ("小", RisingTone);
    ("老", RisingTone);
    ("早", RisingTone);
    ("少", RisingTone);
    ("了", RisingTone);
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
    ("用", DepartingTone);
    ("动", DepartingTone);
    ("等", DepartingTone);
    ("定", DepartingTone);
    ("令", DepartingTone);
    ("命", DepartingTone);
    ("类", DepartingTone);
    ("比", DepartingTone);
    ("值", DepartingTone);
    ("置", DepartingTone);
    ("望", DepartingTone);
    ("放", DepartingTone);
    ("向", DepartingTone);
    ("让", DepartingTone);
    ("当", DepartingTone);
    ("于", DepartingTone);
    ("但", DepartingTone);
    ("到", DepartingTone);
    ("道", DepartingTone);
    ("要", DepartingTone);
    ("在", DepartingTone);
    ("再", DepartingTone);
    ("对", DepartingTone);
    ("却", DepartingTone);
    ("就", DepartingTone);
    ("是", DepartingTone);
    ("为", DepartingTone);
    ("做", DepartingTone);
    ("作", DepartingTone);
    ("个", DepartingTone);
    ("这", DepartingTone);
    ("那", DepartingTone);
    ("下", DepartingTone);
    ("不", DepartingTone);
    ("没", DepartingTone);
    ("会", DepartingTone);
    ("能", DepartingTone);
    ("还", DepartingTone);
    ("已", DepartingTone);
    ("经", DepartingTone);
    ("过", DepartingTone);
    ("自", DepartingTone);
    ("从", DepartingTone);
    ("很", DepartingTone);
    ("多", DepartingTone);
    ("大", DepartingTone);
    ("高", DepartingTone);
    ("低", DepartingTone);
    ("快", DepartingTone);
    ("慢", DepartingTone);
    ("坏", DepartingTone);
    ("旧", DepartingTone);
    ("美", DepartingTone);
    ("丑", DepartingTone);
    ("入", EnteringTone);
    ("出", EnteringTone);
    ("得", EnteringTone);
    ("结", EnteringTone);
    ("法", EnteringTone);
    ("达", EnteringTone);
    ("合", EnteringTone);
    ("接", EnteringTone);
    ("切", EnteringTone);
    ("别", EnteringTone);
    ("说", EnteringTone);
    ("读", EnteringTone);
    ("写", EnteringTone);
    ("学", EnteringTone);
    ("实", EnteringTone);
    ("识", EnteringTone);
    ("极", EnteringTone);
    ("力", EnteringTone);
    ("立", EnteringTone);
    ("及", EnteringTone);
    ("级", EnteringTone);
    ("集", EnteringTone);
    ("急", EnteringTone);
    ("即", EnteringTone);
    ("则", EnteringTone);
    ("测", EnteringTone);
    ("策", EnteringTone);
    ("册", EnteringTone);
    ("色", EnteringTone);
    ("索", EnteringTone);
    ("搜", EnteringTone);
    ("收", EnteringTone);
    ("白", EnteringTone);
    ("黑", EnteringTone);
    ("红", EnteringTone);
    ("绿", EnteringTone);
    ("蓝", EnteringTone);
    ("黄", EnteringTone);
    ("紫", EnteringTone);
    ("灰", EnteringTone);
  ]