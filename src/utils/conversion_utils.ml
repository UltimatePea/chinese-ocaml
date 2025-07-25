(** 通用转换工具模块 - 消除关键字转换中的重复模式 *)

(** 通用映射表转换器 *)
let convert_with_mapping mapping _pos variant =
  try Ok (List.assoc variant mapping) with Not_found -> Error "未知关键字"

(** 批量关键字转换器生成器 *)
let create_keyword_converter mapping error_message =
 fun _pos variant -> try Ok (List.assoc variant mapping) with Not_found -> Error error_message

(** 合并多个映射表 *)
let merge_mappings mappings = List.fold_left ( @ ) [] mappings

(** 条件转换器 - 根据条件选择不同的转换策略 *)
let conditional_converter condition converter1 converter2 =
 fun pos variant -> if condition variant then converter1 pos variant else converter2 pos variant

(** 带回退的转换器 *)
let converter_with_fallback primary_converter fallback_converter =
 fun pos variant ->
  match primary_converter pos variant with
  | Ok result -> Ok result
  | Error _ -> fallback_converter pos variant

(** 验证转换结果 *)
let validate_conversion_result validator result =
  match result with
  | Ok value when validator value -> Ok value
  | Ok _ -> Error "转换结果验证失败"
  | Error msg -> Error msg

(** 批量转换 *)
let convert_batch converter pos_variant_pairs =
  let rec convert_all acc = function
    | [] -> Ok (List.rev acc)
    | (pos, variant) :: rest -> (
        match converter pos variant with
        | Ok result -> convert_all (result :: acc) rest
        | Error msg -> Error msg)
  in
  convert_all [] pos_variant_pairs

(** 转换器组合 *)
let compose_converters c1 c2 =
 fun pos variant ->
  match c1 pos variant with Ok intermediate -> c2 pos intermediate | Error msg -> Error msg

(** 简化的映射转换器 - 最常见的使用模式 *)
let simple_mapping_converter mapping error_message = create_keyword_converter mapping error_message

type conversion_stats = {
  total_conversions : int;
  successful_conversions : int;
  failed_conversions : int;
}
(** 转换统计信息 *)

let empty_stats = { total_conversions = 0; successful_conversions = 0; failed_conversions = 0 }

let update_stats stats result =
  let total = stats.total_conversions + 1 in
  match result with
  | Ok _ ->
      {
        total_conversions = total;
        successful_conversions = stats.successful_conversions + 1;
        failed_conversions = stats.failed_conversions;
      }
  | Error _ ->
      {
        total_conversions = total;
        successful_conversions = stats.successful_conversions;
        failed_conversions = stats.failed_conversions + 1;
      }

(** 带统计的转换器包装器 *)
let converter_with_stats converter stats_ref =
 fun pos variant ->
  let result = converter pos variant in
  stats_ref := update_stats !stats_ref result;
  result
