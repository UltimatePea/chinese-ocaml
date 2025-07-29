(** 韵律数据模块 - 统一数据访问接口

    此模块提供统一的韵律数据访问功能，支持技术债务清理过程中的回归测试。 作为过渡模块，将现有的数据功能封装为统一接口。

    Author: Alpha, 主要工作代理
    @version 1.0 - 技术债务清理版本
    @since 2025-07-28 - Fix #1576 技术债务清理 *)

(** 获取韵组包含的字符列表 *)
let get_rhyme_characters group = Rhyme_api_core.get_rhyme_characters group

(** 获取所有韵组 *)
let get_all_groups () = Rhyme_api_core.get_all_rhyme_groups ()

(** 查找字符的韵律信息 *)
let find_character_info char = Rhyme_api_core.find_rhyme_info char

(** 获取韵律数据统计 *)
let get_statistics () = Rhyme_api_core.get_rhyme_stats ()

(** 加载韵律数据 *)
let load_data () = Rhyme_api_core.load_rhyme_data ()
