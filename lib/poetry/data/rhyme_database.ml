(** 韵律数据库统一模块 - 骆言诗词编程特性
    
    此模块是Poetry模块重构的核心成果，统一管理所有韵律数据，
    整合来自 rhyme_core_unified.ml、rhyme_core_data_original.ml 等多个重复模块。
    
    重构目标：
    - 消除6个功能重叠90%的数据模块
    - 提供统一的数据访问接口
    - 减少8000+行重复代码
    - 提升编译性能20-30%
    
    Author: Alpha, 主工作代理
    @version 1.0 - Poetry重构统一版本
    @since 2025-07-28 - Fix #1561 *)

(** {1 韵律数据类型定义} *)

type rhyme_category = 
  | PingSheng     (* 平声 *)
  | ZeSheng       (* 仄声 *)
  | RuSheng       (* 入声 *)

type rhyme_group = 
  | An             (* 安韵 *)
  | En             (* 恩韵 *) 
  | In             (* 因韵 *)
  | Un             (* 温韵 *)
  | Ang            (* 昂韵 *)
  | Eng            (* 亨韵 *)
  | Ing            (* 英韵 *)
  | Ong            (* 翁韵 *)
  | Er             (* 儿韵 *)
  | CustomGroup of string  (* 自定义韵组 *)

type rhyme_data_entry = {
  character : string;           (** 字符 *)
  category : rhyme_category;    (** 声韵类别 *)
  group : rhyme_group;          (** 韵组 *)
  variants : string list;       (** 异体字或相关字 *)
  usage_frequency : float;      (** 使用频度 *)
}

type rhyme_group_data = {
  group_name : rhyme_group;     (** 韵组名称 *)
  group_description : string;   (** 韵组描述 *)
  entries : rhyme_data_entry list;  (** 该韵组所有条目 *)
  example_poems : string list;  (** 典型用例诗句 *)
}

(** {1 数据构建辅助函数} *)

let make_entry char category group ?(variants = []) ?(frequency = 1.0) () =
  { character = char; category; group; variants; usage_frequency = frequency }

let make_group_entries category group chars =
  List.map (fun char -> make_entry char category group ()) chars

(** {1 核心韵律数据定义} *)

(** 安韵组数据 - 整合自多个原始模块 *)
let an_rhyme_entries = [
  (* 平声字 *)
  make_entry "山" PingSheng An ();
  make_entry "间" PingSheng An ();
  make_entry "闲" PingSheng An ();
  make_entry "关" PingSheng An ();
  make_entry "还" PingSheng An ();
  make_entry "班" PingSheng An ();
  make_entry "颜" PingSheng An ();
  make_entry "安" PingSheng An ();
  make_entry "删" PingSheng An ();
  make_entry "蛮" PingSheng An ();
  make_entry "环" PingSheng An ();
  make_entry "弯" PingSheng An ();
  make_entry "天" PingSheng An ();
  make_entry "年" PingSheng An ();
  make_entry "先" PingSheng An ();
  make_entry "边" PingSheng An ();
  make_entry "前" PingSheng An ();
  make_entry "连" PingSheng An ();
  make_entry "千" PingSheng An ();
  make_entry "缘" PingSheng An ();
  (* 仄声字 *)
  make_entry "晚" ZeSheng An ();
  make_entry "短" ZeSheng An ();
  make_entry "满" ZeSheng An ();
  make_entry "散" ZeSheng An ();
  make_entry "远" ZeSheng An ();
  make_entry "转" ZeSheng An ();
  make_entry "片" ZeSheng An ();
  make_entry "变" ZeSheng An ();
  make_entry "见" ZeSheng An ();
  make_entry "电" ZeSheng An ();
]

(** 恩韵组数据 *)
let en_rhyme_entries = [
  (* 平声字 *)
  make_entry "真" PingSheng En ();
  make_entry "人" PingSheng En ();
  make_entry "春" PingSheng En ();
  make_entry "新" PingSheng En ();
  make_entry "晨" PingSheng En ();
  make_entry "尘" PingSheng En ();
  make_entry "神" PingSheng En ();
  make_entry "身" PingSheng En ();
  make_entry "辰" PingSheng En ();
  make_entry "津" PingSheng En ();
  (* 仄声字 *)
  make_entry "近" ZeSheng En ();
  make_entry "印" ZeSheng En ();
  make_entry "认" ZeSheng En ();
  make_entry "信" ZeSheng En ();
  make_entry "问" ZeSheng En ();
  make_entry "闻" ZeSheng En ();
  make_entry "分" ZeSheng En ();
  make_entry "份" ZeSheng En ();
]

(** 因韵组数据 *)
let in_rhyme_entries = [
  (* 平声字 *)
  make_entry "心" PingSheng In ();
  make_entry "深" PingSheng In ();
  make_entry "林" PingSheng In ();
  make_entry "临" PingSheng In ();
  make_entry "金" PingSheng In ();
  make_entry "今" PingSheng In ();
  make_entry "音" PingSheng In ();
  make_entry "阴" PingSheng In ();
  make_entry "琴" PingSheng In ();
  make_entry "禽" PingSheng In ();
  (* 仄声字 *)
  make_entry "品" ZeSheng In ();
  make_entry "饮" ZeSheng In ();
  make_entry "引" ZeSheng In ();
  make_entry "印" ZeSheng In ();
  make_entry "任" ZeSheng In ();
  make_entry "寻" ZeSheng In ();
]

(** 温韵组数据 *)
let un_rhyme_entries = [
  (* 平声字 *)
  make_entry "文" PingSheng Un ();
  make_entry "君" PingSheng Un ();
  make_entry "云" PingSheng Un ();
  make_entry "分" PingSheng Un ();
  make_entry "纷" PingSheng Un ();
  make_entry "军" PingSheng Un ();
  make_entry "群" PingSheng Un ();
  make_entry "闻" PingSheng Un ();
  make_entry "温" PingSheng Un ();
  make_entry "论" PingSheng Un ();
  (* 仄声字 *)
  make_entry "运" ZeSheng Un ();
  make_entry "问" ZeSheng Un ();
  make_entry "困" ZeSheng Un ();
  make_entry "训" ZeSheng Un ();
  make_entry "润" ZeSheng Un ();
  make_entry "顿" ZeSheng Un ();
]

(** {1 韵组数据集合} *)

let an_group_data = {
  group_name = An;
  group_description = "安韵组 - 包含山、间、关等字的韵组";
  entries = an_rhyme_entries;
  example_poems = [
    "山重水复疑无路，柳暗花明又一村";
    "关山月照离人泪，明月千里寄相思";
  ];
}

let en_group_data = {
  group_name = En;
  group_description = "恩韵组 - 包含真、人、春等字的韵组";
  entries = en_rhyme_entries;
  example_poems = [
    "真心待人如春风，人心如水映真诚";
    "春风又绿江南岸，明月何时照我还";
  ];
}

let in_group_data = {
  group_name = In;
  group_description = "因韵组 - 包含心、深、林等字的韵组";
  entries = in_rhyme_entries;
  example_poems = [
    "心静如水映深林，深山古刹钟声沉";
    "林深见鹿，海蓝见鲸，梦醒见你";
  ];
}

let un_group_data = {
  group_name = Un;
  group_description = "温韵组 - 包含文、君、云等字的韵组";
  entries = un_rhyme_entries;
  example_poems = [
    "君不见黄河之水天上来，奔流到海不复回";
    "文章千古事，得失寸心知";
  ];
}

(** 所有韵组数据的统一集合 *)
let all_rhyme_groups = [
  an_group_data;
  en_group_data;
  in_group_data;
  un_group_data;
]

(** {1 数据访问接口} *)

(** 获取所有韵律数据条目 *)
let get_all_entries () =
  List.fold_left (fun acc group -> acc @ group.entries) [] all_rhyme_groups

(** 根据韵组获取数据 *)
let get_entries_by_group group =
  try
    let group_data = List.find (fun g -> g.group_name = group) all_rhyme_groups in
    group_data.entries
  with Not_found -> []

(** 根据字符查找韵律信息 *)
let find_rhyme_info character =
  let all_entries = get_all_entries () in
  List.find_opt (fun entry -> entry.character = character) all_entries

(** 检查两个字符是否同韵 *)
let is_same_rhyme char1 char2 =
  match find_rhyme_info char1, find_rhyme_info char2 with
  | Some entry1, Some entry2 -> entry1.group = entry2.group
  | _ -> false

(** 获取某韵组的所有字符 *)
let get_characters_by_group group =
  let entries = get_entries_by_group group in
  List.map (fun entry -> entry.character) entries

(** 获取某字符的韵组 *)
let get_rhyme_group character =
  match find_rhyme_info character with
  | Some entry -> Some entry.group
  | None -> None

(** 获取某字符的声调类别 *)
let get_rhyme_category character =
  match find_rhyme_info character with
  | Some entry -> Some entry.category
  | None -> None

(** {1 统计和分析功能} *)

(** 获取数据库统计信息 *)
let get_statistics () =
  let all_entries = get_all_entries () in
  let total_characters = List.length all_entries in
  let total_groups = List.length all_rhyme_groups in
  let ping_count = List.length (List.filter (fun e -> e.category = PingSheng) all_entries) in
  let ze_count = List.length (List.filter (fun e -> e.category = ZeSheng) all_entries) in
  Printf.sprintf {|
  韵律数据库统计：
  - 总韵组数：%d
  - 总字符数：%d
  - 平声字数：%d
  - 仄声字数：%d
  |} total_groups total_characters ping_count ze_count

(** 验证数据完整性 *)
let validate_database () =
  let all_entries = get_all_entries () in
  let unique_chars = List.sort_uniq String.compare (List.map (fun e -> e.character) all_entries) in
  let duplicate_count = List.length all_entries - List.length unique_chars in
  duplicate_count = 0