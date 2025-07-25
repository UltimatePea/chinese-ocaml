(** 通用转换工具模块接口 - 消除关键字转换中的重复模式 *)

val convert_with_mapping : ('a * 'b) list -> 'c -> 'a -> ('b, string) result
(** 通用映射表转换器 *)

val create_keyword_converter : ('a * 'b) list -> string -> 'c -> 'a -> ('b, string) result
(** 批量关键字转换器生成器 *)

val merge_mappings : ('a * 'b) list list -> ('a * 'b) list
(** 合并多个映射表 *)

val conditional_converter :
  ('a -> bool) ->
  ('b -> 'a -> ('c, string) result) ->
  ('b -> 'a -> ('c, string) result) ->
  'b ->
  'a ->
  ('c, string) result
(** 条件转换器 - 根据条件选择不同的转换策略 *)

val converter_with_fallback :
  ('a -> 'b -> ('c, string) result) ->
  ('a -> 'b -> ('c, string) result) ->
  'a ->
  'b ->
  ('c, string) result
(** 带回退的转换器 *)

val validate_conversion_result : ('a -> bool) -> ('a, string) result -> ('a, string) result
(** 验证转换结果 *)

val convert_batch : ('a -> 'b -> ('c, string) result) -> ('a * 'b) list -> ('c list, string) result
(** 批量转换 *)

val compose_converters :
  ('a -> 'b -> ('c, string) result) ->
  ('a -> 'c -> ('d, string) result) ->
  'a ->
  'b ->
  ('d, string) result
(** 转换器组合 *)

val simple_mapping_converter : ('a * 'b) list -> string -> 'c -> 'a -> ('b, string) result
(** 简化的映射转换器 - 最常见的使用模式 *)

type conversion_stats = {
  total_conversions : int;
  successful_conversions : int;
  failed_conversions : int;
}
(** 转换统计信息 *)

val empty_stats : conversion_stats
val update_stats : conversion_stats -> ('a, 'b) result -> conversion_stats

val converter_with_stats :
  ('a -> 'b -> ('c, string) result) -> conversion_stats ref -> 'a -> 'b -> ('c, string) result
(** 带统计的转换器包装器 *)
