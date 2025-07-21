(** 声调数据存储模块 - 模块化重构

    提供所有声调数据的统一访问接口，通过子模块提供数据访问。 已将原本的大型数据列表拆分为独立的声调类型模块。

    @author 骆言诗词编程团队
    @version 2.0 - 模块化重构
    @since 2025-07-20 *)

(** 平声字符数据列表 - 来自 ping_sheng_data 模块 *)
let ping_sheng_list = Poetry_tone_data.Ping_sheng_data.ping_sheng_chars

(** 上声字符数据列表 - 来自 shang_sheng_data 模块 *)
let shang_sheng_list = Poetry_tone_data.Shang_sheng_data.shang_sheng_chars

(** 去声字符数据列表 - 来自 qu_sheng_data 模块 *)
let qu_sheng_list = Poetry_tone_data.Qu_sheng_data.qu_sheng_chars

(** 入声字符数据列表 - 来自 ru_sheng_data 模块 *)
let ru_sheng_list = Poetry_tone_data.Ru_sheng_data.ru_sheng_chars
