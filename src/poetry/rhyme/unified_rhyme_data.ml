(** 统一韵律数据模块
    
    将所有分散的韵组数据文件合并到统一的数据结构中，
    消除重复代码，提供统一的韵律数据访问接口。
    
    Author: Whisky, PR Worker  
    Mission: 真正的韵律数据整合，减少文件碎片化
    Date: 2025-08-04
    Consolidates: 12个*_rhyme_data.ml文件 → 1个统一文件 *)

open Poetry_core.Rhyme_core_types

(** {1 韵组数据定义} *)

(* 来源: rhyme_data_core.ml *)
type rhyme_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  variants : string list;
  usage_frequency : float;
}

type rhyme_group_data = {
  group_name : rhyme_group;
  group_description : string;
  entries : rhyme_entry list;
  example_poems : string list;
}

(** {1 辅助函数} *)

let make_rhyme_group_data group_name description tuples_list =
  let entries =
    List.map
      (fun (char, category, group) ->
        { character = char; category; group; variants = []; usage_frequency = 1.0 })
      tuples_list
  in
  { group_name; group_description = description; entries; example_poems = [] }

let make_ping_sheng_group rhyme_type chars =
  List.map (fun char -> (char, PingSheng, rhyme_type)) chars

let make_ze_sheng_group rhyme_type chars = 
  List.map (fun char -> (char, ZeSheng, rhyme_type)) chars

let create_rhyme_data rhyme_type description ping_chars ze_chars =
  let ping_sheng_data = make_ping_sheng_group rhyme_type ping_chars in
  let ze_sheng_data = make_ze_sheng_group rhyme_type ze_chars in
  let tuples_data = ping_sheng_data @ ze_sheng_data in
  make_rhyme_group_data rhyme_type description tuples_data

(** {1 统一韵组数据映射} *)

(* 来源: an_rhyme_data.ml *)
let an_rhyme_ping_chars = [
  "山"; "间"; "闲"; "关"; "还"; "班"; "颜"; "安"; "删"; "蛮"; 
  "环"; "弯"; "天"; "千"; "田"; "先"; "年"; "连"; "边"; "全"; 
  "春";
]

let an_rhyme_ze_chars = [
  "产"; "满"; "简"; "眼"; "展"; "面"; "限"; "善"; "判"; "管"; 
  "见"; "变"; "片"; "现"; "线"; "显"; "献"; "念"; "练"; "遍";
]

(* 来源: feng_rhyme_data.ml *)
let feng_rhyme_ping_chars = [
  "风"; "东"; "中"; "空"; "同"; "通"; "红"; "公"; "功"; "工"; 
  "穷"; "终"; "冬"; "龙"; "虫"; "融"; "隆"; "松"; "钟"; "宫";
]

let feng_rhyme_ze_chars = [
  "动"; "用"; "重"; "众"; "种"; "痛"; "送"; "统"; "共"; "控"; 
  "总"; "聪"; "充"; "宋"; "诵"; "颂"; "涌"; "拥"; "容"; "纵";
]

(* 来源: hua_rhyme_data.ml *)
let hua_rhyme_ping_chars = [
  "花"; "华"; "家"; "加"; "茶"; "沙"; "霞"; "瓜"; "麻"; "车"; 
  "奢"; "斜"; "邪"; "牙"; "芽"; "哗"; "夸"; "瑕"; "叉"; "差";
]

let hua_rhyme_ze_chars = [
  "化"; "话"; "价"; "假"; "架"; "卸"; "夏"; "下"; "罢"; "马"; 
  "骂"; "打"; "雅"; "亚"; "压"; "洒"; "寡"; "跨"; "挂"; "画";
]

(* 来源: hui_rhyme_data.ml *)
let hui_rhyme_ping_chars = [
  "辉"; "晖"; "飞"; "归"; "微"; "威"; "回"; "催"; "悲"; "雷"; 
  "推"; "追"; "眉"; "杯"; "堆"; "梅"; "来"; "开"; "台"; "该";
]

let hui_rhyme_ze_chars = [
  "会"; "慧"; "费"; "贵"; "味"; "位"; "退"; "类"; "泪"; "累"; 
  "对"; "队"; "内"; "外"; "最"; "罪"; "醉"; "配"; "背"; "废";
]

(* 来源: jiang_rhyme_data.ml *)
let jiang_rhyme_ping_chars = [
  "江"; "双"; "降"; "庄"; "窗"; "床"; "房"; "方"; "王"; "黄"; 
  "光"; "章"; "场"; "长"; "强"; "香"; "乡"; "汤"; "堂"; "当";
]

let jiang_rhyme_ze_chars = [
  "讲"; "上"; "像"; "想"; "向"; "望"; "放"; "让"; "唱"; "响"; 
  "象"; "量"; "样"; "养"; "长"; "党"; "房"; "网"; "状"; "创";
]

