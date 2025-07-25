(** 韵律核心数据模块 - 骆言诗词编程特性

    此模块统一管理所有韵律数据，消除项目中30+文件的数据重复问题。 集成来自
    rhyme_data.ml、poetry_rhyme_data.ml、consolidated_rhyme_data.ml 等模块的数据。

    重构目标：
    - 整合所有分散的韵律数据定义
    - 提供统一的数据访问接口
    - 消除数据重复，提升维护性

    @author 骆言诗词编程团队
    @version 3.0 - 核心重构版本
    @since 2025-07-25 *)

open Rhyme_core_types

(** {1 基础韵律数据} *)

(** 创建韵律数据条目的辅助函数 *)
let make_entry char category group ?(variants = []) ?(frequency = 1.0) () =
  { character = char; category; group; variants; usage_frequency = frequency }

(** 创建某个韵组字符列表的辅助函数 *)
let make_group_entries category group chars =
  List.map (fun char -> make_entry char category group ()) chars

(** {2 安韵组数据 - 整合自多个原始文件} *)

(** 安韵组平声数据 *)
let an_yun_ping_sheng_chars =
  [
    "山";
    "间";
    "闲";
    "关";
    "还";
    "班";
    "颜";
    "安";
    "删";
    "蛮";
    "环";
    "弯";
    "天";
    "年";
    "先";
    "边";
    "前";
    "连";
    "千";
    "线";
    "坚";
    "全";
    "圆";
    "便";
    "言";
    "烟";
    "研";
    "燕";
    "延";
    "权";
    "传";
    "船";
    "川";
    "泉";
    "县";
    "变";
    "团";
    "观";
    "官";
    "端";
    "管";
    "算";
    "短";
    "断";
    "乱";
    "段";
    "判";
    "半";
  ]

let an_yun_ping_sheng_data = make_group_entries PingSheng AnRhyme an_yun_ping_sheng_chars

(** 安韵组仄声数据 *)
let an_yun_ze_sheng_chars =
  [
    "晚";
    "暖";
    "乱";
    "断";
    "慢";
    "满";
    "散";
    "难";
    "看";
    "旦";
    "叹";
    "案";
    "万";
    "办";
    "半";
    "判";
    "般";
    "盘";
    "单";
    "团";
    "观";
    "官";
    "端";
    "管";
    "算";
    "短";
    "段";
    "乱";
    "判";
    "半";
    "版";
    "板";
    "献";
    "见";
    "面";
    "片";
  ]

let an_yun_ze_sheng_data = make_group_entries ZeSheng AnRhyme an_yun_ze_sheng_chars

(** {3 思韵组数据} *)

(** 思韵组平声数据 *)
let si_yun_ping_sheng_chars =
  [
    "诗";
    "时";
    "知";
    "思";
    "才";
    "材";
    "灾";
    "猜";
    "来";
    "开";
    "台";
    "载";
    "白";
    "百";
    "拍";
    "牌";
    "排";
    "怀";
    "坏";
    "海";
    "买";
    "卖";
    "带";
    "待";
    "爱";
    "外";
    "快";
    "块";
    "怪";
    "界";
    "解";
    "类";
    "内";
    "黑";
    "背";
    "配";
  ]

let si_yun_ping_sheng_data = make_group_entries PingSheng SiRhyme si_yun_ping_sheng_chars

(** 思韵组仄声数据 *)
let si_yun_ze_sheng_chars =
  [
    "字";
    "自";
    "紫";
    "次";
    "此";
    "死";
    "史";
    "使";
    "起";
    "里";
    "理";
    "李";
    "子";
    "纸";
    "水";
    "美";
    "比";
    "以";
    "已";
    "似";
    "是";
    "喜";
    "意";
    "气";
    "地";
    "第";
    "体";
    "替";
    "题";
    "系";
    "西";
    "息";
    "席";
    "习";
    "吸";
    "及";
  ]

let si_yun_ze_sheng_data = make_group_entries ZeSheng SiRhyme si_yun_ze_sheng_chars

(** {4 天韵组数据} *)

