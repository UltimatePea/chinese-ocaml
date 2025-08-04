(** 统一韵组管理模块
    
    本模块整合了原本分散在多个文件中的韵组数据，建立统一的韵组管理架构。
    这是Issue #1999韵律模块整合的关键组成部分。
    
    Author: Whisky, PR Worker
    Issue: #1999 - Poetry韵律模块统一整合实施
    
    整合来源:
    - src/poetry/data/rhyme_groups/hua_rhyme_data.ml
    - src/poetry/data/rhyme_groups/yu_rhyme_data.ml
    - src/poetry/data/rhyme_groups/ping_sheng/feng_rhyme_data.ml
    - src/poetry/data/rhyme_groups/ze_sheng/hui_rhyme_data.ml
    - src/poetry/data/rhyme_groups/ze_sheng/jiang_rhyme_data.ml
    - src/poetry/data/rhyme_groups/ze_sheng/yue_rhyme_data.ml
    - 以及其他分散的韵组数据文件
    
    @since 2025-08-04 *)

open Rhyme_types

(** {1 韵组数据整合} *)

(** 整合所有韵组的字符数据 - 统一管理 *)
let all_rhyme_characters = [
  (* 安韵组 - 平声 *)
  ("安", PingSheng, AnRhyme); ("间", PingSheng, AnRhyme); ("关", PingSheng, AnRhyme);
  ("山", PingSheng, AnRhyme); ("闲", PingSheng, AnRhyme); ("环", PingSheng, AnRhyme);
  ("还", PingSheng, AnRhyme); ("弯", PingSheng, AnRhyme); ("湾", PingSheng, AnRhyme);
  ("班", PingSheng, AnRhyme); ("颜", PingSheng, AnRhyme); ("言", PingSheng, AnRhyme);
  
  (* 思韵组 - 平声 *)
  ("思", PingSheng, SiRhyme); ("师", PingSheng, SiRhyme); ("时", PingSheng, SiRhyme);
  ("之", PingSheng, SiRhyme); ("支", PingSheng, SiRhyme); ("枝", PingSheng, SiRhyme);
  ("知", PingSheng, SiRhyme); ("持", PingSheng, SiRhyme); ("池", PingSheng, SiRhyme);
  ("移", PingSheng, SiRhyme); ("宜", PingSheng, SiRhyme); ("疑", PingSheng, SiRhyme);
  
  (* 天韵组 - 平声 *)
  ("天", PingSheng, TianRhyme); ("年", PingSheng, TianRhyme); ("先", PingSheng, TianRhyme);
  ("前", PingSheng, TianRhyme); ("千", PingSheng, TianRhyme); ("边", PingSheng, TianRhyme);
  ("连", PingSheng, TianRhyme); ("田", PingSheng, TianRhyme); ("仙", PingSheng, TianRhyme);
  ("船", PingSheng, TianRhyme); ("眠", PingSheng, TianRhyme); ("绵", PingSheng, TianRhyme);
  
  (* 王韵组 - 平声 *)
  ("王", PingSheng, WangRhyme); ("香", PingSheng, WangRhyme); ("方", PingSheng, WangRhyme);
  ("长", PingSheng, WangRhyme); ("光", PingSheng, WangRhyme); ("黄", PingSheng, WangRhyme);
  ("当", PingSheng, WangRhyme); ("堂", PingSheng, WangRhyme); ("房", PingSheng, WangRhyme);
  ("常", PingSheng, WangRhyme); ("强", PingSheng, WangRhyme); ("张", PingSheng, WangRhyme);
  
  (* 花韵组 - 平声 *)
  ("花", PingSheng, HuaRhyme); ("霞", PingSheng, HuaRhyme); ("家", PingSheng, HuaRhyme);
  ("茶", PingSheng, HuaRhyme); ("华", PingSheng, HuaRhyme); ("沙", PingSheng, HuaRhyme);
  ("纱", PingSheng, HuaRhyme); ("车", PingSheng, HuaRhyme); ("遮", PingSheng, HuaRhyme);
  ("者", PingSheng, HuaRhyme); ("这", PingSheng, HuaRhyme); ("舍", PingSheng, HuaRhyme);
  
  (* 风韵组 - 平声 *)
  ("风", PingSheng, FengRhyme); ("东", PingSheng, FengRhyme); ("中", PingSheng, FengRhyme);
  ("同", PingSheng, FengRhyme); ("通", PingSheng, FengRhyme); ("红", PingSheng, FengRhyme);
  ("空", PingSheng, FengRhyme); ("穷", PingSheng, FengRhyme); ("雄", PingSheng, FengRhyme);
  ("熊", PingSheng, FengRhyme); ("终", PingSheng, FengRhyme); ("钟", PingSheng, FengRhyme);
  
  (* 鱼韵组 - 平声 *)
  ("鱼", PingSheng, YuRhyme); ("书", PingSheng, YuRhyme); ("居", PingSheng, YuRhyme);
  ("区", PingSheng, YuRhyme); ("娱", PingSheng, YuRhyme); ("渠", PingSheng, YuRhyme);
  ("予", PingSheng, YuRhyme); ("余", PingSheng, YuRhyme); ("如", PingSheng, YuRhyme);
  ("除", PingSheng, YuRhyme); ("虚", PingSheng, YuRhyme); ("须", PingSheng, YuRhyme);
  
  (* 去韵组 - 仄声 *)
  ("去", QuSheng, QuRhyme); ("数", QuSheng, QuRhyme); ("路", QuSheng, QuRhyme);
  ("度", QuSheng, QuRhyme); ("处", QuSheng, QuRhyme); ("住", QuSheng, QuRhyme);
  ("故", QuSheng, QuRhyme); ("顾", QuSheng, QuRhyme); ("素", QuSheng, QuRhyme);
  ("诉", QuSheng, QuRhyme); ("愫", QuSheng, QuRhyme); ("固", QuSheng, QuRhyme);
  
  (* 月韵组 - 仄声 *)
  ("月", QuSheng, YueRhyme); ("雪", QuSheng, YueRhyme); ("节", QuSheng, YueRhyme);
  ("切", QuSheng, YueRhyme); ("热", QuSheng, YueRhyme); ("烈", QuSheng, YueRhyme);
  ("别", QuSheng, YueRhyme); ("铁", QuSheng, YueRhyme); ("血", RuSheng, YueRhyme);
  ("结", RuSheng, YueRhyme); ("灭", RuSheng, YueRhyme); ("决", RuSheng, YueRhyme);
  
  (* 江韵组 - 仄声 *)
  ("江", QuSheng, JiangRhyme); ("窗", QuSheng, JiangRhyme); ("床", QuSheng, JiangRhyme);
  ("双", QuSheng, JiangRhyme); ("霜", QuSheng, JiangRhyme); ("亡", QuSheng, JiangRhyme);
  ("忘", QuSheng, JiangRhyme); ("望", QuSheng, JiangRhyme); ("创", QuSheng, JiangRhyme);
  ("狂", QuSheng, JiangRhyme); ("装", QuSheng, JiangRhyme); ("庄", QuSheng, JiangRhyme);
  
  (* 灰韵组 - 仄声 *)
  ("灰", QuSheng, HuiRhyme); ("开", QuSheng, HuiRhyme); ("来", QuSheng, HuiRhyme);
  ("台", QuSheng, HuiRhyme); ("才", QuSheng, HuiRhyme); ("材", QuSheng, HuiRhyme);
  ("回", QuSheng, HuiRhyme); ("杯", QuSheng, HuiRhyme); ("雷", QuSheng, HuiRhyme);
  ("堆", QuSheng, HuiRhyme); ("推", QuSheng, HuiRhyme); ("催", QuSheng, HuiRhyme);
]

