(** 统一韵律核心数据模块 - 整合版
    
    这个模块是Poetry模块技术债务整合的核心部分，将原本分散在124个文件中的
    韵律数据统一到单一模块中，消除大量重复代码和复杂依赖关系。
    
    整合目标：
    - 将20+个韵组数据文件合并为单一数据源
    - 消除重复的韵字定义和API接口
    - 提供统一的数据访问接口
    - 降低编译时间和内存使用
    
    Author: Alpha, 主要工作代理
    @version 1.0 - 韵律数据统一整合版本
    @since 2025-07-30 - Fix #1797 Poetry模块优化 *)

open Poetry_core.Poetry_types

(** {1 核心数据结构定义} *)

type rhyme_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  frequency : float;
  variants : string list;
}

type rhyme_group_data = {
  group : rhyme_group;
  ping_sheng_chars : string list;
  ze_sheng_chars : string list;
  shang_sheng_chars : string list;
  qu_sheng_chars : string list;
  ru_sheng_chars : string list;
}

(** {1 统一韵组数据定义} *)

(** 安韵组数据 - 整合自多个重复文件 *)
let an_rhyme_group_data = {
  group = AnRhyme;
  ping_sheng_chars = [
    "安"; "干"; "看"; "山"; "蓝"; "班"; "颜"; "间"; "闲"; "关";
    "还"; "删"; "蛮"; "环"; "弯"; "万"; "班"; "盘"; "观"; "单";
    "欢"; "寒"; "官"; "端"; "团"; "桓"; "酸"; "宽"; "叹"; "散";
    "店"; "展"; "传"; "专"; "船"; "川"; "泉"; "权"; "团"; "关";
  ];
  ze_sheng_chars = [
    "断"; "短"; "半"; "满"; "散"; "难"; "万"; "反"; "判"; "算";
    "换"; "暖"; "软"; "晚"; "慢"; "乱"; "转"; "段"; "管";
  ];
  shang_sheng_chars = [
    "板"; "晚"; "暖"; "管"; "算"; "短"; "反"; "满"; "散"; "难";
  ];
  qu_sheng_chars = [
    "案"; "岸"; "半"; "伴"; "办"; "变"; "遍"; "倦"; "愿"; "见";
    "现"; "线"; "店"; "电"; "片"; "面"; "便"; "传"; "船"; "专";
  ];
  ru_sheng_chars = [];
}

(** 思韵组数据 - 整合自多个重复文件 *)
let si_rhyme_group_data = {
  group = SiRhyme;
  ping_sheng_chars = [
    "思"; "丝"; "时"; "持"; "支"; "春"; "人"; "真"; "因"; "新";
    "身"; "神"; "深"; "心"; "今"; "金"; "林"; "临"; "音"; "吟";
    "琴"; "亲"; "勤"; "近"; "进"; "民"; "文"; "门"; "存"; "村";
    "温"; "论"; "云"; "君"; "军"; "群"; "分"; "闻"; "纷"; "昏";
  ];
  ze_sheng_chars = [
    "尽"; "近"; "进"; "信"; "印"; "引"; "隐"; "问"; "闻"; "分";
    "纷"; "昏"; "温"; "存"; "村"; "论"; "云"; "君"; "军"; "群";
  ];
  shang_sheng_chars = [
    "品"; "饮"; "引"; "隐"; "印"; "尽"; "近"; "进"; "信"; "问";
  ];
  qu_sheng_chars = [
    "信"; "印"; "引"; "隐"; "问"; "闻"; "分"; "纷"; "昏"; "温";
    "存"; "村"; "论"; "云"; "君"; "军"; "群"; "进"; "尽"; "近";
  ];
  ru_sheng_chars = [];
}

