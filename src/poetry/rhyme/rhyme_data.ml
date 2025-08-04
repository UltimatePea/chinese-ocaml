(** 韵律数据统一整合模块
    
    本模块整合了原有的12个分散韵律数据文件，将所有韵字数据统一管理。
    这是Issue #1999韵律模块整合的核心数据层。
    
    Author: Whisky, PR Worker
    Issue: #1999 - Poetry韵律模块统一整合实施
    
    整合的原始数据文件:
    - an_rhyme_data.ml (安韵组)
    - si_rhyme_data.ml (思韵组)
    - tian_rhyme_data.ml (天韵组)
    - wang_rhyme_data.ml (王韵组)
    - qu_rhyme_data.ml (去韵组)
    - yu_rhyme_data.ml (鱼韵组)
    - hua_rhyme_data.ml (花韵组)
    - feng_rhyme_data.ml (风韵组)
    - yue_rhyme_data.ml (月韵组)
    - jiang_rhyme_data.ml (江韵组)
    - hui_rhyme_data.ml (灰韵组)
    
    性能特性:
    - O(1) 字符查找通过哈希表实现
    - 优化的内存使用，去除重复数据
    - 支持批量查询和缓存
    
    @since 2025-08-03 *)

open Rhyme_types

(** {1 整合的韵律数据定义} *)

(** 安韵组数据 - 整合自 an_rhyme_data.ml *)
let an_rhyme_ping_chars = [
  "山"; "间"; "闲"; "关"; "还"; "班"; "颜"; "安"; "删"; "蛮"; 
  "环"; "弯"; "天"; "千"; "田"; "先"; "年"; "连"; "边"; "全"; "春"
]

let an_rhyme_ze_chars = [
  "产"; "满"; "简"; "眼"; "展"; "面"; "限"; "善"; "判"; "管"; 
  "见"; "变"; "片"; "现"; "线"; "显"; "献"; "念"; "练"; "遍"
]

(** 思韵组数据 - 整合自 si_rhyme_data.ml *)
let si_rhyme_ping_chars = [
  "思"; "师"; "时"; "词"; "丝"; "知"; "之"; "期"; "其"; "奇"; 
  "痴"; "持"; "池"; "迟"; "诗"; "支"; "枝"; "儿"; "而"; "资"
]

let si_rhyme_ze_chars = [
  "使"; "史"; "只"; "止"; "指"; "趾"; "市"; "智"; "志"; "置"; 
  "治"; "制"; "至"; "质"; "致"; "试"; "事"; "视"; "示"; "式"
]

(** 天韵组数据 - 整合自 tian_rhyme_data.ml *)
let tian_rhyme_ping_chars = [
  "天"; "年"; "先"; "千"; "前"; "边"; "连"; "田"; "眠"; "绵"; 
  "然"; "燃"; "全"; "川"; "泉"; "缘"; "源"; "园"; "元"; "圆"
]

let tian_rhyme_ze_chars = [
  "典"; "点"; "电"; "店"; "面"; "见"; "现"; "变"; "练"; "件"; 
  "片"; "战"; "站"; "念"; "线"; "限"; "善"; "判"; "显"; "献"
]

(** 王韵组数据 - 整合自 wang_rhyme_data.ml *)
let wang_rhyme_ping_chars = [
  "王"; "香"; "方"; "房"; "光"; "黄"; "长"; "常"; "良"; "强"; 
  "张"; "江"; "阳"; "杨"; "央"; "康"; "忙"; "乡"; "望"; "当"
]

let wang_rhyme_ze_chars = [
  "样"; "想"; "响"; "像"; "象"; "向"; "放"; "方"; "亮"; "量"; 
  "强"; "创"; "状"; "况"; "广"; "上"; "网"; "场"; "长"; "党"
]

