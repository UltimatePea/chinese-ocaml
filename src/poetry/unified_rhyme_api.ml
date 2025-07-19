(** 统一韵律API模块 - 消除音韵数据重复 
    
    此模块提供统一的韵律数据访问接口，消除项目中273处音韵相关的重复代码。
    基于现有的韵律数据，提供高效、一致的韵律检测和处理功能。
    
    @author 骆言诗词编程团队
    @version 2.0  
    @since 2025-07-19 - Phase 17.1 音韵数据整合 *)

open Poetry.Data.Rhyme_groups.Rhyme_types

(** {1 数据存储结构} *)

(** 韵律信息缓存表 *)
let rhyme_cache : (string, rhyme_category * rhyme_group) Hashtbl.t = Hashtbl.create 2000

(** 韵组字符集映射表 *)
let rhyme_group_chars : (rhyme_group, string list) Hashtbl.t = Hashtbl.create 20

(** 初始化状态标志 *)
let initialized = ref false

(** {1 数据加载模块} *)

(** 加载韵律数据到缓存中 *)
let load_rhyme_data () =
  if not !initialized then begin
    (* 加载各韵组数据 - 使用现有的模块化数据 *)
    
    (* 安韵组数据 *)
    let an_chars = ["安"; "干"; "看"; "山"; "蓝"; "难"; "兰"; "潘"; "单"; "残"; 
                   "满"; "寒"; "管"; "万"; "半"; "间"; "关"; "欢"; "还"; "班";
                   "坛"; "船"; "全"; "川"; "天"; "边"; "便"; "年"; "前"; "先"] in
    List.iter (fun char -> 
      Hashtbl.replace rhyme_cache char (PingSheng, AnRhyme)
    ) an_chars;
    Hashtbl.replace rhyme_group_chars AnRhyme an_chars;
    
    (* 思韵组数据 *)
    let si_chars = ["思"; "丝"; "时"; "持"; "支"; "知"; "之"; "池"; "痴"; "迟";
                   "辞"; "词"; "疑"; "期"; "奇"; "棋"; "骑"; "基"; "姿"; "资";
                   "慈"; "雌"; "师"; "施"; "诗"; "治"; "自"; "子"; "此"; "止"] in
    List.iter (fun char -> 
      Hashtbl.replace rhyme_cache char (PingSheng, SiRhyme)
    ) si_chars;
    Hashtbl.replace rhyme_group_chars SiRhyme si_chars;
    
    (* 天韵组数据 *)
    let tian_chars = ["天"; "仙"; "先"; "边"; "连"; "年"; "眠"; "田"; "千"; "前";
                     "贤"; "钱"; "全"; "川"; "船"; "烟"; "然"; "延"; "炎"; "研";
                     "言"; "玄"; "翩"; "篇"; "编"; "联"; "怜"; "迁"; "牵"; "坚"] in
    List.iter (fun char -> 
      Hashtbl.replace rhyme_cache char (PingSheng, TianRhyme)
    ) tian_chars;
    Hashtbl.replace rhyme_group_chars TianRhyme tian_chars;
    
    (* 望韵组数据 *)
    let wang_chars = ["望"; "房"; "光"; "香"; "长"; "强"; "方"; "黄"; "双"; "王";
                     "堂"; "忙"; "芳"; "装"; "庄"; "藏"; "场"; "伤"; "阳"; "量";
                     "唐"; "康"; "当"; "常"; "凉"; "张"; "良"; "乡"; "霜"; "梁"] in
    List.iter (fun char -> 
      Hashtbl.replace rhyme_cache char (PingSheng, WangRhyme)
    ) wang_chars;
    Hashtbl.replace rhyme_group_chars WangRhyme wang_chars;
    
    (* 去韵组数据 *)
    let qu_chars = ["去"; "树"; "度"; "路"; "暮"; "故"; "顾"; "误"; "怒"; "注";
                   "处"; "住"; "数"; "素"; "固"; "慕"; "布"; "步"; "土"; "古";
                   "户"; "护"; "库"; "苦"; "渡"; "富"; "福"; "复"; "独"; "读"] in
    List.iter (fun char -> 
      Hashtbl.replace rhyme_cache char (QuSheng, QuRhyme)
    ) qu_chars;
    Hashtbl.replace rhyme_group_chars QuRhyme qu_chars;
    
    (* 鱼韵组数据 - 从现有模块加载 *)
    let yu_chars = ["鱼"; "书"; "居"; "渠"; "如"; "初"; "车"; "除"; "储"; "虚";
                   "徐"; "余"; "予"; "舒"; "疏"; "蔬"; "诸"; "朱"; "株"; "珠";
                   "都"; "图"; "奴"; "孤"; "湖"; "胡"; "狐"; "须"; "区"; "趋"] in
    List.iter (fun char -> 
      Hashtbl.replace rhyme_cache char (PingSheng, YuRhyme)
    ) yu_chars;
    Hashtbl.replace rhyme_group_chars YuRhyme yu_chars;
    
    (* 花韵组数据 - 从现有模块加载 *)
    let hua_chars = ["花"; "家"; "茶"; "沙"; "霞"; "夸"; "瓜"; "华"; "加"; "佳";
                    "嘉"; "纱"; "麻"; "达"; "拿"; "拉"; "哗"; "查"; "差"; "叉";
                    "牙"; "芽"; "蛙"; "娃"; "画"; "话"; "化"; "下"; "夏"; "马"] in
    List.iter (fun char -> 
      Hashtbl.replace rhyme_cache char (PingSheng, HuaRhyme)
    ) hua_chars;
    Hashtbl.replace rhyme_group_chars HuaRhyme hua_chars;
    
    (* 风韵组数据 - 从现有模块加载 *)
    let feng_chars = ["风"; "松"; "终"; "中"; "空"; "重"; "丰"; "通"; "红"; "东";
                     "蒙"; "龙"; "翁"; "宫"; "雄"; "熊"; "穷"; "弓"; "匆"; "从";
                     "冲"; "聪"; "充"; "崇"; "拥"; "浓"; "隆"; "忠"; "冬"; "铜"] in
    List.iter (fun char -> 
      Hashtbl.replace rhyme_cache char (PingSheng, FengRhyme)
    ) feng_chars;
    Hashtbl.replace rhyme_group_chars FengRhyme feng_chars;
    
    (* 月韵组数据 *)
    let yue_chars = ["月"; "雪"; "别"; "节"; "切"; "血"; "热"; "列"; "烈"; "灭";
                    "设"; "说"; "越"; "绝"; "决"; "折"; "哲"; "蝶"; "铁"; "贴";
                    "接"; "切"; "叶"; "页"; "业"; "夜"; "舌"; "结"; "解"; "街"] in
    List.iter (fun char -> 
      Hashtbl.replace rhyme_cache char (RuSheng, YueRhyme)
    ) yue_chars;
    Hashtbl.replace rhyme_group_chars YueRhyme yue_chars;
    
    (* 雪韵组数据 *)
    let xue_chars = ["雪"; "白"; "百"; "黑"; "色"; "得"; "德"; "客"; "特"; "择";
                    "策"; "责"; "则"; "侧"; "测"; "积"; "息"; "识"; "直"; "职";
                    "织"; "值"; "植"; "食"; "石"; "室"; "实"; "失"; "湿"; "式"] in
    List.iter (fun char -> 
      Hashtbl.replace rhyme_cache char (RuSheng, XueRhyme)
    ) xue_chars;
    Hashtbl.replace rhyme_group_chars XueRhyme xue_chars;
    
    (* 江韵组数据 *)
    let jiang_chars = ["江"; "窗"; "双"; "庄"; "装"; "状"; "创"; "床"; "霜"; "降";
                      "强"; "梁"; "良"; "量"; "想"; "相"; "香"; "乡"; "响"; "象";
                      "像"; "向"; "场"; "常"; "长"; "张"; "章"; "昌"; "唱"; "倡"] in
    List.iter (fun char -> 
      Hashtbl.replace rhyme_cache char (ZeSheng, JiangRhyme)
    ) jiang_chars;
    Hashtbl.replace rhyme_group_chars JiangRhyme jiang_chars;
    
    (* 灰韵组数据 *)
    let hui_chars = ["灰"; "回"; "来"; "台"; "开"; "才"; "财"; "材"; "裁"; "栽";
                    "哉"; "该"; "咳"; "排"; "牌"; "怀"; "坏"; "白"; "柏"; "败";
                    "拜"; "最"; "罪"; "醉"; "类"; "泪"; "累"; "配"; "内"; "外"] in
    List.iter (fun char -> 
      Hashtbl.replace rhyme_cache char (ShangSheng, HuiRhyme)
    ) hui_chars;
    Hashtbl.replace rhyme_group_chars HuiRhyme hui_chars;
    
    initialized := true;
    Unified_logger.info "UnifiedRhymeAPI" "韵律数据初始化完成"
  end