(* 来源: qu_rhyme_data.ml *)
let qu_rhyme_ping_chars = [
  "区"; "鱼"; "书"; "初"; "居"; "如"; "除"; "车"; "虚"; "余"; 
  "都"; "孤"; "湖"; "胡"; "呼"; "乎"; "须"; "诸"; "珠"; "朱";
]

let qu_rhyme_ze_chars = [
  "去"; "雨"; "树"; "处"; "据"; "路"; "府"; "度"; "数"; "布"; 
  "素"; "故"; "顾"; "户"; "护"; "注"; "住"; "著"; "助"; "主";
]

(* 来源: si_rhyme_data.ml *)
let si_rhyme_ping_chars = [
  "思"; "丝"; "词"; "持"; "时"; "知"; "支"; "枝"; "吹"; "垂"; 
  "移"; "离"; "疑"; "期"; "齐"; "题"; "提"; "啼"; "西"; "妻";
]

let si_rhyme_ze_chars = [
  "事"; "志"; "治"; "制"; "智"; "置"; "至"; "质"; "实"; "失"; 
  "室"; "日"; "七"; "吉"; "集"; "级"; "急"; "及"; "立"; "力";
]

(* 来源: tian_rhyme_data.ml *)
let tian_rhyme_ping_chars = [
  "天"; "千"; "田"; "先"; "年"; "连"; "边"; "全"; "泉"; "权"; 
  "圈"; "牵"; "钱"; "前"; "员"; "圆"; "元"; "言"; "烟"; "延";
]

let tian_rhyme_ze_chars = [
  "变"; "片"; "现"; "线"; "显"; "献"; "念"; "练"; "遍"; "面"; 
  "见"; "间"; "浅"; "选"; "典"; "点"; "店"; "电"; "便"; "篇";
]

(* 来源: wang_rhyme_data.ml *)
let wang_rhyme_ping_chars = [
  "王"; "黄"; "光"; "章"; "场"; "长"; "强"; "香"; "乡"; "汤"; 
  "堂"; "当"; "方"; "房"; "窗"; "床"; "庄"; "装"; "霜"; "双";
]

let wang_rhyme_ze_chars = [
  "望"; "上"; "像"; "想"; "向"; "放"; "让"; "唱"; "响"; "象"; 
  "量"; "样"; "养"; "党"; "网"; "状"; "创"; "掌"; "仗"; "丈";
]

(* 来源: yu_rhyme_data.ml *)
let yu_rhyme_ping_chars = [
  "鱼"; "书"; "初"; "居"; "如"; "除"; "车"; "虚"; "余"; "都"; 
  "孤"; "湖"; "胡"; "呼"; "乎"; "须"; "诸"; "珠"; "朱"; "株";
]

let yu_rhyme_ze_chars = [
  "雨"; "树"; "处"; "据"; "路"; "府"; "度"; "数"; "布"; "素"; 
  "故"; "顾"; "户"; "护"; "注"; "住"; "著"; "助"; "主"; "楚";
]

(* 来源: yue_rhyme_data.ml *)
let yue_rhyme_ping_chars = [
  "月"; "雪"; "绝"; "节"; "别"; "热"; "设"; "切"; "结"; "列"; 
  "烈"; "铁"; "血"; "裂"; "页"; "叶"; "业"; "夜"; "接"; "街";
]

let yue_rhyme_ze_chars = [
  "越"; "说"; "决"; "缺"; "确"; "学"; "觉"; "角"; "各"; "落"; 
  "作"; "错"; "若"; "约"; "药"; "握"; "获"; "货"; "破"; "火";
]

(** {1 统一数据结构} *)

(** 所有韵组数据的统一映射表 *)
let all_rhyme_groups_data = [
  (AnRhyme, ("安韵组：山、关、间等韵字", an_rhyme_ping_chars, an_rhyme_ze_chars));
  (FengRhyme, ("风韵组：风、东、中等韵字", feng_rhyme_ping_chars, feng_rhyme_ze_chars));
  (HuaRhyme, ("花韵组：花、华、家等韵字", hua_rhyme_ping_chars, hua_rhyme_ze_chars));
  (HuiRhyme, ("辉韵组：辉、晖、飞等韵字", hui_rhyme_ping_chars, hui_rhyme_ze_chars));
  (JiangRhyme, ("江韵组：江、双、降等韵字", jiang_rhyme_ping_chars, jiang_rhyme_ze_chars));
  (QuRhyme, ("区韵组：区、鱼、书等韵字", qu_rhyme_ping_chars, qu_rhyme_ze_chars));
  (SiRhyme, ("思韵组：思、丝、词等韵字", si_rhyme_ping_chars, si_rhyme_ze_chars));
  (TianRhyme, ("天韵组：天、千、田等韵字", tian_rhyme_ping_chars, tian_rhyme_ze_chars));
  (WangRhyme, ("王韵组：王、黄、光等韵字", wang_rhyme_ping_chars, wang_rhyme_ze_chars));
  (YuRhyme, ("鱼韵组：鱼、书、初等韵字", yu_rhyme_ping_chars, yu_rhyme_ze_chars));
  (YueRhyme, ("月韵组：月、雪、绝等韵字", yue_rhyme_ping_chars, yue_rhyme_ze_chars));
]