(** 天韵组平声数据 *)
let tian_yun_ping_sheng_chars =
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
    "变";
    "点";
    "电";
    "店";
    "展";
    "县";
    "现";
    "显";
    "间";
    "建";
    "健";
    "件";
    "剑";
    "检";
    "减";
    "简";
    "选";
    "船";
    "传";
    "川";
    "泉";
    "权";
    "全";
    "拳";
    "圈";
    "劝";
    "券";
    "软";
    "源";
    "原";
    "元";
    "园";
  ]

let tian_yun_ping_sheng_data = make_group_entries PingSheng TianRhyme tian_yun_ping_sheng_chars

(** {5 望韵组数据} *)

(** 望韵组仄声数据 *)
let wang_yun_ze_sheng_chars =
  [
    "望";
    "放";
    "向";
    "响";
    "上";
    "长";
    "张";
    "方";
    "房";
    "光";
    "广";
    "想";
    "象";
    "像";
    "相";
    "香";
    "乡";
    "详";
    "享";
    "让";
    "养";
    "样";
    "量";
    "亮";
    "强";
    "墙";
    "王";
    "忘";
    "网";
    "往";
    "旺";
    "晚";
    "万";
    "玩";
    "完";
    "关";
  ]

let wang_yun_ze_sheng_data = make_group_entries ZeSheng WangRhyme wang_yun_ze_sheng_chars

(** {6 去韵组数据} *)

(** 去韵组去声数据 *)
let qu_yun_qu_sheng_chars =
  [
    "去";
    "路";
    "度";
    "步";
    "暮";
    "树";
    "住";
    "注";
    "助";
    "数";
    "术";
    "述";
    "故";
    "固";
    "顾";
    "库";
    "苦";
    "户";
    "护";
    "误";
    "雾";
    "务";
    "物";
    "服";
    "复";
    "福";
    "富";
    "付";
    "父";
    "负";
    "副";
    "附";
    "腹";
    "覆";
    "妇";
    "府";
  ]

let qu_yun_qu_sheng_data = make_group_entries QuSheng QuRhyme qu_yun_qu_sheng_chars

(** {7 扩展韵组数据 - Phase 1 Enhancement} *)

(** 鱼韵组数据 *)
let yu_yun_ping_sheng_chars =
  [
    "鱼";
    "书";
    "居";
    "虚";
    "余";
    "舒";
    "初";
    "疏";
    "如";
    "须";
    "需";
    "渠";
    "驱";
    "区";
    "躯";
    "具";
    "拒";
    "据";
    "句";
    "剧";
    "举";
    "巨";
    "拘";
    "局";
    "竹";
    "祝";
    "族";
    "足";
    "促";
    "触";
    "续";
    "读";
    "独";
    "毒";
    "督";
    "笃";
  ]

let yu_yun_ping_sheng_data = make_group_entries PingSheng YuRhyme yu_yun_ping_sheng_chars

(** 花韵组数据 *)
let hua_yun_ping_sheng_chars =
  [
    "花";
    "霞";
    "家";
    "茶";
    "沙";
    "华";
    "瓜";
    "夸";
    "画";
    "话";
    "化";
    "划";
    "挂";
    "卦";
    "怕";
    "爬";
    "拿";
    "那";
    "哪";
    "马";
    "骂";
    "打";
    "大";
    "达";
    "塔";
    "答";
    "搭";
    "法";
    "发";
    "罚";
    "乏";
    "伐";
    "筏";
    "阀";
    "察";
    "擦";
  ]

let hua_yun_ping_sheng_data = make_group_entries PingSheng HuaRhyme hua_yun_ping_sheng_chars

(** 风韵组数据 *)
let feng_yun_ping_sheng_chars =
  [
    "风";
    "中";
    "东";
    "冬";
    "终";
    "钟";
    "种";
    "重";
    "从";
    "丛";
    "聪";
    "葱";
    "空";
    "孔";
    "控";
    "恐";
    "松";
    "宋";
    "送";
    "诵";
    "颂";
    "动";
    "洞";
    "冻";
    "懂";
    "痛";
    "通";
    "同";
    "铜";
    "童";
    "统";
    "桶";
    "筒";
    "拥";
    "用";
    "永";
  ]