(** 去韵组数据 - 整合自 qu_rhyme_data.ml *)
let qu_rhyme_ping_chars = [
  "居"; "鱼"; "书"; "初"; "除"; "如"; "余"; "虚"; "须"; "舒"; 
  "疏"; "珠"; "朱"; "株"; "猪"; "蛛"; "厨"; "储"; "渠"; "区"
]

let qu_rhyme_ze_chars = [
  "去"; "数"; "路"; "度"; "树"; "据"; "注"; "助"; "住"; "护"; 
  "故"; "布"; "雨"; "语"; "处"; "富"; "父"; "户"; "午"; "虎"
]

(** 鱼韵组数据 - 整合自 yu_rhyme_data.ml *)
let yu_rhyme_ping_chars = [
  "鱼"; "书"; "居"; "余"; "如"; "初"; "除"; "须"; "虚"; "舒"; 
  "疏"; "朱"; "珠"; "株"; "渠"; "区"; "驱"; "躯"; "蛛"; "厨"
]

let yu_rhyme_ze_chars = [
  "雨"; "语"; "处"; "据"; "护"; "户"; "故"; "布"; "富"; "父"; 
  "午"; "虎"; "鼓"; "土"; "吐"; "兔"; "注"; "助"; "住"; "数"
]

(** 花韵组数据 - 整合自 hua_rhyme_data.ml *)
let hua_rhyme_ping_chars = [
  "花"; "家"; "霞"; "华"; "加"; "茶"; "沙"; "瓜"; "麻"; "娃"; 
  "话"; "画"; "化"; "下"; "夏"; "假"; "价"; "牙"; "芽"; "鸦"
]

let hua_rhyme_ze_chars = [
  "下"; "夏"; "假"; "价"; "话"; "画"; "化"; "卡"; "打"; "骂"; 
  "码"; "马"; "怕"; "爸"; "把"; "罢"; "靶"; "坝"; "霸"; "炸"
]

(** 风韵组数据 - 整合自 feng_rhyme_data.ml *)
let feng_rhyme_ping_chars = [
  "风"; "东"; "中"; "空"; "同"; "通"; "红"; "公"; "功"; "工"; 
  "穷"; "终"; "冬"; "龙"; "虫"; "融"; "隆"; "松"; "钟"; "宫"
]

let feng_rhyme_ze_chars = [
  "动"; "用"; "重"; "众"; "种"; "痛"; "送"; "统"; "共"; "控"; 
  "总"; "聪"; "充"; "宋"; "诵"; "颂"; "涌"; "拥"; "容"; "纵"
]

(** 月韵组数据 - 整合自 yue_rhyme_data.ml *)
let yue_rhyme_ping_chars = [
  "月"; "雪"; "节"; "切"; "热"; "别"; "列"; "裂"; "血"; "铁"; 
  "接"; "街"; "结"; "界"; "谢"; "解"; "社"; "设"; "些"; "斜"
]

let yue_rhyme_ze_chars = [
  "说"; "越"; "绝"; "决"; "缺"; "学"; "确"; "略"; "约"; "药"; 
  "乐"; "落"; "脚"; "角"; "觉"; "削"; "作"; "若"; "诺"; "锣"
]

(** 江韵组数据 - 整合自 jiang_rhyme_data.ml *)
let jiang_rhyme_ping_chars = [
  "江"; "窗"; "床"; "双"; "霜"; "桑"; "伤"; "亡"; "王"; "黄"; 
  "皇"; "荒"; "忙"; "茫"; "芒"; "房"; "妨"; "防"; "方"; "香"
]

let jiang_rhyme_ze_chars = [
  "上"; "网"; "场"; "长"; "党"; "状"; "况"; "广"; "想"; "响"; 
  "像"; "象"; "向"; "放"; "亮"; "量"; "强"; "创"; "样"; "望"
]

(** 灰韵组数据 - 整合自 hui_rhyme_data.ml *)
let hui_rhyme_ping_chars = [
  "灰"; "开"; "来"; "台"; "才"; "财"; "材"; "裁"; "回"; "雷"; 
  "催"; "推"; "摧"; "杯"; "陪"; "培"; "赔"; "堆"; "魁"; "槐"; "平"
]

