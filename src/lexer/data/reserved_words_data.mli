(** 骆言保留词数据模块接口

    保留词是优先于关键字处理的特殊词汇， 用于避免复合词被错误分割。

    @since Phase8 技术债务重构 *)

val reserved_words_list : string list
(** 保留词列表

    这些词汇在词法分析时优先处理， 避免被错误地分解为多个token。

    @return 保留词字符串列表 *)