(** 天韵组数据 - 整合自多个重复文件 *)
let tian_rhyme_group_data = {
  group = TianRhyme;
  ping_sheng_chars = [
    "天"; "年"; "先"; "千"; "前"; "边"; "连"; "田"; "眠"; "绵";
    "然"; "燃"; "全"; "川"; "泉"; "权"; "团"; "圆"; "源"; "原";
    "园"; "元"; "言"; "研"; "延"; "烟"; "盐"; "严"; "鲜"; "弦";
    "贤"; "仙"; "船"; "传"; "专"; "编"; "篇"; "便"; "面"; "见";
  ];
  ze_sheng_chars = [
    "变"; "遍"; "便"; "面"; "见"; "片"; "店"; "电"; "点"; "展";
    "传"; "船"; "专"; "编"; "篇"; "鲜"; "弦"; "贤"; "仙"; "延";
  ];
  shang_sheng_chars = [
    "典"; "点"; "展"; "选"; "转"; "软"; "暖"; "管"; "算"; "短";
  ];
  qu_sheng_chars = [
    "见"; "现"; "线"; "店"; "电"; "片"; "面"; "便"; "传"; "船";
    "专"; "编"; "篇"; "变"; "遍"; "典"; "点"; "展"; "选"; "转";
  ];
  ru_sheng_chars = [];
}

(** 风韵组数据 - 整合自多个重复文件 *)
let feng_rhyme_group_data = {
  group = FengRhyme;
  ping_sheng_chars = [
    "风"; "中"; "空"; "东"; "红"; "虹"; "工"; "公"; "功"; "攻";
    "共"; "宫"; "穷"; "弓"; "充"; "冲"; "从"; "丛"; "聪"; "松";
    "翁"; "融"; "雄"; "熊"; "通"; "同"; "铜"; "桐"; "童"; "瞳";
    "终"; "钟"; "重"; "种"; "众"; "浓"; "农"; "龙"; "隆"; "笼";
  ];
  ze_sheng_chars = [
    "重"; "种"; "众"; "浓"; "农"; "龙"; "隆"; "笼"; "筒"; "桶";
    "统"; "痛"; "动"; "洞"; "冻"; "懂"; "董"; "陇"; "拢"; "垄";
  ];
  shang_sheng_chars = [
    "总"; "宗"; "踪"; "纵"; "肿"; "种"; "重"; "众"; "统"; "桶";
  ];
  qu_sheng_chars = [
    "重"; "种"; "众"; "动"; "洞"; "冻"; "懂"; "董"; "统"; "桶";
    "痛"; "送"; "松"; "纵"; "踪"; "总"; "宗"; "肿"; "陇"; "拢";
  ];
  ru_sheng_chars = [];
}

(** 鱼韵组数据 - 整合自多个重复文件 *)
let yu_rhyme_group_data = {
  group = YuRhyme;
  ping_sheng_chars = [
    "鱼"; "书"; "余"; "居"; "如"; "须"; "需"; "虚"; "徐"; "初";
    "除"; "储"; "疏"; "蔬"; "舒"; "殊"; "朱"; "珠"; "株"; "竹";
    "筑"; "逐"; "烛"; "独"; "读"; "督"; "毒"; "牧"; "木"; "目";
    "福"; "服"; "复"; "覆"; "副"; "富"; "妇"; "父"; "附"; "付";
  ];
  ze_sheng_chars = [
    "住"; "主"; "注"; "助"; "数"; "树"; "束"; "述"; "术"; "戍";
    "恕"; "署"; "暑"; "鼠"; "属"; "嘱"; "祝"; "竹"; "筑"; "逐";
  ];
  shang_sheng_chars = [
    "主"; "住"; "注"; "助"; "数"; "树"; "束"; "鼠"; "属"; "嘱";
  ];
  qu_sheng_chars = [
    "住"; "主"; "注"; "助"; "数"; "树"; "束"; "述"; "术"; "戍";
    "恕"; "署"; "暑"; "鼠"; "属"; "嘱"; "祝"; "竹"; "筑"; "逐";
  ];
  ru_sheng_chars = [
    "竹"; "筑"; "逐"; "烛"; "独"; "读"; "督"; "毒"; "牧"; "木";
    "目"; "福"; "服"; "复"; "覆"; "副"; "富"; "妇"; "父"; "附";
  ];
}

