(** 统一韵律核心模块 - Poetry模块整合优化 (简化版本)
    
    此模块整合所有分散的韵律数据文件，提供统一的数据访问接口。
    这是Poetry模块技术债务清理计划的核心成果。
    
    Author: Alpha, 主要工作代理
    @version 1.0 - Poetry模块整合优化版本
    @since 2025-07-29 - Fix #1744 Poetry模块整合优化 *)

open Poetry_core.Poetry_types

(** {1 统一韵律数据类型定义} *)

type unified_rhyme_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  variants : string list;
  frequency : float;
}

type unified_rhyme_group = {
  group_id : rhyme_group;
  group_name : string;
  entries : unified_rhyme_entry list;
  description : string;
}

type database_stats = {
  total_characters : int;
  total_groups : int;
  ping_sheng_count : int;
  ze_sheng_count : int;
  ru_sheng_count : int;
}

type unified_rhyme_database = {
  version : string;
  groups : unified_rhyme_group list;
  index : (string, unified_rhyme_entry) Hashtbl.t;
  stats : database_stats;
}

(** {2 核心韵律数据定义} *)

(** 安韵组 - 整合自多个分散文件 *)
let an_rhyme_entries = [
  { character = "安"; category = PingSheng; group = AnRhyme; variants = ["按"]; frequency = 0.95 };
  { character = "山"; category = PingSheng; group = AnRhyme; variants = ["杉"]; frequency = 0.92 };
  { character = "间"; category = PingSheng; group = AnRhyme; variants = ["闲"]; frequency = 0.88 };
  { character = "关"; category = PingSheng; group = AnRhyme; variants = ["观"]; frequency = 0.85 };
  { character = "还"; category = PingSheng; group = AnRhyme; variants = ["环"]; frequency = 0.90 };
  { character = "班"; category = PingSheng; group = AnRhyme; variants = ["般"]; frequency = 0.78 };
  { character = "颜"; category = PingSheng; group = AnRhyme; variants = ["严"]; frequency = 0.82 };
  { character = "删"; category = PingSheng; group = AnRhyme; variants = []; frequency = 0.65 };
  { character = "蛮"; category = PingSheng; group = AnRhyme; variants = ["谩"]; frequency = 0.72 };
  { character = "弯"; category = PingSheng; group = AnRhyme; variants = ["湾"]; frequency = 0.75 };
]

(** 思韵组 - 整合自多个分散文件 *)
let si_rhyme_entries = [
  { character = "思"; category = PingSheng; group = SiRhyme; variants = ["丝"]; frequency = 0.93 };
  { character = "时"; category = PingSheng; group = SiRhyme; variants = ["石"]; frequency = 0.91 };
  { character = "持"; category = PingSheng; group = SiRhyme; variants = ["迟"]; frequency = 0.87 };
  { character = "支"; category = PingSheng; group = SiRhyme; variants = ["枝"]; frequency = 0.89 };
  { character = "春"; category = PingSheng; group = SiRhyme; variants = ["纯"]; frequency = 0.94 };
  { character = "人"; category = PingSheng; group = SiRhyme; variants = ["仁"]; frequency = 0.98 };
  { character = "真"; category = PingSheng; group = SiRhyme; variants = ["珍"]; frequency = 0.92 };
  { character = "因"; category = PingSheng; group = SiRhyme; variants = ["音"]; frequency = 0.88 };
  { character = "新"; category = PingSheng; group = SiRhyme; variants = ["心"]; frequency = 0.96 };
  { character = "亲"; category = PingSheng; group = SiRhyme; variants = ["侵"]; frequency = 0.84 };
]

(** 天韵组 - 整合自多个分散文件 *)
let tian_rhyme_entries = [
  { character = "天"; category = PingSheng; group = TianRhyme; variants = ["添"]; frequency = 0.97 };
  { character = "仙"; category = PingSheng; group = TianRhyme; variants = ["先"]; frequency = 0.89 };
  { character = "边"; category = PingSheng; group = TianRhyme; variants = ["变"]; frequency = 0.85 };
  { character = "连"; category = PingSheng; group = TianRhyme; variants = ["练"]; frequency = 0.81 };
  { character = "年"; category = PingSheng; group = TianRhyme; variants = ["念"]; frequency = 0.93 };
  { character = "千"; category = PingSheng; group = TianRhyme; variants = ["迁"]; frequency = 0.87 };
  { character = "田"; category = PingSheng; group = TianRhyme; variants = ["填"]; frequency = 0.79 };
  { character = "川"; category = PingSheng; group = TianRhyme; variants = ["传"]; frequency = 0.86 };
  { character = "前"; category = PingSheng; group = TianRhyme; variants = ["钱"]; frequency = 0.90 };
  { character = "全"; category = PingSheng; group = TianRhyme; variants = ["权"]; frequency = 0.88 };
]

