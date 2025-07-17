(* 音韵分析模块 - 骆言诗词编程特性 *)

open Yyocamlc_lib

type rhyme_category =
  | PingSheng (* 平声韵 *)
  | ZeSheng (* 仄声韵 *)
  | ShangSheng (* 上声韵 *)
  | QuSheng (* 去声韵 *)
  | RuSheng (* 入声韵 *)

type rhyme_group =
  | AnRhyme (* 安韵组 *)
  | SiRhyme (* 思韵组 *)
  | TianRhyme (* 天韵组 *)
  | WangRhyme (* 望韵组 *)
  | QuRhyme (* 去韵组 *)
  | UnknownRhyme (* 未知韵组 *)

(* 扩展韵母分类数据库 - 支持更多常用汉字 *)
let rhyme_database =
  [
    (* 平声韵 - 安韵组 *)
    ("安", PingSheng, AnRhyme);
    ("山", PingSheng, AnRhyme);
    ("间", PingSheng, AnRhyme);
    ("闲", PingSheng, AnRhyme);
    ("函", PingSheng, AnRhyme);
    ("参", PingSheng, AnRhyme);
    ("算", PingSheng, AnRhyme);
    ("量", PingSheng, AnRhyme);
    ("状", PingSheng, AnRhyme);
    ("常", PingSheng, AnRhyme);
    ("长", PingSheng, AnRhyme);
    ("班", PingSheng, AnRhyme);
    ("删", PingSheng, AnRhyme);
    ("关", PingSheng, AnRhyme);
    ("还", PingSheng, AnRhyme);
    ("环", PingSheng, AnRhyme);
    ("般", PingSheng, AnRhyme);
    ("看", PingSheng, AnRhyme);
    ("刊", PingSheng, AnRhyme);
    ("阑", PingSheng, AnRhyme);
    ("兰", PingSheng, AnRhyme);
    ("弹", PingSheng, AnRhyme);
    ("单", PingSheng, AnRhyme);
    ("丹", PingSheng, AnRhyme);
    ("残", PingSheng, AnRhyme);
    ("潺", PingSheng, AnRhyme);
    ("寒", PingSheng, AnRhyme);
    ("韩", PingSheng, AnRhyme);
    ("干", PingSheng, AnRhyme);
    ("官", PingSheng, AnRhyme);
    ("观", PingSheng, AnRhyme);
    ("宽", PingSheng, AnRhyme);
    ("欢", PingSheng, AnRhyme);
    ("团", PingSheng, AnRhyme);
    ("专", PingSheng, AnRhyme);
    ("端", PingSheng, AnRhyme);
    ("酸", PingSheng, AnRhyme);
    ("栏", PingSheng, AnRhyme);
    ("滩", PingSheng, AnRhyme);
    ("谈", PingSheng, AnRhyme);
    ("探", PingSheng, AnRhyme);
    ("弯", PingSheng, AnRhyme);
    ("湾", PingSheng, AnRhyme);
    ("完", PingSheng, AnRhyme);
    ("万", PingSheng, AnRhyme);
    ("顽", PingSheng, AnRhyme);
    ("烦", PingSheng, AnRhyme);
    ("繁", PingSheng, AnRhyme);
    ("番", PingSheng, AnRhyme);
    ("盘", PingSheng, AnRhyme);
    ("攀", PingSheng, AnRhyme);
    ("鞍", PingSheng, AnRhyme);
    ("案", PingSheng, AnRhyme);
    ("叹", PingSheng, AnRhyme);
    ("散", PingSheng, AnRhyme);
    ("满", PingSheng, AnRhyme);
    ("难", PingSheng, AnRhyme);
    ("南", PingSheng, AnRhyme);
    ("男", PingSheng, AnRhyme);
    ("蓝", PingSheng, AnRhyme);
    ("篮", PingSheng, AnRhyme);
    ("览", PingSheng, AnRhyme);
    ("懒", PingSheng, AnRhyme);
    ("烂", PingSheng, AnRhyme);
    ("滥", PingSheng, AnRhyme);
    ("暗", PingSheng, AnRhyme);
    ("叁", PingSheng, AnRhyme);
    ("三", PingSheng, AnRhyme);
    ("惨", PingSheng, AnRhyme);
    ("蚕", PingSheng, AnRhyme);
    ("含", PingSheng, AnRhyme);
    ("涵", PingSheng, AnRhyme);
    ("汉", PingSheng, AnRhyme);
    ("旱", PingSheng, AnRhyme);
    ("罕", PingSheng, AnRhyme);
    ("汗", PingSheng, AnRhyme);
    ("憾", PingSheng, AnRhyme);
    ("撼", PingSheng, AnRhyme);
    ("感", PingSheng, AnRhyme);
    ("赶", PingSheng, AnRhyme);
    ("敢", PingSheng, AnRhyme);
    ("橄", PingSheng, AnRhyme);
    ("甘", PingSheng, AnRhyme);
    ("坩", PingSheng, AnRhyme);
    ("钢", PingSheng, AnRhyme);
    ("刚", PingSheng, AnRhyme);
    ("冈", PingSheng, AnRhyme);
    ("纲", PingSheng, AnRhyme);
    ("缸", PingSheng, AnRhyme);
    ("肛", PingSheng, AnRhyme);
    ("港", PingSheng, AnRhyme);
    ("杠", PingSheng, AnRhyme);
    ("扛", PingSheng, AnRhyme);
    ("康", PingSheng, AnRhyme);
    ("抗", PingSheng, AnRhyme);
    ("炕", PingSheng, AnRhyme);
    ("烫", PingSheng, AnRhyme);
    ("汤", PingSheng, AnRhyme);
    ("糖", PingSheng, AnRhyme);
    ("塘", PingSheng, AnRhyme);
    ("堂", PingSheng, AnRhyme);
    ("棠", PingSheng, AnRhyme);
    ("桑", PingSheng, AnRhyme);
    ("嗓", PingSheng, AnRhyme);
    ("搡", PingSheng, AnRhyme);
    ("磅", PingSheng, AnRhyme);
    ("膀", PingSheng, AnRhyme);
    ("帮", PingSheng, AnRhyme);
    ("邦", PingSheng, AnRhyme);
    ("榜", PingSheng, AnRhyme);
    ("梆", PingSheng, AnRhyme);
    ("棒", PingSheng, AnRhyme);
    ("绑", PingSheng, AnRhyme);
    ("蚌", PingSheng, AnRhyme);
    ("谤", PingSheng, AnRhyme);
    ("傍", PingSheng, AnRhyme);
    ("旁", PingSheng, AnRhyme);
    ("庞", PingSheng, AnRhyme);
    ("胖", PingSheng, AnRhyme);
    ("抛", PingSheng, AnRhyme);
    ("炮", PingSheng, AnRhyme);
    ("泡", PingSheng, AnRhyme);
    ("跑", PingSheng, AnRhyme);
    ("袍", PingSheng, AnRhyme);
    ("刨", PingSheng, AnRhyme);
    ("饱", PingSheng, AnRhyme);
    ("褒", PingSheng, AnRhyme);
    ("苞", PingSheng, AnRhyme);
    ("包", PingSheng, AnRhyme);
    ("报", PingSheng, AnRhyme);
    ("抱", PingSheng, AnRhyme);
    ("豹", PingSheng, AnRhyme);
    ("暴", PingSheng, AnRhyme);
    ("堡", PingSheng, AnRhyme);
    ("保", PingSheng, AnRhyme);
    ("宝", PingSheng, AnRhyme);
    ("郑", PingSheng, AnRhyme);
    ("征", PingSheng, AnRhyme);
    ("正", PingSheng, AnRhyme);
    ("整", PingSheng, AnRhyme);
    ("争", PingSheng, AnRhyme);
    ("睁", PingSheng, AnRhyme);
    ("挣", PingSheng, AnRhyme);
    ("赠", PingSheng, AnRhyme);
    ("憎", PingSheng, AnRhyme);
    ("增", PingSheng, AnRhyme);
    ("曾", PingSheng, AnRhyme);
    ("蒸", PingSheng, AnRhyme);
    ("崩", PingSheng, AnRhyme);
    ("绷", PingSheng, AnRhyme);
    ("朋", PingSheng, AnRhyme);
    ("鹏", PingSheng, AnRhyme);
    ("彭", PingSheng, AnRhyme);
    ("蓬", PingSheng, AnRhyme);
    ("捧", PingSheng, AnRhyme);
    ("碰", PingSheng, AnRhyme);
    ("怦", PingSheng, AnRhyme);
    ("砰", PingSheng, AnRhyme);
    ("烹", PingSheng, AnRhyme);
    ("澎", PingSheng, AnRhyme);
    ("棚", PingSheng, AnRhyme);
    ("篷", PingSheng, AnRhyme);
    ("硼", PingSheng, AnRhyme);
    ("腾", PingSheng, AnRhyme);
    ("疼", PingSheng, AnRhyme);
    ("滕", PingSheng, AnRhyme);
    ("藤", PingSheng, AnRhyme);
    ("誊", PingSheng, AnRhyme);
    ("登", PingSheng, AnRhyme);
    ("灯", PingSheng, AnRhyme);
    ("等", PingSheng, AnRhyme);
    ("邓", PingSheng, AnRhyme);
    ("蹬", PingSheng, AnRhyme);
    ("凳", PingSheng, AnRhyme);
    ("瞪", PingSheng, AnRhyme);
    ("噔", PingSheng, AnRhyme);
    ("嘣", PingSheng, AnRhyme);
    ("泵", PingSheng, AnRhyme);
    ("甭", PingSheng, AnRhyme);
    ("塞", PingSheng, AnRhyme);
    ("腮", PingSheng, AnRhyme);
    ("鳃", PingSheng, AnRhyme);
    ("赛", PingSheng, AnRhyme);
    ("哀", PingSheng, AnRhyme);
    ("埃", PingSheng, AnRhyme);
    ("挨", PingSheng, AnRhyme);
    ("哎", PingSheng, AnRhyme);
    ("唉", PingSheng, AnRhyme);
    ("艾", PingSheng, AnRhyme);
    ("爱", PingSheng, AnRhyme);
    ("碍", PingSheng, AnRhyme);
    ("癌", PingSheng, AnRhyme);
    ("岸", PingSheng, AnRhyme);
    ("胺", PingSheng, AnRhyme);
    ("按", PingSheng, AnRhyme);
    ("氨", PingSheng, AnRhyme);
    ("俺", PingSheng, AnRhyme);

    (* 平声韵 - 思韵组 *)
    ("诗", PingSheng, SiRhyme);
    ("时", PingSheng, SiRhyme);
    ("知", PingSheng, SiRhyme);
    ("思", PingSheng, SiRhyme);
    ("程", PingSheng, SiRhyme);
    ("成", PingSheng, SiRhyme);
    ("整", PingSheng, SiRhyme);
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

    (* 平声韵 - 天韵组 *)
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
    ("签", PingSheng, TianRhyme);
    ("谦", PingSheng, TianRhyme);
    ("牵", PingSheng, TianRhyme);
    ("虔", PingSheng, TianRhyme);
    ("潜", PingSheng, TianRhyme);
    ("遣", PingSheng, TianRhyme);
    ("茜", PingSheng, TianRhyme);
    ("倩", PingSheng, TianRhyme);
    ("堑", PingSheng, TianRhyme);
    ("歉", PingSheng, TianRhyme);
    ("欠", PingSheng, TianRhyme);
    ("纤", PingSheng, TianRhyme);
    ("掮", PingSheng, TianRhyme);
    ("钎", PingSheng, TianRhyme);
    ("嵌", PingSheng, TianRhyme);
    ("浅", PingSheng, TianRhyme);
    ("谴", PingSheng, TianRhyme);
    ("缱", PingSheng, TianRhyme);
    ("椠", PingSheng, TianRhyme);
    ("黔", PingSheng, TianRhyme);
    ("钳", PingSheng, TianRhyme);
    ("乾", PingSheng, TianRhyme);
    ("虬", PingSheng, TianRhyme);
    ("秋", PingSheng, TianRhyme);
    ("求", PingSheng, TianRhyme);
    ("球", PingSheng, TianRhyme);
    ("丘", PingSheng, TianRhyme);
    ("邱", PingSheng, TianRhyme);
    ("裘", PingSheng, TianRhyme);
    ("蚯", PingSheng, TianRhyme);
    ("囚", PingSheng, TianRhyme);
    ("仇", PingSheng, TianRhyme);
    ("酋", PingSheng, TianRhyme);
    ("湫", PingSheng, TianRhyme);
    ("逑", PingSheng, TianRhyme);
    ("遒", PingSheng, TianRhyme);
    ("赇", PingSheng, TianRhyme);
    ("糗", PingSheng, TianRhyme);
    ("臼", PingSheng, TianRhyme);
    ("舅", PingSheng, TianRhyme);
    ("咎", PingSheng, TianRhyme);
    ("疚", PingSheng, TianRhyme);
    ("玖", PingSheng, TianRhyme);
    ("久", PingSheng, TianRhyme);
    ("九", PingSheng, TianRhyme);
    ("韭", PingSheng, TianRhyme);
    ("酒", PingSheng, TianRhyme);
    ("就", PingSheng, TianRhyme);
    ("救", PingSheng, TianRhyme);
    ("厩", PingSheng, TianRhyme);
    ("旧", PingSheng, TianRhyme);
    ("柩", PingSheng, TianRhyme);
    ("灸", PingSheng, TianRhyme);
    ("究", PingSheng, TianRhyme);

    (* 仄声韵 - 望韵组 *)
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
    ("巷", ZeSheng, WangRhyme);
    ("橡", ZeSheng, WangRhyme);
    ("享", ZeSheng, WangRhyme);
    ("飨", ZeSheng, WangRhyme);

    (* 仄声韵 - 去韵组 *)
    ("去", ZeSheng, QuRhyme);
    ("路", ZeSheng, QuRhyme);
    ("度", ZeSheng, QuRhyme);
    ("故", ZeSheng, QuRhyme);
    ("步", ZeSheng, QuRhyme);
    ("处", ZeSheng, QuRhyme);
    ("住", ZeSheng, QuRhyme);
    ("数", ZeSheng, QuRhyme);
    ("组", ZeSheng, QuRhyme);
    ("序", ZeSheng, QuRhyme);
    ("述", ZeSheng, QuRhyme);
    ("用", ZeSheng, QuRhyme);
    ("动", ZeSheng, QuRhyme);
    ("等", ZeSheng, QuRhyme);
    ("定", ZeSheng, QuRhyme);
    ("令", ZeSheng, QuRhyme);
    ("命", ZeSheng, QuRhyme);
    ("类", ZeSheng, QuRhyme);
    ("比", ZeSheng, QuRhyme);
    ("值", ZeSheng, QuRhyme);
    ("置", ZeSheng, QuRhyme);
    ("布", ZeSheng, QuRhyme);
    ("部", ZeSheng, QuRhyme);
    ("补", ZeSheng, QuRhyme);
    ("捕", ZeSheng, QuRhyme);
    ("哺", ZeSheng, QuRhyme);
    ("埠", ZeSheng, QuRhyme);
    ("不", ZeSheng, QuRhyme);
    ("孚", ZeSheng, QuRhyme);
    ("符", ZeSheng, QuRhyme);
    ("服", ZeSheng, QuRhyme);
    ("福", ZeSheng, QuRhyme);
    ("腹", ZeSheng, QuRhyme);
    ("复", ZeSheng, QuRhyme);
    ("覆", ZeSheng, QuRhyme);
    ("副", ZeSheng, QuRhyme);
    ("富", ZeSheng, QuRhyme);
    ("负", ZeSheng, QuRhyme);
    ("附", ZeSheng, QuRhyme);
    ("父", ZeSheng, QuRhyme);
    ("付", ZeSheng, QuRhyme);
    ("赴", ZeSheng, QuRhyme);
    ("傅", ZeSheng, QuRhyme);
    ("扶", ZeSheng, QuRhyme);
    ("抚", ZeSheng, QuRhyme);
    ("辅", ZeSheng, QuRhyme);
    ("釜", ZeSheng, QuRhyme);
    ("斧", ZeSheng, QuRhyme);
    ("府", ZeSheng, QuRhyme);
    ("腐", ZeSheng, QuRhyme);
    ("蜇", ZeSheng, QuRhyme);
    ("辙", ZeSheng, QuRhyme);
    ("者", ZeSheng, QuRhyme);
    ("这", ZeSheng, QuRhyme);
    ("哲", ZeSheng, QuRhyme);
    ("蛰", ZeSheng, QuRhyme);
    ("摄", ZeSheng, QuRhyme);
    ("设", ZeSheng, QuRhyme);
    ("社", ZeSheng, QuRhyme);
    ("射", ZeSheng, QuRhyme);
    ("舍", ZeSheng, QuRhyme);
    ("涉", ZeSheng, QuRhyme);
    ("赦", ZeSheng, QuRhyme);

    (* 入声韵 - 常用入声字 *)
    ("入", RuSheng, QuRhyme);
    ("出", RuSheng, QuRhyme);
    ("得", RuSheng, QuRhyme);
    ("结", RuSheng, QuRhyme);
    ("法", RuSheng, QuRhyme);
    ("达", RuSheng, QuRhyme);
    ("合", RuSheng, QuRhyme);
    ("接", RuSheng, QuRhyme);
    ("国", RuSheng, QuRhyme);
    ("学", RuSheng, QuRhyme);
    ("说", RuSheng, QuRhyme);
    ("作", RuSheng, QuRhyme);
    ("昨", RuSheng, QuRhyme);
    ("族", RuSheng, QuRhyme);
    ("足", RuSheng, QuRhyme);
    ("卒", RuSheng, QuRhyme);
    ("速", RuSheng, QuRhyme);
    ("俗", RuSheng, QuRhyme);
    ("蜀", RuSheng, QuRhyme);
    ("属", RuSheng, QuRhyme);
    ("术", RuSheng, QuRhyme);
    ("述", RuSheng, QuRhyme);
    ("叔", RuSheng, QuRhyme);
    ("熟", RuSheng, QuRhyme);
    ("赎", RuSheng, QuRhyme);
    ("塾", RuSheng, QuRhyme);
    ("漱", RuSheng, QuRhyme);
    ("刷", RuSheng, QuRhyme);
    ("率", RuSheng, QuRhyme);
    ("蟀", RuSheng, QuRhyme);
    ("帅", RuSheng, QuRhyme);
    ("摔", RuSheng, QuRhyme);
    ("甩", RuSheng, QuRhyme);
    ("拴", RuSheng, QuRhyme);
    ("闩", RuSheng, QuRhyme);
    ("双", RuSheng, QuRhyme);
    ("霜", RuSheng, QuRhyme);
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

(* 从数据库中查找字符的韵母信息 *)
let find_rhyme_info char =
  let char_str = String.make 1 char in
  try
    let _, category, group = List.find (fun (ch, _, _) -> ch = char_str) rhyme_database in
    Some (category, group)
  with Not_found -> None

(* 检测字符的韵母分类 *)
let detect_rhyme_category char =
  match find_rhyme_info char with Some (category, _) -> category | None -> PingSheng (* 默认为平声 *)

(* 检测字符的韵组 *)
let detect_rhyme_group char =
  match find_rhyme_info char with Some (_, group) -> group | None -> UnknownRhyme

(* 从字符串中提取韵脚字符 *)
let extract_rhyme_ending verse =
  let chars = Utf8_utils.StringUtils.utf8_to_char_list verse in
  match List.rev chars with
  | [] -> None
  | last_char :: _ -> if String.length last_char > 0 then Some last_char.[0] else None

(* 验证韵脚一致性 *)
let validate_rhyme_consistency verses =
  let rhyme_endings = List.filter_map extract_rhyme_ending verses in
  let rhyme_groups = List.map detect_rhyme_group rhyme_endings in

  (* 检查是否所有韵脚都属于同一韵组 *)
  match rhyme_groups with
  | [] -> true
  | first_group :: rest ->
      List.for_all (fun group -> group = first_group || group = UnknownRhyme) rest

(* 验证韵律方案 *)
let validate_rhyme_scheme verses rhyme_pattern =
  let rhyme_endings = List.filter_map extract_rhyme_ending verses in
  let rhyme_groups = List.map detect_rhyme_group rhyme_endings in

  (* 简单的韵律方案检查 - 同字母表示同韵 *)
  let rec check_pattern groups pattern =
    match (groups, pattern) with
    | [], [] -> true
    | g1 :: gs, p1 :: ps ->
        let same_rhyme = List.exists (fun (g2, p2) -> p1 = p2 && g1 = g2) (List.combine gs ps) in
        if p1 = 'A' then same_rhyme || check_pattern gs ps else check_pattern gs ps
    | _ -> false
  in

  if List.length rhyme_groups = List.length rhyme_pattern then
    check_pattern rhyme_groups rhyme_pattern
  else false

(* 分析诗句的韵律信息 *)
let analyze_rhyme_pattern verse =
  let chars = Utf8_utils.StringUtils.utf8_to_char_list verse in
  let rhyme_info =
    List.map
      (fun char_str ->
        let char = if String.length char_str > 0 then char_str.[0] else '?' in
        (char, detect_rhyme_category char, detect_rhyme_group char))
      chars
  in
  rhyme_info

(* 建议韵脚字符 *)
let suggest_rhyme_characters target_group =
  let candidates =
    List.filter_map
      (fun (char, _, group) -> if group = target_group then Some char else None)
      rhyme_database
  in
  candidates

(* 检查两个字符是否押韵 *)
let chars_rhyme char1 char2 =
  let group1 = detect_rhyme_group char1 in
  let group2 = detect_rhyme_group char2 in
  group1 = group2 && group1 <> UnknownRhyme

(* 韵律分析报告 *)
type rhyme_analysis_report = {
  verse : string;
  rhyme_ending : char option;
  rhyme_group : rhyme_group;
  rhyme_category : rhyme_category;
  char_analysis : (char * rhyme_category * rhyme_group) list;
}

(* 生成韵律分析报告 *)
let generate_rhyme_report verse =
  let rhyme_ending = extract_rhyme_ending verse in
  let rhyme_group =
    match rhyme_ending with Some char -> detect_rhyme_group char | None -> UnknownRhyme
  in
  let rhyme_category =
    match rhyme_ending with Some char -> detect_rhyme_category char | None -> PingSheng
  in
  let char_analysis = analyze_rhyme_pattern verse in
  { verse; rhyme_ending; rhyme_group; rhyme_category; char_analysis }

(* 韵律美化建议 *)
let suggest_rhyme_improvements verse target_rhyme_group =
  let report = generate_rhyme_report verse in
  if report.rhyme_group = target_rhyme_group then [] (* 已经符合要求 *)
  else
    let suggestions = suggest_rhyme_characters target_rhyme_group in
    let rec take n lst =
      if n <= 0 then [] else match lst with [] -> [] | h :: t -> h :: take (n - 1) t
    in
    take 5 suggestions (* 返回前5个建议 *)

(* 导出函数 *)
let () = ()
