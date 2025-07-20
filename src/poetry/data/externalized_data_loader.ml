(** 外化数据加载器 - 重构版本，使用现有模块化组件
    
    这个文件作为协调器，使用已经模块化的组件来提供统一的数据访问接口。
    重构目标：减少代码重复，使用现有的模块化结构。
    
    @author 骆言技术债务清理团队 
    @version 2.0 - 重构版本
    @since 2025-07-20 *)

open Printf

(** ========== 错误处理 ========== *)

type externalized_data_error =
  | FileNotFound of string
  | ParseError of string * string
  | ValidationError of string

exception ExternalizedDataError of externalized_data_error

let format_error = function
  | FileNotFound file -> sprintf "数据文件未找到: %s" file
  | ParseError (file, msg) -> sprintf "解析文件 %s 失败: %s" file msg
  | ValidationError msg -> sprintf "数据验证失败: %s" msg

(** ========== 降级机制 ========== *)

(** 如果新的模块化系统加载失败，使用默认数据 *)
let basic_nature_nouns =
  [
    "山"; "川"; "河"; "江"; "海"; "湖"; "天"; "空"; "云"; "雾";
    "春"; "夏"; "秋"; "冬"; "朝"; "暮"; "树"; "木"; "花"; "叶"
  ]

let basic_classifiers =
  [
    "个"; "只"; "条"; "根"; "支"; "片"; "张"; "块"; "团"; "群"
  ]

let basic_tools_objects =
  [
    "桌"; "椅"; "床"; "柜"; "笔"; "墨"; "纸"; "砚"; "琴"; "瑟"
  ]

(** ========== 统一数据访问接口 - 使用现有模块化组件 ========== *)

(** 安全加载自然名词数据 - 使用现有的Poetry_word_class_loader *)
let safe_load_nature_nouns () =
  try
    (* 使用现有的模块化组件 - load_nouns返回10个类别的元组 *)
    let (_, _, _, geography_politics, _,
         _, _, _, time_space, _) = 
      Poetry_word_class_loader.load_nouns () in
    
    (* 从地理政治、时间空间类别中提取自然相关词汇 *)
    let geography_words = List.map fst geography_politics in
    let time_space_words = List.map fst time_space in
    
    (* 合并自然相关词汇 *)
    geography_words @ time_space_words
  with
  | e ->
    Printf.eprintf "警告: 加载自然名词数据失败 (%s)，使用默认数据\n" (Printexc.to_string e);
    basic_nature_nouns

(** 安全加载量词数据 - 使用现有的Poetry_word_class_loader *)
let safe_load_measuring_classifiers () =
  try
    (* 使用现有的模块化组件 - load_numerals_classifiers返回分类词 *)
    let (_, _, classifiers) = Poetry_word_class_loader.load_numerals_classifiers () in
    List.map fst classifiers
  with
  | e ->
    Printf.eprintf "警告: 加载量词数据失败 (%s)，使用默认数据\n" (Printexc.to_string e);
    basic_classifiers

(** 安全加载工具物品数据 - 使用现有的Poetry_word_class_loader *)
let safe_load_tools_objects () =
  try
    (* 使用现有的模块化组件 - 从名词类别中提取工具物品 *)
    let (_, _, _, _, tools_objects, _, _, _, _, _) = 
      Poetry_word_class_loader.load_nouns () in
    List.map fst tools_objects
  with
  | e ->
    Printf.eprintf "警告: 加载工具物品数据失败 (%s)，使用默认数据\n" (Printexc.to_string e);
    basic_tools_objects

(** 安全加载声调数据 - 使用现有的tone_data模块 *)
let safe_load_tone_data () =
  try
    (* 使用现有的声调数据模块 *)
    let ping_sheng = Poetry_tone_data.Ping_sheng_data.get_ping_sheng_chars () in
    let shang_sheng = Poetry_tone_data.Shang_sheng_data.get_shang_sheng_chars () in 
    let qu_sheng = Poetry_tone_data.Qu_sheng_data.get_qu_sheng_chars () in
    let ru_sheng = Poetry_tone_data.Ru_sheng_data.get_ru_sheng_chars () in
    (ping_sheng, shang_sheng, qu_sheng, ru_sheng)
  with
  | e ->
    Printf.eprintf "警告: 加载声调数据失败 (%s)，使用基本默认数据\n" (Printexc.to_string e);
    (["一"; "天"; "年"; "先"; "田"], 
     ["上"; "老"; "好"; "小"; "少"],
     ["去"; "次"; "事"; "字"; "自"],
     ["入"; "出"; "国"; "德"; "得"])

