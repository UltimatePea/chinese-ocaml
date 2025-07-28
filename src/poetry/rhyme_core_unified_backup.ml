(** 韵律数据统一核心模块 - 骆言诗词编程特性

    此模块是技术债务重构的核心成果，经过模块化重构后提供统一的韵律数据访问接口。 模块化重构消除了854行单一文件的维护复杂度，提高编译并行度。

    重构目标：
    - 模块化拆分降低单文件复杂度（从854行拆分为4个职责单一模块）
    - 提供统一的数据访问接口
    - 提升编译效率和维护性
    - 保持100%的API兼容性

    Author: Alpha, 主要工作代理
    @version 5.0 - 模块化重构版本
    @since 2025-07-28 - 基于Issue #1585的科学技术债务重构计划 *)

(** {1 模块化重构导入} *)

open Poetry_types_consolidated
(** 导入重构后的模块化组件 *)

open Rhyme_core_types
open Rhyme_data_builder
open Rhyme_group_manager
open Rhyme_query_engine

(** {2 类型重导出 - 保持API兼容性} *)

type rhyme_data_entry = Rhyme_core_types.rhyme_data_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  variants : string list;
  usage_frequency : float;
}
(** 重导出核心类型以保持现有代码兼容 *)

type rhyme_group_data = Rhyme_core_types.rhyme_group_data = {
  group_name : rhyme_group;
  group_description : string;
  entries : rhyme_data_entry list;
  example_poems : string list;
}

(** {3 构建函数重导出} *)

(** 重导出构建辅助函数以保持API兼容性 *)
let make_entry = Rhyme_data_builder.make_entry

let make_group_entries = Rhyme_data_builder.make_group_entries

(** {4 韵律数据重导出 - 保持API兼容性} *)

(** 重导出所有韵组数据以保持现有代码兼容 *)
let an_rhyme_data = Rhyme_data_builder.an_rhyme_data

let si_rhyme_data = Rhyme_data_builder.si_rhyme_data

(** 天韵组数据 - 整合自 tian_rhyme_data.ml 和相关文件 *)
let tian_rhyme_data =
  let ping_sheng_chars =
    [
      "天";
      "年";
      "先";
      "田";
      "边";
      "前";
      "连";
      "千";
      "线";
      "坚";
      "全";
      "圆";
      "便";
      "面";
      "见";
      "片";
      "编";
      "眠";
      "蟾";
      "贤";
      "填";
      "肩";
      "传";
      "船";
      "川";
      "泉";
      "弦";
      "烟";
      "燕";
      "县";
      "仙";
      "鲜";
      "绵";
      "延";
      "颠";
      "牵";
    ]
  in
  let ze_sheng_chars =
    [
      "变";
      "电";
      "片";
      "店";
      "点";
      "念";
      "见";
      "现";
      "线";
      "显";
      "典";
      "殿";
      "遍";
      "便";
      "面";
      "箭";
      "剑";
      "件";
      "建";
      "健";
      "键";
      "练";
      "炼";
      "链";
    ]
  in
  {
    group_name = TianRhyme;
    group_description = "天韵组 - 含年、先、田等字，天籁之音";
    entries =
      make_group_entries PingSheng TianRhyme ping_sheng_chars
      @ make_group_entries ZeSheng TianRhyme ze_sheng_chars;
    example_poems = [ "天生我材必有用，千金散尽还复来"; "春花秋月何时了，往事知多少"; "床前明月光，疑是地上霜" ];
  }

(** 望韵组数据 - 整合自 wang_rhyme_data.ml 和相关文件 *)
let wang_rhyme_data =
  let ze_sheng_chars =
    [
      "望";
      "放";
      "向";
      "响";
      "亮";
      "唱";
      "忘";
      "想";
      "上";
      "当";
      "长";
      "张";
      "房";
      "方";
      "旁";
      "傍";
      "堂";
      "塘";
      "墙";
      "强";
      "光";
      "广";
      "网";
      "状";
      "样";
      "量";
      "场";
      "常";
      "床";
      "窗";
      "双";
      "霜";
      "创";
      "装";
      "藏";
      "浪";
    ]
  in
  {
    group_name = WangRhyme;
    group_description = "望韵组 - 含放、向、响等字，远望之意";
    entries = make_group_entries ZeSheng WangRhyme ze_sheng_chars;
    example_poems = [ "西塞山前白鹭飞，桃花流水鳜鱼肥"; "两个黄鹂鸣翠柳，一行白鹭上青天"; "窗含西岭千秋雪，门泊东吴万里船" ];
  }