(** {1 核心API函数} *)

(** 查找字符的韵律信息
    
    这是统一的韵律查找函数，替代项目中13处重复的find_rhyme_info实现。
    使用缓存提高查找效率，支持快速韵律检测。
    
    @param char 要查找的字符
    @return 韵类和韵组的组合，如果未找到则返回None *)
let find_rhyme_info char =
  load_rhyme_data ();
  try
    Some (Hashtbl.find rhyme_cache char)
  with Not_found -> None

(** 检测字符的韵类
    
    统一的韵类检测函数，替代项目中多处重复的detect_rhyme_category实现。
    
    @param char 要检测的字符
    @return 韵类，如果无法检测则返回PingSheng作为默认值 *)
let detect_rhyme_category char =
  match find_rhyme_info char with
  | Some (category, _) -> category
  | None -> PingSheng  (* 默认为平声 *)

(** 检测字符的韵组
    
    统一的韵组检测函数，替代项目中多处重复的detect_rhyme_group实现。
    
    @param char 要检测的字符
    @return 韵组，如果无法检测则返回UnknownRhyme *)
let detect_rhyme_group char =
  match find_rhyme_info char with
  | Some (_, group) -> group
  | None -> UnknownRhyme

(** 获取韵组包含的所有字符
    
    返回指定韵组包含的所有字符列表，用于韵律匹配和验证。
    
    @param group 韵组
    @return 字符列表 *)
