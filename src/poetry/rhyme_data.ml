(** 音韵数据存储模块 - 骆言诗词编程特性
    
    盖古之诗者，音韵为要。此模块统一管理音韵数据，
    引用分离后的数据模块，架构清晰便于维护。
    依《广韵》、《集韵》等韵书传统，模块化管理。
    
    重构说明：将大型数据列表分离为独立模块，
    提升代码可维护性和模块化程度。
    
    @author 骆言诗词编程团队
    @version 2.0 (重构版)
    @since 2025-07-18
*)

open Rhyme_types

(** {1 音韵数据统一接口} *)

(** 引入分离后的数据模块 *)
module An_yun = Poetry_data.An_yun_data

(** {2 平声韵数据 - 重构后接口} *)

(** 安韵组数据 - 从独立模块引入，140行数据拆分为独立文件 *)
let an_yun_ping_sheng = 
  List.map (fun (char, _, _) -> (char, PingSheng, AnRhyme)) An_yun.an_yun_ping_sheng

(** 思韵组 - 诗时知思，情思绵绵如春水 *)
let si_yun_ping_sheng = [
  ("诗", PingSheng, SiRhyme);
  ("时", PingSheng, SiRhyme);
  ("知", PingSheng, SiRhyme);
  ("思", PingSheng, SiRhyme);
  ("程", PingSheng, SiRhyme);
  ("成", PingSheng, SiRhyme);
  ("清", PingSheng, SiRhyme);
  ("同", PingSheng, SiRhyme);
  ("中", PingSheng, SiRhyme);
  ("东", PingSheng, SiRhyme);
  ("冬", PingSheng, SiRhyme);
  ("终", PingSheng, SiRhyme);
  ("钟", PingSheng, SiRhyme);
  ("种", PingSheng, SiRhyme);
  ("重", PingSheng, SiRhyme);
  ("充", PingSheng, SiRhyme);
  ("冲", PingSheng, SiRhyme);
  ("虫", PingSheng, SiRhyme);
  ("崇", PingSheng, SiRhyme);
  ("匆", PingSheng, SiRhyme);
  ("从", PingSheng, SiRhyme);
  ("丛", PingSheng, SiRhyme);
  ("聪", PingSheng, SiRhyme);
  ("葱", PingSheng, SiRhyme);
  ("囱", PingSheng, SiRhyme);
  ("松", PingSheng, SiRhyme);
  ("嵩", PingSheng, SiRhyme);
  ("送", PingSheng, SiRhyme);
  ("宋", PingSheng, SiRhyme);
  ("颂", PingSheng, SiRhyme);
  ("诵", PingSheng, SiRhyme);
  ("耸", PingSheng, SiRhyme);
  ("怂", PingSheng, SiRhyme);
  ("悚", PingSheng, SiRhyme);
  ("粟", PingSheng, SiRhyme);
  ("肃", PingSheng, SiRhyme);
  ("宿", PingSheng, SiRhyme);
  ("素", PingSheng, SiRhyme);
  ("速", PingSheng, SiRhyme);
  ("塑", PingSheng, SiRhyme);
  ("诉", PingSheng, SiRhyme);
  ("溯", PingSheng, SiRhyme);
  ("蔌", PingSheng, SiRhyme);
  ("夙", PingSheng, SiRhyme);
  ("俗", PingSheng, SiRhyme);
  ("谷", PingSheng, SiRhyme);
  ("鼓", PingSheng, SiRhyme);
  ("古", PingSheng, SiRhyme);
  ("故", PingSheng, SiRhyme);
  ("固", PingSheng, SiRhyme);
  ("顾", PingSheng, SiRhyme);
  ("雇", PingSheng, SiRhyme);
  ("股", PingSheng, SiRhyme);
  ("骨", PingSheng, SiRhyme);
  ("姑", PingSheng, SiRhyme);
  ("孤", PingSheng, SiRhyme);
  ("辜", PingSheng, SiRhyme);
  ("菇", PingSheng, SiRhyme);
  ("枯", PingSheng, SiRhyme);
  ("哭", PingSheng, SiRhyme);
  ("库", PingSheng, SiRhyme);
  ("裤", PingSheng, SiRhyme);
  ("酷", PingSheng, SiRhyme);
  ("窟", PingSheng, SiRhyme);
  ("苦", PingSheng, SiRhyme);
  ("堵", PingSheng, SiRhyme);
  ("赌", PingSheng, SiRhyme);
  ("毒", PingSheng, SiRhyme);
  ("独", PingSheng, SiRhyme);
  ("读", PingSheng, SiRhyme);
  ("督", PingSheng, SiRhyme);
  ("都", PingSheng, SiRhyme);
  ("豆", PingSheng, SiRhyme);
  ("斗", PingSheng, SiRhyme);
  ("抖", PingSheng, SiRhyme);
  ("逗", PingSheng, SiRhyme);
  ("痘", PingSheng, SiRhyme);
  ("陡", PingSheng, SiRhyme);
  ("兜", PingSheng, SiRhyme);
  ("蚪", PingSheng, SiRhyme);
  ("窦", PingSheng, SiRhyme);
  ("渎", PingSheng, SiRhyme);
  ("牍", PingSheng, SiRhyme);
  ("椟", PingSheng, SiRhyme);
  ("犊", PingSheng, SiRhyme);
  ("黩", PingSheng, SiRhyme);
  ("浊", PingSheng, SiRhyme);
  ("濯", PingSheng, SiRhyme);
  ("灼", PingSheng, SiRhyme);
  ("拙", PingSheng, SiRhyme);
  ("卓", PingSheng, SiRhyme);
  ("啄", PingSheng, SiRhyme);
  ("着", PingSheng, SiRhyme);
]

