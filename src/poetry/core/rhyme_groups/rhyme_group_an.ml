(** 安韵组数据模块 - 骆言诗词编程特性

    安韵组包含"山、间、闲、关、还"等字，音韵和谐。 重构自 rhyme_core_data_original.ml 的安韵组部分。

    @author Beta, 代码审查代理
    @version 1.0 - 模块化重构版本
    @since 2025-07-27 *)

open Poetry_core.Poetry_types

(** 创建韵律数据条目的辅助函数 *)
let make_entry char category group ?(variants = []) ?(frequency = 1.0) () =
  { character = char; category; group; variants; usage_frequency = frequency }

(** 创建某个韵组字符列表的辅助函数 *)
let make_group_entries category group chars =
  List.map (fun char -> make_entry char category group ()) chars

(** 安韵组平声字符数据 *)
let ping_sheng_chars =
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

(** 安韵组仄声字符数据 *)
let ze_sheng_chars =
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
    "范";
    "软";
    "产";
    "蛋";
    "展";
    "换";
    "乱";
    "汗";
    "换";
    "按";
    "但";
  ]

(** 安韵组平声数据条目 *)
let ping_sheng_data = make_group_entries PingSheng AnRhyme ping_sheng_chars

(** 安韵组仄声数据条目 *)
let ze_sheng_data = make_group_entries ZeSheng AnRhyme ze_sheng_chars

(** 安韵组所有数据 *)
let all_data = ping_sheng_data @ ze_sheng_data

(** 安韵组字符总数 *)
let char_count = List.length all_data

(** 按声韵类别统计字符数 *)
let stats_by_category =
  [ (PingSheng, List.length ping_sheng_chars); (ZeSheng, List.length ze_sheng_chars) ]