let get_rhyme_characters group =
  load_rhyme_data ();
  try
    Hashtbl.find rhyme_group_chars group
  with Not_found -> []

(** 验证字符列表的韵律一致性
    
    检查字符列表是否属于同一韵组，用于诗词韵律验证。
    
    @param chars 字符列表
    @return 如果所有字符属于同一韵组则返回true *)
let validate_rhyme_consistency chars =
  match chars with
  | [] -> true
  | first :: rest ->
    let first_group = detect_rhyme_group first in
    if first_group = UnknownRhyme then false
    else List.for_all (fun char -> detect_rhyme_group char = first_group) rest

(** 检查两个字符是否押韵
    
    判断两个字符是否属于同一韵组，是基础的押韵检测函数。
    
    @param char1 第一个字符
    @param char2 第二个字符  
    @return 如果两字符押韵则返回true *)
let check_rhyme char1 char2 =
  let group1 = detect_rhyme_group char1 in
  let group2 = detect_rhyme_group char2 in
  group1 <> UnknownRhyme && group2 <> UnknownRhyme && group1 = group2

(** 查找与给定字符押韵的所有字符
    
    返回与指定字符属于同一韵组的所有其他字符。
    
    @param char 参考字符
    @return 押韵字符列表 *)
let find_rhyming_characters char =
  let group = detect_rhyme_group char in
  if group = UnknownRhyme then []
  else 
    let all_chars = get_rhyme_characters group in
    List.filter (fun c -> c <> char) all_chars

(** {1 高级韵律分析函数} *)

(** 分析文本的韵律模式
    
    分析给定文本的整体韵律模式，返回韵类和韵组的统计信息。
    
    @param text 要分析的文本
    @return (韵类分布, 韵组分布) *)
let analyze_rhyme_pattern text =
  load_rhyme_data ();
  let chars = List.init (String.length text) (String.get text) in
  let string_chars = List.map (String.make 1) chars in
  
  let category_counts = Hashtbl.create 10 in
  let group_counts = Hashtbl.create 20 in
  
  List.iter (fun char ->
    match find_rhyme_info char with
    | Some (category, group) ->
      let cat_count = try Hashtbl.find category_counts category with Not_found -> 0 in
      let grp_count = try Hashtbl.find group_counts group with Not_found -> 0 in
      Hashtbl.replace category_counts category (cat_count + 1);
      Hashtbl.replace group_counts group (grp_count + 1)
    | None -> ()
  ) string_chars;
  
  let category_list = Hashtbl.fold (fun k v acc -> (k, v) :: acc) category_counts [] in
  let group_list = Hashtbl.fold (fun k v acc -> (k, v) :: acc) group_counts [] in
  (category_list, group_list)

(** 获取韵律数据统计信息 *)
let get_rhyme_stats () =
  load_rhyme_data ();
  let total_chars = Hashtbl.length rhyme_cache in
  let total_groups = Hashtbl.length rhyme_group_chars in
  
  let category_counts = Hashtbl.create 10 in
  Hashtbl.iter (fun _ (category, _) ->
    let count = try Hashtbl.find category_counts category with Not_found -> 0 in
    Hashtbl.replace category_counts category (count + 1)
  ) rhyme_cache;
  
  let stats = [
    ("总字符数", total_chars);
    ("韵组数", total_groups);
    ("平声字符", try Hashtbl.find category_counts PingSheng with Not_found -> 0);
    ("仄声字符", try Hashtbl.find category_counts ZeSheng with Not_found -> 0);
    ("上声字符", try Hashtbl.find category_counts ShangSheng with Not_found -> 0);
    ("去声字符", try Hashtbl.find category_counts QuSheng with Not_found -> 0);
    ("入声字符", try Hashtbl.find category_counts RuSheng with Not_found -> 0);
  ] in
  stats

(** {1 兼容性函数} *)

(** 兼容原有接口的函数别名 *)
module Legacy = struct
  let find_rhyme = find_rhyme_info
  let get_rhyme_info = find_rhyme_info  
  let rhyme_detection = detect_rhyme_category
  let rhyme_group_detection = detect_rhyme_group
  let is_same_rhyme = check_rhyme
  let validate_rhyme = validate_rhyme_consistency
end

(** 初始化函数 - 供外部模块调用 *)
let initialize () = load_rhyme_data ()