(** 音韵工具模块 - 骆言诗词编程特性
    
    盖古之诗者，音韵为要。声韵调谐，方称佳构。
    此模块专司音韵分析辅助工具，提供字符处理等基础功能。
    凡诗词编程，必先备工具，后成大器。
    
    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-17
*)

(** {1 字符串转换函数} *)

(** 将UTF-8字符串转换为字符串列表
    
    @param s 输入的UTF-8字符串
    @return 字符串列表，每个元素为单个字符的字符串形式
    
    @example [utf8_to_char_list "诗韵"] 返回 [["诗"; "韵"]]
*)
val utf8_to_char_list : string -> string list

(** 将字符串转换为字符列表
    
    @param s 输入字符串
    @return 字符列表
    
    @example [string_to_char_list "abc"] 返回 [['a'; 'b'; 'c']]
*)
val string_to_char_list : string -> char list

(** 将字符列表转换为字符串
    
    @param chars 字符列表
    @return 组合后的字符串
    
    @example [char_list_to_string ['a'; 'b'; 'c']] 返回 ["abc"]
*)
val char_list_to_string : char list -> string

(** {1 字符获取函数} *)

(** 获取字符串的最后一个字符
    
    @param s 输入字符串
    @return 最后一个字符的选项值；空字符串返回None
    
    @example [get_last_char "诗韵"] 返回 [Some '韵']
    @example [get_last_char ""] 返回 [None]
*)
val get_last_char : string -> char option

(** 获取字符串的第一个字符
    
    @param s 输入字符串
    @return 第一个字符的选项值；空字符串返回None
    
    @example [get_first_char "诗韵"] 返回 [Some '诗']
    @example [get_first_char ""] 返回 [None]
*)
val get_first_char : string -> char option

(** {1 字符串处理函数} *)

(** 移除字符串中的空白字符
    
    去除字符串首尾的空格、制表符、换行符等空白字符。
    
    @param s 输入字符串
    @return 去除空白字符后的字符串
    
    @example [trim_whitespace "  诗韵  "] 返回 ["诗韵"]
*)
val trim_whitespace : string -> string

(** 判断字符是否为中文字符
    
    使用Unicode编码范围判断字符是否为中文字符。
    
    @param c 待判断的字符
    @return 是中文字符返回true，否则返回false
    
    @example [is_chinese_char '诗'] 返回 [true]
    @example [is_chinese_char 'a'] 返回 [false]
*)
val is_chinese_char : char -> bool

(** 过滤出字符串中的中文字符
    
    @param s 输入字符串
    @return 仅包含中文字符的字符串
    
    @example [filter_chinese_chars "诗韵abc"] 返回 ["诗韵"]
*)
val filter_chinese_chars : string -> string

(** 计算字符串中中文字符的长度
    
    @param s 输入字符串
    @return 中文字符的数量
    
    @example [chinese_length "诗韵abc"] 返回 [2]
*)
val chinese_length : string -> int

(** {1 诗句处理函数} *)

(** 分割文本为诗句行
    
    按换行符分割文本，并去除空白行。
    
    @param text 输入的多行文本
    @return 诗句行列表
    
    @example [split_verse_lines "诗韵\\n格律\\n"] 返回 [["诗韵"; "格律"]]
*)
val split_verse_lines : string -> string list

(** 规范化诗句格式
    
    去除空白字符并只保留中文字符。
    
    @param verse 输入诗句
    @return 规范化后的诗句
    
    @example [normalize_verse "  诗韵abc  "] 返回 ["诗韵"]
*)
val normalize_verse : string -> string

(** 判断两个字符串是否相等（忽略空白）
    
    @param s1 第一个字符串
    @param s2 第二个字符串
    @return 忽略空白后相等返回true，否则返回false
*)
val equal_ignoring_whitespace : string -> string -> bool

(** 检查字符串是否为空或仅包含空白字符
    
    @param s 输入字符串
    @return 为空或仅包含空白返回true，否则返回false
*)
val is_empty_or_whitespace : string -> bool

(** {1 列表处理函数} *)

(** 安全获取列表指定位置的元素
    
    @param list 输入列表
    @param n 索引位置（从0开始）
    @return 元素的选项值；超出范围返回None
*)
val safe_nth : 'a list -> int -> 'a option

(** 安全获取列表头部元素
    
    @param list 输入列表
    @return 头部元素的选项值；空列表返回None
*)
val safe_head : 'a list -> 'a option

(** 安全获取列表尾部
    
    @param list 输入列表
    @return 尾部列表的选项值；空列表返回None
*)
val safe_tail : 'a list -> 'a list option

(** 列表去重
    
    @param list 输入列表
    @return 去重后的列表
*)
val unique_list : 'a list -> 'a list

(** 计算两个列表的交集
    
    @param list1 第一个列表
    @param list2 第二个列表
    @return 交集列表
*)
val intersect : 'a list -> 'a list -> 'a list

(** 计算两个列表的并集
    
    @param list1 第一个列表
    @param list2 第二个列表
    @return 并集列表（已去重）
*)
val union : 'a list -> 'a list -> 'a list

(** 映射并过滤None值
    
    @param f 映射函数，返回选项值
    @param list 输入列表
    @return 过滤后的结果列表
*)
val filter_map : ('a -> 'b option) -> 'a list -> 'b list

(** {1 格式化函数} *)

(** 格式化列表为字符串
    
    @param to_string 元素转字符串函数
    @param separator 分隔符
    @param list 输入列表
    @return 格式化后的字符串
*)
val format_list : ('a -> string) -> string -> 'a list -> string

(** 创建带编号的列表
    
    @param list 输入列表
    @return 带编号的(索引, 元素)列表
    
    @example [enumerate ["a"; "b"]] 返回 [[(0, "a"); (1, "b")]]
*)
val enumerate : 'a list -> (int * 'a) list