(** 去韵组数据 - 整合自 qu_rhyme_data.ml 和相关文件 *)
let qu_rhyme_data =
  let ze_sheng_chars =
    [
      "去";
      "路";
      "度";
      "步";
      "府";
      "故";
      "住";
      "处";
      "数";
      "素";
      "布";
      "户";
      "古";
      "土";
      "苦";
      "库";
      "护";
      "互";
      "注";
      "助";
      "著";
      "部";
      "图";
      "途";
      "树";
      "书";
      "鼠";
      "暑";
      "绪";
      "序";
      "叙";
      "述";
      "术";
      "束";
      "属";
      "竹";
    ]
  in
  {
    group_name = QuRhyme;
    group_description = "去韵组 - 含路、度、步等字，去声之韵";
    entries = make_group_entries ZeSheng QuRhyme ze_sheng_chars;
    example_poems = [ "国破山河在，城春草木深"; "好雨知时节，当春乃发生"; "黄河远上白云间，一片孤城万仞山" ];
  }

(** 鱼韵组数据 - 整合自 yu_rhyme_data.ml 和相关文件 *)
let yu_rhyme_data =
  let ping_sheng_chars =
    [
      "鱼";
      "书";
      "余";
      "居";
      "如";
      "初";
      "渠";
      "车";
      "花";
      "家";
      "华";
      "加";
      "嘉";
      "茶";
      "沙";
      "纱";
      "牙";
      "芽";
      "霞";
      "瓜";
      "蛙";
      "娃";
      "画";
      "话";
      "化";
      "划";
      "马";
      "下";
      "夏";
      "价";
      "架";
      "假";
      "货";
      "火";
      "果";
      "过";
    ]
  in
  {
    group_name = YuRhyme;
    group_description = "鱼韵组 - 含鱼、书、居等字，渔樵江渚";
    entries = make_group_entries PingSheng YuRhyme ping_sheng_chars;
    example_poems = [ "江南可采莲，莲叶何田田"; "青青河畔草，绵绵思远道"; "相见时难别亦难，东风无力百花残" ];
  }

(** 花韵组数据 - 整合自 hua_rhyme_data.ml 和相关文件 *)
let hua_rhyme_data =
  let ping_sheng_chars =
    [
      "花";
      "华";
      "家";
      "加";
      "嘉";
      "茶";
      "沙";
      "纱";
      "牙";
      "芽";
      "霞";
      "瓜";
      "蛙";
      "娃";
      "画";
      "话";
      "化";
      "划";
      "马";
      "下";
      "夏";
      "价";
      "架";
      "假";
    ]
  in
  let ze_sheng_chars =
    [
      "化";
      "话";
      "画";
      "划";
      "价";
      "架";
      "假";
      "货";
      "火";
      "果";
      "过";
      "坐";
      "座";
      "作";
      "做";
      "破";
      "播";
      "课";
      "可";
      "河";
      "何";
      "哥";
      "歌";
      "多";
    ]
  in
  {
    group_name = HuaRhyme;
    group_description = "花韵组 - 含花、霞、家等字，春花秋月";
    entries =
      make_group_entries PingSheng HuaRhyme ping_sheng_chars
      @ make_group_entries ZeSheng HuaRhyme ze_sheng_chars;
    example_poems = [ "人面不知何处去，桃花依旧笑春风"; "花开堪折直须折，莫待无花空折枝"; "春色满园关不住，一枝红杏出墙来" ];
  }

