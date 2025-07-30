(** 统一韵律数据模块 - 整合所有韵组数据
    
    此模块整合了分散在rhyme_groups_1_5.ml、rhyme_groups_6_10.ml和rhyme_groups_11.ml
    中的韵组数据，提供统一的访问接口，减少模块数量和维护复杂度。
    
    @author Alpha, 主要工作代理
    @version 1.0 - Phase 2.1 韵组数据整合
    @since 2025-07-30
    @fix_issue #1753 诗韵模块深度整合优化 Phase 2 *)

open Poetry_core.Types
open Rhyme_helpers
open Rhyme_core_types

(** {1 韵组数据统一定义} *)

(** 辅助函数：将元组列表转换为rhyme_group_data结构 *)
let make_rhyme_group_data group_name description tuples_list =
  let entries = List.map (fun (char, category, group) ->
    { character = char; category; group; variants = []; usage_frequency = 1.0 }
  ) tuples_list in
  { group_name; group_description = description; entries; example_poems = [] }

(** 所有韵组数据的统一访问模块 *)
module Unified_rhyme_data = struct
  
  (** {2 第一组韵群 (1-5): 安、思、天、王、曲韵组} *)
  
  (** 安韵组数据 *)
  let an_rhyme_data =
    let ping_sheng_chars =
      [
        "山"; "间"; "闲"; "关"; "还"; "班"; "颜"; "安"; "删"; "蛮"; 
        "环"; "弯"; "天"; "千"; "田"; "先"; "年"; "连"; "边"; "全";
        "春"
      ]
    in
    let ze_sheng_chars = 
      [
        "产"; "满"; "简"; "眼"; "展"; "面"; "限"; "善"; "判"; "管";
        "见"; "变"; "片"; "现"; "线"; "显"; "献"; "念"; "练"; "遍"
      ]
    in
    let ping_sheng_data = make_ping_sheng_group AnRhyme ping_sheng_chars in
    let ze_sheng_data = make_ze_sheng_group AnRhyme ze_sheng_chars in
    let tuples_data = ping_sheng_data @ ze_sheng_data in
    make_rhyme_group_data AnRhyme "安韵组：山、关、间等韵字" tuples_data

  (** 思韵组数据 *)
  let si_rhyme_data =
    let ping_sheng_chars =
      [
        "思"; "师"; "时"; "词"; "丝"; "知"; "之"; "期"; "其"; "奇";
        "痴"; "持"; "池"; "迟"; "诗"; "支"; "枝"; "儿"; "而"; "资"
      ]
    in
    let ze_sheng_chars =
      [
        "使"; "史"; "只"; "止"; "指"; "趾"; "市"; "智"; "志"; "置";
        "治"; "制"; "至"; "质"; "致"; "试"; "事"; "视"; "示"; "式"
      ]
    in
    let ping_sheng_data = make_ping_sheng_group SiRhyme ping_sheng_chars in
    let ze_sheng_data = make_ze_sheng_group SiRhyme ze_sheng_chars in
    let tuples_data = ping_sheng_data @ ze_sheng_data in
    make_rhyme_group_data SiRhyme "思韵组：思、师、时等韵字" tuples_data
  
  (** 天韵组数据 *)
  let tian_rhyme_data =
    let ping_sheng_chars =
      [
        "天"; "年"; "先"; "千"; "前"; "边"; "连"; "田"; "眠"; "绵";
        "然"; "燃"; "全"; "川"; "泉"; "缘"; "源"; "园"; "元"; "圆"
      ]
    in
    let ze_sheng_chars =
      [
        "典"; "点"; "电"; "店"; "面"; "见"; "现"; "变"; "练"; "件";
        "片"; "战"; "站"; "念"; "线"; "限"; "善"; "判"; "显"; "献"
      ]
    in
    let ping_sheng_data = make_ping_sheng_group TianRhyme ping_sheng_chars in
    let ze_sheng_data = make_ze_sheng_group TianRhyme ze_sheng_chars in
    let tuples_data = ping_sheng_data @ ze_sheng_data in
    make_rhyme_group_data TianRhyme "天韵组：天、年、先等韵字" tuples_data

  (** 王韵组数据 *)
  let wang_rhyme_data =
    let ping_sheng_chars =
      [
        "王"; "章"; "张"; "长"; "场"; "房"; "方"; "香"; "黄"; "光";
        "当"; "堂"; "常"; "望"; "强"; "良"; "皇"; "央"; "扬"; "阳"
      ]
    in
    let ze_sheng_chars =
      [
        "上"; "响"; "向"; "像"; "想"; "相"; "状"; "况"; "望"; "量";
        "样"; "养"; "忘"; "放"; "访"; "房"; "防"; "仿"; "妨"; "芳"
      ]
    in
    let ping_sheng_data = make_ping_sheng_group WangRhyme ping_sheng_chars in
    let ze_sheng_data = make_ze_sheng_group WangRhyme ze_sheng_chars in
    let tuples_data = ping_sheng_data @ ze_sheng_data in
    make_rhyme_group_data WangRhyme "王韵组：王、章、张等韵字" tuples_data

  (** 曲韵组数据 *)
  let qu_rhyme_data =
    let ping_sheng_chars =
      [
        "曲"; "书"; "虚"; "如"; "居"; "渠"; "车"; "除"; "余"; "鱼";
        "初"; "无"; "吴"; "须"; "徐"; "胥"; "疏"; "图"; "途"; "都"
      ]
    in
    let ze_sheng_chars =
      [
        "去"; "取"; "住"; "数"; "度"; "路"; "故"; "顾"; "具"; "句";
        "处"; "据"; "遇"; "务"; "树"; "素"; "注"; "助"; "著"; "暑"
      ]
    in
    let ping_sheng_data = make_ping_sheng_group QuRhyme ping_sheng_chars in
    let ze_sheng_data = make_ze_sheng_group QuRhyme ze_sheng_chars in
    let tuples_data = ping_sheng_data @ ze_sheng_data in
    make_rhyme_group_data QuRhyme "曲韵组：曲、书、虚等韵字" tuples_data

  (** {2 第二组韵群 (6-10): 鱼、花、风、月、江韵组} *)

  (** 鱼韵组数据 *)
  let yu_rhyme_data =
    let ping_sheng_chars =
      [
        "鱼"; "余"; "居"; "初"; "渠"; "车"; "花"; "家";
        "华"; "加"; "嘉"; "茶"; "霞"; "沙"; "斜"; "牙"; "芽"; "瓜"
      ]
    in
    let ze_sheng_chars =
      [
        "语"; "举"; "女"; "雨"; "与"; "许"; "处"; "虑"; "数"; "度";
        "路"; "故"; "顾"; "具"; "句"; "据"; "遇"; "务"; "树"; "素"
      ]
    in
    let ping_sheng_data = make_ping_sheng_group YuRhyme ping_sheng_chars in
    let ze_sheng_data = make_ze_sheng_group YuRhyme ze_sheng_chars in
    let tuples_data = ping_sheng_data @ ze_sheng_data in
    make_rhyme_group_data YuRhyme "鱼韵组：鱼、书、余等韵字" tuples_data

  (** 花韵组数据 *)
  let hua_rhyme_data =
    let ping_sheng_chars =
      [
        "花"; "家"; "华"; "加"; "嘉"; "茶"; "霞"; "沙"; "斜"; "牙";
        "芽"; "瓜"; "麻"; "纱"; "娃"; "蛙"; "哇"; "奢"; "车"; "赊"
      ]
    in
    let ze_sheng_chars =
      [
        "化"; "话"; "画"; "价"; "架"; "假"; "下"; "夏"; "罢"; "马";
        "卦"; "挂"; "骂"; "巴"; "把"; "爸"; "打"; "达"; "答"; "塔"
      ]
    in
    let ping_sheng_data = make_ping_sheng_group HuaRhyme ping_sheng_chars in
    let ze_sheng_data = make_ze_sheng_group HuaRhyme ze_sheng_chars in
    let tuples_data = ping_sheng_data @ ze_sheng_data in
    make_rhyme_group_data HuaRhyme "花韵组：花、家、华等韵字" tuples_data

  (** 风韵组数据 *)
  let feng_rhyme_data =
    let ping_sheng_chars =
      [
        "风"; "东"; "中"; "空"; "同"; "通"; "红"; "公"; "功"; "工";
        "穷"; "终"; "冬"; "龙"; "虫"; "融"; "隆"; "松"; "钟"; "宫"
      ]
    in
    let ze_sheng_chars =
      [
        "动"; "用"; "重"; "众"; "种"; "痛"; "送"; "统"; "共"; "控";
        "总"; "聪"; "充"; "宋"; "诵"; "颂"; "涌"; "拥"; "容"; "纵"
      ]
    in
    let ping_sheng_data = make_ping_sheng_group FengRhyme ping_sheng_chars in
    let ze_sheng_data = make_ze_sheng_group FengRhyme ze_sheng_chars in
    let tuples_data = ping_sheng_data @ ze_sheng_data in
    make_rhyme_group_data FengRhyme "风韵组：风、东、中等韵字" tuples_data

  (** 月韵组数据 *)
  let yue_rhyme_data =
    let ping_sheng_chars =
      [
        "月"; "越"; "说"; "雪"; "节"; "切"; "热"; "别"; "铁"; "烈";
        "血"; "结"; "裂"; "折"; "缺"; "绝"; "决"; "穴"; "列"; "灭"
      ]
    in
    let ze_sheng_chars =
      [
        "阅"; "悦"; "劣"; "列"; "灭"; "绝"; "决"; "缺"; "雪"; "血";
        "热"; "铁"; "烈"; "别"; "切"; "节"; "折"; "裂"; "结"; "穴"
      ]
    in
    let ping_sheng_data = make_ping_sheng_group YueRhyme ping_sheng_chars in
    let ze_sheng_data = make_ze_sheng_group YueRhyme ze_sheng_chars in
    let tuples_data = ping_sheng_data @ ze_sheng_data in
    make_rhyme_group_data YueRhyme "月韵组：月、越、说等韵字" tuples_data

  (** 江韵组数据 *)
  let jiang_rhyme_data =
    let ping_sheng_chars =
      [
        "江"; "强"; "详"; "香"; "望"; "方"; "房"; "双"; "床";
        "霜"; "庄"; "黄"; "皇"; "光"; "堂"; "常"; "良"
      ]
    in
    let ze_sheng_chars =
      [
        "上"; "响"; "向"; "像"; "想"; "相"; "状"; "况"; "望"; "量";
        "样"; "养"; "忘"; "放"; "访"; "房"; "防"; "仿"; "妨"; "芳"
      ]
    in
    let ping_sheng_data = make_ping_sheng_group JiangRhyme ping_sheng_chars in
    let ze_sheng_data = make_ze_sheng_group JiangRhyme ze_sheng_chars in
    let tuples_data = ping_sheng_data @ ze_sheng_data in
    make_rhyme_group_data JiangRhyme "江韵组：江、长、强等韵字" tuples_data

  (** {2 第三组韵群 (11+): 会韵及其他韵组} *)

  (** 会韵组数据 *)
  let hui_rhyme_data =
    let ping_sheng_chars =
      [
        "会"; "回"; "来"; "开"; "台"; "才"; "材"; "白"; "百"; "排";
        "败"; "买"; "卖"; "海"; "害"; "爱"; "在"; "再"; "外"; "内"
      ]
    in
    let ze_sheng_chars =
      [
        "对"; "队"; "背"; "黑"; "北"; "倍"; "配"; "退"; "推"; "追";
        "催"; "灰"; "悔"; "累"; "类"; "泪"; "醉"; "罪"; "碎"; "岁"
      ]
    in
    let ping_sheng_data = make_ping_sheng_group HuiRhyme ping_sheng_chars in
    let ze_sheng_data = make_ze_sheng_group HuiRhyme ze_sheng_chars in
    let tuples_data = ping_sheng_data @ ze_sheng_data in
    make_rhyme_group_data HuiRhyme "会韵组：会、回、来等韵字" tuples_data

  (** {1 统一数据访问接口} *)

  (** 获取所有韵组数据 *)
  let get_all_rhyme_data () =
    [
      an_rhyme_data; si_rhyme_data; tian_rhyme_data; wang_rhyme_data; qu_rhyme_data;
      yu_rhyme_data; hua_rhyme_data; feng_rhyme_data; yue_rhyme_data; jiang_rhyme_data;
      hui_rhyme_data
    ]

  (** 按韵组获取数据 *)
  let get_rhyme_data_by_group = function
    | AnRhyme -> an_rhyme_data
    | SiRhyme -> si_rhyme_data  
    | TianRhyme -> tian_rhyme_data
    | WangRhyme -> wang_rhyme_data
    | QuRhyme -> qu_rhyme_data
    | YuRhyme -> yu_rhyme_data
    | HuaRhyme -> hua_rhyme_data
    | FengRhyme -> feng_rhyme_data
    | YueRhyme -> yue_rhyme_data
    | XueRhyme -> yue_rhyme_data  (* XueRhyme使用与YueRhyme相同的数据 *)
    | JiangRhyme -> jiang_rhyme_data
    | HuiRhyme -> hui_rhyme_data
    | UnknownRhyme -> { group_name = UnknownRhyme; group_description = "未知韵组"; entries = []; example_poems = [] }

  (** 获取韵组统计信息 *)
  let get_rhyme_stats () =
    let all_groups = get_all_rhyme_data () in
    let total_entries = List.fold_left (fun acc group -> acc + (List.length group.entries)) 0 all_groups in
    let ping_sheng_count = List.fold_left (fun acc group ->
      acc + (List.length (List.filter (fun entry -> entry.category = PingSheng) group.entries))
    ) 0 all_groups in
    let ze_sheng_count = total_entries - ping_sheng_count in
    (total_entries, ping_sheng_count, ze_sheng_count)

end

(** {1 向后兼容性接口} *)

(* 重新导出所有数据以保持向后兼容性 *)
let an_rhyme_data = Unified_rhyme_data.get_rhyme_data_by_group AnRhyme
let si_rhyme_data = Unified_rhyme_data.get_rhyme_data_by_group SiRhyme
let tian_rhyme_data = Unified_rhyme_data.get_rhyme_data_by_group TianRhyme
let wang_rhyme_data = Unified_rhyme_data.get_rhyme_data_by_group WangRhyme
let qu_rhyme_data = Unified_rhyme_data.get_rhyme_data_by_group QuRhyme
let yu_rhyme_data = Unified_rhyme_data.get_rhyme_data_by_group YuRhyme
let hua_rhyme_data = Unified_rhyme_data.get_rhyme_data_by_group HuaRhyme
let feng_rhyme_data = Unified_rhyme_data.get_rhyme_data_by_group FengRhyme
let yue_rhyme_data = Unified_rhyme_data.get_rhyme_data_by_group YueRhyme
let jiang_rhyme_data = Unified_rhyme_data.get_rhyme_data_by_group JiangRhyme
let hui_rhyme_data = Unified_rhyme_data.get_rhyme_data_by_group HuiRhyme

(* 统一访问函数 *)
let get_all_rhyme_data = Unified_rhyme_data.get_all_rhyme_data
let get_rhyme_data_by_group = Unified_rhyme_data.get_rhyme_data_by_group
let get_rhyme_stats = Unified_rhyme_data.get_rhyme_stats