(** 华韵组数据 - 整合自多个重复文件 *)
let hua_rhyme_group_data = {
  group = HuaRhyme;
  ping_sheng_chars = [];
  ze_sheng_chars = [
    "花"; "家"; "华"; "加"; "嘉"; "佳"; "夸"; "瓜"; "画"; "话";
    "化"; "下"; "马"; "把"; "打"; "大"; "达"; "他"; "她"; "沙";
  ];
  shang_sheng_chars = [
    "马"; "把"; "打"; "大"; "达"; "她"; "沙"; "洒"; "撒"; "卡";
  ];
  qu_sheng_chars = [
    "花"; "家"; "华"; "加"; "嘉"; "佳"; "夸"; "瓜"; "画"; "话";
    "化"; "下"; "马"; "把"; "打"; "大"; "达"; "他"; "她"; "沙";
  ];
  ru_sheng_chars = [];
}

(** 江韵组数据 - 整合自多个重复文件 *)
let jiang_rhyme_group_data = {
  group = JiangRhyme;
  ping_sheng_chars = [
    "江"; "窗"; "双"; "霜"; "床"; "房"; "方"; "香"; "乡"; "相";
    "想"; "详"; "祥"; "长"; "常"; "场"; "唱"; "创"; "伤"; "商";
    "上"; "尚"; "张"; "章"; "彰"; "昌"; "常"; "场"; "唱"; "创";
  ];
  ze_sheng_chars = [
    "上"; "尚"; "想"; "响"; "象"; "像"; "向"; "望"; "忘"; "王";
    "往"; "网"; "放"; "访"; "房"; "防"; "芳"; "方"; "旁"; "磅";
  ];
  shang_sheng_chars = [
    "上"; "尚"; "想"; "响"; "象"; "像"; "往"; "网"; "放"; "访";
  ];
  qu_sheng_chars = [
    "上"; "尚"; "想"; "响"; "象"; "像"; "向"; "望"; "忘"; "王";
    "往"; "网"; "放"; "访"; "房"; "防"; "芳"; "方"; "旁"; "磅";
  ];
  ru_sheng_chars = [];
}

(** 月韵组数据 - 整合自多个重复文件 *)
let yue_rhyme_group_data = {
  group = YueRhyme;
  ping_sheng_chars = [];
  ze_sheng_chars = [
    "月"; "越"; "悦"; "阅"; "说"; "设"; "节"; "结"; "雪"; "血";
    "热"; "烈"; "列"; "别"; "切"; "接"; "街"; "界"; "解"; "借";
  ];
  shang_sheng_chars = [
    "月"; "越"; "悦"; "阅"; "说"; "设"; "节"; "结"; "雪"; "血";
  ];
  qu_sheng_chars = [
    "月"; "越"; "悦"; "阅"; "说"; "设"; "节"; "结"; "雪"; "血";
    "热"; "烈"; "列"; "别"; "切"; "接"; "街"; "界"; "解"; "借";
  ];
  ru_sheng_chars = [
    "热"; "烈"; "列"; "别"; "切"; "接"; "街"; "界"; "解"; "借";
  ];
}

(** 汇韵组数据 - 整合自多个重复文件 *)
let hui_rhyme_group_data = {
  group = HuiRhyme;
  ping_sheng_chars = [];
  ze_sheng_chars = [
    "汇"; "会"; "回"; "惠"; "慧"; "悔"; "毁"; "灰"; "辉"; "挥";
    "晖"; "徽"; "飞"; "非"; "费"; "肥"; "废"; "沸"; "未"; "味";
  ];
  shang_sheng_chars = [
    "汇"; "会"; "回"; "惠"; "慧"; "悔"; "毁"; "灰"; "辉"; "挥";
  ];
  qu_sheng_chars = [
    "汇"; "会"; "回"; "惠"; "慧"; "悔"; "毁"; "灰"; "辉"; "挥";
    "晖"; "徽"; "飞"; "非"; "费"; "肥"; "废"; "沸"; "未"; "味";
  ];
  ru_sheng_chars = [
    "飞"; "非"; "费"; "肥"; "废"; "沸"; "未"; "味"; "卫"; "位";
  ];
}