(** 天韵组 - 天年先田，天籁之音驰太虚 *)
let tian_yun_ping_sheng = [
  ("天", PingSheng, TianRhyme);
  ("年", PingSheng, TianRhyme);
  ("先", PingSheng, TianRhyme);
  ("田", PingSheng, TianRhyme);
  ("言", PingSheng, TianRhyme);
  ("然", PingSheng, TianRhyme);
  ("连", PingSheng, TianRhyme);
  ("边", PingSheng, TianRhyme);
  ("变", PingSheng, TianRhyme);
  ("见", PingSheng, TianRhyme);
  ("面", PingSheng, TianRhyme);
  ("前", PingSheng, TianRhyme);
  ("钱", PingSheng, TianRhyme);
  ("千", PingSheng, TianRhyme);
  ("迁", PingSheng, TianRhyme);
  ("牵", PingSheng, TianRhyme);
  ("签", PingSheng, TianRhyme);
  ("浅", PingSheng, TianRhyme);
  ("遣", PingSheng, TianRhyme);
  ("谴", PingSheng, TianRhyme);
  ("歉", PingSheng, TianRhyme);
  ("欠", PingSheng, TianRhyme);
  ("倩", PingSheng, TianRhyme);
  ("嵌", PingSheng, TianRhyme);
  ("悭", PingSheng, TianRhyme);
  ("涧", PingSheng, TianRhyme);
  ("建", PingSheng, TianRhyme);
  ("健", PingSheng, TianRhyme);
  ("键", PingSheng, TianRhyme);
  ("渐", PingSheng, TianRhyme);
  ("间", PingSheng, TianRhyme);
  ("监", PingSheng, TianRhyme);
  ("坚", PingSheng, TianRhyme);
  ("兼", PingSheng, TianRhyme);
  ("肩", PingSheng, TianRhyme);
  ("艰", PingSheng, TianRhyme);
  ("奸", PingSheng, TianRhyme);
  ("尖", PingSheng, TianRhyme);
  ("煎", PingSheng, TianRhyme);
  ("拣", PingSheng, TianRhyme);
  ("检", PingSheng, TianRhyme);
  ("减", PingSheng, TianRhyme);
  ("简", PingSheng, TianRhyme);
  ("茧", PingSheng, TianRhyme);
  ("碱", PingSheng, TianRhyme);
  ("剪", PingSheng, TianRhyme);
  ("箭", PingSheng, TianRhyme);
]

(** {2 仄声韵数据} *)

(** 望韵组 - 上想望放，远望之意蕴深情 *)
let wang_yun_ze_sheng = [
  ("上", ZeSheng, WangRhyme);
  ("想", ZeSheng, WangRhyme);
  ("望", ZeSheng, WangRhyme);
  ("放", ZeSheng, WangRhyme);
  ("向", ZeSheng, WangRhyme);
  ("响", ZeSheng, WangRhyme);
  ("象", ZeSheng, WangRhyme);
  ("像", ZeSheng, WangRhyme);
  ("相", ZeSheng, WangRhyme);
  ("项", ZeSheng, WangRhyme);
  ("享", ZeSheng, WangRhyme);
  ("详", ZeSheng, WangRhyme);
  ("祥", ZeSheng, WangRhyme);
  ("翔", ZeSheng, WangRhyme);
  ("香", ZeSheng, WangRhyme);
  ("乡", ZeSheng, WangRhyme);
]

