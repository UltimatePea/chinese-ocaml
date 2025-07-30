(** 统一声调数据模块 - 合并四声数据
    
    此模块整合了原有的四个独立声调数据文件(ping_sheng, shang_sheng, qu_sheng, ru_sheng)，
    减少代码重复，提高维护效率。保持所有原有API的向后兼容性。
    
    Author: Alpha, 主要工作代理 - Poetry模块重构Phase 1
    技术债务清理: 4个文件合并为1个统一模块 
    Fix #1765 - Poetry韵律数据重复整合优化
    @since 2025-07-30 *)

(** {1 平声数据} *)

(** 平声字符数据列表 - 从JSON文件动态加载 *)
let ping_sheng_chars = lazy (
  try
    Tone_data_json_loader.get_ping_sheng_chars ()
  with
  | _ -> [] (* 降级处理 *)
)

(** 获取平声字符列表 *)
let get_ping_sheng_chars () = Lazy.force ping_sheng_chars

(** 检查字符是否为平声 *)
let is_ping_sheng char = List.mem char (get_ping_sheng_chars ())

(** 平声字符数量 *)
let count_ping_sheng () = List.length (get_ping_sheng_chars ())

(** {1 上声数据} *)

(** 上声字符数据列表 - 从JSON文件动态加载 *)
let shang_sheng_chars = lazy (
  try
    Tone_data_json_loader.get_shang_sheng_chars ()
  with
  | _ -> [] (* 降级处理 *)
)

(** 获取上声字符列表 *)
let get_shang_sheng_chars () = Lazy.force shang_sheng_chars

(** 检查字符是否为上声 *)
let is_shang_sheng char = List.mem char (get_shang_sheng_chars ())

(** 上声字符数量 *)
let count_shang_sheng () = List.length (get_shang_sheng_chars ())

(** {1 去声数据} *)

(** 基础去声字符 - 包含常用单音节去声字 *)
let basic_qu_sheng_chars = [ "去"; "大"; "下"; "过"; "话"; "坏"; "快"; "块"; "怪" ]

(** 存在类去声字符 - 表示存在、等待、携带等概念 *)
let existence_qu_sheng_chars = [ "外"; "带"; "待"; "代"; "在"; "再"; "爱"; "载" ]

(** 交易类去声字符 - 表示买卖、派遣、排列等动作 *)
let transaction_qu_sheng_chars = [ "卖"; "买"; "派"; "排"; "白"; "百"; "拍"; "败"; "摆" ]

(** 恐惧类去声字符 - 表示害怕、把握、权威等概念 *)
let authority_qu_sheng_chars = [ "怕"; "帕"; "把"; "霸"; "爸"; "八" ]

(** 法则类去声字符 - 表示法律、规则、惩罚等概念 *)
let law_qu_sheng_chars = [ "发"; "法"; "罚"; "乏"; "伐"; "筏" ]

(** 感官类去声字符 - 表示观察、区别、清洁等动作 *)
let sensory_qu_sheng_chars =
  [ "察"; "差"; "茶"; "杀"; "杂"; "擦"; "洒"; "撒"; "呀"; "押"; "压"; "鸭"; "夏"; "侠" ]

(** 完整去声字符列表 - 通过分组合并生成 *)
let qu_sheng_chars =
  List.concat
    [
      basic_qu_sheng_chars;
      existence_qu_sheng_chars;
      transaction_qu_sheng_chars;
      authority_qu_sheng_chars;
      law_qu_sheng_chars;
      sensory_qu_sheng_chars;
    ]

(** 获取去声字符列表 *)
let get_qu_sheng_chars () = qu_sheng_chars

(** 检查字符是否为去声 *)
let is_qu_sheng char = List.mem char qu_sheng_chars

(** 去声字符数量 *)
let count_qu_sheng () = List.length qu_sheng_chars

(** {1 入声数据} *)

(** 入声字符数据列表 - 从JSON文件动态加载 *)
let ru_sheng_chars = lazy (
  try
    (* 尝试从原ru_sheng_data模块获取数据 *)
    let module Ru_data = struct
      let get_data_file_path filename =
        let rec find_project_root dir =
          let dune_project = Filename.concat dir "dune-project" in
          if Sys.file_exists dune_project then dir
          else
            let parent = Filename.dirname dir in
            if parent = dir then Sys.getcwd ()
            else find_project_root parent
        in
        let project_root = find_project_root (Sys.getcwd ()) in
        Filename.concat (Filename.concat project_root "data/poetry/tone_data") filename
      
      let ru_sheng_data_file = get_data_file_path "ru_sheng.json"
      
      let get_ru_sheng_chars () =
        try
          let json = Yojson.Safe.from_file ru_sheng_data_file in
          json |> Yojson.Safe.Util.member "characters" 
               |> Yojson.Safe.Util.to_list 
               |> List.map Yojson.Safe.Util.to_string
        with
        | _ -> []
    end in
    Ru_data.get_ru_sheng_chars ()
  with
  | _ -> [] (* 降级处理 *)
)

(** 获取入声字符列表 *)
let get_ru_sheng_chars () = Lazy.force ru_sheng_chars

(** 检查字符是否为入声 *)
let is_ru_sheng char = List.mem char (get_ru_sheng_chars ())

(** 入声字符数量 *)
let count_ru_sheng () = List.length (get_ru_sheng_chars ())

(** {1 统一声调API} *)

(** 声调类型 *)
type tone_type = Ping | Shang | Qu | Ru

(** 获取指定声调的字符列表 *)
let get_chars_by_tone = function
  | Ping -> get_ping_sheng_chars ()
  | Shang -> get_shang_sheng_chars ()
  | Qu -> get_qu_sheng_chars ()
  | Ru -> get_ru_sheng_chars ()

(** 检查字符的声调类型 *)
let get_tone_type char =
  if is_ping_sheng char then Some Ping
  else if is_shang_sheng char then Some Shang
  else if is_qu_sheng char then Some Qu
  else if is_ru_sheng char then Some Ru
  else None

(** 获取所有声调的字符统计 *)
let get_tone_statistics () =
  [
    ("平声", count_ping_sheng ());
    ("上声", count_shang_sheng ());
    ("去声", count_qu_sheng ());
    ("入声", count_ru_sheng ());
  ]

(** 验证统一声调数据的完整性 *)
let validate_unified_data () =
  let stats = get_tone_statistics () in
  List.for_all (fun (_, count) -> count > 0) stats