(** 风韵组数据 - 整合自 feng_rhyme_data.ml 和相关文件 *)
let feng_rhyme_data =
  let ping_sheng_chars =
    [
      "风";
      "中";
      "空";
      "东";
      "红";
      "虫";
      "冲";
      "从";
      "重";
      "宫";
      "公";
      "功";
      "工";
      "弓";
      "穷";
      "终";
      "钟";
      "雄";
      "熊";
      "充";
      "松";
      "送";
      "通";
      "同";
      "童";
      "桐";
      "铜";
      "朋";
      "蓬";
      "鹏";
      "陇";
      "隆";
      "龙";
      "浓";
      "农";
      "绒";
    ]
  in
  let ze_sheng_chars =
    [
      "送";
      "用";
      "动";
      "众";
      "重";
      "种";
      "总";
      "宗";
      "综";
      "纵";
      "从";
      "冲";
      "统";
      "痛";
      "通";
      "同";
      "童";
      "桐";
      "铜";
      "筒";
      "控";
      "空";
      "孔";
      "洞";
    ]
  in
  {
    group_name = FengRhyme;
    group_description = "风韵组 - 含风、送、中等字，秋风萧瑟";
    entries =
      make_group_entries PingSheng FengRhyme ping_sheng_chars
      @ make_group_entries ZeSheng FengRhyme ze_sheng_chars;
    example_poems = [ "大漠沙如雪，燕山月似钩"; "黄河之水天上来，奔流到海不复回"; "飞流直下三千尺，疑是银河落九天" ];
  }

(** 月韵组数据 - 整合自 yue_rhyme_data.ml 和相关文件 *)
let yue_rhyme_data =
  let ze_sheng_chars =
    [
      "月";
      "雪";
      "节";
      "热";
      "切";
      "设";
      "说";
      "决";
      "绝";
      "血";
      "铁";
      "别";
      "列";
      "烈";
      "裂";
      "灭";
      "结";
      "洁";
      "接";
      "街";
      "解";
      "界";
      "借";
      "介";
      "戒";
      "届";
      "疥";
      "芥";
      "械";
      "懈";
      "谢";
      "楔";
      "泄";
      "屑";
      "咽";
      "噎";
    ]
  in
  {
    group_name = YueRhyme;
    group_description = "月韵组 - 含月、雪、节等字，秋月如霜";
    entries = make_group_entries ZeSheng YueRhyme ze_sheng_chars;
    example_poems = [ "明月几时有，把酒问青天"; "海上生明月，天涯共此时"; "月落乌啼霜满天，江枫渔火对愁眠" ];
  }

(** 江韵组数据 - 整合自 jiang_rhyme_data.ml 和相关文件 *)
let jiang_rhyme_data =
  let ping_sheng_chars =
    [
      "江";
      "窗";
      "双";
      "霜";
      "创";
      "装";
      "藏";
      "浪";
      "郎";
      "狼";
      "廊";
      "朗";
      "忙";
      "茫";
      "忘";
      "芒";
      "亡";
      "王";
      "往";
      "网";
      "旺";
      "汪";
      "妄";
    ]
  in
  let ze_sheng_chars =
    [
      "唱";
      "创";
      "装";
      "藏";
      "浪";
      "郎";
      "狼";
      "廊";
      "朗";
      "忙";
      "茫";
      "忘";
      "芒";
      "亡";
      "王";
      "往";
      "网";
      "旺";
      "汪";
      "妄";
      "方";
      "房";
    ]
  in
  {
    group_name = JiangRhyme;
    group_description = "江韵组 - 含江、窗、双等字，大江东去";
    entries =
      make_group_entries PingSheng JiangRhyme ping_sheng_chars
      @ make_group_entries ZeSheng JiangRhyme ze_sheng_chars;
    example_poems = [ "孤帆远影碧空尽，唯见长江天际流"; "无边落木萧萧下，不尽长江滚滚来"; "朝辞白帝彩云间，千里江陵一日还" ];
  }

(** 灰韵组数据 - 整合自 hui_rhyme_data.ml 和相关文件 *)
let hui_rhyme_data =
  let ping_sheng_chars =
    [
      "灰";
      "回";
      "推";
      "胎";
      "台";
      "来";
      "开";
      "才";
      "材";
      "财";
      "裁";
      "哀";
      "崖";
      "涯";
      "牌";
      "排";
      "培";
      "陪";
      "赔";
      "杯";
      "悲";
      "北";
      "备";
      "被";
    ]
  in
  let ze_sheng_chars =
    [
      "改";
      "海";
      "害";
      "亥";
      "代";
      "带";
      "待";
      "黛";
      "呆";
      "袋";
      "贷";
      "逮";
      "态";
      "太";
      "泰";
      "汰";
      "肽";
      "钛";
      "苔";
      "抬";
      "胎";
      "台";
      "怠";
      "殆";
    ]
  in
  {
    group_name = HuiRhyme;
    group_description = "灰韵组 - 含灰、回、推等字，灰飞烟灭";
    entries =
      make_group_entries PingSheng HuiRhyme ping_sheng_chars
      @ make_group_entries ZeSheng HuiRhyme ze_sheng_chars;
    example_poems = [ "白日依山尽，黄河入海流"; "欲穷千里目，更上一层楼"; "莫愁前路无知己，天下谁人不识君" ];
  }