let feng_yun_ping_sheng_data = make_group_entries PingSheng FengRhyme feng_yun_ping_sheng_chars

(** 月韵组数据 *)
let yue_yun_ze_sheng_chars =
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
    "解";
    "界";
    "借";
    "街";
    "接";
    "皆";
    "阶";
    "揭";
    "竭";
    "截";
    "洁";
    "杰";
    "捷";
    "劫";
    "届";
    "界";
    "戒";
    "介";
    "价";
  ]

let yue_yun_ze_sheng_data = make_group_entries ZeSheng YueRhyme yue_yun_ze_sheng_chars

(** 江韵组数据 *)
let jiang_yun_ping_sheng_chars =
  [
    "江";
    "窗";
    "双";
    "霜";
    "装";
    "庄";
    "状";
    "撞";
    "创";
    "床";
    "伤";
    "商";
    "尚";
    "上";
    "常";
    "场";
    "厂";
    "长";
    "张";
    "章";
    "障";
    "掌";
    "藏";
    "仓";
    "苍";
    "沧";
    "堂";
    "糖";
    "塘";
    "汤";
    "唐";
    "当";
    "党";
    "档";
    "挡";
    "荡";
  ]

let jiang_yun_ping_sheng_data = make_group_entries PingSheng JiangRhyme jiang_yun_ping_sheng_chars

(** 灰韵组数据 *)
let hui_yun_ze_sheng_chars =
  [
    "灰";
    "回";
    "推";
    "退";
    "追";
    "坠";
    "醉";
    "碎";
    "岁";
    "税";
    "睡";
    "水";
    "谁";
    "虽";
    "随";
    "隋";
    "髓";
    "遂";
    "祟";
    "崇";
    "从";
    "匆";
    "聪";
    "葱";
    "囱";
    "冲";
    "充";
    "虫";
    "崇";
    "重";
    "种";
    "钟";
    "终";
    "中";
    "忠";
    "衷";
  ]

let hui_yun_ze_sheng_data = make_group_entries ZeSheng HuiRhyme hui_yun_ze_sheng_chars

(** {8 统一数据集成} *)

(** 所有韵律数据的统一集合 *)
let all_rhyme_data =
  an_yun_ping_sheng_data @ an_yun_ze_sheng_data @ si_yun_ping_sheng_data @ si_yun_ze_sheng_data
  @ tian_yun_ping_sheng_data @ wang_yun_ze_sheng_data @ qu_yun_qu_sheng_data
  @ yu_yun_ping_sheng_data @ hua_yun_ping_sheng_data @ feng_yun_ping_sheng_data
  @ yue_yun_ze_sheng_data @ jiang_yun_ping_sheng_data @ hui_yun_ze_sheng_data

(** 按韵组分类的数据 *)
let data_by_group =
  [
    (AnRhyme, an_yun_ping_sheng_data @ an_yun_ze_sheng_data);
    (SiRhyme, si_yun_ping_sheng_data @ si_yun_ze_sheng_data);
    (TianRhyme, tian_yun_ping_sheng_data);
    (WangRhyme, wang_yun_ze_sheng_data);
    (QuRhyme, qu_yun_qu_sheng_data);
    (YuRhyme, yu_yun_ping_sheng_data);
    (HuaRhyme, hua_yun_ping_sheng_data);
    (FengRhyme, feng_yun_ping_sheng_data);
    (YueRhyme, yue_yun_ze_sheng_data);
    (JiangRhyme, jiang_yun_ping_sheng_data);
    (HuiRhyme, hui_yun_ze_sheng_data);
  ]