(** {1 韵组管理函数} *)

(** 按韵组分类所有字符 *)
let group_characters_by_rhyme () =
  let group_table = Hashtbl.create 12 in
  List.iter (fun (char, tone, group) ->
    let char_info = make_rhyme_character char tone group in
    let current_chars = try Hashtbl.find group_table group with Not_found -> [] in
    Hashtbl.replace group_table group (char_info :: current_chars)
  ) all_rhyme_characters;
  group_table

(** 获取特定韵组的所有字符 *)
let get_group_characters group =
  List.filter (fun (_, _, g) -> g = group) all_rhyme_characters
  |> List.map (fun (char, tone, group) -> make_rhyme_character char tone group)

(** 获取平声韵组 *)
let get_ping_sheng_groups () = [AnRhyme; SiRhyme; TianRhyme; WangRhyme; HuaRhyme; FengRhyme; YuRhyme]

(** 获取仄声韵组 *)
let get_ze_sheng_groups () = [QuRhyme; YueRhyme; JiangRhyme; HuiRhyme]

(** 判断韵组是否为平声 *)
let is_ping_sheng_group = function
  | AnRhyme | SiRhyme | TianRhyme | WangRhyme | HuaRhyme | FengRhyme | YuRhyme -> true
  | QuRhyme | YueRhyme | JiangRhyme | HuiRhyme | UnknownRhyme -> false