(** ========== 导出接口 - 兼容原有接口 ========== *)

(** 兼容原有接口的统一访问函数 *)
let get_nature_nouns_list () = safe_load_nature_nouns ()

let get_measuring_classifiers_list () = safe_load_measuring_classifiers ()

let get_tools_objects_list () = safe_load_tools_objects ()

let get_ping_sheng_list () =
  let (ping_sheng, _, _, _) = safe_load_tone_data () in
  ping_sheng

let get_shang_sheng_list () =
  let (_, shang_sheng, _, _) = safe_load_tone_data () in
  shang_sheng

let get_qu_sheng_list () =
  let (_, _, qu_sheng, _) = safe_load_tone_data () in
  qu_sheng

let get_ru_sheng_list () =
  let (_, _, _, ru_sheng) = safe_load_tone_data () in
  ru_sheng

(** ========== 接口兼容函数 - 满足.mli要求 ========== *)

(** 获取基础自然名词列表 *)
let get_nature_nouns () = safe_load_nature_nouns ()

(** 获取地理政治名词列表 *)
let get_geography_politics_nouns () =
  try
    let (_, _, _, geography_politics, _, _, _, _, _, _) = 
      Poetry_word_class_loader.load_nouns () in
    List.map fst geography_politics
  with
  | e ->
    Printf.eprintf "警告: 加载地理政治名词数据失败 (%s)，使用默认数据\n" (Printexc.to_string e);
    ["京"; "都"; "城"; "乡"; "州"; "府"; "县"; "村"]

(** 获取人物关系名词列表 *)
let get_person_relation_nouns () =
  try
    let (person_relation, _, _, _, _, _, _, _, _, _) = 
      Poetry_word_class_loader.load_nouns () in
    List.map fst person_relation
  with
  | e ->
    Printf.eprintf "警告: 加载人物关系名词数据失败 (%s)，使用默认数据\n" (Printexc.to_string e);
    ["父"; "母"; "兄"; "弟"; "姐"; "妹"; "友"; "朋"]

(** 获取社会地位名词列表 *)
let get_social_status_nouns () =
  try
    let (_, social_status, _, _, _, _, _, _, _, _) = 
      Poetry_word_class_loader.load_nouns () in
    List.map fst social_status
  with
  | e ->
    Printf.eprintf "警告: 加载社会地位名词数据失败 (%s)，使用默认数据\n" (Printexc.to_string e);
    ["王"; "帝"; "君"; "臣"; "士"; "民"; "仕"; "官"]

(** 获取工具物品名词列表 *)
let get_tools_objects_nouns () = safe_load_tools_objects ()

(** 获取建筑场所名词列表 *)
let get_building_place_nouns () =
  try
    let (_, _, building_place, _, _, _, _, _, _, _) = 
      Poetry_word_class_loader.load_nouns () in
    List.map fst building_place
  with
  | e ->
    Printf.eprintf "警告: 加载建筑场所名词数据失败 (%s)，使用默认数据\n" (Printexc.to_string e);
    ["宫"; "殿"; "阁"; "楼"; "台"; "亭"; "堂"; "院"]

(** 验证数据完整性 *)
let validate_data_integrity () =
  try
    let _ = Poetry_word_class_loader.load_nouns () in
    let _ = Poetry_word_class_loader.load_numerals_classifiers () in
    let _ = safe_load_tone_data () in
    true
  with
  | _ -> false

(** ========== 新的统一加载接口 ========== *)

(** 数据结构定义 *)
type all_poetry_data = {
  nature_nouns : string list;
  classifiers : string list;
  tools_objects : string list;
  ping_sheng : string list;
  shang_sheng : string list;
  qu_sheng : string list;
  ru_sheng : string list;
}

(** 返回所有数据的统一接口 *)
let load_all_data () =
  let nature_nouns = get_nature_nouns_list () in
  let classifiers = get_measuring_classifiers_list () in
  let tools_objects = get_tools_objects_list () in
  let (ping_sheng, shang_sheng, qu_sheng, ru_sheng) = safe_load_tone_data () in
  {
    nature_nouns;
    classifiers; 
    tools_objects;
    ping_sheng;
    shang_sheng;
    qu_sheng;
    ru_sheng;
  }