(** {1 统一访问接口} *)

(** 获取指定韵组的数据 *)
let get_rhyme_group_info rhyme_group =
  List.find_opt (fun (group, _) -> group = rhyme_group) all_rhyme_groups_data
  |> Option.map (fun (_, info) -> info)

(** 获取指定韵组的平声字 *)
let get_ping_sheng_chars rhyme_group =
  match get_rhyme_group_info rhyme_group with
  | Some (_, ping_chars, _) -> ping_chars
  | None -> []

(** 获取指定韵组的仄声字 *)
let get_ze_sheng_chars rhyme_group =
  match get_rhyme_group_info rhyme_group with
  | Some (_, _, ze_chars) -> ze_chars
  | None -> []

(** 创建韵组数据结构 *)
let get_rhyme_data rhyme_group =
  match get_rhyme_group_info rhyme_group with
  | Some (description, ping_chars, ze_chars) ->
      create_rhyme_data rhyme_group description ping_chars ze_chars
  | None -> 
      make_rhyme_group_data rhyme_group "未知韵组" []

(** 列出所有可用的韵组 *)
let list_all_rhyme_groups () =
  List.map (fun (group, (desc, _, _)) -> (group, desc)) all_rhyme_groups_data

(** {1 向后兼容接口} *)

(* 保持原有模块接口的兼容性 *)
module An_rhyme_data = struct
  let ping_sheng_chars = an_rhyme_ping_chars
  let ze_sheng_chars = an_rhyme_ze_chars
  let an_rhyme_data = get_rhyme_data AnRhyme
end

module Feng_rhyme_data = struct
  let ping_sheng_chars = feng_rhyme_ping_chars
  let ze_sheng_chars = feng_rhyme_ze_chars
  let feng_rhyme_data = get_rhyme_data FengRhyme
end

module Hua_rhyme_data = struct
  let ping_sheng_chars = hua_rhyme_ping_chars
  let ze_sheng_chars = hua_rhyme_ze_chars
  let hua_rhyme_data = get_rhyme_data HuaRhyme
end

module Hui_rhyme_data = struct
  let ping_sheng_chars = hui_rhyme_ping_chars
  let ze_sheng_chars = hui_rhyme_ze_chars
  let hui_rhyme_data = get_rhyme_data HuiRhyme
end

module Jiang_rhyme_data = struct
  let ping_sheng_chars = jiang_rhyme_ping_chars
  let ze_sheng_chars = jiang_rhyme_ze_chars
  let jiang_rhyme_data = get_rhyme_data JiangRhyme
end

module Qu_rhyme_data = struct
  let ping_sheng_chars = qu_rhyme_ping_chars
  let ze_sheng_chars = qu_rhyme_ze_chars
  let qu_rhyme_data = get_rhyme_data QuRhyme
end

module Si_rhyme_data = struct
  let ping_sheng_chars = si_rhyme_ping_chars
  let ze_sheng_chars = si_rhyme_ze_chars
  let si_rhyme_data = get_rhyme_data SiRhyme
end

module Tian_rhyme_data = struct
  let ping_sheng_chars = tian_rhyme_ping_chars
  let ze_sheng_chars = tian_rhyme_ze_chars
  let tian_rhyme_data = get_rhyme_data TianRhyme
end

module Wang_rhyme_data = struct
  let ping_sheng_chars = wang_rhyme_ping_chars
  let ze_sheng_chars = wang_rhyme_ze_chars
  let wang_rhyme_data = get_rhyme_data WangRhyme
end

module Yu_rhyme_data = struct
  let ping_sheng_chars = yu_rhyme_ping_chars
  let ze_sheng_chars = yu_rhyme_ze_chars
  let yu_rhyme_data = get_rhyme_data YuRhyme
end

module Yue_rhyme_data = struct
  let ping_sheng_chars = yue_rhyme_ping_chars
  let ze_sheng_chars = yue_rhyme_ze_chars
  let yue_rhyme_data = get_rhyme_data YueRhyme
end

(* 来源: rhyme_data_registry.ml - 韵组注册功能 *)
module Rhyme_data_registry = struct
  let registry = Hashtbl.create 16
  
  let register_rhyme_group group data =
    Hashtbl.replace registry group data
  
  let get_registered_rhyme_group group =
    Hashtbl.find_opt registry group
  
  let list_registered_groups () =
    Hashtbl.fold (fun group _ acc -> group :: acc) registry []
  
  (* 初始化注册所有韵组 *)
  let initialize () =
    List.iter (fun (group, _) ->
      let data = get_rhyme_data group in
      register_rhyme_group group data
    ) all_rhyme_groups_data
end

(* 自动初始化韵组注册 *)
let () = Rhyme_data_registry.initialize ()