(** 按声韵类别分类的数据 *)
let data_by_category =
  [
    ( PingSheng,
      an_yun_ping_sheng_data @ si_yun_ping_sheng_data @ tian_yun_ping_sheng_data
      @ yu_yun_ping_sheng_data @ hua_yun_ping_sheng_data @ feng_yun_ping_sheng_data
      @ jiang_yun_ping_sheng_data );
    ( ZeSheng,
      an_yun_ze_sheng_data @ si_yun_ze_sheng_data @ wang_yun_ze_sheng_data @ yue_yun_ze_sheng_data
      @ hui_yun_ze_sheng_data );
    (QuSheng, qu_yun_qu_sheng_data);
    (ShangSheng, []);
    (* 暂无上声数据，可后续扩展 *)
    (RuSheng, []);
    (* 暂无入声数据，可后续扩展 *)
  ]

(** {9 韵组描述数据} *)

(** 韵组描述信息 *)
let rhyme_group_descriptions =
  [
    (AnRhyme, "安韵组：含山、间、闲等字，音韵和谐，多用于描写自然景色");
    (SiRhyme, "思韵组：含时、诗、知等字，情思绵绵，适合抒发内心感情");
    (TianRhyme, "天韵组：含年、先、田等字，天籁之音，常用于描写时间变迁");
    (WangRhyme, "望韵组：含放、向、响等字，远望之意，表达远大志向");
    (QuRhyme, "去韵组：含路、度、步等字，去声之韵，体现行走和离别");
    (YuRhyme, "鱼韵组：含鱼、书、居等字，渔樵江渚，描写隐逸生活");
    (HuaRhyme, "花韵组：含花、霞、家等字，春花秋月，表现自然美景");
    (FengRhyme, "风韵组：含风、送、中等字，秋风萧瑟，营造肃杀氛围");
    (YueRhyme, "月韵组：含月、雪、节等字，秋月如霜，表现时节变化");
    (JiangRhyme, "江韵组：含江、窗、双等字，大江东去，描写壮阔景象");
    (HuiRhyme, "灰韵组：含灰、回、推等字，灰飞烟灭，表现消逝和变迁");
    (UnknownRhyme, "未知韵组：韵书未载，待考证者");
  ]

(** 典型诗句示例 *)
let example_poems_by_group =
  [
    (AnRhyme, [ "春眠不觉晓"; "处处闻啼鸟"; "夜来风雨声"; "花落知多少" ]);
    (SiRhyme, [ "床前明月光"; "疑是地上霜"; "举头望明月"; "低头思故乡" ]);
    (TianRhyme, [ "白日依山尽"; "黄河入海流"; "欲穷千里目"; "更上一层楼" ]);
    (WangRhyme, [ "登高望远方"; "心中有理想"; "志向如海洋"; "前程无限量" ]);
    (QuRhyme, [ "莫愁前路无知己"; "天下谁人不识君" ]);
    (YuRhyme, [ "孤舟蓑笠翁"; "独钓寒江雪" ]);
    (HuaRhyme, [ "人面桃花相映红" ]);
    (FengRhyme, [ "秋风萧瑟天气凉" ]);
    (YueRhyme, [ "明月几时有"; "把酒问青天" ]);
    (JiangRhyme, [ "大江东去浪淘尽" ]);
    (HuiRhyme, [ "往事如烟随风去" ]);
  ]

(** {10 性能优化数据结构} *)

module CharacterMap = Map.Make (String)
(** 字符快速查找映射 - 从 O(n) 线性搜索优化为 O(log n) 查找 *)

(** 基于字符的快速查找映射 *)
let character_lookup_map =
  List.fold_left
    (fun acc entry -> CharacterMap.add entry.character entry acc)
    CharacterMap.empty all_rhyme_data

(** 优化的字符查找函数 *)
let find_character_rhyme_fast (char : string) : rhyme_data_entry option =
  CharacterMap.find_opt char character_lookup_map

(** {11 统计信息} *)

(** 数据统计 *)
let total_characters = List.length all_rhyme_data

let groups_count = List.length data_by_group
let categories_count = List.length data_by_category

(** 按韵组统计字符数量 *)
let character_count_by_group =
  List.map (fun (group, data) -> (group, List.length data)) data_by_group

(** 按声韵类别统计字符数量 *)
let character_count_by_category =
  List.map (fun (category, data) -> (category, List.length data)) data_by_category