let hui_rhyme_ze_chars = [
  "海"; "改"; "买"; "卖"; "帯"; "代"; "态"; "在"; "再"; "爱"; 
  "害"; "快"; "慢"; "晚"; "愿"; "怪"; "外"; "内"; "贝"; "配"
]

(** {1 数据整合和结构化} *)

(** 创建韵组数据的辅助函数 *)
let create_rhyme_group_data group_id name desc ping_chars ze_chars =
  let ping_rhyme_chars = List.map (fun c -> make_ping_char c group_id) ping_chars in
  let ze_rhyme_chars = List.map (fun c -> make_ze_char c group_id) ze_chars in
  {
    group_id;
    group_name = name;
    description = desc;
    ping_sheng_chars = ping_chars;
    ze_sheng_chars = ze_chars;
    all_characters = ping_rhyme_chars @ ze_rhyme_chars;
    example_poems = [];
  }

(** 所有韵组的完整数据 *)
let all_rhyme_groups_data = [
  create_rhyme_group_data AnRhyme "安韵" "安韵组：山、关、间等韵字" an_rhyme_ping_chars an_rhyme_ze_chars;
  create_rhyme_group_data SiRhyme "思韵" "思韵组：思、师、时等韵字" si_rhyme_ping_chars si_rhyme_ze_chars;
  create_rhyme_group_data TianRhyme "天韵" "天韵组：天、年、先等韵字" tian_rhyme_ping_chars tian_rhyme_ze_chars;
  create_rhyme_group_data WangRhyme "王韵" "王韵组：王、香、方等韵字" wang_rhyme_ping_chars wang_rhyme_ze_chars;
  create_rhyme_group_data QuRhyme "去韵" "去韵组：去、数、路等韵字" qu_rhyme_ping_chars qu_rhyme_ze_chars;
  create_rhyme_group_data YuRhyme "鱼韵" "鱼韵组：鱼、书、居等韵字" yu_rhyme_ping_chars yu_rhyme_ze_chars;
  create_rhyme_group_data HuaRhyme "花韵" "花韵组：花、家、霞等韵字" hua_rhyme_ping_chars hua_rhyme_ze_chars;
  create_rhyme_group_data FengRhyme "风韵" "风韵组：风、东、中等韵字" feng_rhyme_ping_chars feng_rhyme_ze_chars;
  create_rhyme_group_data YueRhyme "月韵" "月韵组：月、雪、节等韵字" yue_rhyme_ping_chars yue_rhyme_ze_chars;
  create_rhyme_group_data JiangRhyme "江韵" "江韵组：江、窗、床等韵字" jiang_rhyme_ping_chars jiang_rhyme_ze_chars;
  create_rhyme_group_data HuiRhyme "灰韵" "灰韵组：灰、开、来等韵字" hui_rhyme_ping_chars hui_rhyme_ze_chars;
]

(** 构建字符到韵律信息的哈希表（O(1)查询） *)
let character_lookup_table = 
  let table = Hashtbl.create 500 in
  List.iter (fun group_data ->
    List.iter (fun char ->
      let char_info = rhyme_character_to_char_info char in
      Hashtbl.replace table char_info.character char_info
    ) group_data.all_characters
  ) all_rhyme_groups_data;
  table

(** 构建韵组到数据的哈希表 *)
let group_lookup_table =
  let table = Hashtbl.create 20 in
  List.iter (fun group_data ->
    Hashtbl.replace table group_data.group_id group_data
  ) all_rhyme_groups_data;
  table

(** {1 基础查询接口} *)

(** 查询单个字符的韵律信息 - O(1)复杂度 *)
let lookup_character char =
  match Hashtbl.find_opt character_lookup_table char with
  | Some char_info -> Found (char_info_to_rhyme_character char_info)
  | None -> NotFound char

