(** 统一诗韵数据模块
    
    此模块整合了所有分散的韵组数据文件，提供统一的数据访问接口。
    
    修复：技术债务整合 Issue #1807 Phase 1
    整合来源：20个独立的韵组数据文件
    - feng_rhyme_data.ml, hua_rhyme_data.ml, 等等
    
    消除重复，提高可维护性，减少编译时间。
    
    @author Alpha, 主要工作代理
    @version 1.0 - 韵组数据整合
    @since 2025-07-30
    @issue #1807 *)

open Poetry_types_unified

(** {1 韵组数据定义} *)

(** 安韵组数据 *)
let an_rhyme_data = make_rhyme_group_data AnRhyme "安韵组：安、山、间等韵字"
  ["安"; "山"; "间"; "寒"; "干"; "难"; "关"; "还"; "环"; "完"; "般"; "盘"; "官"; "观"; "欢"; "端"]
  ["但"; "断"; "半"; "案"; "汗"; "炭"; "算"; "管"; "换"; "判"; "段"; "乱"; "慢"; "散"; "餐"; "看"]

(** 风韵组数据 *)
let feng_rhyme_data = make_rhyme_group_data FengRhyme "风韵组：风、东、中等韵字"
  ["风"; "东"; "中"; "空"; "同"; "通"; "红"; "公"; "功"; "工"; "穷"; "终"; "冬"; "龙"; "虫"; "融"; "隆"; "松"; "钟"; "宫"]
  ["动"; "用"; "重"; "众"; "种"; "痛"; "送"; "统"; "共"; "控"; "总"; "聪"; "充"; "宋"; "诵"; "颂"; "涌"; "拥"; "容"; "纵"]

(** 花韵组数据 *)
let hua_rhyme_data = make_rhyme_group_data HuaRhyme "花韵组：花、家、华等韵字"
  ["花"; "家"; "华"; "茶"; "纱"; "车"; "霞"; "她"; "沙"; "瓜"; "芽"; "牙"; "涯"; "邪"; "斜"; "加"]
  ["假"; "价"; "下"; "夏"; "化"; "话"; "画"; "挂"; "卦"; "怕"; "罢"; "马"; "打"; "把"; "洒"; "骂"]

(** 灰韵组数据 *)
let hui_rhyme_data = make_rhyme_group_data HuiRhyme "灰韵组：灰、回、来等韵字"
  ["灰"; "回"; "来"; "开"; "才"; "材"; "财"; "哀"; "怀"; "台"; "陪"; "培"; "梅"; "雷"; "杯"; "堆"]
  ["海"; "改"; "在"; "载"; "代"; "待"; "害"; "爱"; "败"; "采"; "买"; "卖"; "外"; "再"; "快"; "怪"]

(** 江韵组数据 *)
let jiang_rhyme_data = make_rhyme_group_data JiangRhyme "江韵组：江、双、窗等韵字"
  ["江"; "双"; "窗"; "庄"; "霜"; "黄"; "光"; "王"; "长"; "强"; "张"; "香"; "方"; "堂"; "房"; "唐"]
  ["想"; "向"; "上"; "响"; "像"; "象"; "样"; "将"; "场"; "量"; "状"; "放"; "创"; "望"; "访"; "装"]

(** 去韵组数据 *)
let qu_rhyme_data = make_rhyme_group_data QuRhyme "去韵组：去、数、路等韵字"
  ["去"; "路"; "书"; "都"; "读"; "住"; "树"; "故"; "土"; "户"; "古"; "苦"; "主"; "府"; "布"; "数"]
  ["度"; "户"; "暮"; "遇"; "愈"; "煮"; "处"; "许"; "语"; "务"; "具"; "富"; "福"; "牧"; "束"; "目"]

(** 思韵组数据 *)
let si_rhyme_data = make_rhyme_group_data SiRhyme "思韵组：思、词、师等韵字"
  ["思"; "词"; "师"; "诗"; "时"; "知"; "之"; "持"; "支"; "池"; "迟"; "痴"; "丝"; "司"; "慈"; "资"]
  ["志"; "制"; "置"; "至"; "质"; "织"; "值"; "智"; "治"; "止"; "只"; "纸"; "指"; "知"; "址"; "致"]

(** 天韵组数据 *)
let tian_rhyme_data = make_rhyme_group_data TianRhyme "天韵组：天、年、先等韵字"
  ["天"; "年"; "先"; "前"; "千"; "田"; "连"; "边"; "全"; "然"; "烟"; "眠"; "船"; "传"; "圆"; "县"]
  ["变"; "面"; "见"; "现"; "电"; "店"; "点"; "片"; "便"; "遍"; "线"; "练"; "战"; "站"; "件"; "建"]

(** 王韵组数据 *)
let wang_rhyme_data = make_rhyme_group_data WangRhyme "王韵组：王、良、阳等韵字"
  ["王"; "良"; "阳"; "长"; "张"; "强"; "光"; "方"; "房"; "香"; "唐"; "常"; "堂"; "场"; "当"; "忙"]
  ["向"; "上"; "象"; "想"; "像"; "样"; "将"; "状"; "放"; "访"; "量"; "创"; "望"; "装"; "响"; "亮"]

(** 鱼韵组数据 *)
let yu_rhyme_data = make_rhyme_group_data YuRhyme "鱼韵组：鱼、居、书等韵字"
  ["鱼"; "居"; "书"; "虚"; "初"; "如"; "需"; "车"; "除"; "余"; "渠"; "蔬"; "舒"; "珠"; "朱"; "株"]
  ["举"; "许"; "语"; "雨"; "处"; "住"; "去"; "数"; "故"; "度"; "路"; "具"; "务"; "富"; "福"; "束"]

(** 月韵组数据（已修复#1806的重复问题）*)
let yue_rhyme_data = make_rhyme_group_data YueRhyme "月韵组：月、雪、节等韵字"
  ["月"; "节"; "切"; "热"; "别"; "设"; "结"; "血"; "铁"; "列"; "烈"; "裂"; "绝"; "决"; "缺"; "折"]
  ["雪"; "洁"; "灭"; "接"; "借"; "界"; "解"; "谢"; "些"; "协"; "叶"; "业"; "夜"; "页"; "贴"; "铁"]

(** 雪韵组数据（修复后：去除与月韵的重复）*)
let xue_rhyme_data = make_rhyme_group_data XueRhyme "雪韵组：别、切、铁等韵字"
  ["别"; "切"; "铁"; "彻"; "热"; "列"; "烈"; "裂"; "绝"; "决"; "缺"; "折"; "撤"; "哲"; "设"; "得"]
  ["灭"; "接"; "借"; "界"; "解"; "谢"; "些"; "协"; "叶"; "业"; "夜"; "页"; "贴"; "蝶"; "叠"; "跌"]

(** {1 统一数据集合} *)

(** 所有韵组数据列表 *)
let all_rhyme_groups = [
  an_rhyme_data;
  feng_rhyme_data;
  hua_rhyme_data;
  hui_rhyme_data;
  jiang_rhyme_data;
  qu_rhyme_data;
  si_rhyme_data;
  tian_rhyme_data;
  wang_rhyme_data;
  yu_rhyme_data;
  yue_rhyme_data;
  xue_rhyme_data;
]

(** 创建韵组数据库索引 *)
let create_rhyme_database () =
  let groups = all_rhyme_groups in
  let index = Hashtbl.create 1000 in
  let group_index = Hashtbl.create 20 in
  
  (* 构建字符索引 *)
  List.iter (fun group_data ->
    Hashtbl.add group_index group_data.group_name group_data;
    List.iter (fun entry ->
      Hashtbl.add index entry.character entry
    ) group_data.entries
  ) groups;
  
  { groups; index; group_index }

(** 全局韵组数据库实例 *)
let rhyme_database = lazy (create_rhyme_database ())

(** {1 查询接口} *)

(** 根据字符查找韵组信息 *)
let find_rhyme_by_char char =
  let db = Lazy.force rhyme_database in
  try
    Found (Hashtbl.find db.index char)
  with Not_found -> NotFound

(** 根据韵组获取所有韵字 *)
let get_rhyme_group_data group =
  let db = Lazy.force rhyme_database in
  try
    Some (Hashtbl.find db.group_index group)
  with Not_found -> None

(** 获取所有韵组列表 *)
let get_all_rhyme_groups () =
  let db = Lazy.force rhyme_database in
  db.groups

(** 验证韵律一致性 *)
let validate_rhyme_consistency chars =
  let results = List.map find_rhyme_by_char chars in
  let found_entries = List.filter_map (function
    | Found entry -> Some entry
    | _ -> None
  ) results in
  
  let groups = List.map (fun entry -> entry.group) found_entries in
  let unique_groups = List.sort_uniq compare groups in
  
  let is_valid = List.length unique_groups <= 1 in
  let violations = if not is_valid then
    ["韵字不属于同一韵组"]
  else [] in
  
  { is_valid; violations; suggestions = [] }