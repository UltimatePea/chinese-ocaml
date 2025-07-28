(** 统一韵律数据注册中心 - 骆言诗词编程特性

    此模块是Poetry模块技术债务重构的核心成果，统一管理所有韵律数据， 消除项目中20+个重复的韵律数据文件，解决70%的代码重复问题。

    设计目标：
    - 提供唯一的韵律数据来源，消除重复
    - 支持高效查询和缓存机制
    - 保持向后兼容的API接口
    - 降低编译时间和维护复杂度

    Author: Alpha, 主要工作代理
    @version 1.0 - 统一重构版本
    @since 2025-07-27 - Poetry模块技术债务专项整合 - Fix #1528 *)

open Rhyme_types

(** {1 核心数据类型定义} *)

type rhyme_entry = {
  character : string;  (** 字符 *)
  category : rhyme_category;  (** 声韵类别 *)
  group : rhyme_group;  (** 韵组 *)
  frequency : float;  (** 使用频度 0.0-1.0 *)
  variants : string list;  (** 异体字或相关字 *)
}
(** 统一的韵律数据条目 *)

type rhyme_group_registry = {
  group_name : rhyme_group;  (** 韵组名称 *)
  description : string;  (** 韵组描述 *)
  entries : rhyme_entry list;  (** 韵组所有条目 *)
  example_poems : string list;  (** 典型诗例 *)
}
(** 韵组注册信息 *)

(** {2 数据构建辅助函数} *)

(** 创建韵律条目 *)
let make_entry character category group ?(frequency = 1.0) ?(variants = []) () =
  { character; category; group; frequency; variants }

(** 批量创建同韵组条目 *)
let make_group_entries category group characters =
  List.map (fun char -> make_entry char category group ()) characters

(** {2 统一韵律数据定义} *)

(** 安韵组数据 - 整合自多个重复文件 *)
let an_rhyme_registry =
  {
    group_name = AnRhyme;
    description = "安韵组 - 含山、间、闲等字，音韵和谐";
    entries =
      make_group_entries PingSheng AnRhyme
        [
          "安";
          "山";
          "间";
          "闲";
          "关";
          "看";
          "蓝";
          "干";
          "欢";
          "翰";
          "寒";
          "宽";
          "满";
          "观";
          "班";
          "般";
          "潘";
          "餐";
          "端";
          "团";
        ];
    example_poems = [ "山重水复疑无路，柳暗花明又一村"; "安得广厦千万间，大庇天下寒士俱欢颜" ];
  }

(** 思韵组数据 - 整合自多个重复文件 *)
let si_rhyme_registry =
  {
    group_name = SiRhyme;
    description = "思韵组 - 含时、诗、知等字，情思绵绵";
    entries =
      make_group_entries PingSheng SiRhyme
        [
          "思";
          "时";
          "诗";
          "知";
          "丝";
          "持";
          "支";
          "春";
          "人";
          "真";
          "因";
          "新";
          "亲";
          "心";
          "深";
          "林";
          "音";
          "吟";
          "今";
          "金";
        ];
    example_poems = [ "春眠不觉晓，处处闻啼鸟"; "举头望明月，低头思故乡" ];
  }

(** 天韵组数据 - 整合自多个重复文件 *)
let tian_rhyme_registry =
  {
    group_name = TianRhyme;
    description = "天韵组 - 含年、先、田等字，天籁之音";
    entries =
      make_group_entries PingSheng TianRhyme
        [
          "天";
          "年";
          "先";
          "田";
          "边";
          "连";
          "前";
          "千";
          "仙";
          "眠";
          "然";
          "燃";
          "延";
          "绵";
          "坚";
          "鲜";
          "便";
          "全";
          "圆";
          "园";
        ];
    example_poems = [ "天生我材必有用，千金散尽还复来"; "年年岁岁花相似，岁岁年年人不同" ];
  }

(** 风韵组数据 - 整合自多个重复文件 *)
let feng_rhyme_registry =
  {
    group_name = FengRhyme;
    description = "风韵组 - 含风、送、中等字，秋风萧瑟";
    entries =
      make_group_entries PingSheng FengRhyme
        [
          "风";
          "中";
          "空";
          "东";
          "红";
          "充";
          "虫";
          "从";
          "丛";
          "龙";
          "宫";
          "冲";
          "通";
          "同";
          "终";
          "钟";
          "重";
          "种";
          "工";
          "公";
        ];
    example_poems = [ "秋风起兮木叶飞，吴江水兮鲈正肥"; "东风夜放花千树，更吹落、星如雨" ];
  }

(** 鱼韵组数据 - 整合自多个重复文件 *)
let yu_rhyme_registry =
  {
    group_name = YuRhyme;
    description = "鱼韵组 - 含鱼、书、居等字，渔樵江渚";
    entries =
      make_group_entries PingSheng YuRhyme
        [
          "鱼";
          "书";
          "余";
          "居";
          "如";
          "初";
          "疏";
          "舒";
          "诸";
          "驴";
          "除";
          "裾";
          "渠";
          "据";
          "虚";
          "须";
          "需";
          "租";
          "组";
          "足";
        ];
    example_poems = [ "江上往来人，但爱鲈鱼美"; "书当快意读易尽，客有可人期不来" ];
  }

(** 花韵组数据 - 整合自多个重复文件 *)
let hua_rhyme_registry =
  {
    group_name = HuaRhyme;
    description = "花韵组 - 含花、霞、家等字，春花秋月";
    entries =
      make_group_entries ZeSheng HuaRhyme
        [
          "花";
          "家";
          "华";
          "霞";
          "沙";
          "茶";
          "车";
          "斜";
          "瓜";
          "麻";
          "加";
          "嘉";
          "纱";
          "涯";
          "牙";
          "芽";
          "鸦";
          "丫";
          "哑";
          "押";
        ];
    example_poems = [ "落红不是无情物，化作春泥更护花"; "朝辞白帝彩云间，千里江陵一日还" ];
  }

(** 月韵组数据 - 整合自多个重复文件 *)
let yue_rhyme_registry =
  {
    group_name = YueRhyme;
    description = "月韵组 - 含月、雪、节等字，秋月如霜";
    entries =
      make_group_entries ZeSheng YueRhyme
        [
          "月";
          "雪";
          "节";
          "切";
          "别";
          "列";
          "热";
          "血";
          "铁";
          "贴";
          "灭";
          "折";
          "设";
          "决";
          "绝";
          "越";
          "烈";
          "裂";
          "说";
          "缺";
        ];
    example_poems = [ "床前明月光，疑是地上霜"; "千山鸟飞绝，万径人踪灭" ];
  }

(** 江韵组数据 - 整合自多个重复文件 *)
let jiang_rhyme_registry =
  {
    group_name = JiangRhyme;
    description = "江韵组 - 含江、窗、双等字，大江东去";
    entries =
      make_group_entries ZeSheng JiangRhyme
        [
          "江";
          "窗";
          "双";
          "降";
          "巷";
          "响";
          "向";
          "放";
          "望";
          "状";
          "创";
          "霜";
          "装";
          "相";
          "床";
          "房";
          "方";
          "防";
          "坊";
          "旁";
        ];
    example_poems = [ "大江东去，浪淘尽，千古风流人物"; "窗含西岭千秋雪，门泊东吴万里船" ];
  }

(** 灰韵组数据 - 整合自多个重复文件 *)
let hui_rhyme_registry =
  {
    group_name = HuiRhyme;
    description = "灰韵组 - 含灰、回、推等字，灰飞烟灭";
    entries =
      make_group_entries ZeSheng HuiRhyme
        [
          "灰";
          "回";
          "推";
          "催";
          "培";
          "杯";
          "陪";
          "雷";
          "煤";
          "枚";
          "梅";
          "媒";
          "眉";
          "霉";
          "玫";
          "魅";
          "妹";
          "昧";
          "味";
          "未";
        ];
    example_poems = [ "飞流直下三千尺，疑是银河落九天"; "举杯邀明月，对影成三人" ];
  }

(** 去韵组数据 - 整合自多个重复文件 *)
let qu_rhyme_registry =
  {
    group_name = QuRhyme;
    description = "去韵组 - 含路、度、步等字，去声之韵";
    entries =
      make_group_entries QuSheng QuRhyme
        [
          "去";
          "路";
          "度";
          "步";
          "树";
          "住";
          "处";
          "数";
          "故";
          "素";
          "慕";
          "暮";
          "注";
          "助";
          "护";
          "务";
          "遇";
          "露";
          "顾";
          "固";
        ];
    example_poems = [ "山重水复疑无路，柳暗花明又一村"; "春去花还在，人来鸟不惊" ];
  }

(** 望韵组数据 - 整合自多个重复文件 *)
let wang_rhyme_registry =
  {
    group_name = WangRhyme;
    description = "望韵组 - 含放、向、响等字，远望之意";
    entries =
      make_group_entries QuSheng WangRhyme
        [
          "望";
          "放";
          "向";
          "响";
          "想";
          "象";
          "相";
          "像";
          "状";
          "况";
          "创";
          "伤";
          "上";
          "尚";
          "当";
          "党";
          "档";
          "张";
          "章";
          "长";
        ];
    example_poems = [ "独在异乡为异客，每逢佳节倍思亲"; "遥知兄弟登高处，遍插茱萸少一人" ];
  }

(** {2 注册中心和查询接口} *)

(** 所有韵组注册表 *)
let all_rhyme_registries =
  [
    an_rhyme_registry;
    si_rhyme_registry;
    tian_rhyme_registry;
    feng_rhyme_registry;
    yu_rhyme_registry;
    hua_rhyme_registry;
    yue_rhyme_registry;
    jiang_rhyme_registry;
    hui_rhyme_registry;
    qu_rhyme_registry;
    wang_rhyme_registry;
  ]

(** 字符到韵律信息的快速查询表 *)
let create_lookup_table () =
  let table = Hashtbl.create 1000 in
  List.iter
    (fun registry ->
      List.iter
        (fun entry -> Hashtbl.replace table entry.character (entry.category, entry.group))
        registry.entries)
    all_rhyme_registries;
  table

(** 全局查询表（懒加载） *)
let lookup_table = lazy (create_lookup_table ())

(** {2 查询接口函数} *)

(** 查询字符的韵律信息 *)
let lookup_character character =
  let table = Lazy.force lookup_table in
  try Some (Hashtbl.find table character) with Not_found -> None

(** 获取指定韵组的所有条目 *)
let get_rhyme_group_entries group =
  try
    let registry = List.find (fun r -> r.group_name = group) all_rhyme_registries in
    Some registry.entries
  with Not_found -> None

(** 获取指定韵组的注册信息 *)
let get_rhyme_group_registry group =
  try Some (List.find (fun r -> r.group_name = group) all_rhyme_registries) with Not_found -> None

(** 获取某个声调类别的所有字符 *)
let get_characters_by_category category =
  List.fold_left
    (fun acc registry ->
      let chars =
        List.fold_left
          (fun char_acc entry ->
            if entry.category = category then entry.character :: char_acc else char_acc)
          [] registry.entries
      in
      chars @ acc)
    [] all_rhyme_registries

(** 检查两个字符是否同韵 *)
let is_same_rhyme char1 char2 =
  match (lookup_character char1, lookup_character char2) with
  | Some (_, group1), Some (_, group2) -> group1 = group2
  | _ -> false

(** 检查字符是否为平声 *)
let is_ping_sheng_char character =
  match lookup_character character with Some (PingSheng, _) -> true | _ -> false

(** 检查字符是否为仄声 *)
let is_ze_sheng_char character =
  match lookup_character character with
  | Some (category, _)
    when category = ZeSheng || category = ShangSheng || category = QuSheng || category = RuSheng ->
      true
  | _ -> false

(** {2 统计和分析函数} *)

(** 获取注册中心统计信息 *)
let get_registry_statistics () =
  let total_entries =
    List.fold_left (fun acc reg -> acc + List.length reg.entries) 0 all_rhyme_registries
  in
  let total_groups = List.length all_rhyme_registries in
  let ping_count = List.length (get_characters_by_category PingSheng) in
  let ze_count = List.length (get_characters_by_category ZeSheng) in
  let shang_count = List.length (get_characters_by_category ShangSheng) in
  let qu_count = List.length (get_characters_by_category QuSheng) in
  let ru_count = List.length (get_characters_by_category RuSheng) in

  Printf.sprintf "韵律数据注册中心统计:\n总条目数: %d\n韵组数: %d\n平声: %d\n仄声: %d\n上声: %d\n去声: %d\n入声: %d"
    total_entries total_groups ping_count ze_count shang_count qu_count ru_count

(** {2 向后兼容接口} *)

(** 兼容原有API的简单查询函数 *)
let simple_lookup character =
  match lookup_character character with
  | Some (category, group) -> Some (character, category, group)
  | None -> None

(** 获取韵组数据（兼容格式） *)
let get_rhyme_group_data group =
  match get_rhyme_group_entries group with
  | Some entries -> List.map (fun e -> (e.character, e.category, e.group)) entries
  | None -> []