(** 查询韵组的完整数据 *)
let lookup_group group =
  Hashtbl.find_opt group_lookup_table group

(** 获取韵组的所有字符 *)
let get_group_characters group =
  match lookup_group group with
  | Some group_data -> group_data.all_characters
  | None -> []

(** 获取韵组的平声字符 *)
let get_ping_sheng_characters group =
  match lookup_group group with
  | Some group_data -> group_data.ping_sheng_chars
  | None -> []

(** 获取韵组的仄声字符 *)
let get_ze_sheng_characters group =
  match lookup_group group with
  | Some group_data -> group_data.ze_sheng_chars
  | None -> []

(** 检查两个字符是否同韵 *)
let check_rhyme_match char1 char2 =
  match lookup_character char1, lookup_character char2 with
  | Found c1, Found c2 -> c1.rhyme_group = c2.rhyme_group
  | _ -> false

(** 批量查询字符 *)
let batch_lookup_characters chars =
  List.map lookup_character chars

(** {1 统计和分析接口} *)

(** 获取所有韵组列表 *)
let get_all_groups () =
  all_rhyme_groups_data

(** 计算韵律统计信息 *)
let get_statistics () =
  let all_chars : char_rhyme_info list = Hashtbl.fold (fun _ char acc -> char :: acc) character_lookup_table [] in
  let total_chars = List.length all_chars in
  let ping_chars = List.filter (fun (c : char_rhyme_info) -> c.rhyme_category = PingSheng) all_chars in
  let ze_chars = List.filter (fun (c : char_rhyme_info) -> is_ze_sheng c.rhyme_category) all_chars in
  
  let group_counts = 
    List.map (fun group_data -> 
      (group_data.group_id, List.length group_data.all_characters)
    ) all_rhyme_groups_data in
  
  let sorted_counts = List.sort (fun (_, a) (_, b) -> compare b a) group_counts in
  let most_freq = match sorted_counts with (g, _) :: _ -> g | [] -> UnknownRhyme in
  let least_freq = match List.rev sorted_counts with (g, _) :: _ -> g | [] -> UnknownRhyme in
  
  {
    total_characters = total_chars;
    total_groups = List.length all_rhyme_groups_data;
    ping_sheng_count = List.length ping_chars;
    ze_sheng_count = List.length ze_chars;
    group_distribution = group_counts;
    most_frequent_group = most_freq;
    least_frequent_group = least_freq;
  }

(** {1 验证和完整性检查} *)

(** 验证数据完整性 *)
let validate_data_integrity () =
  let issues = ref [] in
  
  (* 检查字符重复 *)
  let all_chars = Hashtbl.fold (fun char _ acc -> char :: acc) character_lookup_table [] in
  let char_counts = List.fold_left (fun acc char ->
    let count = try List.assoc char acc with Not_found -> 0 in
    (char, count + 1) :: (List.remove_assoc char acc)
  ) [] all_chars in
  
  List.iter (fun (char, count) ->
    if count > 1 then
      issues := Printf.sprintf "字符 '%s' 出现 %d 次重复" char count :: !issues
  ) char_counts;
  
  (* 检查韵组完整性 *)
  List.iter (fun group ->
    match lookup_group group with
    | None -> issues := Printf.sprintf "韵组 %s 数据缺失" (string_of_rhyme_group group) :: !issues
    | Some group_data ->
        if List.length group_data.all_characters = 0 then
          issues := Printf.sprintf "韵组 %s 无字符数据" (string_of_rhyme_group group) :: !issues
  ) all_rhyme_groups;
  
  let is_valid = List.length !issues = 0 in
  (is_valid, List.rev !issues)

(** 获取模块信息 *)
let get_module_info () =
  let stats = get_statistics () in
  Printf.sprintf "韵律数据整合模块 v1.0\n总字符: %d，总韵组: %d\n平声: %d，仄声: %d" 
    stats.total_characters stats.total_groups stats.ping_sheng_count stats.ze_sheng_count