(** 曲韵组数据 - 整合自多个重复文件 *)
let qu_rhyme_group_data = {
  group = QuRhyme;
  ping_sheng_chars = [
    "曲"; "区"; "渠"; "驱"; "趋"; "屈"; "取"; "娶"; "去"; "除";
    "出"; "处"; "初"; "楚"; "础"; "储"; "触"; "厨"; "诸"; "珠";
  ];
  ze_sheng_chars = [
    "曲"; "区"; "渠"; "驱"; "趋"; "屈"; "取"; "娶"; "去"; "除";
    "出"; "处"; "初"; "楚"; "础"; "储"; "触"; "厨"; "诸"; "珠";
  ];
  shang_sheng_chars = [
    "曲"; "区"; "渠"; "驱"; "趋"; "屈"; "取"; "娶"; "去"; "除";
  ];
  qu_sheng_chars = [
    "曲"; "区"; "渠"; "驱"; "趋"; "屈"; "取"; "娶"; "去"; "除";
    "出"; "处"; "初"; "楚"; "础"; "储"; "触"; "厨"; "诸"; "珠";
  ];
  ru_sheng_chars = [
    "出"; "处"; "初"; "楚"; "础"; "储"; "触"; "厨"; "诸"; "珠";
  ];
}

(** 王韵组数据 - 整合自多个重复文件 *)
let wang_rhyme_group_data = {
  group = WangRhyme;
  ping_sheng_chars = [
    "王"; "长"; "常"; "场"; "唱"; "创"; "伤"; "商"; "上"; "尚";
    "张"; "章"; "彰"; "昌"; "强"; "墙"; "梁"; "良"; "量"; "亮";
  ];
  ze_sheng_chars = [
    "上"; "尚"; "想"; "响"; "象"; "像"; "向"; "望"; "忘"; "王";
    "往"; "网"; "放"; "访"; "房"; "防"; "芳"; "方"; "旁"; "磅";
  ];
  shang_sheng_chars = [
    "上"; "尚"; "想"; "响"; "象"; "像"; "往"; "网"; "放"; "访";
  ];
  qu_sheng_chars = [
    "上"; "尚"; "想"; "响"; "象"; "像"; "向"; "望"; "忘"; "王";
    "往"; "网"; "放"; "访"; "房"; "防"; "芳"; "方"; "旁"; "磅";
  ];
  ru_sheng_chars = [];
}

(** {1 统一数据访问接口} *)

(** 所有韵组数据的统一注册表 *)
let all_rhyme_groups = [
  an_rhyme_group_data;
  si_rhyme_group_data;
  tian_rhyme_group_data;
  feng_rhyme_group_data;
  yu_rhyme_group_data;
  hua_rhyme_group_data;
  jiang_rhyme_group_data;
  yue_rhyme_group_data;
  hui_rhyme_group_data;
  qu_rhyme_group_data;
  wang_rhyme_group_data;
]

(** 根据韵组获取数据 *)
let get_rhyme_group_data group =
  List.find_opt (fun rg -> rg.group = group) all_rhyme_groups

(** 优化的字符韵组映射表 - 使用Hashtbl提供O(1)查找性能 *)
let character_rhyme_map = 
  let tbl = Hashtbl.create 1024 in
  List.iter (fun group ->
    let add_chars category chars =
      List.iter (fun char -> 
        Hashtbl.replace tbl char (group.group, category)
      ) chars
    in
    add_chars PingSheng group.ping_sheng_chars;
    add_chars ZeSheng group.ze_sheng_chars;
    add_chars ShangSheng group.shang_sheng_chars;
    add_chars QuSheng group.qu_sheng_chars;
    add_chars RuSheng group.ru_sheng_chars;
  ) all_rhyme_groups;
  tbl

