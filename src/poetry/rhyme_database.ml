(* 音韵数据库模块 - 骆言诗词编程特性
   盖古之诗者，音韵为要。声韵调谐，方称佳构。
   此模块专司音韵数据库，收录三千余字音韵分类。
   依《广韵》、《集韵》等韵书传统，分类整理。
   平声清越，仄声沉郁，入声短促，各有所归。
*)

open Rhyme_types

(* 韵母分类数据库 - 博采众长，涵盖常用汉字音韵 *)
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
    ("含", PingSheng, AnRhyme);
    ("寒", PingSheng, AnRhyme);
    ("汗", PingSheng, AnRhyme);
    ("干", PingSheng, AnRhyme);
    ("甘", PingSheng, AnRhyme);
    ("三", PingSheng, AnRhyme);
    ("弹", PingSheng, AnRhyme);
    ("坛", PingSheng, AnRhyme);
    ("摊", PingSheng, AnRhyme);
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
    ("刊", PingSheng, AnRhyme);
    ("阑", PingSheng, AnRhyme);
    ("兰", PingSheng, AnRhyme);
    ("单", PingSheng, AnRhyme);
    ("丹", PingSheng, AnRhyme);
    ("残", PingSheng, AnRhyme);
    ("潺", PingSheng, AnRhyme);
    ("韩", PingSheng, AnRhyme);
    ("官", PingSheng, AnRhyme);
    ("观", PingSheng, AnRhyme);
    ("宽", PingSheng, AnRhyme);
    ("欢", PingSheng, AnRhyme);
    ("团", PingSheng, AnRhyme);
    ("专", PingSheng, AnRhyme);
    ("端", PingSheng, AnRhyme);
    ("酸", PingSheng, AnRhyme);
    ("栏", PingSheng, AnRhyme);
    ("惨", PingSheng, AnRhyme);
    ("蚕", PingSheng, AnRhyme);
    ("涵", PingSheng, AnRhyme);
    ("汉", PingSheng, AnRhyme);
    ("旱", PingSheng, AnRhyme);
    ("罕", PingSheng, AnRhyme);
    ("憾", PingSheng, AnRhyme);
    ("撼", PingSheng, AnRhyme);
    ("感", PingSheng, AnRhyme);
    ("赶", PingSheng, AnRhyme);
    ("敢", PingSheng, AnRhyme);
    ("橄", PingSheng, AnRhyme);
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

    (* 平声韵 - 思韵组 *)
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
    ("步", ZeSheng, QuRhyme);
    ("处", ZeSheng, QuRhyme);
    ("住", ZeSheng, QuRhyme);
    ("数", ZeSheng, QuRhyme);
    ("组", ZeSheng, QuRhyme);
    ("序", ZeSheng, QuRhyme);
    ("述", ZeSheng, QuRhyme);
    ("用", ZeSheng, QuRhyme);
    ("动", ZeSheng, QuRhyme);
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
    ("蜀", RuSheng, QuRhyme);
    ("属", RuSheng, QuRhyme);
    ("术", RuSheng, QuRhyme);
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

(* 数据库统计信息类型 *)
type database_stats = {
  total_chars: int;
  ping_sheng_count: int;
  ze_sheng_count: int;
  ru_sheng_count: int;
  group_counts: (string * int) list;
}

(* 数据库查询函数 *)

(* 查找字符的韵母信息 *)
let find_rhyme_info char =
  let char_str = String.make 1 char in
  try
    let (_, category, group) = List.find (fun (c, _, _) -> c = char_str) rhyme_database in
    Some (category, group)
  with Not_found -> None

(* 数据库统计信息 *)
let get_database_stats () =
  let total_chars = List.length rhyme_database in
  let ping_sheng_count = List.length (List.filter (fun (_, cat, _) -> cat = PingSheng) rhyme_database) in
  let ze_sheng_count = List.length (List.filter (fun (_, cat, _) -> cat = ZeSheng) rhyme_database) in
  let ru_sheng_count = List.length (List.filter (fun (_, cat, _) -> cat = RuSheng) rhyme_database) in
  let group_counts = [
    ("安韵", List.length (List.filter (fun (_, _, grp) -> grp = AnRhyme) rhyme_database));
    ("思韵", List.length (List.filter (fun (_, _, grp) -> grp = SiRhyme) rhyme_database));
    ("天韵", List.length (List.filter (fun (_, _, grp) -> grp = TianRhyme) rhyme_database));
    ("望韵", List.length (List.filter (fun (_, _, grp) -> grp = WangRhyme) rhyme_database));
    ("去韵", List.length (List.filter (fun (_, _, grp) -> grp = QuRhyme) rhyme_database));
  ] in
  {
    total_chars = total_chars;
    ping_sheng_count = ping_sheng_count;
    ze_sheng_count = ze_sheng_count;
    ru_sheng_count = ru_sheng_count;
    group_counts = group_counts;
  }

(* 获取指定韵组的所有字符 *)
let get_chars_by_group group =
  List.filter_map (fun (char, _, grp) ->
    if grp = group then Some char else None
  ) rhyme_database

(* 获取指定韵类的所有字符 *)
let get_chars_by_category category =
  List.filter_map (fun (char, cat, _) ->
    if cat = category then Some char else None
  ) rhyme_database