(** 鱼韵组 - 整合自多个分散文件 *)
let yu_rhyme_entries = [
  { character = "鱼"; category = PingSheng; group = YuRhyme; variants = ["渔"]; frequency = 0.86 };
  { character = "书"; category = PingSheng; group = YuRhyme; variants = ["舒"]; frequency = 0.94 };
  { character = "余"; category = PingSheng; group = YuRhyme; variants = ["于"]; frequency = 0.91 };
  { character = "居"; category = PingSheng; group = YuRhyme; variants = ["举"]; frequency = 0.88 };
  { character = "如"; category = PingSheng; group = YuRhyme; variants = ["儒"]; frequency = 0.92 };
  { character = "初"; category = PingSheng; group = YuRhyme; variants = ["出"]; frequency = 0.89 };
  { character = "渠"; category = PingSheng; group = YuRhyme; variants = ["区"]; frequency = 0.78 };
  { character = "车"; category = PingSheng; group = YuRhyme; variants = ["处"]; frequency = 0.85 };
  { character = "虚"; category = PingSheng; group = YuRhyme; variants = ["须"]; frequency = 0.82 };
  { character = "徐"; category = PingSheng; group = YuRhyme; variants = ["序"]; frequency = 0.77 };
]

(** 花韵组 - 整合自多个分散文件 *)
let hua_rhyme_entries = [
  { character = "花"; category = ZeSheng; group = HuaRhyme; variants = ["华"]; frequency = 0.95 };
  { character = "家"; category = ZeSheng; group = HuaRhyme; variants = ["嘉"]; frequency = 0.93 };
  { character = "加"; category = ZeSheng; group = HuaRhyme; variants = ["佳"]; frequency = 0.87 };
  { character = "茶"; category = ZeSheng; group = HuaRhyme; variants = ["查"]; frequency = 0.84 };
  { character = "沙"; category = ZeSheng; group = HuaRhyme; variants = ["纱"]; frequency = 0.81 };
  { character = "霞"; category = ZeSheng; group = HuaRhyme; variants = ["侠"]; frequency = 0.79 };
  { character = "瓜"; category = ZeSheng; group = HuaRhyme; variants = ["刮"]; frequency = 0.76 };
  { character = "芽"; category = ZeSheng; group = HuaRhyme; variants = ["雅"]; frequency = 0.73 };
  { character = "叉"; category = ZeSheng; group = HuaRhyme; variants = ["茬"]; frequency = 0.65 };
  { character = "夸"; category = ZeSheng; group = HuaRhyme; variants = ["跨"]; frequency = 0.72 };
]

(** {3 统一数据库构建} *)

let unified_rhyme_groups = [
  { group_id = AnRhyme; group_name = "安韵"; entries = an_rhyme_entries; description = "平声安韵组，古典诗词常用韵组" };
  { group_id = SiRhyme; group_name = "思韵"; entries = si_rhyme_entries; description = "平声思韵组，表达思考情感" };
  { group_id = TianRhyme; group_name = "天韵"; entries = tian_rhyme_entries; description = "平声天韵组，常用于描写天地自然" };
  { group_id = YuRhyme; group_name = "鱼韵"; entries = yu_rhyme_entries; description = "平声鱼韵组，描写水中生物和居住" };
  { group_id = HuaRhyme; group_name = "花韵"; entries = hua_rhyme_entries; description = "仄声花韵组，描写美好事物" };
]

(** 构建字符索引 *)
let build_character_index groups =
  let index = Hashtbl.create 500 in
  List.iter (fun group ->
    List.iter (fun entry ->
      Hashtbl.add index entry.character entry
    ) group.entries
  ) groups;
  index

(** 计算数据库统计信息 *)
let calculate_stats groups =
  let total_characters = List.fold_left (fun acc group -> acc + List.length group.entries) 0 groups in
  let ping_count = ref 0 in
  let ze_count = ref 0 in
  let ru_count = ref 0 in
  
  List.iter (fun group ->
    List.iter (fun entry ->
      match entry.category with
      | PingSheng -> incr ping_count
      | ZeSheng -> incr ze_count
      | RuSheng -> incr ru_count
      | _ -> ()
    ) group.entries
  ) groups;
  
  {
    total_characters;
    total_groups = List.length groups;
    ping_sheng_count = !ping_count;
    ze_sheng_count = !ze_count;
    ru_sheng_count = !ru_count;
  }

(** 构建统一韵律数据库 *)
let unified_database = {
  version = "1.0-consolidated";
  groups = unified_rhyme_groups;
  index = build_character_index unified_rhyme_groups;
  stats = calculate_stats unified_rhyme_groups;
}

(** {4 统一API接口} *)

(** 查找字符对应的韵律信息 *)
let find_rhyme_info character =
  try Some (Hashtbl.find unified_database.index character)
  with Not_found -> None

(** 检查两个字符是否押韵 *)
let check_rhyme char1 char2 =
  match find_rhyme_info char1, find_rhyme_info char2 with
  | Some entry1, Some entry2 -> entry1.group = entry2.group
  | _ -> false

(** 获取指定韵组的所有字符 *)
let get_rhyme_group_characters group_id =
  try
    let group = List.find (fun g -> g.group_id = group_id) unified_database.groups in
    List.map (fun entry -> entry.character) group.entries
  with Not_found -> []

(** 获取数据库统计信息 *)
let get_database_stats () = unified_database.stats

(** 获取所有可用韵组列表 *)
let get_available_rhyme_groups () =
  List.map (fun group -> (group.group_id, group.group_name, group.description)) unified_database.groups

(** {5 向后兼容性接口} *)

(** 兼容旧API的韵律数据访问 *)
let get_an_rhyme_data () = an_rhyme_entries
let get_si_rhyme_data () = si_rhyme_entries  
let get_tian_rhyme_data () = tian_rhyme_entries
let get_yu_rhyme_data () = yu_rhyme_entries
let get_hua_rhyme_data () = hua_rhyme_entries

(** 导出整合后的统一数据库 *)
let get_unified_database () = unified_database