(** 韵律类型定义模块 - 骆言诗词编程特性
    
    此模块定义了韵律数据的基础类型和辅助函数，为各韵组模块提供统一的类型基础。
    依《平水韵》、《中华新韵》等韵书传统，建立完整的韵类和韵组体系。
    
    @author 骆言诗词编程团队  
    @version 1.0
    @since 2025-07-19 - Phase 14.2 模块化重构 *)

(** {1 韵类定义} *)

(** 韵类：按声调分类的基本韵律类别 *)
type rhyme_category =
  | PingSheng (* 平声韵 - 音调平和，韵味悠长 *)
  | ZeSheng (* 仄声韵 - 音调起伏，韵律跌宕 *)
  | ShangSheng (* 上声韵 - 音调上扬，韵感清雅 *)
  | QuSheng (* 去声韵 - 音调下降，韵律沉稳 *)
  | RuSheng (* 入声韵 - 音调急促，韵味刚劲 *)

(** {1 韵组定义} *)

(** 韵组：按韵母分类的具体韵律组别 *)
type rhyme_group =
  | AnRhyme (* 安韵组 - 安然自若，韵味平和 *)
  | SiRhyme (* 思韵组 - 深思熟虑，韵致深远 *)
  | TianRhyme (* 天韵组 - 天高云淡，韵律高远 *)
  | WangRhyme (* 望韵组 - 望眼欲穿，韵情悠长 *)
  | QuRhyme (* 去韵组 - 去留无意，韵味淡泊 *)
  | YuRhyme (* 鱼韵组 - 鱼游春水，韵趣盎然 *)
  | HuaRhyme (* 花韵组 - 花开花落，韵华天成 *)
  | FengRhyme (* 风韵组 - 风流韵事，韵致飘逸 *)
  | YueRhyme (* 月韵组 - 月圆月缺，韵律圆融 *)
  | XueRhyme (* 雪韵组 - 雪花飞舞，韵味清冽 *)
  | JiangRhyme (* 江韵组 - 大江东去，韵流不息 *)
  | HuiRhyme (* 灰韵组 - 灰飞烟灭，韵意苍茫 *)
  | UnknownRhyme (* 未知韵组 - 待考证分类 *)

(** {1 韵律数据辅助工具} *)

(** 创建韵律数据项的辅助函数
    
    将字符列表转换为包含韵类和韵组信息的完整韵律数据项。
    这是构建韵律数据库的基础函数，确保数据格式的一致性。
    
    @param chars 字符列表
    @param category 韵类
    @param group 韵组
    @return 韵律数据项列表 *)
let create_rhyme_data chars category group = 
  List.map (fun char -> (char, category, group)) chars

(** {1 韵类相关函数} *)

(** 获取韵类的字符串表示 *)
let string_of_rhyme_category = function
  | PingSheng -> "平声"
  | ZeSheng -> "仄声"
  | ShangSheng -> "上声"
  | QuSheng -> "去声"
  | RuSheng -> "入声"

(** 获取韵组的字符串表示 *)
let string_of_rhyme_group = function
  | AnRhyme -> "安韵"
  | SiRhyme -> "思韵"
  | TianRhyme -> "天韵"
  | WangRhyme -> "望韵"
  | QuRhyme -> "去韵"
  | YuRhyme -> "鱼韵"
  | HuaRhyme -> "花韵"
  | FengRhyme -> "风韵"
  | YueRhyme -> "月韵"
  | XueRhyme -> "雪韵"
  | JiangRhyme -> "江韵"
  | HuiRhyme -> "灰韵"
  | UnknownRhyme -> "未知韵"

(** 判断是否为平声韵 *)
let is_ping_sheng = function
  | PingSheng -> true
  | _ -> false

(** 判断是否为仄声韵 *)
let is_ze_sheng = function
  | ZeSheng | ShangSheng | QuSheng | RuSheng -> true
  | _ -> false