(** 去韵组 - 去路度步，去声之韵意深远 *)
let qu_yun_ze_sheng = [
  ("去", ZeSheng, QuRhyme);
  ("路", ZeSheng, QuRhyme);
  ("度", ZeSheng, QuRhyme);
  ("步", ZeSheng, QuRhyme);
  ("处", ZeSheng, QuRhyme);
  ("住", ZeSheng, QuRhyme);
  ("数", ZeSheng, QuRhyme);
  ("组", ZeSheng, QuRhyme);
  ("序", ZeSheng, QuRhyme);
  ("述", ZeSheng, QuRhyme);
  ("树", ZeSheng, QuRhyme);
  ("注", ZeSheng, QuRhyme);
  ("助", ZeSheng, QuRhyme);
  ("主", ZeSheng, QuRhyme);
  ("著", ZeSheng, QuRhyme);
  ("驻", ZeSheng, QuRhyme);
  ("柱", ZeSheng, QuRhyme);
  ("筑", ZeSheng, QuRhyme);
  ("竹", ZeSheng, QuRhyme);
  ("逐", ZeSheng, QuRhyme);
  ("烛", ZeSheng, QuRhyme);
  ("族", ZeSheng, QuRhyme);
  ("足", ZeSheng, QuRhyme);
  ("阻", ZeSheng, QuRhyme);
  ("组", ZeSheng, QuRhyme);
  ("租", ZeSheng, QuRhyme);
  ("祖", ZeSheng, QuRhyme);
  ("诅", ZeSheng, QuRhyme);
  ("做", ZeSheng, QuRhyme);
  ("坐", ZeSheng, QuRhyme);
  ("座", ZeSheng, QuRhyme);
  ("作", ZeSheng, QuRhyme);
  ("昨", ZeSheng, QuRhyme);
]

(** {2 入声韵数据} *)

(** 入声韵组 - 音促而急，如鼓点节拍 *)
let ru_sheng_yun_zu = [
  ("国", RuSheng, QuRhyme);
  ("确", RuSheng, QuRhyme);
  ("却", RuSheng, QuRhyme);
  ("鹊", RuSheng, QuRhyme);
  ("雀", RuSheng, QuRhyme);
  ("缺", RuSheng, QuRhyme);
  ("阙", RuSheng, QuRhyme);
  ("瘸", RuSheng, QuRhyme);
  ("炔", RuSheng, QuRhyme);
  ("趣", RuSheng, QuRhyme);
  ("取", RuSheng, QuRhyme);
  ("娶", RuSheng, QuRhyme);
  ("曲", RuSheng, QuRhyme);
  ("屈", RuSheng, QuRhyme);
  ("驱", RuSheng, QuRhyme);
  ("区", RuSheng, QuRhyme);
  ("躯", RuSheng, QuRhyme);
  ("渠", RuSheng, QuRhyme);
  ("蛆", RuSheng, QuRhyme);
  ("蠕", RuSheng, QuRhyme);
  ("如", RuSheng, QuRhyme);
  ("儒", RuSheng, QuRhyme);
  ("乳", RuSheng, QuRhyme);
  ("辱", RuSheng, QuRhyme);
  ("入", RuSheng, QuRhyme);
  ("日", RuSheng, QuRhyme);
  ("肉", RuSheng, QuRhyme);
  ("柔", RuSheng, QuRhyme);
  ("揉", RuSheng, QuRhyme);
  ("若", RuSheng, QuRhyme);
  ("弱", RuSheng, QuRhyme);
  ("锐", RuSheng, QuRhyme);
  ("瑞", RuSheng, QuRhyme);
  ("睿", RuSheng, QuRhyme);
  ("蕊", RuSheng, QuRhyme);
  ("芮", RuSheng, QuRhyme);
  ("闰", RuSheng, QuRhyme);
  ("润", RuSheng, QuRhyme);
  ("软", RuSheng, QuRhyme);
  ("孀", RuSheng, QuRhyme);
  ("爽", RuSheng, QuRhyme);
  ("谁", RuSheng, QuRhyme);
  ("水", RuSheng, QuRhyme);
  ("税", RuSheng, QuRhyme);
  ("睡", RuSheng, QuRhyme);
  ("吮", RuSheng, QuRhyme);
  ("顺", RuSheng, QuRhyme);
  ("瞬", RuSheng, QuRhyme);
  ("舜", RuSheng, QuRhyme);
  ("硕", RuSheng, QuRhyme);
  ("朔", RuSheng, QuRhyme);
  ("烁", RuSheng, QuRhyme);
  ("铄", RuSheng, QuRhyme);
  ("妁", RuSheng, QuRhyme);
  ("蒴", RuSheng, QuRhyme);
  ("搠", RuSheng, QuRhyme);
  ("槊", RuSheng, QuRhyme);
]

(** {1 音韵数据库合成} *)

(** 音韵数据库 - 合并所有韵组的完整数据库 
    
    通过组合各韵组数据，形成完整的音韵数据库。
    此设计使数据结构清晰，便于维护和扩展。
    各韵组数据相互独立，符合模块化设计原则。
*)
let rhyme_database = 
  an_yun_ping_sheng @ 
  si_yun_ping_sheng @ 
  tian_yun_ping_sheng @
  wang_yun_ze_sheng @ 
  qu_yun_ze_sheng @
  ru_sheng_yun_zu