(** {3 韵律数据集合} *)

(** 所有韵组数据的统一集合 - 消除重复文件的核心数据结构 *)
let all_rhyme_groups =
  [
    an_rhyme_data;
    si_rhyme_data;
    tian_rhyme_data;
    wang_rhyme_data;
    qu_rhyme_data;
    yu_rhyme_data;
    hua_rhyme_data;
    feng_rhyme_data;
    yue_rhyme_data;
    jiang_rhyme_data;
    hui_rhyme_data;
  ]

(** 扁平化的所有韵律数据条目 - 内部使用延迟初始化优化性能 *)
let all_rhyme_entries_lazy =
  lazy
    (List.fold_left
       (fun acc group_data -> List.rev_append group_data.entries acc)
       [] all_rhyme_groups
    |> List.rev)

(** 扁平化的所有韵律数据条目 - 对外接口保持兼容性 *)
let all_rhyme_entries = Lazy.force all_rhyme_entries_lazy

(** 高效字符查询哈希表 - 延迟初始化以提升性能 *)
let char_lookup_table =
  lazy
    (let table = Hashtbl.create 1024 in
     List.iter
       (fun entry -> Hashtbl.add table entry.character entry)
       (Lazy.force all_rhyme_entries_lazy);
     table)

(** 韵组查询哈希表 - 优化韵组查找性能 *)
let group_lookup_table =
  lazy
    (let table = Hashtbl.create 64 in
     List.iter
       (fun group_data -> Hashtbl.add table group_data.group_name group_data)
       all_rhyme_groups;
     table)

(** {4 查询接口函数} *)

(** 根据字符查找韵律信息 - 优化为O(1)哈希查询 *)
let find_char_rhyme_info char = Hashtbl.find_opt (Lazy.force char_lookup_table) char

(** 根据韵组获取所有数据 - 优化为O(1)哈希查询 *)
let get_rhyme_group_data group = Hashtbl.find_opt (Lazy.force group_lookup_table) group

(** 根据韵类获取所有字符 *)
let get_chars_by_category category =
  List.filter_map
    (fun entry -> if entry.category = category then Some entry.character else None)
    (Lazy.force all_rhyme_entries_lazy)

(** 根据韵组获取所有字符 *)
let get_chars_by_group group =
  List.filter_map
    (fun entry -> if entry.group = group then Some entry.character else None)
    (Lazy.force all_rhyme_entries_lazy)

(** 获取统计信息 - 缓存统计结果以提升性能 *)
let get_statistics =
  let cached_stats = ref None in
  fun () ->
    match !cached_stats with
    | Some stats -> stats
    | None ->
        let all_entries = Lazy.force all_rhyme_entries_lazy in
        let total_entries = List.length all_entries in
        let total_groups = List.length all_rhyme_groups in
        let ping_sheng_count = List.length (get_chars_by_category PingSheng) in
        let ze_sheng_count = List.length (get_chars_by_category ZeSheng) in
        let stats =
          Printf.sprintf "韵律数据统计: 总计 %d 个字符，%d 个韵组，平声 %d 字，仄声 %d 字" total_entries total_groups
            ping_sheng_count ze_sheng_count
        in
        cached_stats := Some stats;
        stats

(** {5 向后兼容性接口} *)

(** 为保持兼容性而提供的遗留接口函数 *)
let get_legacy_rhyme_data () = Lazy.force all_rhyme_entries_lazy

(** 导出供其他模块使用的数据访问函数 *)
let lookup_character = find_char_rhyme_info

let lookup_group = get_rhyme_group_data
let get_all_groups () = all_rhyme_groups
let get_all_entries () = Lazy.force all_rhyme_entries_lazy
let get_all_rhyme_groups () = List.map (fun group_data -> group_data.group_name) all_rhyme_groups