(** 根据字符查找韵组和声调 - 优化版本使用hashtable O(1)查找 *)
let find_character_rhyme char =
  Hashtbl.find_opt character_rhyme_map char

(** 验证两个字符是否同韵 *)
let are_rhyme_matched char1 char2 =
  match find_character_rhyme char1, find_character_rhyme char2 with
  | Some (group1, _), Some (group2, _) -> group1 = group2
  | _ -> false

(** 获取指定韵组的所有字符 *)
let get_all_characters_in_group group =
  match get_rhyme_group_data group with
  | Some rg ->
      rg.ping_sheng_chars @ rg.ze_sheng_chars @ rg.shang_sheng_chars @ 
      rg.qu_sheng_chars @ rg.ru_sheng_chars
  | None -> []

(** 获取所有韵字总数 *)
let get_total_character_count () =
  List.fold_left (fun acc group ->
    acc + List.length (get_all_characters_in_group group.group)
  ) 0 all_rhyme_groups

(** 获取统计信息 *)
let get_rhyme_statistics () =
  let total = get_total_character_count () in
  let group_counts = List.map (fun group ->
    (group.group, List.length (get_all_characters_in_group group.group))
  ) all_rhyme_groups in
  (total, group_counts)

(** {1 向后兼容接口} *)

(** 为现有代码提供向后兼容的数据访问 *)
let an_rhyme_data =
  List.map (fun char -> (char, PingSheng, AnRhyme)) an_rhyme_group_data.ping_sheng_chars @
  List.map (fun char -> (char, ZeSheng, AnRhyme)) an_rhyme_group_data.ze_sheng_chars

let tian_rhyme_data =
  List.map (fun char -> (char, PingSheng, TianRhyme)) tian_rhyme_group_data.ping_sheng_chars @
  List.map (fun char -> (char, ZeSheng, TianRhyme)) tian_rhyme_group_data.ze_sheng_chars

let si_rhyme_data =
  List.map (fun char -> (char, PingSheng, SiRhyme)) si_rhyme_group_data.ping_sheng_chars @
  List.map (fun char -> (char, ZeSheng, SiRhyme)) si_rhyme_group_data.ze_sheng_chars

let yu_rhyme_data =
  List.map (fun char -> (char, PingSheng, YuRhyme)) yu_rhyme_group_data.ping_sheng_chars @
  List.map (fun char -> (char, ZeSheng, YuRhyme)) yu_rhyme_group_data.ze_sheng_chars

let feng_rhyme_data =
  List.map (fun char -> (char, PingSheng, FengRhyme)) feng_rhyme_group_data.ping_sheng_chars @
  List.map (fun char -> (char, ZeSheng, FengRhyme)) feng_rhyme_group_data.ze_sheng_chars

let hua_rhyme_data =
  List.map (fun char -> (char, ZeSheng, HuaRhyme)) hua_rhyme_group_data.ze_sheng_chars

let jiang_rhyme_data =
  List.map (fun char -> (char, PingSheng, JiangRhyme)) jiang_rhyme_group_data.ping_sheng_chars @
  List.map (fun char -> (char, ZeSheng, JiangRhyme)) jiang_rhyme_group_data.ze_sheng_chars

let yue_rhyme_data =
  List.map (fun char -> (char, ZeSheng, YueRhyme)) yue_rhyme_group_data.ze_sheng_chars

let hui_rhyme_data =
  List.map (fun char -> (char, ZeSheng, HuiRhyme)) hui_rhyme_group_data.ze_sheng_chars

let qu_rhyme_data =
  List.map (fun char -> (char, PingSheng, QuRhyme)) qu_rhyme_group_data.ping_sheng_chars @
  List.map (fun char -> (char, ZeSheng, QuRhyme)) qu_rhyme_group_data.ze_sheng_chars

let wang_rhyme_data =
  List.map (fun char -> (char, PingSheng, WangRhyme)) wang_rhyme_group_data.ping_sheng_chars @
  List.map (fun char -> (char, ZeSheng, WangRhyme)) wang_rhyme_group_data.ze_sheng_chars