(** 去声字符数据模块

    包含所有去声声调的汉字字符数据，从原tone_data_storage.ml提取。 去声是诗词韵律中的重要声调之一。

    @author 骆言诗词编程团队
    @version 1.0 - 模块化重构
    @since 2025-07-20 *)

(** {1 去声字符数据分组定义} *)

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
