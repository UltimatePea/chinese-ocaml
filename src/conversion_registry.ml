(** Token转换器注册和调度模块
 *
 *  从token_conversion_core.ml重构而来，提供统一的Token转换调度服务
 *  
 *  @author 骆言技术债务清理团队 Issue #1276, #1278
 *  @version 2.1 - 修复 Issue #1278: 动态统计、优化异常处理、改进错误信息
 *  @since 2025-07-25 *)

(** 聚合所有转换器的异常 *)
exception Token_conversion_failed of string

(** 统一的Token转换接口 - 优化的转换流程 *)
let convert_token token =
  let try_converter converter =
    try Some (converter token)
    with _ -> None
  in
  (* 按照优先级顺序尝试转换，避免深度嵌套异常 *)
  match try_converter Identifier_converter.convert_identifier_token with
  | Some result -> Some result
  | None -> 
    (match try_converter Literal_converter.convert_literal_token with
     | Some result -> Some result
     | None ->
       (match try_converter Keyword_converter.convert_basic_keyword_token with
        | Some result -> Some result
        | None ->
          (match try_converter Keyword_converter.convert_type_keyword_token with
           | Some result -> Some result
           | None -> try_converter Classical_converter.convert_classical_token)))

(** 批量转换Token列表 - 改进的错误信息 *)
let convert_token_list tokens =
  List.map (fun token ->
    match convert_token token with
    | Some converted -> converted
    | None -> 
        let token_type = Obj.tag (Obj.repr token) |> string_of_int in
        let error_msg = Printf.sprintf "无法转换token: 类型标签=%s, 请检查token是否为支持的类型" token_type in
        raise (Token_conversion_failed error_msg)
  ) tokens

(** 动态转换统计信息 - 从各模块获取实际规则数量 *)
let get_conversion_stats () =
  let identifiers_count = Identifier_converter.get_rule_count () in
  let literals_count = Literal_converter.get_rule_count () in  
  let basic_keywords_count = Keyword_converter.get_basic_keyword_rule_count () in
  let type_keywords_count = Keyword_converter.get_type_keyword_rule_count () in
  let classical_count = Classical_converter.get_rule_count () in
  let total_count = identifiers_count + literals_count + basic_keywords_count + type_keywords_count + classical_count in
  Printf.sprintf "Token转换模块化统计: 标识符(%d) + 字面量(%d) + 基础关键字(%d) + 类型关键字(%d) + 古典语言(%d) = 总计(%d)个转换规则"
    identifiers_count literals_count basic_keywords_count type_keywords_count classical_count total_count