(** 创建韵组数据结构 *)
let create_rhyme_group_data group =
  let characters : rhyme_character list = get_group_characters group in
  let ping_chars = List.filter (fun c -> c.rhyme_category = PingSheng) characters
                   |> List.map (fun c -> c.character) in
  let ze_chars = List.filter (fun c -> is_ze_sheng c.rhyme_category) characters
                 |> List.map (fun c -> c.character) in
  {
    group_id = group;
    group_name = string_of_rhyme_group group;
    description = Printf.sprintf "%s韵组，包含%d个字符" (string_of_rhyme_group group) (List.length characters);
    ping_sheng_chars = ping_chars;
    ze_sheng_chars = ze_chars;
    all_characters = characters;
    example_poems = []; (* 可以后续添加示例诗句 *)
  }

(** 获取所有韵组数据 *)
let get_all_rhyme_group_data () =
  List.map create_rhyme_group_data all_rhyme_groups

(** 查找字符所属韵组 *)
let find_character_group char =
  try
    let (_, tone, group) = List.find (fun (c, _, _) -> c = char) all_rhyme_characters in
    Some (group, tone)
  with Not_found -> None

(** 获取韵组统计信息 *)
let get_rhyme_statistics () =
  let total_chars = List.length all_rhyme_characters in
  let ping_count = List.length (List.filter (fun (_, tone, _) -> tone = PingSheng) all_rhyme_characters) in
  let ze_count = total_chars - ping_count in
  let group_counts = Hashtbl.create 12 in
  List.iter (fun (_, _, group) ->
    let current = try Hashtbl.find group_counts group with Not_found -> 0 in
    Hashtbl.replace group_counts group (current + 1)
  ) all_rhyme_characters;
  let group_distribution = Hashtbl.fold (fun group count acc -> (group, count) :: acc) group_counts [] in
  let most_frequent = List.fold_left (fun (max_group, max_count) (group, count) ->
    if count > max_count then (group, count) else (max_group, max_count)
  ) (UnknownRhyme, 0) group_distribution |> fst in
  let least_frequent = List.fold_left (fun (min_group, min_count) (group, count) ->
    if count < min_count || min_count = 0 then (group, count) else (min_group, min_count)
  ) (UnknownRhyme, max_int) group_distribution |> fst in
  {
    total_characters = total_chars;
    total_groups = List.length all_rhyme_groups;
    ping_sheng_count = ping_count;
    ze_sheng_count = ze_count;
    group_distribution = group_distribution;
    most_frequent_group = most_frequent;
    least_frequent_group = least_frequent;
  }

(** {1 兼容性接口} *)

(** 为了兼容现有代码，提供访问特定韵组数据的函数 *)
module Compat = struct
  (** 获取花韵组字符 *)
  let get_hua_rhyme_chars () = get_group_characters HuaRhyme |> List.map (fun c -> c.character)
  
  (** 获取风韵组字符 *)
  let get_feng_rhyme_chars () = get_group_characters FengRhyme |> List.map (fun c -> c.character)
  
  (** 获取鱼韵组字符 *)
  let get_yu_rhyme_chars () = get_group_characters YuRhyme |> List.map (fun c -> c.character)
  
  (** 获取月韵组字符 *)
  let get_yue_rhyme_chars () = get_group_characters YueRhyme |> List.map (fun c -> c.character)
  
  (** 获取江韵组字符 *)
  let get_jiang_rhyme_chars () = get_group_characters JiangRhyme |> List.map (fun c -> c.character)
  
  (** 获取灰韵组字符 *)
  let get_hui_rhyme_chars () = get_group_characters HuiRhyme |> List.map (fun c -> c.character)
end